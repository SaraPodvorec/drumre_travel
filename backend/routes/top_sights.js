import { Router } from "express";
import { getTopSightsByCityId } from "../controllers/city_top_sights_controller";

const router = Router();

router.get("/", getTopSightsByCityId);

export default router;