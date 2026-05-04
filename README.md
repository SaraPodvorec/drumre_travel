# Drumre Travel

`Drumre Travel` is a full-stack travel application for discovering cities, exploring activities and top sights, sharing impressions, and receiving personalized recommendations based on user preferences and friends' activity.

The project is divided into:

- `frontend` - Flutter web/mobile application
- `backend` - Node.js + Express API
- `db_export` - exported JSON data for initial database content

## Main Features

- Google sign-in and session handling with JWT cookies
- user onboarding and preference storage
- browsing top cities
- searching for new cities and saving them dynamically to the database
- city details with weather data, descriptions, images, and additional content
- activities and top sights for each city
- leaving reviews and impressions for cities
- city recommendations based on user preferences and friends' reviews
- social features such as friends activity feed and user discovery
- basic accessibility settings, including text scaling and `OpenDyslexic` font

## Technologies

### Frontend

- Flutter
- Provider
- `http`
- `google_sign_in`
- `shared_preferences`

### Backend

- Node.js
- Express
- MongoDB + Mongoose
- JWT autentikacija
- JWT authentication
- Google Auth Library

### External Services

- Google Sign-In
- Geoapify
- Unsplash
- OpenWeather
- SerpAPI
- Amadeus
- REST Countries
- CountriesNow

## Project Structure

```text
drumre_travel/
|- backend/
|  |- config/
|  |- controllers/
|  |- middleware/
|  |- models/
|  |- routes/
|  |- services/
|  |- seed/
|- frontend/
|  |- lib/
|  |  |- models/
|  |  |- providers/
|  |  |- screens/
|  |  |- services/
|  |  |- widgets/
|- db_export/
|- README.md
```

## Running the Project Locally

### 1. Backend

Install dependencies inside the `backend` folder:

```bash
npm install
```

Create a `.env` file inside `backend/` with the following variables:

```env
PORT=3000
FRONTEND_URL=http://localhost:4000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
GOOGLE_CLIENT_ID=your_google_client_id
GEOAPIFY_KEY=your_geoapify_key
UNSPLASH_KEY=your_unsplash_key
OPEN_WEATHER_API_KEY=your_openweather_key
SERPAPI_KEY=your_serpapi_key
AMADEUS_KEY=your_amadeus_key
AMADEUS_SECRET=your_amadeus_secret
```

Start the backend server:

```bash
npm run dev
```

or

```bash
npm start
```

The backend runs on:

```text
http://localhost:3000
```

### 2. Frontend

Install Flutter packages inside the `frontend` folder:

```bash
flutter pub get
```

Run the web version:

```bash
flutter run -d web-server --web-port 4000
```

The frontend expects the backend at:

```text
http://localhost:3000/api
```

## Seed Data

The backend includes seed scripts:

```bash
npm run seed_cities
npm run seed_activities
```

JSON exports are stored in the `db_export/` folder.

## Main API Endpoints

- `/api/auth` - Google login, session, and logout
- `/api/cities` - city list, search, and filters
- `/api/activities` - city activities
- `/api/topSights` - top sights
- `/api/review` - reviews and aggregate review data
- `/api/user` - user profile, wishlist, favorites, and social data
- `/api/cityShorts` - short-form city video content
- `/api/recommendations` - personalized recommendations and friends activity
- `/api/weather/:cityName` - current city weather

## How the Application Works

Users sign in with their Google account, complete onboarding, and define their preferences. After that, they can browse cities, search for new destinations, save favorites, leave impressions, and follow other users' activity. The backend combines database content with external APIs to enrich city data and calculate recommendations.

## Notes

- `frontend/lib/services/api_service.dart` currently uses a hardcoded `http://localhost:3000/api`
- backend CORS is configured through `FRONTEND_URL`
- the project currently does not include automated backend tests

## Possible Future Improvements

- Docker setup for the full project
- production-ready cookie and authentication configuration
- better test coverage for frontend and backend
- deployment documentation
