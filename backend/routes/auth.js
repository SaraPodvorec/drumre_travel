import express from 'express';
import { googleAuth, getSession, logout } from '../controllers/auth_controller.js';

const router = express.Router();

router.post('/google', googleAuth);
router.get('/session', getSession);
router.post('/logout', logout);

export default router;