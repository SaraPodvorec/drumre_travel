import City from "../models/city.js";
import { fetchCityGeoapify } from "../services/geoapify.js";
import { fetchCityImage } from "../services/unsplash.js";
import { fetchCityWeather } from "../services/openWeather.js";

export async function getAllCities(req, res) {
  const cities = await City.find();
  res.json(cities);
 //console.log("Top cities:", cities);
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
      };

      const newCity = new City(cityData);
      await newCity.save();
      console.log(`City ${geoapify.city} saved successfully`);
      return newCity;
    } catch (error) {
      console.error(`Error fetching city ${cityName}:`, error.message);
      console.error(`Full error:`, error);
      throw new Error(`Failed to fetch city data: ${error.message}`);
    }
  } else {
    console.log(`City ${cityName} found in database.`);
    return city;
  }
}

//Funkcija filtrira po drzavi (country_code), temperaturi i ratingu
//Korisnim moze odabrati jedanu ili više opcija za filtriranje npr svi gradovi iz HR, sortirani po temperaturi ili avgImpression 
export const cityFilters = async (req, res) => {
  try {
    const {
      country,
      continent,
      sort,   
      order = "asc",
      //limit = 20
    } = req.query; //Trenutno je napravljeno da se parametri salju kao query parametri npr. /cities/filters?country=US&sort=temperature&order=desc

    const filter = {};

    if (country) {
      filter.country_code = country;
    }

    if (continent) {
      filter.continent = continent;

    }

    const sortOptions = {};
    if (sort) {
      const sortFields = sort.split(",");       // npr. ['avgImpression', 'popularity', 'temperature'] -> redosljed je bitan zbog prioritera (najveci ima avgImpression)
      const sortOrders = (order || "").split(","); // npr. ['desc','asc']

      sortFields.forEach((field, i) => {
        const dir = sortOrders[i] === "desc" ? -1 : 1; 
        sortOptions[field] = dir;
      });
    }

    if (!sort && (country || continent)) {
      sortOptions.city = order === "desc" ? -1 : 1;
    }
    const cities = await City.find(filter)
      .sort(sortOptions);
      //.limit(Number(limit));

    res.json({ cities });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};