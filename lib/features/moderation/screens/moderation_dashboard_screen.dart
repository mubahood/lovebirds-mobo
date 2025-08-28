import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';

import '../../../services/moderation_service.dart';
import '../../../utils/CustomTheme.dart';
import '../../../utils/Utilities.dart';

class ModerationDashboardScreen extends StatefulWidget {
  const ModerationDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ModerationDashboardScreen> createState() =>
      _ModerationDashboardScreenState();
}

class _ModerationDashboardScreenState extends State<ModerationDashboardScreen> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ModerationService.getModerationDashboard();
      if (result['code'] == 1 && result['data'] != null) {
        setState(() {
          _dashboardData = result['data'];
        });
      } else {
        Utils.toast('Failed to load dashboard data');
      }
    } catch (e) {
      Utils.toast('An error occurred while loading dashboard');
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
        title: FxText.titleLarge('Moderation Dashboard', color: Colors.white),
        backgroundColor: CustomTheme.primary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: CustomTheme.primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        actions: [
          IconButton(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child:
                    _dashboardData == null
                        ? _buildErrorState()
                        : SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              _buildHeaderCard(),
                              const SizedBox(height: 24),

                              // Statistics Grid
                              FxText.titleMedium(
                                'Moderation Statistics',
                                fontWeight: 600,
                                color: Colors.grey[800],
                              ),
                              const SizedBox(height: 16),
                              _buildStatisticsGrid(),
                              const SizedBox(height: 24),

                              // Recent Activity
                              FxText.titleMedium(
                                'Recent Activity',
                                fontWeight: 600,
                                color: Colors.grey[800],
                              ),
                              const SizedBox(height: 16),
                              _buildRecentActivity(),
                              const SizedBox(height: 24),

                              // System Health
                              FxText.titleMedium(
                                'System Health',
                                fontWeight: 600,
                                color: Colors.grey[800],
                              ),
                              const SizedBox(height: 16),
                              _buildSystemHealth(),
                            ],
                          ),
                        ),
              ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            FxText.titleMedium(
              'Dashboard Unavailable',
              color: Colors.grey[600],
              fontWeight: 600,
            ),
            const SizedBox(height: 8),
            FxText.bodyMedium(
              'Unable to load moderation dashboard. Please check your admin permissions.',
              color: Colors.grey[500],
              textAlign: TextAlign.center,
              height: 1.4,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadDashboardData,
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primary,
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: CustomTheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FxText.titleMedium(
                    'Content Moderation Overview',
                    fontWeight: 600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FxText.bodyMedium(
              'Monitor and manage content moderation activities across the platform. '
              'Review reports, track system performance, and ensure community safety.',
              color: Colors.grey[600],
              height: 1.4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Pending Reports',
          _dashboardData?['pending_reports']?.toString() ?? '0',
          Icons.pending_actions,
          Colors.orange,
        ),
        _buildStatCard(
          'Total Reports',
          _dashboardData?['total_reports']?.toString() ?? '0',
          Icons.report,
          Colors.blue,
        ),
        _buildStatCard(
          'Blocked Users',
          _dashboardData?['blocked_users']?.toString() ?? '0',
          Icons.block,
          Colors.red,
        ),
        _buildStatCard(
          'Actions Today',
          _dashboardData?['actions_today']?.toString() ?? '0',
          Icons.today,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            FxText.titleLarge(value, fontWeight: 700, color: color),
            const SizedBox(height: 4),
            FxText.bodySmall(
              title,
              color: Colors.grey[600],
              textAlign: TextAlign.center,
              fontWeight: 600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final recentLogs = _dashboardData?['recent_logs'] as List<dynamic>? ?? [];

    if (recentLogs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.timeline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                FxText.bodyMedium(
                  'No recent activity',
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children:
            recentLogs.take(10).map<Widget>((log) {
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getActionColor(log['action_type']).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getActionIcon(log['action_type']),
                    color: _getActionColor(log['action_type']),
                    size: 20,
                  ),
                ),
                title: FxText.bodyMedium(
                  _getActionDescription(log),
                  fontWeight: 600,
                ),
                subtitle: FxText.bodySmall(
                  _formatDateTime(log['created_at']),
                  color: Colors.grey[600],
                ),
                trailing: _buildSeverityChip(log['severity_level']),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSystemHealth() {
    final health = _dashboardData?['system_health'] ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHealthMetric(
              'Content Filter Status',
              health['filter_status'] ?? 'unknown',
              health['filter_status'] == 'active' ? Colors.green : Colors.red,
            ),
            const Divider(),
            _buildHealthMetric(
              'Average Response Time',
              '${health['avg_response_time'] ?? 'N/A'}ms',
              Colors.blue,
            ),
            const Divider(),
            _buildHealthMetric(
              'Reports Processing',
              health['processing_status'] ?? 'unknown',
              health['processing_status'] == 'normal'
                  ? Colors.green
                  : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetric(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: FxText.bodyMedium(label, color: Colors.grey[700])),
          FxText.bodyMedium(value, fontWeight: 600, color: color),
        ],
      ),
    );
  }

  Widget _buildSeverityChip(String? severity) {
    Color color;
    switch (severity?.toLowerCase()) {
      case 'critical':
        color = Colors.red;
        break;
      case 'high':
        color = Colors.orange;
        break;
      case 'medium':
        color = Colors.yellow[700]!;
        break;
      case 'low':
      default:
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: FxText.bodySmall(
        severity?.toUpperCase() ?? 'LOW',
        color: color,
        fontWeight: 600,
      ),
    );
  }

  IconData _getActionIcon(String? actionType) {
    switch (actionType) {
      case 'content_reported':
        return Icons.report;
      case 'user_blocked':
        return Icons.block;
      case 'content_filtered':
        return Icons.filter_alt;
      case 'content_approved':
        return Icons.check_circle;
      default:
        return Icons.security;
    }
  }

  Color _getActionColor(String? actionType) {
    switch (actionType) {
      case 'content_reported':
        return Colors.orange;
      case 'user_blocked':
        return Colors.red;
      case 'content_filtered':
        return Colors.blue;
      case 'content_approved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getActionDescription(dynamic log) {
    final actionType = log['action_type'];
    final automated = log['automated'] == true;
    final prefix = automated ? 'Auto: ' : '';

    switch (actionType) {
      case 'content_reported':
        return '${prefix}Content reported';
      case 'user_blocked':
        return '${prefix}User blocked';
      case 'content_filtered':
        return '${prefix}Content filtered';
      case 'content_approved':
        return '${prefix}Content approved';
      default:
        return '${prefix}Moderation action';
    }
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
