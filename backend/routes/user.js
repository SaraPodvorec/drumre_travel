import express from 'express';
import { authenticate } from '../middleware/auth_middleware.js';
import {
  getUserData,
  addFavoriteCity,
  removeFavoriteCity,
  deleteCity,
  undeleteCity,
} from '../controllers/user_controller.js';

const router = express.Router();

router.get('/data', authenticate, getUserData);
router.post('/favorites/add', authenticate, addFavoriteCity);
router.delete('/favorites/remove/:cityId', authenticate, removeFavoriteCity);
router.post('/deleted-cities/add', authenticate, deleteCity);
router.delete('/deleted-cities/remove/:cityId', authenticate, undeleteCity);

export default router;