import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../utils/CustomTheme.dart';

class UpgradePromptDialog extends StatelessWidget {
  final String title;
  final String message;
  final List<String> features;

  const UpgradePromptDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.features,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: CustomTheme.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: CustomTheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Premium badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [CustomTheme.primary, CustomTheme.primaryDark],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  FxText.bodyMedium(
                    'Premium',
                    color: Colors.white,
                    fontWeight: 600,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Title
            FxText.titleLarge(
              title,
              color: Colors.white,
              fontWeight: 700,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12),

            // Message
            FxText.bodyMedium(
              message,
              color: Colors.white70,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 20),

            // Features list
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CustomTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CustomTheme.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                children:
                    features
                        .map((feature) => _buildFeatureItem(feature))
                        .toList(),
              ),
            ),

            SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: FxText.bodyMedium(
                      'Not Now',
                      color: Colors.grey,
                      fontWeight: 600,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to subscription screen - implement later
                      Get.snackbar(
                        'Premium',
                        'Subscription screen coming soon!',
                        backgroundColor: CustomTheme.primary.withValues(alpha: 0.9),
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomTheme.primary,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: FxText.bodyMedium(
                      'Upgrade Now',
                      color: Colors.white,
                      fontWeight: 600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: CustomTheme.primary, size: 20),
          SizedBox(width: 12),
          Expanded(child: FxText.bodyMedium(feature, color: Colors.white)),
        ],
      ),
    );
  }
}
