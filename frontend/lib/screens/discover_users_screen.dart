import 'package:flutter/material.dart';
import 'package:frontend/providers/social_provider.dart';
import 'package:frontend/screens/other_user_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/api_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger loading users once when the screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SocialProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SocialProvider>();
    if (provider.isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
