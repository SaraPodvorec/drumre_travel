import City from '../models/city.js';
import CityReview from '../models/city_review.js';
import User from '../models/user.js';

function getPreferenceBoost(city, prefs) {
    let boost = 1;

    const { continents, citySize } = prefs;

    if (continents?.length) {
        if (continents.includes(city.continent)) boost += 0.35;
        else boost -= 0.15;
    }

    if (citySize) {
        if (citySize === 'small' && city.population < 1_000_000) boost += 0.25;
        else if (citySize === 'medium' && city.population >= 1_000_000 && city.population < 4_000_000) boost += 0.25;
        else if (citySize === 'large' && city.population >= 4_000_000) boost += 0.25;
        else boost -= 0.1;
    }

    return boost;
}

export const getRecommendedCities = async (req, res) => {
    try {
        const { userId } = req.params;

        const user = await User.findById(userId)
            .select('following deletedCities favoriteCities onboardingPreferences');

        if (!user) return res.status(404).json({ message: "User not found" });

        const { impressionPreference } = user.onboardingPreferences;

        const friendsAgg = await CityReview.aggregate([
            { $match: { userId: { $in: user.following } } },
            {
                $group: {
                    _id: "$cityId",
                    avgFriendImpression: { $avg: "$impression" },
                    avgFriendPeople: { $avg: "$people" },
                    avgFriendSights: { $avg: "$sights" },
                    avgFriendSafety: { $avg: "$safety" },
                    avgFriendAffordability: { $avg: "$affordability" },
                    friendVisitCount: { $sum: 1 }
                }
            }
        ]);

        const friendMap = friendsAgg.reduce((acc, c) => {
            acc[c._id.toString()] = c;
            return acc;
        }, {});

        const allCities = await City.find({
            _id: { $nin: [...user.deletedCities, ...user.favoriteCities] }
        });

        const globalAgg = await CityReview.aggregate([
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

        const globalMap = globalAgg.reduce((acc, g) => {
            acc[g._id.toString()] = g;
            return acc;
        }, {});

        const scoredCities = allCities.map(city => {
            const g = globalMap[city._id.toString()] || {};
            const f = friendMap[city._id.toString()] || null;

            let score = 0;

            if (f) {
                let friendScore = f.avgFriendImpression;

                if (impressionPreference === 'people') friendScore += f.avgFriendPeople;
                if (impressionPreference === 'sights') friendScore += f.avgFriendSights;
                if (impressionPreference === 'safety') friendScore += f.avgFriendSafety;
                if (impressionPreference === 'affordability') friendScore += f.avgFriendAffordability;

                friendScore /= 2;

                const visitBoost = 1 + Math.min(f.friendVisitCount / 5, 2);
                const dislikePenalty = f.avgFriendImpression < 3 ? 0.5 : 1;

                score += friendScore * 0.6 * visitBoost * dislikePenalty;
            }

            if (g.avgImpression) {
                let globalScore = g.avgImpression;

                if (impressionPreference === 'people') globalScore += g.avgPeople;
                if (impressionPreference === 'sights') globalScore += g.avgSights;
                if (impressionPreference === 'safety') globalScore += g.avgSafety;
                if (impressionPreference === 'affordability') globalScore += g.avgAffordability;

                score += (globalScore / 2) * 0.3;
            }

            score += (city.popularity || 1) / 100 * 0.1;

            score *= getPreferenceBoost(city, user.onboardingPreferences);

            return {
                ...city.toObject(),
                recommendationScore: Number(score.toFixed(2)),
                friendsData: f || null,
                globalData: g || null
            };
        });

        const sorted = scoredCities.sort((a, b) => b.recommendationScore - a.recommendationScore);

        res.status(200).json(sorted);

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: err.message });
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
