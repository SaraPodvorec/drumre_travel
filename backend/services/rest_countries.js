import axios from "axios";

export async function getCountryData(countryName) {
  try {
    const res = await axios.get(
      `https://restcountries.com/v3.1/name/${encodeURIComponent(countryName)}?fields=currencies,languages,population`
    );

    if (!res.data || res.data.length === 0) {
      console.log(`No data found for country: ${countryName}`);
      return null;
    }

    const country = res.data[0];
    const currencies = country.currencies || {};
    const languages = country.languages || {};

    //currency
    const currencyCode = Object.keys(currencies)[0];
    const currency = currencyCode
      ? `${currencyCode} (${currencies[currencyCode].symbol})`
      : null;

    //languages
    const language = Object.values(languages).join(", ") || null;

    return {
      currency,
      language,
      population: country.population || null,
    };
  } catch (error) {
    console.log(`Error fetching country data for ${countryName}:`, error.message);
    return null;
  }
}
