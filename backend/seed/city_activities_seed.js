import dotenv from "dotenv";
dotenv.config();

import connectDB from "../config/db.js";
import City from "../models/city.js";
import CityActivity from "../models/city_activity.js";

import { fetchActivities } from "../services/amadeus.js";

await connectDB();
console.log("Seeding city activities...");

const cities = await City.find();

async function seed() {
    for (let i = 0; i < cities.length; i++) {
        const cityId = cities[i]._id;

        try {
            console.log(`Fetching activities for ${cities[i].city}...`);
            const activities = await fetchActivities(cities[i].lat, cities[i].lon);

            for (const a of activities) {
                console.log(`Saving activity ${a.name}...`);
                await CityActivity.findOneAndUpdate(
                    { amadeusId: a.amadeusId },
                    {
                      amadeusId: a.amadeusId,
                      cityId: cityId,
                        name: a.name,
                        description: a.description,
                        price: a.price,
                        images: a.images,
                        bookingLink: a.bookingLink,
                        minimumDuration: a.minimumDuration,
                        lastFetched: new Date()
                    },
                    { upsert: true }
                );

            }
        } catch (err) {
            console.error(`Error fetching activities for ${cities[i].city}:`, err);
        }
    }
    console.log("City activities seeding completed.");
    process.exit();
}

seed();