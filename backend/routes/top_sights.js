import { Router } from "express";
import { getTopSightsByCityId } from "../controllers/city_top_sights_controller.js";

const router = Router();

router.get("/", getTopSightsByCityId);

export default router;