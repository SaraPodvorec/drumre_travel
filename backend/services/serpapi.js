import { getJson } from "serpapi";

export async function fetchCityDescription(cityName) {
  try {
    const params = {
      engine: "google",
      q: `${cityName}`,
      api_key: process.env.SERPAPI_KEY,
      hl: "en",
    };

    const data = await getJson(params);
    
    // Google Knowledge Graph is usually the best source for descriptions
    return (
      data.knowledge_graph?.description || data.organic_results[0]?.snippet
    );
  } catch (error) {
    console.error("SerpApi Setup Error:", error);
  }
}

export async function fetchCityTopSights(cityName) {
  try {
    const params = {
      engine: "google",
      q: `top sights in ${cityName}`,
      api_key: process.env.SERPAPI_KEY,
      hl: "en",
    };

    const data = await getJson(params);
    
    if (data.top_sights?.sights) {
      return data.top_sights.sights.map((sight) => ({
        name: sight.title,
        description: sight.description,
        link: sight.link,
        image: sight.thumbnail,
      }));
    }

    // Fallback: Some regions might return 'knowledge_graph' results for points of interest
    return data.knowledge_graph?.see_also?.map((item) => item.name) || [];
  } catch (error) {
    console.error("SerpApi Top Sights Error:", error);
    return [];
  }
}
export async function fetchCityShorts(cityName) {
  try {
    const params = {
      engine: "google",
      q: `${cityName} travel short reels`,
      hl: "en",
      gl: "us",
      api_key: process.env.SERPAPI_KEY,
    };

    const data = await getJson(params);

    if (!data.short_videos) return [];

    return data.short_videos.map((video) => ({
      title: video.title,
      source: video.source,
      link: video.link,
      thumbnail: video.thumbnail,
      extensions: Array.isArray(video.extensions)
        ? video.extensions.join(", ")
        : video.extensions ?? "",
    }));
  } catch (error) {
    console.error("SerpApi Shorts Error:", error);
    return [];
  }
};
