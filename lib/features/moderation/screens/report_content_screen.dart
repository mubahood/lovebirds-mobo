import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../services/moderation_service.dart';
import '../../../utils/CustomTheme.dart';
import '../../../utils/Utilities.dart';

class ReportContentScreen extends StatefulWidget {
  final String? initialContentType;
  final String? initialContentId;
  final String? initialContentTitle;
  final String? initialReportedUserId;

  const ReportContentScreen({
    Key? key,
    this.initialContentType,
    this.initialContentId,
    this.initialContentTitle,
    this.initialReportedUserId,
  }) : super(key: key);

  @override
  State<ReportContentScreen> createState() => _ReportContentScreenState();
}

class _ReportContentScreenState extends State<ReportContentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentIdController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedContentType = 'movie';
  String _selectedReason = 'copyright_infringement';
  bool _isSubmitting = false;

  final List<Map<String, String>> _contentTypes = [
    {'value': 'movie', 'label': 'Movie/Video'},
    {'value': 'user', 'label': 'User Profile'},
    {'value': 'comment', 'label': 'Comment'},
    {'value': 'chat_message', 'label': 'Chat Message'},
    {'value': 'other', 'label': 'Other Content'},
  ];

  final List<Map<String, String>> _reportReasons = [
    {'value': 'copyright_infringement', 'label': 'Copyright Infringement'},
    {'value': 'request_delete_movie', 'label': 'Request to Delete Movie'},
    {'value': 'inappropriate_content', 'label': 'Inappropriate Content'},
    {'value': 'adult_content', 'label': 'Adult/Sexual Content'},
    {'value': 'violence', 'label': 'Violence or Graphic Content'},
    {'value': 'hate_speech', 'label': 'Hate Speech'},
    {'value': 'harassment', 'label': 'Harassment or Bullying'},
    {'value': 'spam', 'label': 'Spam or Fake Content'},
    {'value': 'false_information', 'label': 'False Information'},
    {'value': 'privacy_violation', 'label': 'Privacy Violation'},
    {'value': 'illegal_content', 'label': 'Illegal Content'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();

    // Pre-fill form with provided data
    if (widget.initialContentType != null) {
      _selectedContentType = widget.initialContentType!;
    }
    if (widget.initialContentId != null) {
      _contentIdController.text = widget.initialContentId!;
    }

    // Also load from Get arguments for backward compatibility
    _loadArguments();
  }

  void _loadArguments() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args['content_type'] != null) {
        _selectedContentType = args['content_type'];
      }
      if (args['content_id'] != null) {
        _contentIdController.text = args['content_id'];
      }
    }
  }

  @override
  void dispose() {
    _contentIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await ModerationService.reportContent(
        contentType: _selectedContentType,
        contentId: _contentIdController.text.trim(),
        reason: _selectedReason,
        description: _descriptionController.text.trim(),
        reportedUserId: widget.initialReportedUserId,
      );



      if (result['code'] == 1) {
        Utils.toast(
          "Report submitted successfully. We'll review it within 24 hours.",
        );
        Get.back();
      } else {
        Utils.toast(result['message'] ?? 'Failed to submit report');
      }
    } catch (e) {
      Utils.toast('An error occurred while submitting the report');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: FxText.titleLarge('Report Content', color: Colors.white),
        backgroundColor: CustomTheme.primary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: CustomTheme.primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Information header
              Card(
                color: Colors.orange[50],
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          FxText.titleSmall(
                            'Report Guidelines',
                            fontWeight: 600,
                            color: Colors.orange[800],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FxText.bodySmall(
                        'Please provide accurate information about the content you\'re reporting. '
                        'False reports may result in restrictions on your account. '
                        'Reports are reviewed within 24 hours.',
                        color: Colors.orange[700],
                        height: 1.4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Content Type Selection
              FxText.titleSmall(
                'Content Type',
                fontWeight: 600,
                color: Colors.grey[800],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedContentType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  fillColor: Colors.black,
                  filled: true,
                ),
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                items:
                    _contentTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type['value'],
                        child: Text(type['label']!),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedContentType = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a content type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Content ID/URL
              FxText.titleSmall(
                'Content ID or URL',
                fontWeight: 600,
                color: Colors.grey[800],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentIdController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter the ID or URL of the content to report',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the content ID or URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Report Reason
              FxText.titleSmall(
                'Reason for Report',
                fontWeight: 600,
                color: Colors.grey[800],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  fillColor: Colors.black,
                  filled: true,
                ),
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                items:
                    _reportReasons.map((reason) {
                      return DropdownMenuItem<String>(
                        value: reason['value'],
                        child: Text(reason['label']!),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a reason';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Additional Description
              FxText.titleSmall(
                'Additional Details (Optional)',
                fontWeight: 600,
                color: Colors.grey[800],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText:
                      'Provide additional context about why you\'re reporting this content...',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : FxText.titleSmall(
                            'Submit Report',
                            color: Colors.white,
                            fontWeight: 600,
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
