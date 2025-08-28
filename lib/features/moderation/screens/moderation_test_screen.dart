import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/CustomTheme.dart';
import '../widgets/moderation_action_buttons.dart';

class ModerationTestScreen extends StatelessWidget {
  const ModerationTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderation Features Test'),
        backgroundColor: CustomTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Moderation Action Buttons',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Test Movie Content Card with moderation buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.movie, size: 40),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sample Movie Title',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Uploaded by: TestUser123',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        // Clear moderation buttons (not hidden)
                        ModerationActionButtons(
                          contentType: 'movie',
                          contentId: '1',
                          contentTitle: 'Sample Movie Title',
                          userId: '2',
                          userName: 'TestUser123',
                          compact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This is a sample movie card showing how moderation buttons appear clearly visible to users.',
                    ),
                    const SizedBox(height: 12),
                    // Full-size moderation buttons
                    ModerationActionButtons(
                      contentType: 'movie',
                      contentId: '1',
                      contentTitle: 'Sample Movie Title',
                      userId: '2',
                      userName: 'TestUser123',
                      compact: false,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Test User Profile Card with moderation buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.person),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TestUser123',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Member since 2024',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        // User-specific moderation (only block option)
                        ModerationActionButtons(
                          userId: '2',
                          userName: 'TestUser123',
                          showReportButton: false,
                          showBlockButton: true,
                          compact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'User profile with block user functionality clearly visible.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Test Comment with moderation buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.person, size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'TestCommenter',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        ModerationActionButtons(
                          contentType: 'comment',
                          contentId: '3',
                          contentTitle: 'User Comment',
                          userId: '3',
                          userName: 'TestCommenter',
                          compact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This is a sample comment that users can report or block the commenter. The moderation options are clearly visible.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Test Quick Report and Block Buttons
            const Text(
              'Quick Action Buttons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                QuickReportButton(
                  contentType: 'movie',
                  contentId: '1',
                  contentTitle: 'Sample Movie',
                  showLabel: true,
                ),
                QuickBlockButton(
                  userId: '2',
                  userName: 'TestUser',
                  showLabel: true,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Test Content Moderation Banner
            const Text(
              'Content Status Banners',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const ContentModerationBanner(
              message: 'This content has been reviewed and approved.',
              icon: Icons.verified,
              backgroundColor: Colors.green,
            ),
            const SizedBox(height: 8),
            const ContentModerationBanner(
              message: 'This content is under moderation review.',
              icon: Icons.hourglass_empty,
              backgroundColor: Colors.orange,
            ),
            const SizedBox(height: 8),
            ContentModerationBanner(
              message: 'This content has been flagged. Click for details.',
              icon: Icons.warning,
              backgroundColor: Colors.red[600]!,
              onTap: () {
                Get.snackbar('Info', 'Content details would be shown here');
              },
            ),
            const SizedBox(height: 20),

            // Navigation buttons to other moderation screens
            const Text(
              'Moderation Screens',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/moderation/my-reports'),
                  icon: const Icon(Icons.history),
                  label: const Text('My Reports'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/moderation/blocked-users'),
                  icon: const Icon(Icons.block),
                  label: const Text('Blocked Users'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/moderation/report-content'),
                  icon: const Icon(Icons.flag),
                  label: const Text('Report Content'),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: ModerationFloatingMenu(
        contentType: 'movie',
        contentId: '1',
        contentTitle: 'Sample Movie',
        userId: '2',
        userName: 'TestUser',
      ),
    );
  }
}
