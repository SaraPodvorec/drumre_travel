import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/providers/accessibility_provider.dart';
import 'package:frontend/providers/social_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/screens/city_activities_screen.dart';
import 'package:frontend/screens/discover_users_screen.dart';
import 'package:frontend/screens/friends_activity_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/leave_review_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/onboarding_screen.dart';
import 'package:frontend/screens/city_details_screen.dart';
import 'package:frontend/screens/recommended_cities_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/city_provider.dart';
import 'providers/activity_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CityProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SocialProvider()),
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 0, 96, 175);
    const backgroundColor = Color.fromARGB(255, 250, 253, 255);
    const textColor = Color(0xFF212121);

    final ThemeData theme = ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textColor),
        bodyMedium: TextStyle(fontSize: 14, color: textColor),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
    );

    return Consumer<AccessibilityProvider>(
      builder: (context, accessibility, _) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(accessibility.textScale)),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Traveler",
            theme: theme.copyWith(
              textTheme: theme.textTheme.apply(
                fontFamily: accessibility.fontFamily,
              ),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthWrapper(),
              '/login': (context) => const LoginScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/home': (context) => const HomeScreen(),
              '/city-details': (context) {
                final selectedCity = context.watch<CityProvider>().selectedCity;
                if (selectedCity != null) {
                  return CityDetailsScreen(city: selectedCity);
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
              '/city-activities': (context) {
                final selectedCity = context.watch<CityProvider>().selectedCity;
                if (selectedCity != null) {
                  return CityActivitiesScreen(city: selectedCity);
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
              '/leave-review': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                final initialCity = args is String ? args : null;
                return LeaveReviewScreen(initialCityName: initialCity);
              },
              '/discover-users': (context) => const UsersScreen(),
              // '/recommended-cities': (context) => RecommendedCitiesScreen(),
              '/friends-activity': (context) => FriendsActivityScreen()
            },
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final authProvider = context.read<AuthProvider>();
    await context.read<AccessibilityProvider>().loadPreferences();

    await authProvider.initialize();

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();

    if (_loading) {
      log('AuthWrapper: Loading...');
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!authProvider.isAuthenticated) {
      log('AuthWrapper: User not authenticated, navigating to LoginScreen');
      return const LoginScreen();
    }

    // ensure user data is loaded
    if (!userProvider.isInitialized) {
      if (!userProvider.isLoading) {
        log('AuthWrapper: User authenticated, scheduling user data load');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final userProv = context.read<UserProvider>();
          if (!userProv.isInitialized && !userProv.isLoading) {
            userProv.loadUserData();
          }
        });
      }

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!userProvider.onboardingCompleted) {
      log(
        'AuthWrapper: Onboarding not completed, navigating to OnboardingScreen',
      );
      return const OnboardingScreen();
    }

    log(
      'AuthWrapper: User authenticated and onboarding completed, navigating to HomeScreen',
    );
    return const HomeScreen();
  }
}
