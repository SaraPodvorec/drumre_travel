import mongoose from 'mongoose';

const cityReview = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    cityId: { type: mongoose.Schema.Types.ObjectId, ref: 'City', required: true, index: true },
    impression: { type: Number, required: true, min: 1, max: 5, required: true },
    people: { type: Number, required: true, min: 0, max: 5, required: true  },
    sights: {type: Number, required: true, min: 0, max: 5, required: true  },
    safety: { type: Number, required: true, min: 0, max: 5, required: true },
    affordability: { type: Number, required: true, min: 0, max: 5, required: true },
    comments: { type: String },
},
  { timestamps: true }
);

export default mongoose.model('CityReview', cityReview);