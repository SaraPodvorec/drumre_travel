import 'package:flutter/material.dart';
import 'package:frontend/providers/social_provider.dart';
import 'package:frontend/screens/other_user_profile_screen.dart';
import 'package:provider/provider.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SocialProvider()..loadUsers(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Users')),
        body: Consumer<SocialProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text(provider.error!));
            }

            return ListView.builder(
              itemCount: provider.users.length,
              itemBuilder: (context, index) {
                final user = provider.users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (user.picture.isNotEmpty)
                        ? NetworkImage(user.picture)
                        : null,
                    child: (user.picture.isEmpty)
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: ElevatedButton(
                    onPressed: () => provider.toggleFollow(user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user.isFollowing
                          ? Colors.grey
                          : Colors.blue,
                    ),
                    child: Text(user.isFollowing ? 'Unfollow' : 'Follow'),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OtherUserProfileScreen(userId: user.id),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
