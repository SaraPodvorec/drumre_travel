import CityActivity from "../models/city_activity.js";
import { fetchActivities } from "../services/amadeus.js";


export async function getActivitiesByCityId(cityId) {
  const activities = await CityActivity.find({ cityId });
  // console.log(`Activities for cityId ${cityId}:`, activities);
  return activities;
};

export async function saveCityActivities(cityId, lat, lon) {

  const fresh = await fetchActivities(lat, lon);
  
  for (const a of fresh) {
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
}

export async function getCityActivities(req, res) {
  const { cityId, lat, lon } = req.query;

  const existing = await CityActivity.find({ cityId });

  const oneWeek = 1000 * 60 * 60 * 24 * 7;

  if(existing.length > 0 && Date.now() - existing[0].lastFetched < oneWeek) {
    console.log("Returning cached activities");
    return res.json(existing);
  }

  const fresh = await fetchActivities(lat, lon);

  for (const a of fresh) {
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
  };

  const updated = await CityActivity.find({ cityId });
  res.json(updated);
  console.log("Activities data:", updated);
}

