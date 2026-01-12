import express from 'express';
import { authenticate } from '../middleware/auth_middleware.js';
import {
  getUserData,
  getAllUsers,
  addWishlistCity,
  removeWishlistCity,
  addFavoriteCity,
  removeFavoriteCity,
  deleteCity,
  undeleteCity,
  addFollowing,
  getUserFollowStats,
  removeFollowing,
  completeOnboarding,
  getUsersProfile
} from '../controllers/user_controller.js';
const router = express.Router();

router.get('/data', authenticate, getUserData);
router.get('/all', authenticate, getAllUsers);
router.post('/wishlist/add', authenticate, addWishlistCity);
router.delete('/wishlist/remove/:cityId', authenticate, removeWishlistCity);
router.post('/favorites/add', authenticate, addFavoriteCity);
router.delete('/favorites/remove/:cityId', authenticate, removeFavoriteCity);
router.post('/deleted-cities/add', authenticate, deleteCity);
router.delete('/deleted-cities/remove/:cityId', authenticate, undeleteCity);
router.post('/follow/add', authenticate, addFollowing);
router.delete('/follow/remove/:userId', authenticate, removeFollowing);
router.get('/follow/stats', authenticate, getUserFollowStats);
router.get('/:id/profile', authenticate, getUsersProfile);

router.post('/onboarding/complete', authenticate, completeOnboarding);

export default router;