import dotenv from "dotenv";
dotenv.config();
import connectDB from "./config/db.js";
import City from "./models/city.js";
import { populateCityShortsOnce } from "./controllers/city_shorts_controller.js";

//ovo pokrećem za puniti bazu s videima - node script.js
await connectDB();

async function run() {
    console.log("SERPAPI_KEY loaded:", !!process.env.SERPAPI_KEY);

  const cities = await City.find();

  console.log(`Found ${cities.length} cities`);

  for (const city of cities) {
    try {
      await populateCityShortsOnce(city);
    } catch (err) {
      console.error(`Failed for ${city.city}`, err.message);
    }
  }

  console.log("Finished populating city shorts");
  process.exit(0);
}

run();
