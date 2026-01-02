import express from 'express';
import { getAllCities, getCityData } from '../controllers/city_controller.js';

const router = express.Router();

router.get('/', getAllCities);

router.get('/search', async (req, res) => {
  const { query } = req.query;
  
  if (!query || query.trim().length === 0) {
    return res.status(400).json({ error: 'Search query required' });
  }

  try {
    const cityData = await getCityData(query);
    res.json(cityData);
  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ error: 'Failed to search city: ' + error.message });
  }
});

export default router;