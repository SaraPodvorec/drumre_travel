import express from 'express';
import { authenticate } from '../middleware/auth_middleware.js';
import {
  getUserData,
  getAllUsers,
  getUserProfile,
  addWishlistCity,
  removeWishlistCity,
  addFavoriteCity,
  removeFavoriteCity,
  deleteCity,
  undeleteCity,
  addFollowing,
  removeFollowing,
  completeOnboarding
} from '../controllers/user_controller.js';
const router = express.Router();

router.get('/data', authenticate, getUserData);
router.get('/all', authenticate, getAllUsers);
router.get('/:userId', authenticate, getUserProfile);
router.post('/wishlist/add', authenticate, addWishlistCity);
router.delete('/wishlist/remove/:cityId', authenticate, removeWishlistCity);
router.post('/favorites/add', authenticate, addFavoriteCity);
router.delete('/favorites/remove/:cityId', authenticate, removeFavoriteCity);
router.post('/deleted-cities/add', authenticate, deleteCity);
router.delete('/deleted-cities/remove/:cityId', authenticate, undeleteCity);
router.post('/follow/add', authenticate, addFollowing);
router.delete('/follow/remove/:userId', authenticate, removeFollowing);

router.post('/onboarding/complete', authenticate, completeOnboarding);

export default router;