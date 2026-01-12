import 'package:flutter/material.dart';
import 'package:frontend/models/review.dart';

class ReviewCard extends StatelessWidget {
  final CityReview review;
  final bool canDelete;
  final VoidCallback? onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    this.canDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_city,
                  size: 18,
                  color: Colors.blue,
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
                          review.city ?? 'Unknown city',
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
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 16,
                      children: [
                        _ReviewRating(
                          icon: Icons.star,
                          color: Colors.amber.shade600,
                          value: review.impression,
                        ),
                        _ReviewRating(
                          icon: Icons.people,
                          color: Colors.cyan.shade600,
                          value: review.people,
                        ),
                        _ReviewRating(
                          icon: Icons.account_balance,
                          color: Colors.deepPurpleAccent,
                          value: review.sights,
                        ),
                        _ReviewRating(
                          icon: Icons.shield,
                          color: Colors.green.shade600,
                          value: review.safety,
                        ),
                        _ReviewRating(
                          icon: Icons.attach_money,
                          color: Colors.orange.shade600,
                          value: review.affordability,
                        ),
                      ],
                    ),
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
              if (canDelete)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}.";
  }
}

class _ReviewRating extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int value;

  const _ReviewRating({
    required this.icon,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}