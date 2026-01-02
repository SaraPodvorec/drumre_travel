import axios from "axios";

export async function getAmadeusToken() {
  const res = await axios.post(
    "https://test.api.amadeus.com/v1/security/oauth2/token",
    new URLSearchParams({
      grant_type: "client_credentials",
      client_id: process.env.AMADEUS_KEY,
      client_secret: process.env.AMADEUS_SECRET,
    })
  );

  console.log(`Amadeus token fetched: ${res.data.access_token}`);

  return res.data.access_token;
}

export async function fetchActivities(lat, lon) {
  const token = await getAmadeusToken();

  const res = await axios.get(
    "https://test.api.amadeus.com/v1/shopping/activities",
    {
      params: { latitude: lat, longitude: lon, radius: 15 },
      headers: { Authorization: `Bearer ${token}` },
    }
  );

  console.log(`Fetched ${res.data.data.length} activities`);

  return res.data.data.map((a) => {
    const priceAmount = a.price?.amount ? parseFloat(a.price.amount) : 0;
    
    return {
      amadeusId: a.id,
      name: a.name,
      description: a.description || "",
      lat: a.geoCode?.latitude || lat,
      lon: a.geoCode?.longitude || lon,
      price: {
        amount: isNaN(priceAmount) ? 0 : priceAmount,
        currency: a.price?.currencyCode || "USD",
      },
      images: a.pictures || [],
      bookingLink: a.bookingLink || "",
    };
  });
}