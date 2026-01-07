import User from '../models/user.js';

export const getUserData = async (req, res) => {
  try {
    const user = await User.findOne({ googleId: req.user.googleId })
      .select('wishlistCities favoriteCities deletedCities');
    
    res.json({
      wishlistedCities: user?.wishlistCities || [],
      favoriteCities: user?.favoriteCities || [],
      deletedCities: user?.deletedCities || []
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

export const addWishlistCity = async (req, res) => {
  const { cityId } = req.body;
  try {
    const user = await User.findOneAndUpdate(
      { googleId: req.user.googleId },
      { $addToSet: { wishlistCities: cityId } },
      { new: true }
    ).populate('wishlistCities');
    res.json({ success: true, wishlistCities: user.wishlistCities });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};
export const removeWishlistCity = async (req, res) => {
  const { cityId } = req.params;
  try {
    const user = await User.findOneAndUpdate(
      { googleId: req.user.googleId },
      { $pull: { wishlistCities: cityId } },
      { new: true }
    ).populate('wishlistCities');
    res.json({ success: true, wishlistCities: user.wishlistCities });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

export const addFavoriteCity = async (req, res) => {
  const { cityId } = req.body;
  
  try {
    const user = await User.findOneAndUpdate(
      { googleId: req.user.googleId },
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
      { googleId: req.user.googleId },
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
      { googleId: req.user.googleId },
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
      { googleId: req.user.googleId },
      { $pull: { deletedCities: cityId } },
      { new: true }
    );
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

