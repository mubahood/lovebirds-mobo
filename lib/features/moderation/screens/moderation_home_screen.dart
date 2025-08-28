import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../services/moderation_service.dart';
import '../../../utils/CustomTheme.dart';
import '../../../utils/my_colors.dart';
import 'blocked_users_screen.dart';
import 'legal_consent_screen.dart';
import 'moderation_dashboard_screen.dart';
import 'moderation_demo_screen.dart';
import 'my_reports_screen.dart';
import 'report_content_screen.dart';

class ModerationHomeScreen extends StatefulWidget {
  const ModerationHomeScreen({Key? key}) : super(key: key);

  @override
  State<ModerationHomeScreen> createState() => _ModerationHomeScreenState();
}

class _ModerationHomeScreenState extends State<ModerationHomeScreen> {
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      bool adminStatus = await ModerationService.isCurrentUserAdmin();
      setState(() {
        _isAdmin = adminStatus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isAdmin = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: FxText.titleLarge('Safety & Moderation', color: Colors.white),
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
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.security,
                                  color: MyColors.primary,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FxText.titleMedium(
                                    'Community Safety Tools',
                                    fontWeight: 600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            FxText.bodyMedium(
                              'Help us maintain a safe and respectful community. Use these tools to report inappropriate content, manage blocked users, and stay informed about our safety policies.',
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // User Safety Tools
                    FxText.titleMedium(
                      'Safety Tools',
                      fontWeight: 600,
                      color: Colors.grey[800],
                    ),
                    const SizedBox(height: 12),

                    _buildModeratorTile(
                      icon: Icons.report_problem,
                      title: 'Report Content',
                      subtitle:
                          'Report inappropriate content, users, or violations',
                      color: Colors.orange,
                      onTap: () {
                        Get.to(() => const ReportContentScreen());
                      },
                    ),

                    _buildModeratorTile(
                      icon: Icons.block,
                      title: 'Blocked Users',
                      subtitle: 'Manage users you have blocked',
                      color: Colors.red,
                      onTap: () {
                        Get.to(() => const BlockedUsersScreen());
                      },
                    ),

                    _buildModeratorTile(
                      icon: Icons.history,
                      title: 'My Reports',
                      subtitle: 'View status of reports you have submitted',
                      color: Colors.blue,
                      onTap: () {
                        Get.to(() => const MyReportsScreen());
                      },
                    ),

                    _buildModeratorTile(
                      icon: Icons.science,
                      title: 'Demo & Test',
                      subtitle: 'Test moderation features with sample data',
                      color: Colors.purple,
                      onTap: () {
                        Get.to(() => const ModerationDemoScreen());
                      },
                    ),

                    // Legal & Compliance Section
                    const SizedBox(height: 32),
                    FxText.titleMedium(
                      'Legal & Compliance',
                      fontWeight: 600,
                      color: Colors.grey[800],
                    ),
                    const SizedBox(height: 12),

                    _buildModeratorTile(
                      icon: Icons.gavel,
                      title: 'Legal Consent',
                      subtitle:
                          'Review and manage your legal consent preferences',
                      color: Colors.green,
                      onTap: () {
                        Get.to(() => const LegalConsentScreen());
                      },
                    ),

                    // Admin Tools (only if user is admin)
                    if (_isAdmin) ...[
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            color: MyColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          FxText.titleMedium(
                            'Admin Tools',
                            fontWeight: 600,
                            color: Colors.grey[800],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildModeratorTile(
                        icon: Icons.dashboard,
                        title: 'Moderation Dashboard',
                        subtitle:
                            'View moderation statistics and manage reports',
                        color: Colors.purple,
                        onTap: () {
                          Get.to(() => const ModerationDashboardScreen());
                        },
                      ),
                    ],

                    // Information Section
                    const SizedBox(height: 32),
                    Card(
                      color: Colors.blue[50],
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
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                FxText.titleSmall(
                                  'How Content Moderation Works',
                                  fontWeight: 600,
                                  color: Colors.blue[800],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            FxText.bodySmall(
                              '• Reports are reviewed within 24 hours\n'
                              '• Automated filtering helps catch inappropriate content\n'
                              '• Repeated violations may result in account restrictions\n'
                              '• You can appeal moderation decisions through support',
                              color: Colors.blue[700],
                              height: 1.6,
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

  Widget _buildModeratorTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: FxText.titleSmall(title, fontWeight: 600),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: FxText.bodySmall(
            subtitle,
            color: Colors.grey[600],
            height: 1.3,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }
}
