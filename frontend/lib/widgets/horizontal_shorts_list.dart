import 'package:flutter/material.dart';
import 'package:frontend/models/city_short_videos.dart';
import 'package:frontend/services/city_shorts_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HorizontalShortsList extends StatefulWidget {
  final String cityId;

  const HorizontalShortsList({super.key, required this.cityId});

  @override
  State<HorizontalShortsList> createState() => _HorizontalShortsListState();
}

class _HorizontalShortsListState extends State<HorizontalShortsList> {
  final CityShortsService _shortsService = CityShortsService();
  late Future<List<CityShortVideos>> _shortsFuture;

  @override
  void initState() {
    super.initState();
    _shortsFuture = _shortsService.fetchTopShortVideos(widget.cityId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('City Shorts & Reels',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color.fromARGB(255, 0, 96, 175))),
        SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: FutureBuilder<List<CityShortVideos>>(
            future: _shortsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No videos found.'));
              }

              final videos = snapshot.data!;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  if (video.thumbnail.startsWith("https://serpapi.com")) {return const SizedBox.shrink();}

                  return GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse(video.link);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      width: 180,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              video.thumbnail,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.65),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              right: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    video.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    video.source,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
