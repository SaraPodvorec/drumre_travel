import 'package:flutter/material.dart';
import 'package:frontend/providers/social_provider.dart';
import 'package:frontend/screens/other_user_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/api_service.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SocialProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: ListView.builder(
        itemCount: provider.users.length,
        itemBuilder: (context, index) {
          final user = provider.users[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: (user.picture.isNotEmpty)
                  ? NetworkImage(Api.getProxyImageUrl(user.picture))
                  : null,
              child: (user.picture.isEmpty) ? const Icon(Icons.person) : null,
            ),
            title: Text(user.name),
            subtitle: Text(user.email),
            trailing: ElevatedButton(
              onPressed: () => provider.toggleFollow(user),
              style: ElevatedButton.styleFrom(
                backgroundColor: user.isFollowing ? Colors.grey : Colors.blue,
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
      ),
    );
  }
}
