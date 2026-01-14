import mongoose from "mongoose";

const CityTopSightSchema = new mongoose.Schema({
  cityId: { type: mongoose.Schema.Types.ObjectId, ref: "City" },

  name: {type: String, required: true },
  description: {type: String, required: false },
  link: {type: String, required: false},
  image: {type: String, required: true},

  // caching info
  lastFetched: { type: Date, default: Date.now }
});

export default mongoose.model("CityTopSight", CityTopSightSchema);
