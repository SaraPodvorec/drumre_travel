import CityReview from '../models/city_review.js';
import User from "../models/user.js";
import City from "../models/city.js";

export async function submitReview(req, res) {
    const { 
        cityName,
        impression,
        people,
        sights,
        safety, 
        affordability, 
        comments
    } = req.body;
    try {
        if (!cityName || cityName.trim() === '') {
            return res.status(400).json({ error: 'City name is required' });
        }

        if (impression === undefined || impression === null) {
            return res.status(400).json({ error: 'Impression is required' });
        }
        if (typeof impression !== 'number' || impression < 1 || impression > 5) {
            return res.status(400).json({ error: 'Impression must be a number between 1 and 5' });
        }
        const peopleVal = people ?? 0;
        const sightsVal = sights ?? 0;
        const safetyVal = safety ?? 0;
        const affordabilityVal = affordability ?? 0;

        const ratings = [peopleVal, sightsVal, safetyVal, affordabilityVal];
        for (let rating of ratings) {
            if (rating < 0 || rating > 5) {
                return res.status(400).json({ error: 'Ratings must be numbers between 0 and 5' });
            }
        }

        if (comments && typeof comments !== 'string') {
            return res.status(400).json({ error: 'Comments must be a string' });
        }
        if (comments && comments.length > 1000) {
            return res.status(400).json({ error: 'Comments cannot exceed 1000 characters' });
        }

        // Find city (case-insensitive)
        const city = await City.findOne({ 
            city: new RegExp(`^${cityName.trim()}$`, 'i') 
        });
        if (!city) {
            return res.status(404).json({ error: 'City not found' });
        }
        // Update city's number of reviews and average impression
        city.numOfReviews += 1;
        city.avgImpression = ((city.avgImpression * (city.numOfReviews - 1)) + impression) / city.numOfReviews;
        await city.save();

        const user = await User.findOne({ googleId: req.user.googleId });
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        const existingReview = await CityReview.findOne({
            userId: user._id, 
            cityId: city._id
        });
        if (existingReview) {
            return res.status(400).json({ error: 'Review already exists for this user and city' });
        }

        const newReview = new CityReview({
            userId: user._id,
            cityId: city._id,
            impression,
            people: peopleVal,
            sights: sightsVal,
            safety: safetyVal,
            affordability: affordabilityVal,
            comments: comments || ''
        });

        await newReview.save();
        res.status(201).json({success: true, review: newReview});

    } catch (error) {
        console.error('Review creation error:', error);
        res.status(500).json({ error: 'Failed to create review', details: error.message });
    }
}

export async function deleteReview(req, res) {
    const { cityName } = req.params;
    const city = await City.findOne({ 
            city: new RegExp(`^${cityName.trim()}$`, 'i') });
    if (!city) {
        return res.status(404).json({ error: 'City not found' });
    }
    const user = await User.findOne({ googleId: req.user.googleId });
    if (!user) {
        return res.status(404).json({ error: 'User not found' });
    }
    const review = await CityReview.findOneAndDelete({
        userId: user._id,
        cityId: city._id
    });
    if (!review) {
        return res.status(404).json({ error: 'Review not found' });
    }
    res.status(200).json({ message: 'Review deleted successfully' });
}

