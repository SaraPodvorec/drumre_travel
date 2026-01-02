import mongoose from "mongoose";

const UserActivitySchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  activityId: { type: mongoose.Schema.Types.ObjectId, ref: "Activity" },

  saved: { type: Boolean, default: false },
  hidden: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});

export default mongoose.model("UserActivity", UserActivitySchema);
