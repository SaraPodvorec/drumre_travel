import axios from "axios";

const COUNTRY_POP_URL = 'https://countriesnow.space/api/v0.1/countries/population';
const CITY_POP_URL = 'https://countriesnow.space/api/v0.1/countries/population/cities';

export function getLatestPopulationFromArray(arr) {
    // console.log(arr);
    if (!arr || arr.length === 0) return null;

    const latestEntry = arr.reduce((latest, current) => {
        return Number(current.year) >= Number(latest.year) ? current : latest;
    });

    return latestEntry.value;
}

export async function fetchAllCityPopulations() {
    const response = await axios.get(CITY_POP_URL);

    return response.data.data.map(item => ({
        ...item,
        city: item.city.toLowerCase()
    }));
}

export async function fetchCityPopulation(cityName) {
    const populations = await fetchAllCityPopulations();
    const cityData = populations.find( item =>
      item => item.city.toLowerCase() === cityName.toLowerCase()
    );
    return getLatestPopulationFromArray(cityData.populationCounts);
}