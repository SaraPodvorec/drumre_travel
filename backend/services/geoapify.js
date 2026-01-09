import axios from "axios";

export async function fetchCityGeoapify(cityName) {
  const url = "https://api.geoapify.com/v1/geocode/search";

  const res = await axios.get(url, {
    params: {
      text: cityName,
      apiKey: process.env.GEOAPIFY_KEY,
    },
  });
  //console.log("Geoapify response data:", res.data);

  // Geoapify vraća GeoJSON format s features array
  const feature = res.data.features?.[0];
  if (!feature) {
    throw new Error(`City "${cityName}" not found in Geoapify`);
  }

  const props = feature.properties;
  const coords = feature.geometry.coordinates; // [lon, lat]

  //console.log("Geoapify city data:", props);

  // Try multiple fields to get city name - Geoapify returns different fields based on result type
  const cityName_ = props.city || 
                    props.name || 
                    props.address_line1 ||
                    props.other_names?.name ||
                    props.other_names?._place_name ||
                    cityName; // fallback to input
             
  const data = {
    city: cityName_,
    country: props.country,
    lat: coords[1],
    lon: coords[0],
    popularity: props.rank?.popularity || 0,
    country_code: props.country_code,
    continent: props.timezone.name? props.timezone.name.split('/')[0] : '',
    state: props.state,
    timezone: props.timezone ? 
      `${props.timezone.name} (${props.timezone.abbreviation_STD} ${props.timezone.offset_STD} / ${props.timezone.abbreviation_DST} ${props.timezone.offset_DST})` 
      : 'UTC',
    formatted: props.formatted,
  };

  console.log("Parsed Geoapify city data:", data);

  return data;
}