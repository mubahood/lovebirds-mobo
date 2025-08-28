import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';

import '../../../utils/CustomTheme.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: FxText.titleLarge('How It Works', color: Colors.white),
        backgroundColor: CustomTheme.primary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: CustomTheme.primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      backgroundColor: CustomTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Card(
              color: Colors.blue[50],
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.play_circle_filled,
                      color: Colors.blue[700],
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    FxText.titleLarge(
                      'Welcome to UGFlix',
                      fontWeight: 700,
                      color: Colors.blue[800],
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FxText.bodyMedium(
                      'Your gateway to the best Ugandan movies and entertainment, translated into local languages.',
                      color: Colors.blue[700],
                      textAlign: TextAlign.center,
                      height: 1.5,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // How to Use Steps
            _buildStepCard(
              step: '1',
              title: 'Browse & Discover',
              description:
                  'Explore our vast collection of Ugandan movies, series, and documentaries. Use search and filters to find content you love.',
              icon: Icons.explore,
              color: Colors.green,
            ),

            _buildStepCard(
              step: '2',
              title: 'Watch & Download',
              description:
                  'Stream movies instantly or download them for offline viewing. Enjoy high-quality content anytime, anywhere.',
              icon: Icons.download_for_offline,
              color: Colors.purple,
            ),

            _buildStepCard(
              step: '3',
              title: 'Language Options',
              description:
                  'Choose from multiple local language translations. Experience content in Luganda, English, and other local languages.',
              icon: Icons.translate,
              color: Colors.orange,
            ),

            _buildStepCard(
              step: '4',
              title: 'Safe Community',
              description:
                  'Report inappropriate content, block users, and enjoy a safe viewing environment with our moderation tools.',
              icon: Icons.security,
              color: Colors.red,
            ),

            const SizedBox(height: 24),

            // Features Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FxText.titleMedium(
                      'Key Features',
                      fontWeight: 700,
                      color: CustomTheme.primary,
                    ),
                    const SizedBox(height: 16),

                    _buildFeatureItem(
                      icon: Icons.hd,
                      title: 'High Quality Streaming',
                      description:
                          'Crystal clear video quality with adaptive streaming.',
                    ),

                    _buildFeatureItem(
                      icon: Icons.download,
                      title: 'Offline Downloads',
                      description:
                          'Download movies to watch without internet connection.',
                    ),

                    _buildFeatureItem(
                      icon: Icons.language,
                      title: 'Multi-Language Support',
                      description:
                          'Content available in multiple local languages.',
                    ),

                    _buildFeatureItem(
                      icon: Icons.family_restroom,
                      title: 'Family Friendly',
                      description:
                          'Safe content with parental controls and moderation.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tips Section
            Card(
              color: Colors.amber[50],
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Colors.amber[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        FxText.titleMedium(
                          'Tips for Best Experience',
                          fontWeight: 700,
                          color: Colors.amber[800],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    FxText.bodySmall(
                      '• Create a complete profile for personalized recommendations\n'
                      '• Download content on WiFi to save data\n'
                      '• Use the search feature to find specific movies or actors\n'
                      '• Report any inappropriate content to keep the community safe\n'
                      '• Check your downloads section for offline content\n'
                      '• Update the app regularly for new features and content',
                      color: Colors.amber[700],
                      height: 1.8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String step,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: FxText.titleMedium(step, fontWeight: 700, color: color),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FxText.titleSmall(
                          title,
                          fontWeight: 700,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FxText.bodySmall(
                    description,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CustomTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: CustomTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.bodyMedium(
                  title,
                  fontWeight: 600,
                  color: Colors.grey[800],
                ),
                const SizedBox(height: 4),
                FxText.bodySmall(
                  description,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
