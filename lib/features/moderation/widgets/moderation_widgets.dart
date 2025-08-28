import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/report_content_screen.dart';

/// A quick-access widget for reporting content
/// Use this widget to add report functionality to any content item
class QuickReportButton extends StatelessWidget {
  final String contentType;
  final String contentId;
  final String? contentTitle;
  final bool showLabel;
  final Color? iconColor;
  final double? iconSize;

  const QuickReportButton({
    Key? key,
    required this.contentType,
    required this.contentId,
    this.contentTitle,
    this.showLabel = false,
    this.iconColor,
    this.iconSize = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(
          () => const ReportContentScreen(),
          arguments: {
            'content_type': contentType,
            'content_id': contentId,
            'content_title': contentTitle,
          },
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            showLabel
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag,
                      size: iconSize,
                      color: iconColor ?? Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Report',
                      style: TextStyle(
                        color: iconColor ?? Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
                : Icon(
                  Icons.flag,
                  size: iconSize,
                  color: iconColor ?? Colors.grey[600],
                ),
      ),
    );
  }
}

/// A dialog for quick user blocking
class QuickBlockUserDialog {
  static Future<void> show({
    required BuildContext context,
    required String userId,
    required String userName,
  }) async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block $userName?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              // Navigate to blocked users screen to handle the blocking
              Get.toNamed(
                '/moderation',
                arguments: {
                  'action': 'block_user',
                  'user_id': userId,
                  'user_name': userName,
                },
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}

/// A banner that can be shown when content has been filtered or flagged
class ContentModerationBanner extends StatelessWidget {
  final String message;
  final Color? backgroundColor;
  final IconData? icon;
  final VoidCallback? onTap;

  const ContentModerationBanner({
    Key? key,
    required this.message,
    this.backgroundColor,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.orange[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: backgroundColor?.withValues(alpha: 0.3) ?? Colors.orange[300]!,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              icon ?? Icons.info_outline,
              size: 20,
              color:
                  backgroundColor != null ? Colors.white : Colors.orange[800],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color:
                      backgroundColor != null
                          ? Colors.white
                          : Colors.orange[800],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color:
                    backgroundColor != null ? Colors.white : Colors.orange[800],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
