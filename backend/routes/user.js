import express from 'express';
import { authenticate } from '../middleware/auth_middleware.js';
import {
  getUserData,
  addWishlistCity,
  removeWishlistCity,
  addFavoriteCity,
  removeFavoriteCity,
  deleteCity,
  undeleteCity,
  addFollowing,
  removeFollowing,
} from '../controllers/user_controller.js';
import { mockAuthenticate } from '../middleware/mockAuthenticate.js';

const router = express.Router();

router.get('/data', authenticate, getUserData);
router.post('/wishlist/add', authenticate, addWishlistCity);
router.delete('/wishlist/remove/:cityId', authenticate, removeWishlistCity);
router.post('/favorites/add', authenticate, addFavoriteCity);
router.delete('/favorites/remove/:cityId', authenticate, removeFavoriteCity);
router.post('/deleted-cities/add', authenticate, deleteCity);
router.delete('/deleted-cities/remove/:cityId', authenticate, undeleteCity);
router.post('/follow/add', mockAuthenticate, addFollowing);
router.delete('/follow/remove/:userId', mockAuthenticate, removeFollowing);

export default router;