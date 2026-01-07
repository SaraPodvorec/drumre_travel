import mongoose from 'mongoose';

const userSchema = new mongoose.Schema(
  {
    googleId: { type: String, required: true, unique: true, index: true },
    email: { type: String, required: true, unique: true, index: true },
    name: { type: String },
    picture: { type: String },
    wishlistCities: [{ type: mongoose.Schema.Types.ObjectId, ref: 'City' }],
    favoriteCities: [{ type: mongoose.Schema.Types.ObjectId, ref: 'City' }],
    deletedCities: [{ type: mongoose.Schema.Types.ObjectId, ref: 'City' }],
    deletedActivities: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Activity' }],
  },
  { timestamps: true }
);

export default mongoose.model('User', userSchema);