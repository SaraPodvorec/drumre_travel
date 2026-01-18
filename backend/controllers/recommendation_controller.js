import City from '../models/city.js';
import CityReview from '../models/city_review.js';
import User from '../models/user.js';

export const getRecommendedCities = async (req, res) => {
    try {
        const { userId } = req.params;

        // 1. Fetch user and their following list
        const user = await User.findById(userId).select('onboardingPreferences deletedCities favoriteCities following');
        if (!user) return res.status(404).json({ message: "User not found" });

        const { continents, citySize, impressionPreference } = user.onboardingPreferences;

        // 2. Aggregate friends' impressions and individual category scores
        // We calculate the average of all metrics for friends who rated the city > 3
        const friendStats = await CityReview.aggregate([
            { 
                $match: { 
                    userId: { $in: user.following }, 
                    impression: { $gt: 3 } 
                } 
            },
            {
                $group: {
                    _id: "$cityId",
                    avgFriendImpression: { $avg: "$impression" },
                    avgFriendPeople: { $avg: "$people" },
                    avgFriendSights: { $avg: "$sights" },
                    avgFriendSafety: { $avg: "$safety" },
                    avgFriendAffordability: { $avg: "$affordability" }
                }
            }
        ]);

        // Create a lookup map for easy access
        const friendRatingMap = friendStats.reduce((acc, curr) => {
            acc[curr._id.toString()] = curr;
            return acc;
        }, {});

        let query = {
            _id: { $nin: [...user.deletedCities, ...user.favoriteCities] }
        };

        if (continents && continents.length > 0) {
            query.continent = { $in: continents };
        }

        // Apply population filters
        if (citySize === 'small') query.population = { $lt: 1000000 };
        else if (citySize === 'medium') query.population = { $gte: 1000000, $lt: 4000000 };
        else if (citySize === 'large') query.population = { $gte: 4000000 };

        const potentialCities = await City.find(query).limit(50);

        const recommendations = await Promise.all(potentialCities.map(async (city) => {
            const stats = await CityReview.aggregate([
                { $match: { cityId: city._id } },
                {
                    $group: {
                        _id: "$cityId",
                        avgImpression: { $avg: "$impression" },
                        avgPeople: { $avg: "$people" },
                        avgSights: { $avg: "$sights" },
                        avgSafety: { $avg: "$safety" },
                        avgAffordability: { $avg: "$affordability" }
                    }
                }
            ]);

            let score = 0;
            if (stats.length > 0) {
                const s = stats[0];
                score += s.avgImpression;

                if (impressionPreference === 'people') score += (s.avgPeople * 2);
                if (impressionPreference === 'sights') score += (s.avgSights * 2);
                if (impressionPreference === 'safety') score += (s.avgSafety * 2);
                if (impressionPreference === 'affordability') score += (s.avgAffordability * 2);
            } else {
                score = city.popularity / 10;
            }

            // 3. Apply Social Bonus and attach Friend Data
            const fData = friendRatingMap[city._id.toString()];
            let friendsImpression = null;

            if (fData) {
                // Calculation: Proportional boost based on how far above 3 the rating is
                const multiplier = 1 + (fData.avgFriendImpression - 3) * 0.25;
                score *= multiplier;

                // Format the scores to return to the frontend
                friendsImpression = {
                    avgImpression: fData.avgFriendImpression,
                    avgPeople: fData.avgFriendPeople,
                    avgSights: fData.avgFriendSights,
                    avgSafety: fData.avgFriendSafety,
                    avgAffordability: fData.avgFriendAffordability
                };
            }

            return { 
                ...city.toObject(), 
                recommendationScore: score,
                friendsImpression // This will be null if no friends rated it > 3
            };
        }));

        const sortedResults = recommendations
            .sort((a, b) => b.recommendationScore - a.recommendationScore)
            .slice(0, 10);

        res.status(200).json(sortedResults);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

export const getFriendsActivity = async (req, res) => {
    try {
        const { userId } = req.params;
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        const currentUser = await User.findById(userId).select('following');
        if (!currentUser) {
            return res.status(404).json({ message: "User not found" });
        }

        const filter = { userId: { $in: currentUser.following } };

        const [totalItems, friendsActivity] = await Promise.all([
            CityReview.countDocuments(filter), // Get total count of relevant reviews
            CityReview.find(filter)
                .sort({ createdAt: -1 }) //
                .skip(skip)
                .limit(limit)
                .populate('cityId') //
                .populate('userId', 'name picture') //
        ]);

        const totalPages = Math.ceil(totalItems / limit);

        const formattedActivity = friendsActivity.map(review => ({
            city: review.cityId, 
            review: {
                impression: review.impression,
                people: review.people,
                sights: review.sights,
                safety: review.safety,
                affordability: review.affordability,
                comments: review.comments,
                createdAt: review.createdAt
            },
            reviewer: review.userId
        }));

        res.status(200).json({
            page,
            totalPages,
            limit,
            data: formattedActivity,
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// export const getFriendsActivity = async (req, res) => {
//     try {
//         const { userId } = req.params;
//         const page = parseInt(req.query.page) || 1;
//         const limit = parseInt(req.query.limit) || 10;
//         const skip = (page - 1) * limit;

//         const currentUser = await User.findById(userId).select('following');
//         if (!currentUser) {
//             return res.status(404).json({ message: "User not found" });
//         }

//         const friendsActivity = await CityReview.find({
//             userId: { $in: currentUser.following }
//         })
//         .sort({ createdAt: -1 })
//         .skip(skip)
//         .limit(limit)
//         .populate('cityId')
//         .populate('userId', 'name picture');

//         const formattedActivity = friendsActivity.map(review => ({
//             city: review.cityId,
//             review: {
//                 impression: review.impression,
//                 people: review.people,
//                 sights: review.sights,
//                 safety: review.safety,
//                 affordability: review.affordability,
//                 comments: review.comments,
//                 createdAt: review.createdAt
//             },
//             reviewer: review.userId
//         }));

//         res.status(200).json({
//             page,
//             limit,
//             data: formattedActivity
//         });
//     } catch (error) {
//         res.status(500).json({ message: error.message });
//     }
// };