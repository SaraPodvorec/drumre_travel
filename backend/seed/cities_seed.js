import dotenv from "dotenv";
dotenv.config();

import connectDB from "../config/db.js";
import City from "../models/city.js";

import { fetchCityGeoapify } from "../services/geoapify.js";
import { fetchCityImage } from "../services/unsplash.js";
import { fetchCityWeather } from "../services/openWeather.js";

await connectDB();

console.log("Seeding cities...");

const TOP_CITIES = [
  "London",
  "Paris",
  "New York",
  "Tokyo",
  "Dubai",
  "Singapore",
  "Barcelona",
  "Rome",
  "Bangkok",
  "Sydney",
];


async function seed() {
  for (let i = 0; i < TOP_CITIES.length; i++) {
    const cityName = TOP_CITIES[i];

    try {
      console.log(`Fetching ${cityName}...`);

      const geoapify = await fetchCityGeoapify(cityName);
      const unsplash = await fetchCityImage(cityName);
      const openweather = await fetchCityWeather(geoapify.lat, geoapify.lon);

      await City.findOneAndUpdate(
        { city: geoapify.city },
        {
          city: geoapify.city,
          country: geoapify.country,
          lat: geoapify.lat,
          lon: geoapify.lon,
          popularity: geoapify.popularity,
          state: geoapify.state,
          timezone: geoapify.timezone,
          formatted: geoapify.formatted,
          country_code: geoapify.country_code,
          temperature: openweather.temperature,
          imageUrl: unsplash.imageUrl,
          imageAuthor: unsplash.imageAuthor,
          imageAuthorLink: unsplash.imageAuthorLink,
          imageDescription: unsplash.imageDescription,
          imageAltDescription: unsplash.imageAltDescription,
        },
        { upsert: true }
      );

      console.log(`${cityName} saved`);
    } catch (err) {
      console.log(`Error for ${cityName}:`, err.message);
    }
  }

  console.log("Seeding complete.");
  process.exit();
}

seed();