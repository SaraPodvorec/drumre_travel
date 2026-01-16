import axios from "axios";

export async function fetchCityWeather(lat, lon) {
    const url = "https://api.openweathermap.org/data/3.0/onecall";

    const res = await axios.get(url, {
        params: {
            lat: lat,
            lon: lon,
            units: "metric",
            appid: process.env.OPEN_WEATHER_API_KEY,
        },
    });
    //console.log("OpenWeather response data:", res.data);

    const data = {
        temperature: res.data.current.temp,
    };
    return data;
}

// Cache duration: 5 minutes
const WEATHER_CACHE_DURATION = 5 * 60 * 1000; // ms

// In-memory cache: { "<cityName>": { data: ..., fetchedAt: ... } }
const weatherCache = {};

export async function fetchCityWeatherByName(cityName) {
  const key = cityName.toLowerCase();
  const cached = weatherCache[key];
  console.log(`Checking weather cache for "${cityName}":`, cached);

  if (cached && Date.now() - cached.fetchedAt < WEATHER_CACHE_DURATION) {
    return cached.data;
  }

  try {
    const url = "https://api.openweathermap.org/data/2.5/weather";
    const res = await axios.get(url, {
      params: {
        q: cityName,
        units: "metric",
        appid: process.env.OPEN_WEATHER_API_KEY,
      },
    });

    const data = {
      temperature: res.data.main.temp,
      main: res.data.weather?.[0]?.main || "",
    };

    // Cache the result
    weatherCache[key] = { data, fetchedAt: Date.now() };

    console.log(`Fetched weather for "${cityName}":`, data);
    return data;
  } catch (err) {
    console.error(`Error fetching weather for "${cityName}":`, err.message);
    return null;
  }
}
