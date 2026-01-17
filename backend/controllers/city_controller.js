import City from "../models/city.js";
import CityTopSight from "../models/city_top_sight.js";
import CityShort from "../models/city_short_video.js";
import { fetchCityGeoapify } from "../services/geoapify.js";
import { fetchCityImage } from "../services/unsplash.js";
import { fetchCityWeather } from "../services/openweather.js";
import { fetchCityDescription, fetchCityShorts } from "../services/serpapi.js";
import { updateMissingCitySights, saveCityTopSights } from "./city_top_sights_controller.js";
import { getCountryData } from "../services/rest_countries.js";


export async function updateMissingDescriptions() {
  console.log("Starting batch update for cities missing descriptions...");

  try {
    const citiesToUpdate = await City.find({
      $or: [
        { description: { $exists: false } },
        { description: null },
        { description: "" }
      ]
    });

    console.log(`Found ${citiesToUpdate.length} cities to update.`);

    if (citiesToUpdate.length === 0) {
      console.log("All cities already have descriptions.");
      return;
    }

    for (const city of citiesToUpdate) {
      try {
        console.log(`Updating description for: ${city.city}...`);
        
        const description = await fetchCityDescription(city.city, city.country);

        if (description) {
          city.description = description;
          await city.save();
          console.log(`Successfully updated ${city.city}`);
        } else {
          console.warn(`No description returned for ${city.city}`);
        }

      } catch (error) {
        console.error(`Failed to update ${city.city}:`, error.message);
      }
    }

    console.log("Batch update completed.");
  } catch (error) {
    console.error("Critical error during batch update:", error);
  }
}

export async function getAllCities(req, res) {
  // updateMissingDescriptions();
  let cities = await City.find();
  
  cities = await Promise.all(
    cities.map(async (city) => {
      if (!city.currency || !city.language) {
        const countryData = await getCountryData(city.country);
        if (countryData) {
          city.currency = countryData.currency;
          city.language = countryData.language;
          console.log(`Updated country data for ${city.city}: ${city.currency}, ${city.language}`);
          //city.population = countryData.population;
          await city.save();
        }
      }
      return city;
    })
  );
  
  res.json(cities);
}

export async function getCityLonLat(cityName) {
  const city = await City.findOne({ city: cityName });

  if (!city) {
    throw new Error("City not found");
  }

  console.log(`City ${cityName} found: lat=${city.lat}, lon=${city.lon}`);

  return { lat: city.lat, lon: city.lon };
}

export async function saveCity(cityData) {
  const existing = await City.findOne({ city: cityData.city });

  if (existing) {
    console.log(`City ${cityData.city} already exists in the database.`);
    return existing;
  }

  const city = new City(cityData);
  await city.save();

  console.log(`City ${cityData.city} saved to the database.`);
  return city;
}

export async function getCityData(cityName) {
  
  console.log(`Getting data for: ${cityName}`);
  
  const city = await City.findOne({ city: new RegExp(`^${cityName}$`, 'i') });

  if (!city) {
    console.log(`City ${cityName} not found in database. Fetching data...`);

    try {
      //console.log(`Fetching Geoapify data for ${cityName}...`);
      const geoapify = await fetchCityGeoapify(cityName);
      //console.log(`Geoapify success for ${cityName}:`, geoapify);
      
      //console.log(`Fetching Unsplash data for ${cityName}...`);
      const unsplash = await fetchCityImage(cityName);
      //console.log(`Unsplash success for ${cityName}:`, unsplash);

      //console.log(`Fetching OpenWeather data for ${cityName}...`);
      const openweather = await fetchCityWeather(geoapify.lat, geoapify.lon);
      // console.log(`OpenWeather success for ${cityName}:`, openweather);

      //console.log(`Fetching SerpAPI data for ${cityName}...`);
      const serpapiDescription = await fetchCityDescription(cityName)
      // console.log(`SerpAPI success for ${cityName}:`, openweather);

      // check again before saving in case another request saved it simultaneously
      const existingCity = await City.findOne({ 
        city: new RegExp(`^${geoapify.city}$`, 'i') 
      });
      
      if (existingCity) {
        console.log(`City ${geoapify.city} was already saved by another request.`);
        return existingCity;
      }

      const cityData = {
        city: geoapify.city,
        country: geoapify.country,
        lat: geoapify.lat,
        lon: geoapify.lon,
        popularity: geoapify.popularity,
        state: geoapify.state,
        timezone: geoapify.timezone,
        formatted: geoapify.formatted,
        country_code: geoapify.country_code,
        continent: geoapify.continent,
        temperature: openweather.temperature,
        imageUrl: unsplash.imageUrl,
        imageAuthor: unsplash.imageAuthor,
        imageAuthorLink: unsplash.imageAuthorLink,
        imageDescription: unsplash.imageDescription,
        imageAltDescription: unsplash.imageAltDescription,
        description: serpapiDescription
      };

      const newCity = new City(cityData);
      const savedCity = await newCity.save();

      console.log(`City ${geoapify.city} saved successfully`);
      return newCity;
    } catch (error) {
      console.error(`Error fetching city ${cityName}:`, error.message);
      console.error(`Full error:`, error);
      throw new Error(`Failed to fetch city data: ${error.message}`);
    }
  } else if (!city.description) {
    console.log(`City ${cityName} found, but description is missing. Updating...`);
    try {
      const description = await fetchCityDescription(city.city, city.country);
      
      city.description = description;
      await city.save();
      
      console.log(`Updated description for ${city.city}`);
      return city;
    } catch (error) {
      console.error(`Failed to update description for ${cityName}:`, error);
      return city; 
    }
  } else {
    console.log(`City ${cityName} found in database.`);
    return city;
  }
}

export const cityFilters = async (req, res) => {
  const cityFields = [ 'city', 'temperature', 'popularity' ];
  try {
    const {
      country,
      continent,
      sort,   
      order,
      //limit = 20
    } = req.query; 

    const filter = {};

    if (country) {
      filter.country= country;
    }

    if (continent) {
      filter.continent = continent;

    }
    let pipeline = [ { $match: filter } ];
    console.log("Sort field:", sort);
    if(cityFields.includes(sort)) {
      pipeline.push({
        $sort: {
          [sort]: order === "asc" ? 1 : -1
        }
      });
    }
    else {
      pipeline.push({
        $lookup: {
          from: "cityreviews",
          localField: "_id",
          foreignField: "cityId",
          as: "reviews"
        }
      },
      {
        $addFields: {
          avgSortField: { $avg: `$reviews.${sort}`}
        }
      },
      { $sort: { avgSortField: order === "asc" ? 1 : -1 } }
      );
    }

    const cities =  await City.aggregate(pipeline);

    res.json({ cities });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};