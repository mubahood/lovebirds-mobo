import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/CustomTheme.dart';
import '../../../widgets/common/responsive_dialog_wrapper.dart';

class ReportContentDialog extends StatefulWidget {
  final String contentType; // 'Movie', 'Comment', 'User', etc.
  final String contentPreview; // Brief preview of the content
  final String contentId; // ID of the content being reported
  final String reportedUserId; // ID of the user who created the content

  const ReportContentDialog({
    Key? key,
    required this.contentType,
    required this.contentPreview,
    required this.contentId,
    required this.reportedUserId,
  }) : super(key: key);

  @override
  State<ReportContentDialog> createState() => _ReportContentDialogState();
}

class _ReportContentDialogState extends State<ReportContentDialog> {
  String? selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  // Report categories for dating app context
  final List<Map<String, dynamic>> reportReasons = [
    {
      'id': 'fake_profile',
      'title': 'Fake Profile',
      'description': 'Using fake photos or false identity',
      'icon': Icons.person_off,
      'color': Colors.red,
    },
    {
      'id': 'inappropriate_photos',
      'title': 'Inappropriate Photos',
      'description': 'Nude, sexual, or offensive images',
      'icon': Icons.photo_camera_back,
      'color': Colors.orange,
    },
    {
      'id': 'harassment',
      'title': 'Harassment',
      'description': 'Unwanted messages, threats, or stalking behavior',
      'icon': Icons.warning,
      'color': Colors.red,
    },
    {
      'id': 'catfishing',
      'title': 'Catfishing',
      'description': 'Pretending to be someone else entirely',
      'icon': Icons.masks,
      'color': Colors.deepOrange,
    },
    {
      'id': 'scam_spam',
      'title': 'Scam or Spam',
      'description': 'Asking for money, promoting business, or spam',
      'icon': Icons.block,
      'color': Colors.purple,
    },
    {
      'id': 'underage',
      'title': 'Underage User',
      'description': 'Appears to be under 18 years old',
      'icon': Icons.child_care,
      'color': Colors.red,
    },
    {
      'id': 'hate_speech',
      'title': 'Hate Speech',
      'description': 'Discriminatory or offensive language',
      'icon': Icons.report,
      'color': Colors.deepOrange,
    },
    {
      'id': 'married_committed',
      'title': 'Married/In Relationship',
      'description': 'Not single or cheating on partner',
      'icon': Icons.favorite,
      'color': Colors.amber,
    },
    {
      'id': 'other',
      'title': 'Other',
      'description': 'Something else that violates our community standards',
      'icon': Icons.more_horiz,
      'color': Colors.grey,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialogWrapper(
      backgroundColor: CustomTheme.card,
      child: ResponsiveDialogPadding(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.flag, color: CustomTheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report ${widget.contentType}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Help us maintain a safe dating environment',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: Colors.grey[400]),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Content preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reporting:',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.contentPreview,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Report reasons
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Why are you reporting this?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Reason options
                    ...reportReasons.map((reason) {
                      final isSelected = selectedReason == reason['id'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedReason = reason['id'];
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? CustomTheme.primary.withValues(alpha: 0.1)
                                    : Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? CustomTheme.primary
                                      : Colors.grey[600]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                reason['icon'],
                                color:
                                    isSelected
                                        ? CustomTheme.primary
                                        : reason['color'],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reason['title'],
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.grey[300],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      reason['description'],
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: CustomTheme.primary,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    if (selectedReason != null) ...[
                      const SizedBox(height: 16),

                      // Additional details
                      Text(
                        'Additional details (optional)',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _detailsController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Provide more context about this report...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[600]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[600]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: CustomTheme.primary),
                          ),
                          filled: true,
                          fillColor: Colors.grey[800],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[600]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        selectedReason != null && !_isSubmitting
                            ? _submitReport
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isSubmitting
                            ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Submit Report',
                              style: TextStyle(color: Colors.white),
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

  Future<void> _submitReport() async {
    if (selectedReason == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Here you would integrate with your backend API
      // For now, we'll simulate the API call
      await Future.delayed(const Duration(seconds: 2));

      // Create report data
      final reportData = {
        'contentType': widget.contentType,
        'contentId': widget.contentId,
        'reportedUserId': widget.reportedUserId,
        'reason': selectedReason,
        'details': _detailsController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
        'reporterId': 'current_user_id', // Get from auth controller
      };

      // TODO: Send to backend API
      print('Report submitted: $reportData');

      // Show success message
      Get.back(); // Close dialog first

      Get.snackbar(
        'Report Submitted',
        'Thank you for helping keep our community safe. We\'ll review this report within 24 hours.',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        icon: Icon(Icons.check_circle, color: Colors.green[700]),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } catch (e) {
      // Handle error
      Get.snackbar(
        'Report Failed',
        'Unable to submit report. Please try again later.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        icon: Icon(Icons.error, color: Colors.red[700]),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }
}
