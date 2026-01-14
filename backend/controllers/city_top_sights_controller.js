import CityTopSight from "../models/city_top_sight.js";
import City from "../models/city.js";
import { fetchCityTopSights } from "../services/serpapi.js";

export async function updateMissingCitySights() {
  console.log("Checking for cities missing top sights...");

  try {
    const citiesWithSights = await CityTopSight.distinct("cityId");

    const citiesToUpdate = await City.find({
      _id: { $nin: citiesWithSights }
    });

    console.log(`Found ${citiesToUpdate.length} cities missing sights.`);

    if (citiesToUpdate.length === 0) {
      console.log("All cities have associated sights.");
      return;
    }

    for (const city of citiesToUpdate) {
      try {
        console.log(`Fetching sights for: ${city.city}...`);
        
        const sights = await fetchCityTopSights(city.city);

        if (sights && sights.length > 0) {
          const sightDocs = sights.map(sight => ({
            ...sight,
            cityId: city._id,
            lastFetched: Date.now()
          }));

          await CityTopSight.insertMany(sightDocs);
          console.log(`Successfully added ${sights.length} sights for ${city.city}`);
        } else {
          console.warn(`No sights found for ${city.city}`);
        }

      } catch (error) {
        console.error(`Failed to fetch sights for ${city.city}:`, error.message);
      }
    }

    console.log("Batch update for city sights completed.");
  } catch (error) {
    console.error("Critical error during sights update:", error);
  }
}

export async function getTopSightsByCityId(req, res) {
  const { cityId } = req.query;
  const topSights = await CityTopSight.find({ cityId });
  console.log(`Top sights for cityId ${cityId}:`, topSights);
  return res.json(topSights);
};

export async function saveCityTopSights(cityId, cityName) {

  const topSights = await fetchCityTopSights(cityName);
  
  for (const topSight of topSights) {
    await CityTopSight.findOneAndUpdate(
      {
        cityId: cityId,
        name: topSight.name,
        description: topSight.description,
        link: topSight.link,
        image: topSight.image,
        lastFetched: new Date()
      },
      { upsert: true }
    );
  }
}
