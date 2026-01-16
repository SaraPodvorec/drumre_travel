import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import auth from './routes/auth.js';
import cities from './routes/cities.js';
import activities from './routes/tours_and_activities.js';
import topSights from './routes/top_sights.js';
import review from './routes/review.js';
import connectDB from './config/db.js';
import user from './routes/user.js';
import cityShorts from './routes/city_shorts.js';
import { fetchCityWeatherByName } from './services/openweather.js';


dotenv.config();
await connectDB();

const app = express();
const PORT = process.env.PORT;
const FRONTEND_URL = process.env.FRONTEND_URL || 'http://localhost:4000';


app.use(cors({ 
  origin: FRONTEND_URL,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type']
}));
app.use(express.json());
app.use(cookieParser());

app.use("/api/auth", auth);
app.use("/api/cities", cities);
app.use("/api/activities", activities);
app.use("/api/topSights", topSights);
app.use("/api/user", user);
app.use("/api/review", review);
app.use("/api/cityShorts", cityShorts);

app.get("/api/proxy-image", async (req, res) => {
  const imageUrl = req.query.url;
  if (!imageUrl) {
    return res.status(400).json({ error: "URL required" });
  }
  try {
    const response = await fetch(imageUrl);
    const buffer = await response.arrayBuffer();
    res.set('Content-Type', response.headers.get('content-type'));
    res.send(Buffer.from(buffer));
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch image" });
  }
});
app.get("/api/weather/:cityName", async (req, res) => {
  const { cityName } = req.params;
  const weather = await fetchCityWeatherByName(cityName);
  if (!weather) return res.status(404).json({ error: "City not found" });
  res.json(weather);
});

// app.get("/", async (req, res) => {
//   await getAllCities(req, res);
//   const cityData = await getCityData("Berlin");
//   const cityId = cityData._id;
//   const activities = await getActivitiesByCityId(cityId);
//   console.log("Activities for Berlin from controller:", activities);
//   //const activities = await fetchActivities(cityData.lat, cityData.lon);
//   //console.log("Sample activities for Berlin:", activities);

// });

app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}/`);
});