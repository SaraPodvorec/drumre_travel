import express from 'express';
import { getRecommendedCities } from '../controllers/recommendation_controller.js';

const router = express.Router();

router.get('/:userId', getRecommendedCities);

export default router;