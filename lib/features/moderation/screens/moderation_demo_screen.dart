import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../services/moderation_service.dart';
import '../../../utils/CustomTheme.dart';
import '../../../utils/Utilities.dart';
import '../widgets/quick_block_button.dart';
import '../widgets/quick_report_button.dart';
import 'report_content_screen.dart';

class ModerationDemoScreen extends StatefulWidget {
  const ModerationDemoScreen({Key? key}) : super(key: key);

  @override
  State<ModerationDemoScreen> createState() => _ModerationDemoScreenState();
}

class _ModerationDemoScreenState extends State<ModerationDemoScreen> {
  bool _isLoading = false;

  // Demo data
  final List<Map<String, dynamic>> _demoMovies = [
    {
      'id': '1',
      'title': 'Sample Movie 1',
      'description': 'This is a sample movie for testing moderation features.',
      'poster':
          'https://freedesignfile.com/upload/2018/02/Film-sample-background-vector.jpg',
    },
    {
      'id': '2',
      'title': 'Sample Movie 2',
      'description': 'Another sample movie to demonstrate content reporting.',
      'poster': 'https://thumbs.dreamstime.com/b/film-background-10772201.jpg',
    },
  ];

  final List<Map<String, dynamic>> _demoUsers = [
    {
      'id': '101',
      'name': 'Demo User 1',
      'email': 'demo1@example.com',
      'avatar':
          'https://cdn.pixabay.com/photo/2023/02/18/11/00/icon-7797704_640.png',
    },
    {
      'id': '102',
      'name': 'Demo User 2',
      'email': 'demo2@example.com',
      'avatar':
          'https://cdn.pixabay.com/photo/2023/02/18/11/00/icon-7797704_640.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: FxText.titleLarge('Moderation Demo', color: Colors.white),
        backgroundColor: CustomTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info section
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        FxText.titleMedium('Demo Mode', fontWeight: 600),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FxText.bodyMedium(
                      'This screen demonstrates moderation features with sample data. You can test reporting content and blocking users.',
                      color: Colors.grey[700],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick actions
            FxText.titleLarge('Quick Actions', fontWeight: 600),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(
                        () => const ReportContentScreen(
                          initialContentType: 'movie',
                          initialContentId: 'demo_movie_1',
                          initialContentTitle: 'Demo Movie',
                        ),
                      );
                    },
                    icon: const Icon(Icons.report),
                    label: const Text('Report Content'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testModerationAPI,
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.api),
                    label: const Text('Test API'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Demo Movies Section
            FxText.titleLarge('Demo Movies', fontWeight: 600),
            const SizedBox(height: 16),
            ..._demoMovies.map((movie) => _buildMovieCard(movie)),
            const SizedBox(height: 32),

            // Demo Users Section
            FxText.titleLarge('Demo Users', fontWeight: 600),
            const SizedBox(height: 16),
            ..._demoUsers.map((user) => _buildUserCard(user)),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> movie) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                movie['poster'],
                width: 60,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      width: 60,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.movie),
                    ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FxText.titleMedium(movie['title'], fontWeight: 600),
                  const SizedBox(height: 4),
                  FxText.bodySmall(
                    movie['description'],
                    color: Colors.grey[600],
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            QuickReportButton(
              contentType: 'movie',
              contentId: movie['id'],
              contentTitle: movie['title'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(user['avatar']),
              onBackgroundImageError: (error, stackTrace) {},
              child:
                  user['avatar'].toString().isEmpty
                      ? Text(user['name'][0].toUpperCase())
                      : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FxText.titleMedium(user['name'], fontWeight: 600),
                  const SizedBox(height: 4),
                  FxText.bodySmall(user['email'], color: Colors.grey[600]),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                QuickReportButton(
                  contentType: 'user',
                  contentId: user['id'],
                  contentTitle: user['name'],
                ),
                const SizedBox(width: 8),
                QuickBlockButton(userId: user['id'], userName: user['name']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testModerationAPI() async {
    setState(() => _isLoading = true);

    try {
      // Test filter content endpoint (non-authenticated)
      final filterResult = await ModerationService.filterContent(
        'This is a test message',
      );
      Utils.toast('API Test: ${filterResult['message'] ?? 'Success'}');
    } catch (e) {
      Utils.toast('API Test failed: ${e.toString()}', color: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
