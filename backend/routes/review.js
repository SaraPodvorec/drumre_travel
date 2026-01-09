import express from 'express';
import { submitReview, deleteReview } from '../controllers/city_review.js';
import { authenticate } from '../middleware/auth_middleware.js';

const router = express.Router();

router.get('/', (req, res) => {
	res.status(200).json({ message: 'Reviews endpoint alive' });
});

router.post('/', authenticate, submitReview);
router.delete('/:cityName', authenticate, deleteReview);
export default router;