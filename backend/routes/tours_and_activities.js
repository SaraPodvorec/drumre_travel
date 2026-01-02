import { Router } from "express";
import { getCityActivities } from "../controllers/city_activities_controller.js";

const router = Router();

router.get("/", getCityActivities);

export default router;
