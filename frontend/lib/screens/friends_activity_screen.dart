import 'package:flutter/material.dart';
import 'package:frontend/models/review.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/screens/other_user_profile_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/review_card.dart';
import 'package:provider/provider.dart';

class FriendsActivityScreen extends StatelessWidget {
  const FriendsActivityScreen({super.key});

  Future<List<CityReview>> fetchFriendsActivity(String userId) async {
    final res = await Api.getRequest('/recommendations/friends/$userId');

    final List<dynamic> data = res['data'];

    return data.map((item) {
      final Map<String, dynamic> flat = {
        '_id': item['review']['_id'] ?? '',
        'city': item['city']['city'],
        'userId': item['reviewer']['_id'],
        'name': item['reviewer']['name'],
        'picture': item['reviewer']['picture'],
        'impression': item['review']['impression'],
        'people': item['review']['people'],
        'sights': item['review']['sights'],
        'safety': item['review']['safety'],
        'affordability': item['review']['affordability'],
        'comments': item['review']['comments'] ?? '',
        'createdAt': item['review']['createdAt'],
        'cityImage': item['city']['imageUrl'],
      };

      return CityReview.fromJson(flat);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final userId = userProvider.currentUserId;

    if (userId == null) {
      return const Center(child: Text("User not loaded"));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Friends Activity")),
      body: FutureBuilder<List<CityReview>>(
        future: fetchFriendsActivity(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reviews = snapshot.data!;

          if (reviews.isEmpty) {
            return const Center(child: Text("No friends activity yet"));
          }

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return reviewCard(context, reviews[index]);
            },
          );
        },
      ),
    );
  }

  Widget reviewCard(BuildContext context, CityReview review) {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;
    final currentUserId = userProvider.currentUserId;

    return Center(
      child: SizedBox(
        width: 700,
        child: Container(
          margin: EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (review.cityImage != null)
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          Api.getProxyImageUrl(review.cityImage!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),

                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          review.city ?? 'Unknown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          if ( review.userId != currentUserId) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OtherUserProfileScreen(
                                  userId: review.userId!,
                                ),
                              ),
                            );
                          } 
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blue.shade100,
                          backgroundImage: review.userPicture != null
                              ? NetworkImage(
                                  Api.getProxyImageUrl(review.userPicture!),
                                )
                              : null,
                          child: review.userPicture == null
                              ? const Icon(
                                  Icons.person,
                                  size: 18,
                                  color: Colors.blue,
                                )
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                review.userName ?? 'Anonymous',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(review.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Spacer(),
                              Wrap(
                                spacing: 16,
                                children: [
                                  _iconValue(
                                    Icons.star,
                                    Colors.amber.shade600,
                                    review.impression,
                                  ),
                                  _iconValue(
                                    Icons.people,
                                    Colors.cyan.shade600,
                                    review.people,
                                  ),
                                  _iconValue(
                                    Icons.attractions,
                                    Colors.deepPurpleAccent,
                                    review.sights,
                                  ),
                                  _iconValue(
                                    Icons.security,
                                    Colors.green.shade600,
                                    review.safety,
                                  ),
                                  _iconValue(
                                    Icons.attach_money,
                                    Colors.orange.shade600,
                                    review.affordability,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          if (review.comments.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              review.comments,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconValue(IconData icon, Color color, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}.";
  }
}
