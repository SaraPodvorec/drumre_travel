import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in_web/web_only.dart' as web;
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 96, 175),
      body: Center(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isAuthenticated) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/home');
                }
              });
            }

            return Center(
              child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                  'Welcome to Traveler',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                  'Discover amazing activities around the world!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                  ),
                  const Text(
                  'Sign in to start exploring.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                  ),
                  const SizedBox(height: 16),
                  if (authProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                    authProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                  width: 300,
                  height: 50,
                  child: web.renderButton(),
                  ),
                ],
                ),
              ),
              ),
            );
          },
        ),
      ),
    );
  }
}