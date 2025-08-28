import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

import '../features/moderation/widgets/moderation_widgets.dart';

/// Example of how to integrate moderation features into content screens
/// This shows how to add reporting and blocking capabilities to any content
class ExampleContentIntegration extends StatelessWidget {
  final String movieId;
  final String movieTitle;
  final String userId;
  final String userName;

  const ExampleContentIntegration({
    Key? key,
    required this.movieId,
    required this.movieTitle,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movieTitle),
        actions: [
          // Add report button to app bar
          QuickReportButton(
            contentType: 'movie',
            contentId: movieId,
            contentTitle: movieTitle,
            iconColor: Colors.white,
          ),
          // Add options menu with moderation options
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'report':
                  // The QuickReportButton handles this
                  break;
                case 'block_user':
                  QuickBlockUserDialog.show(
                    context: context,
                    userId: userId,
                    userName: userName,
                  );
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag, size: 18),
                        SizedBox(width: 8),
                        Text('Report Content'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'block_user',
                    child: Row(
                      children: [
                        Icon(Icons.block, size: 18),
                        SizedBox(width: 8),
                        Text('Block User'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Example of content moderation banner
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ContentModerationBanner(
              message:
                  'This content has been reviewed and approved for viewing.',
              icon: Icons.verified,
              backgroundColor: Colors.green,
            ),
          ),

          // Main content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie title and info
                  FxText.titleLarge(movieTitle),
                  const SizedBox(height: 8),
                  FxText.bodyMedium('Uploaded by: $userName'),
                  const SizedBox(height: 16),

                  // Content area
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Text('Movie Content Here')),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom action bar with moderation options
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Play movie logic
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Report button
                      QuickReportButton(
                        contentType: 'movie',
                        contentId: movieId,
                        contentTitle: movieTitle,
                        showLabel: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Integration example for comment sections
class ExampleCommentWithModeration extends StatelessWidget {
  final String commentId;
  final String commentText;
  final String authorId;
  final String authorName;

  const ExampleCommentWithModeration({
    Key? key,
    required this.commentId,
    required this.commentText,
    required this.authorId,
    required this.authorName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comment header with author info and moderation actions
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(authorName[0].toUpperCase()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.bodyMedium(authorName, fontWeight: 600),
                      FxText.bodySmall('2 hours ago', color: Colors.grey[600]),
                    ],
                  ),
                ),
                // Moderation actions dropdown
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
                  onSelected: (value) {
                    switch (value) {
                      case 'report':
                        // Report comment
                        break;
                      case 'block':
                        QuickBlockUserDialog.show(
                          context: context,
                          userId: authorId,
                          userName: authorName,
                        );
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: [
                              Icon(Icons.flag, size: 16),
                              SizedBox(width: 8),
                              Text('Report'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'block',
                          child: Row(
                            children: [
                              Icon(Icons.block, size: 16),
                              SizedBox(width: 8),
                              Text('Block User'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Comment text
            FxText.bodyMedium(commentText),

            const SizedBox(height: 8),

            // Comment actions with quick report
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.thumb_up, size: 16),
                  label: const Text('Like'),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.reply, size: 16),
                  label: const Text('Reply'),
                ),
                const Spacer(),
                QuickReportButton(
                  contentType: 'comment',
                  contentId: commentId,
                  contentTitle: 'Comment by $authorName',
                  iconSize: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
