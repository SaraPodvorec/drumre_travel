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

    onWishlists: { type: Number, default: 0 },

    //rest_countries
    currency: { type: String, required: false },
    language: { type: String, required: false },
    population: { type: Number, required: false },

    //serpapi
    description: {type: String, required: false},
});

export default mongoose.model("City", CitySchema);
