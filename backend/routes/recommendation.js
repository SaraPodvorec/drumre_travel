import express from 'express';
import { getRecommendedCities, getFriendsActivity } from '../controllers/recommendation_controller.js';

const router = express.Router();

router.get('/:userId', getRecommendedCities);
router.get('/friends/:userId', getFriendsActivity);

export default router;