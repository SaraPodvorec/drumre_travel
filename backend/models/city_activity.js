import mongoose from "mongoose";

const CityActivitySchema = new mongoose.Schema({
  amadeusId: { type: String, unique: true },   
  cityId: { type: mongoose.Schema.Types.ObjectId, ref: "City" },

  name: {type: String, required: true },
  description: {type: String, required: true },
  price: {
    amount: Number,
    currency: String,
  },
  images: { type: [String] },
  bookingLink: {type: String },
  minimumDuration: {type: String },

  // caching info
  lastFetched: { type: Date, default: Date.now }
});

export default mongoose.model("CityActivity", CityActivitySchema);