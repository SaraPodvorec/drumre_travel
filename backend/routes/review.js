import express from 'express';
import { authenticate } from '../middleware/auth_middleware.js';
import { 
    submitReview, 
    deleteReview, 
    getReviewsByCity,
    getReviewsByUser 
} from '../controllers/city_review.js';  

const router = express.Router();

router.get('/', (req, res) => {
	res.status(200).json({ message: 'Reviews endpoint alive' });
});

router.post('/', authenticate, submitReview);
router.delete('/:cityId', authenticate, deleteReview);
router.get('/city', getReviewsByCity);
router.get('/user', getReviewsByUser);
export default router;