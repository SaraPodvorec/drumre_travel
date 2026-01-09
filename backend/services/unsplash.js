import axios from "axios";

export async function fetchCityImage(cityName) {
  const res = await axios.get("https://api.unsplash.com/search/photos", {
    params: {
      query: cityName,
      per_page: 1,
      orientation: "landscape",
      client_id: process.env.UNSPLASH_KEY,
    },
  });

  //console.log("Unsplash image data:", res.data);


  //console.log(`Photo by ${authorName} (${authorLink}) on Unsplash`);

  const cityImage = {
    imageUrl: res.data.results?.[0]?.urls?.regular || null,
    imageAuthor: res.data.results?.[0]?.user?.name || null,
    imageAuthorLink: res.data.results?.[0]?.user?.links?.html || null,
    imageDescription: res.data.results?.[0]?.description || null,
    imageAltDescription: res.data.results?.[0]?.alt_description || null,
  }

  console.log("Parsed Unsplash city image data:", cityImage);

  return cityImage;
}
