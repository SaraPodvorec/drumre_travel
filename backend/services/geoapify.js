import axios from "axios";

export async function fetchCityGeoapify(cityName) {
  const url = "https://api.geoapify.com/v1/geocode/search";

  const res = await axios.get(url, {
    params: {
      text: cityName,
      apiKey: process.env.GEOAPIFY_KEY,
    },
  });

  // Log the entire Geoapify response once for debugging
  console.log("Geoapify response data:", JSON.stringify(res.data, null, 2));

  const features = Array.isArray(res.data.features) ? res.data.features : [];
  if (!features.length) {
    throw new Error(`City "${cityName}" not found in Geoapify`);
  }

  // Only accept features where result_type is exactly "city"
  const cityFeature = features.find(f => f?.properties?.result_type === "city");

  if (!cityFeature) {
    throw new Error(`No valid city found for "${cityName}"`);
  }

  const props = cityFeature.properties;
  const coords = cityFeature.geometry.coordinates; // [lon, lat]

  // Determine city name from multiple possible fields
  const cityName_ =
    props.city ||
    props.name ||
    props.address_line1 ||
    props.other_names?.name ||
    props.other_names?._place_name ||
    cityName; // fallback

  const data = {
    city: cityName_,
    country: props.country || "",
    lat: coords?.[1] || 0,
    lon: coords?.[0] || 0,
    popularity: props.rank?.popularity || 0,
    country_code: props.country_code || "",
    continent: props.timezone?.name ? props.timezone.name.split("/")[0] : "",
    state: props.state || "",
    timezone: props.timezone
      ? `${props.timezone.name} (${props.timezone.abbreviation_STD} ${props.timezone.offset_STD} / ${props.timezone.abbreviation_DST} ${props.timezone.offset_DST})`
      : "UTC",
    formatted: props.formatted || `${cityName_}, ${props.state || ""}, ${props.country || ""}`,
  };

  console.log("Parsed Geoapify city data:", data);

  return data;
}
