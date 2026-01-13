import mongoose from "mongoose";

const CitySchema = new mongoose.Schema({
    //geoapify 
    city: { type: String, required: true },           
    country: { type: String, required: true },
    continent: { type: String },    
    lat: { type: Number, required: true },
    lon: { type: Number, required: true },   
    popularity: { type: Number, required: true }, 
    state: { type: String },
    timezone: { type: String },
    formatted: { type: String },
    country_code: { type: String },

    //openWeather
    temperature: { type: Number, required: true },

    //unsplash
    imageUrl: { type: String, required: true }, 
    imageAuthor: { type: String },
    imageAuthorLink: { type: String },
    imageDescription: { type: String },
    imageAltDescription: { type: String },

    numOfReviews: { type: Number, default: 0 },
    avgImpression: { type: Number, default: 0 },
    onWishlists: { type: Number, default: 0 },

    //serpapi
    description: {type: String, required: false},
});

export default mongoose.model("City", CitySchema);
