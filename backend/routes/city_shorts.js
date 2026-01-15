import express from "express";
import { getTopShortVideosByCity } from "../controllers/city_shorts_controller.js";

const router = express.Router();

router.get("/", getTopShortVideosByCity);

export default router;
