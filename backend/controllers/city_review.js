import CityReview from '../models/city_review.js';
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

        if (!impression || !people || !sights || !safety || !affordability) {
            return res.status(400).json({ error: 'All ratings (impression, people, sights, safety, affordability) are required' });
        }

        const ratings = [impression, people, sights, safety, affordability];
        for (let rating of ratings) {
            if (typeof rating !== 'number' || rating < 1 || rating > 5) {
                return res.status(400).json({ error: 'All ratings must be numbers between 1 and 5' });
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

        const existingReview = await CityReview.findOne({
            userId: req.user.id, 
            cityId: city._id
        });
        if (existingReview) {
            return res.status(400).json({ error: 'Review already exists for this user and city' });
        }

        const newReview = new CityReview({
            userId: req.user.id,
            cityId: city._id,
            impression,
            people: people,
            sights: sights,
            safety: safety,
            affordability: affordability,
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
    const { reviewId } = req.params;
    const review = await CityReview.findOneAndDelete({
        _id: reviewId,
    });
    if (!review) {
        return res.status(404).json({ error: 'Review not found' });
    }
    
    res.status(200).json({ message: 'Review deleted successfully' });
}

export async function getReviewsByCity(req, res) {
    const { cityId } = req.body;
    try {
    const reviews = await CityReview.find({ cityId: cityId }).populate('userId', '_id name picture');
    const response = reviews.map(review => ({
      id: review._id,
      userId: review.userId?._id ?? null,
      name: review.userId?.name ?? null,
      picture: review.userId?.picture ?? null,
      impression: review.impression,
      people: review.people,
      sights: review.sights,
      safety: review.safety,
      affordability: review.affordability,
      comments: review.comments
    }));
    res.status(200).json(response);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch reviews', details: error.message });
    }
}

export async function getReviewsByUser(req, res) {
    const { userId } = req.body; 
    try{
        const reviews = await CityReview.find({ userId: userId }).populate('cityId', 'city country imageUrl');
        const response = reviews.map(review => ({
            id: review._id,
            city: review.cityId?.city ?? null,
            country: review.cityId?.country ?? null,
            imageUrl: review.cityId?.imageUrl ?? null,
            impression: review.impression,  
            people: review.people,
            sights: review.sights,
            safety: review.safety,
            affordability: review.affordability,
            comments: review.comments,
            createdAt: review.createdAt,
        }));
    res.status(200).json(response);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch user reviews', details: error.message });
    }
}

export async function updateReview(req, res) {
    const { reviewId } = req.params;
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
        if (!impression || !people || !sights || !safety || !affordability) {
            return res.status(400).json({ error: 'All ratings (impression, people, sights, safety, affordability) are required' });
        }

        const ratings = [impression, people, sights, safety, affordability];
        for (let rating of ratings) {
            if (typeof rating !== 'number' || rating < 1 || rating > 5) {
                return res.status(400).json({ error: 'All ratings must be numbers between 1 and 5' });
            }
        }

        if (comments && typeof comments !== 'string') {
            return res.status(400).json({ error: 'Comments must be a string' });
        }
        if (comments && comments.length > 1000) {
            return res.status(400).json({ error: 'Comments cannot exceed 1000 characters' });
        }

        console.log("Updating review:", reviewId);
        const review = await CityReview.findByIdAndUpdate(
        reviewId,
        {
            impression,
            people,
            sights,
            safety,
            affordability,
            comments,
        },
        { new: true }
        );
        res.status(200).json({ success: true, review });
    } catch (error) {
        console.error('Review update error:', error);
        res.status(500).json({ error: 'Failed to update review', details: error.message });
    }
}

export async function getCityReviewsData(req, res) {
    const { cityId } = req.params;

    try {
        const reviews = await CityReview.find({ cityId: cityId });
        if (reviews.length === 0) {
            return res.status(200).json({
                avgImpression: 0,
                avgPeople: 0,
                avgSights: 0,
                avgSafety: 0,
                avgAffordability: 0,
                numOfReviews: 0
            });
        }
        const totalImpression = reviews.reduce((sum, review) => sum + review.impression, 0);
        const totalPeople = reviews.reduce((sum, review) => sum + review.people, 0);
        const totalSights = reviews.reduce((sum, review) => sum + review.sights, 0);
        const totalSafety = reviews.reduce((sum, review) => sum + review.safety, 0);
        const totalAffordability = reviews.reduce((sum, review) => sum + review.affordability, 0);

        const avgImpression = totalImpression / reviews.length;
        const avgPeople = totalPeople / reviews.length;
        const avgSights = totalSights / reviews.length;
        const avgSafety = totalSafety / reviews.length;
        const avgAffordability = totalAffordability / reviews.length;

        res.status(200).json({
            avgImpression,
            avgPeople,
            avgSights,
            avgSafety,
            avgAffordability,
            numOfReviews: reviews.length
        });
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch average review data', details: error.message });
    }
}