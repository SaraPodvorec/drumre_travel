import User from '../models/user.js';
import City from '../models/city.js';

export const getUserData = async (req, res) => {
  try {
    const user = await User.findOne({ _id: req.user.id })
      .select('_id wishlistCities favoriteCities deletedCities onboardingCompleted onboardingPreferences');
    
    res.json({
      user_id: user._id,
      wishlistedCities: user?.wishlistCities || [],
      favoriteCities: user?.favoriteCities || [],
      deletedCities: user?.deletedCities || [],
      onboardingCompleted: user?.onboardingCompleted || false,
      onboardingPreferences: user?.onboardingPreferences || {},
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

// export const getAllUsers = async (req, res) => {
//   try {
//     const users = await User.find().select('name email picture');
//     res.json({users});
//   } catch (e) {
//     res.status(500).json({ error: e.message });
//   }
// };
export const getAllUsers = async (req, res) => {
  try {
    const currentUser = await User.findById(req.user.id)
      .select('following');

    const users = await User.find({ _id: { $ne: req.user.id } })
      .select('name email picture');

    res.json({
      users,
      following: currentUser.following
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

export const getUserProfile = async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findOne({ _id: userId })
    .select('name picture wishlistCities favoriteCities');
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    const currentUser = await User.findById(req.user.id).select('following');
    const isFollowing = currentUser.following.includes(userId);
    res.json({
      name: user.name,
      picture: user.picture,
      wishlistedCities: user.wishlistCities,
      favoriteCities: user.favoriteCities,
      isFollowing: isFollowing
    });
  }catch (e) {
    res.status(500).json({ error: e.message });
  }
};

export const addWishlistCity = async (req, res) => {
  const { cityId } = req.body;
  try {
    const user = await User.findOneAndUpdate(
      { _id: req.user.id },
      { $addToSet: { wishlistCities: cityId } },
      { new: true }
    ).populate('wishlistCities');

    const city = await City.findOne({ _id: cityId });
    city.onWishlists += 1;
    await city.save();

    res.json({ success: true, wishlistCities: user.wishlistCities });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

export const removeWishlistCity = async (req, res) => {
  const { cityId } = req.params;
  try {
    const user = await User.findOneAndUpdate(
      { _id: req.user.id },
      { $pull: { wishlistCities: cityId } },
      { new: true }
    ).populate('wishlistCities');

    const city = await City.findOne({ _id: cityId });
    city.onWishlists = Math.max(0, city.onWishlists - 1);
    await city.save();

    res.json({ success: true, wishlistCities: user.wishlistCities });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

export const addFavoriteCity = async (req, res) => {
  const { cityId } = req.body;
  
  try {
    const user = await User.findOneAndUpdate(
      { _id: req.user.id },
      { $addToSet: { favoriteCities: cityId } },
      { new: true }
    ).populate('favoriteCities');
    res.json({ success: true, favoriteCities: user.favoriteCities });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

export const removeFavoriteCity = async (req, res) => {
  const { cityId } = req.params;
  
  try {
    const user = await User.findOneAndUpdate(
      { _id: req.user.id },
      { $pull: { favoriteCities: cityId } },
      { new: true }
    ).populate('favoriteCities');
    res.json({ success: true, favoriteCities: user.favoriteCities });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

export const deleteCity = async (req, res) => {
  const { cityId } = req.body;
  
  try {
    const user = await User.findOneAndUpdate(
      { _id: req.user.id },
      { $addToSet: { deletedCities: cityId } },
      { new: true }
    );
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

export const undeleteCity = async (req, res) => {
  const { cityId } = req.params;
  
  try {
    await User.findOneAndUpdate(
      { _id: req.user.id },
      { $pull: { deletedCities: cityId } },
      { new: true }
    );
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};
export const addFollowing = async (req, res) => {
  const { userId } = req.body; // ID of the user to follow
  try {
    const user = await User.findOneAndUpdate(
      { _id: req.user.id },
      { $addToSet: { following: userId } },
      { new: true }
    ).populate('following');
    res.json({ success: true, following: user.following });
  }
  catch (e) {
    res.status(500).json({ error: e.message });
  }
};
//needs fix bcs we dont have userId on frontend (userId is mongoDB id)
export const removeFollowing = async (req, res) => {
  const { userId } = req.params; // ID of the user to unfollow
  try {
    const user = await User.findOneAndUpdate(
      { _id: req.user.id },
      { $pull: { following: userId } },
      { new: true } 
    ).populate('following');
    res.json({ success: true, following: user.following });
  }
  catch (e) {
    res.status(500).json({ error: e.message });
  } 
};

export const completeOnboarding = async (req, res) => {
  const { climate, citySize, continents } = req.body;

  if (!climate || !citySize || !continents) {
    return res.status(400).json({ error: 'Missing onboarding data' });
  }

  try {
    const user = await User.findOneAndUpdate(
      { _id: req.user.id },
      {
        onboardingCompleted: true,
        onboardingPreferences: { climate, citySize, continents },
      },
      { new: true }
    );

    res.json({
      success: true,
      onboardingCompleted: user.onboardingCompleted,
      onboardingPreferences: user.onboardingPreferences,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};


