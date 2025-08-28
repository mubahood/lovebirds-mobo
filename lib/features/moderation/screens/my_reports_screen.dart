import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';

import '../../../services/moderation_service.dart';
import '../../../utils/CustomTheme.dart';
import '../../../utils/Utilities.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({Key? key}) : super(key: key);

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  List<dynamic> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyReports();
  }

  Future<void> _loadMyReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ModerationService.getMyReports();
      if (result['code'] == 1 && result['data'] != null) {
        setState(() {
          _reports = result['data'];
        });
      }
    } catch (e) {
      Utils.toast('Failed to load reports');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: FxText.titleLarge('My Reports', color: Colors.white),
        backgroundColor: CustomTheme.primary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: CustomTheme.primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadMyReports,
                child:
                    _reports.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _reports.length,
                          itemBuilder: (context, index) {
                            final report = _reports[index];
                            return _buildReportCard(report);
                          },
                        ),
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.report_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            FxText.titleMedium(
              'No Reports Yet',
              color: Colors.grey[600],
              fontWeight: 600,
            ),
            const SizedBox(height: 8),
            FxText.bodyMedium(
              'You haven\'t submitted any reports yet. When you report content, it will appear here.',
              color: Colors.grey[500],
              textAlign: TextAlign.center,
              height: 1.4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(dynamic report) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Expanded(
                  child: FxText.titleSmall(
                    _getContentTypeLabel(report['content_type']),
                    fontWeight: 600,
                  ),
                ),
                _buildStatusChip(report['status'] ?? 'pending'),
              ],
            ),
            const SizedBox(height: 12),

            // Content details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _getContentTypeIcon(report['content_type']),
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.bodySmall(
                        'Content ID: ${report['content_id'] ?? 'N/A'}',
                        color: Colors.grey[600],
                      ),
                      if (report['reason'] != null) ...[
                        const SizedBox(height: 4),
                        FxText.bodySmall(
                          'Reason: ${_getReasonLabel(report['reason'])}',
                          color: Colors.grey[600],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Description if available
            if (report['description'] != null &&
                report['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FxText.bodySmall(
                  report['description'],
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Footer with date and actions
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                FxText.bodySmall(
                  'Reported: ${_formatDate(report['created_at'])}',
                  color: Colors.grey[500],
                ),
                const Spacer(),
                if (report['status'] == 'pending') ...[
                  FxText.bodySmall(
                    'Under Review',
                    color: Colors.orange[700],
                    fontWeight: 600,
                  ),
                ],
              ],
            ),

            // Resolution details if resolved
            if (report['status'] == 'resolved' &&
                report['resolution'] != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                  const SizedBox(width: 4),
                  FxText.bodySmall(
                    'Resolution: ${report['resolution']}',
                    color: Colors.green[700],
                    fontWeight: 600,
                  ),
                ],
              ),
            ],

            // Admin action details
            if (report['admin_action'] != null ||
                report['moderator_notes'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 4),
                        FxText.bodySmall(
                          'Admin Action Taken',
                          color: Colors.blue[800],
                          fontWeight: 700,
                        ),
                      ],
                    ),
                    if (report['admin_action'] != null) ...[
                      const SizedBox(height: 6),
                      FxText.bodySmall(
                        'Action: ${_getAdminActionLabel(report['admin_action'])}',
                        color: Colors.blue[700],
                        fontWeight: 600,
                      ),
                    ],
                    if (report['moderator_notes'] != null) ...[
                      const SizedBox(height: 6),
                      FxText.bodySmall(
                        'Notes: ${report['moderator_notes']}',
                        color: Colors.blue[700],
                        height: 1.3,
                      ),
                    ],
                    if (report['action_taken_at'] != null) ...[
                      const SizedBox(height: 6),
                      FxText.bodySmall(
                        'Reviewed: ${_formatDate(report['action_taken_at'])}',
                        color: Colors.blue[600],
                        fontSize: 11,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        label = 'Pending';
        break;
      case 'under_review':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        label = 'Under Review';
        break;
      case 'resolved':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        label = 'Resolved';
        break;
      case 'dismissed':
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        label = 'Dismissed';
        break;
      default:
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: FxText.bodySmall(label, color: textColor, fontWeight: 600),
    );
  }

  IconData _getContentTypeIcon(String? contentType) {
    switch (contentType) {
      case 'movie':
        return Icons.movie;
      case 'user':
        return Icons.person;
      case 'comment':
        return Icons.comment;
      case 'chat_message':
        return Icons.chat;
      default:
        return Icons.content_copy;
    }
  }

  String _getContentTypeLabel(String? contentType) {
    switch (contentType) {
      case 'movie':
        return 'Movie/Video Report';
      case 'user':
        return 'User Report';
      case 'comment':
        return 'Comment Report';
      case 'chat_message':
        return 'Chat Message Report';
      default:
        return 'Content Report';
    }
  }

  String _getAdminActionLabel(String? action) {
    switch (action?.toLowerCase()) {
      case 'content_removed':
        return 'Content Removed';
      case 'user_warned':
        return 'User Warned';
      case 'user_suspended':
        return 'User Suspended';
      case 'user_banned':
        return 'User Banned';
      case 'content_approved':
        return 'Content Approved (No Violation)';
      case 'no_action':
        return 'No Action Required';
      case 'under_investigation':
        return 'Under Investigation';
      case 'escalated':
        return 'Escalated to Senior Moderator';
      default:
        return action ?? 'Unknown Action';
    }
  }

  String _getReasonLabel(String? reason) {
    switch (reason) {
      case 'inappropriate_content':
        return 'Inappropriate Content';
      case 'spam':
        return 'Spam';
      case 'harassment':
        return 'Harassment or Bullying';
      case 'violence':
        return 'Violence or Threats';
      case 'hate_speech':
        return 'Hate Speech';
      case 'adult_content':
        return 'Adult Content';
      case 'copyright':
        return 'Copyright Violation';
      case 'false_information':
        return 'False Information';
      case 'privacy_violation':
        return 'Privacy Violation';
      case 'illegal_content':
        return 'Illegal Content';
      default:
        return reason ?? 'Other';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
