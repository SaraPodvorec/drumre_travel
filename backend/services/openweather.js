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