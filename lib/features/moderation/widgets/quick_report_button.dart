import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/moderation_service.dart';
import '../../../utils/Utilities.dart';
import '../screens/report_content_screen.dart';

class QuickReportButton extends StatelessWidget {
  final String contentType;
  final String contentId;
  final String contentTitle;

  const QuickReportButton({
    Key? key,
    required this.contentType,
    required this.contentId,
    required this.contentTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showReportOptions(context),
      icon: const Icon(Icons.flag, color: Colors.orange),
      tooltip: 'Report this $contentType',
    );
  }

  void _showReportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Report $contentTitle',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.report, color: Colors.red),
                  title: const Text('Report this content'),
                  subtitle: const Text(
                    'Report inappropriate or harmful content',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(
                      () => ReportContentScreen(
                        initialContentType: contentType,
                        initialContentId: contentId,
                        initialContentTitle: contentTitle,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description, color: Colors.blue),
                  title: const Text('Quick report - Spam'),
                  subtitle: const Text('Report as spam content'),
                  onTap: () => _quickReport(context, 'spam'),
                ),
                ListTile(
                  leading: const Icon(Icons.warning, color: Colors.orange),
                  title: const Text('Quick report - Inappropriate'),
                  subtitle: const Text('Report as inappropriate content'),
                  onTap: () => _quickReport(context, 'inappropriate'),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _quickReport(BuildContext context, String reason) async {
    Navigator.pop(context);
    Utils.showLoader(false);

    try {
      final result = await ModerationService.reportContent(
        contentType: contentType,
        contentId: contentId,
        reason: reason,
        description: 'Quick report: $reason',
      );

      Utils.hideLoader();

      if (result['code'] == 1) {
        Utils.toast('Content reported successfully');
      } else {
        Utils.toast(
          result['message'] ?? 'Failed to report content',
          color: Colors.red,
        );
      }
    } catch (e) {
      Utils.hideLoader();
      Utils.toast(
        'Failed to report content: ${e.toString()}',
        color: Colors.red,
      );
    }
  }
}
