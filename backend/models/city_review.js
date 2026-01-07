import mongoose from 'mongoose';

const cityReview = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    cityId: { type: mongoose.Schema.Types.ObjectId, ref: 'City', required: true, index: true },
    impression: { type: Number, required: true, min: 1, max: 5, required: true },
    people: { type: Number, required: true, min: 0, max: 5 },
    sights: {type: Number, required: true, min: 0, max: 5 },
    safety: { type: Number, required: true, min: 0, max: 5 },
    affordability: { type: Number, required: true, min: 0, max: 5 },
    comments: { type: String },
},);

export default mongoose.model('CityReview', cityReview);