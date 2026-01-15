import mongoose from "mongoose";

const CityShortVideoSchema = new mongoose.Schema({
  cityId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "City",
    index: true,
  },
  title: String,
  source: String,
  extensions: String,
  thumbnail: String,
  link: String,
  lastFetched: { type: Date, default: Date.now },
});

CityShortVideoSchema.index({ cityId: 1, link: 1 }, { unique: true });

export default mongoose.model("CityShorts", CityShortVideoSchema);