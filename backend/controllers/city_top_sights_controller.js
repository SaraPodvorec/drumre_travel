import CityTopSight from "../models/city_top_sight.js";
import { fetchCityTopSights } from "../services/serpapi.js";

export async function getTopSightsByCityId(cityId) {
  const topSights = await CityTopSight.find({ cityId });
  console.log(`Top sights for cityId ${cityId}:`, topSights);
  return topSights;
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
