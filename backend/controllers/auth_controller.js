import { OAuth2Client } from 'google-auth-library';
import User from '../models/user.js';
import jwt from 'jsonwebtoken';

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

export const googleAuth = async (req, res) => {
  const { token } = req.body;

  if (!token) {
    return res.status(400).json({ message: 'Token is required' });
  }

  try {

    const ticket = await client.verifyIdToken({
      idToken: token,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    if (!payload) {
      return res.status(401).json({ message: 'Invalid token payload' });
    }

    const user = {
      googleId: payload.sub,
      email: payload.email,
      name: payload.name,
      picture: payload.picture,
    };

    // create or find user in DB 
    const db_user = await User.findOneAndUpdate(
      { googleId: user.googleId },
      { $set: user },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    console.log('Authenticated user:', db_user);

    // Create JWT with _id from database
    const tokenPayload = {
      id: db_user._id.toString(),
      email: db_user.email,
      name: db_user.name,
      picture: db_user.picture
    };

    const jwtToken = jwt.sign(tokenPayload, process.env.JWT_SECRET, { expiresIn: '1h' });

    res.cookie('token', jwtToken, { httpOnly: true, secure: false, sameSite: 'lax' });
    return res.json({ user: tokenPayload });
  } catch (error) {
    console.error('Token exchange or verification failed:', error);
    res.status(401).json({ message: 'Invalid or expired code' });
  }
};

export const getSession = (req, res) => {
  try {
    const token = req.cookies?.token; 
    
    if (!token) {
      return res.status(401).json({ message: 'Not authenticated' });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    res.json({ user: decoded, authenticated: true });
  } catch (err) {
    res.status(401).json({ message: 'Invalid or expired token' });
  }
};

export const logout = (req, res) => {
  res.clearCookie('token');
  res.json({ message: 'Logged out successfully' });
};