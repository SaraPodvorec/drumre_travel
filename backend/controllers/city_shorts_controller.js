// controllers/city_shorts_controller.js
import CityShortVideo from "../models/city_short_video.js";
import { fetchCityShorts } from "../services/serpapi.js";

export async function populateCityShortsOnce(city) {
  const existing = await CityShortVideo.countDocuments({
    cityId: city._id
  });

  if (existing > 0) {
    console.log(`Shorts already exist for ${city.city}`);
    return;
  }

  console.log(`Fetching shorts for ${city.city}...`);

  const shorts = await fetchCityShorts(city.city);

  if (!shorts.length) {
    console.log(`No shorts found for ${city.city}`);
    return;
  }

  await CityShortVideo.insertMany(
    shorts.map(s => ({
      ...s,
      cityId: city._id,
    })),
    { ordered: false }
  );

  console.log(`Saved ${shorts.length} shorts for ${city.city}`);
}


export async function getTopShortVideosByCity(req, res) {
  try {
    const { cityId } = req.query;

    if (!cityId) {
      return res.status(400).json({ error: "cityId is required" });
    }

    const videos = await CityShortVideo
      .find({ cityId })
      .sort({ lastFetched: -1 });

    return res.json(videos);
  } catch (error) {
    console.error("Failed to get short videos:", error);
    return res.status(500).json({ error: "Failed to fetch short videos" });
  }
}
