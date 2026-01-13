import 'package:flutter/material.dart';
import 'package:frontend/screens/discover_users_screen.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/profile_screen.dart';
import '../services/api_service.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  const MainAppBar({super.key, this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return AppBar(
      title: Text(title ?? ''),
      actions: [
        if (authProvider.isAuthenticated && authProvider.userData != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/discover-users');
                    },
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 2),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 2.5, 
                          ),
                        ),
                      ),
                      child: const Text(
                        'Discover users',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/leave-review');
                    },
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 2),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 2.5, 
                          ),
                        ),
                      ),
                      child: const Text(
                        'Leave review',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (authProvider.userData!['picture'] != null)
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        Api.getProxyImageUrl(authProvider.userData!['picture']),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Text(
                    authProvider.userData!['name'] ?? 'User',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  PopupMenuButton(
                    child: const Icon(Icons.more_vert, color: Colors.white),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Profile'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Logout'),
                        onTap: () async {
                          await authProvider.signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushReplacementNamed('/');
                          }
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Settings'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AccessibilitySettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
