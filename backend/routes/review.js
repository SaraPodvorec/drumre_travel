import express from 'express';
import { authenticate } from '../middleware/auth_middleware.js';
import { 
    submitReview, 
    deleteReview, 
    getReviewsByCity,
    getReviewsByUser,
    updateReview
} from '../controllers/city_review.js';  

const router = express.Router();

router.get('/', (req, res) => {
	res.status(200).json({ message: 'Reviews endpoint alive' });
});

router.post('/', authenticate, submitReview);
router.delete('/:reviewId', authenticate, deleteReview);
router.post('/city', getReviewsByCity);
router.post('/user', getReviewsByUser);
router.put('/:reviewId', authenticate, updateReview);
export default router;