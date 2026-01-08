// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/browser_client.dart' as browser;

class AuthProvider extends ChangeNotifier {
  GoogleSignInAccount? _currentUser;
  Map<String, dynamic>? _userData; 
  final bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthorized = false;
  bool _isInitialized = false;

  
  GoogleSignInAccount? get currentUser => _currentUser;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _userData != null;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      unawaited(
        googleSignIn.initialize().then((_) async {
          // check if user has an active session on backend
          await _checkSession();
          
          // listen for authentication events
          googleSignIn.authenticationEvents
              .listen(_handleAuthenticationEvent);
          
          _isInitialized = true;
          notifyListeners();
        }),
      );
    } catch (error) {
      print('Error initializing Google Sign-In: $error');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _checkSession() async {
    try {
      final client = browser.BrowserClient()..withCredentials = true;
      final res = await client.get(
        Uri.parse('http://localhost:3000/api/auth/session'),
      );
      client.close();

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['authenticated'] == true) {
          print('Session found');
          _isAuthorized = true;
          // user data from backend
          _userData = data['user'];
          print('User data from session: $_userData');
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error checking session: $e');
    }
  }

  Future<void> _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    _currentUser = user;
    notifyListeners();

    if (user != null) {
      try {
        final auth = user.authentication;
        final idToken = auth.idToken;

        if (idToken != null && idToken.isNotEmpty) {
          final client = browser.BrowserClient()..withCredentials = true;
          final res = await client.post(
            Uri.parse('http://localhost:3000/api/auth/google'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': idToken}),
          );
          client.close();

          if (res.statusCode == 200) {
            final responseData = jsonDecode(res.body);
            _userData = responseData['user'];
            _errorMessage = null;
            _isAuthorized = true;
            print('Backend auth OK');
          } else {
            _errorMessage = 'Backend rejected token';
            _isAuthorized = false;
            _userData = null;
            _currentUser = null;
            print('Backend rejected idToken: ${res.statusCode} ${res.body}');
          }
        }
      } catch (e, st) {
        _errorMessage = 'Error sending idToken to backend: $e';
        _userData = null;
        _currentUser = null;
        print('Error sending idToken to backend: $e\n$st');
      }
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.disconnect();
      
      // call backend logout endpoint to clear session
      final client = browser.BrowserClient()..withCredentials = true;
      await client.post(
        Uri.parse('http://localhost:3000/api/auth/logout'),
      );
      client.close();
      
      _currentUser = null;
      _userData = null;
      _errorMessage = null;
      _isAuthorized = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Sign out failed: $error';
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    // Wait until _initializeGoogleSignIn completes
    if (_isInitialized) return;

    final completer = Completer<void>();

    void listener() {
      if (_isInitialized) {
        completer.complete();
        removeListener(listener);
      }
    }

    addListener(listener);
    await completer.future;
  }
}