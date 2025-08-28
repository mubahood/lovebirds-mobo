import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_optimization_service.dart';
import '../../services/offline_mode_service.dart';
import '../../services/analytics_service.dart';
import '../../services/app_launch_optimization_service.dart';

/// Comprehensive Performance & Analytics Dashboard
/// Showcases all Phase 10.4 optimizations and provides analytics insights
class PerformanceAnalyticsDashboard extends StatefulWidget {
  const PerformanceAnalyticsDashboard({Key? key}) : super(key: key);

  @override
  State<PerformanceAnalyticsDashboard> createState() =>
      _PerformanceAnalyticsDashboardState();
}

class _PerformanceAnalyticsDashboardState
    extends State<PerformanceAnalyticsDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Service instances
  final _apiOptimization = APIOptimizationService();
  final _offlineMode = OfflineModeService();
  final _analytics = AnalyticsService();
  final _launchOptimization = AppLaunchOptimizationService();

  // Dashboard data
  Map<String, dynamic> _apiMetrics = {};
  Map<String, dynamic> _offlineStats = {};
  Map<String, dynamic> _analyticsData = {};
  Map<String, dynamic> _launchMetrics = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeServices();
    _loadDashboardData();
  }

  /// Initialize all performance services
  Future<void> _initializeServices() async {
    await _offlineMode.initialize();
    await _analytics.initialize();
    await _launchOptimization.initialize();
  }

  /// Load dashboard data from all services
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Load API optimization metrics
      _apiMetrics = {
        'cache_stats': _apiOptimization.getCacheStatistics(),
        'performance_metrics': _apiOptimization.getAllPerformanceMetrics(),
      };

      // Load offline mode statistics
      _offlineStats = _offlineMode.getOfflineStatistics();

      // Load analytics data
      _analyticsData = await _analytics.getAnalyticsDashboard();

      // Load launch optimization metrics
      _launchMetrics = _launchOptimization.getLaunchPerformanceReport();
    } catch (e) {
      // Handle loading errors gracefully
      _apiMetrics = {'error': 'Failed to load API metrics'};
      _offlineStats = {'error': 'Failed to load offline stats'};
      _analyticsData = {'error': 'Failed to load analytics'};
      _launchMetrics = {'error': 'Failed to load launch metrics'};
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Performance & Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.onPrimary,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
          tabs: const [
            Tab(icon: Icon(Icons.speed), text: 'API'),
            Tab(icon: Icon(Icons.offline_bolt), text: 'Offline'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.rocket_launch), text: 'Launch'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body:
          _isLoading
              ? _buildLoadingScreen()
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildAPIOptimizationTab(),
                  _buildOfflineModeTab(),
                  _buildAnalyticsTab(),
                  _buildLaunchOptimizationTab(),
                ],
              ),
    );
  }

  /// Build loading screen with shimmer effect
  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading Performance Data...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// Build API Optimization tab
  Widget _buildAPIOptimizationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '🚀 API Optimization',
            'Intelligent batching & caching',
          ),
          const SizedBox(height: 16),

          // Cache Statistics
          _buildMetricCard(
            title: 'Cache Statistics',
            icon: Icons.storage,
            color: Colors.blue,
            child: _buildCacheStats(),
          ),

          const SizedBox(height: 16),

          // Performance Metrics
          _buildMetricCard(
            title: 'Performance Metrics',
            icon: Icons.speed,
            color: Colors.green,
            child: _buildPerformanceMetrics(),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          _buildActionButtons([
            _ActionButton(
              label: 'Clear Cache',
              icon: Icons.clear_all,
              color: Colors.orange,
              onPressed: () {
                _apiOptimization.clearCache();
                _showSuccessSnackbar('Cache cleared successfully');
              },
            ),
            _ActionButton(
              label: 'Flush Batches',
              icon: Icons.send,
              color: Colors.purple,
              onPressed: () async {
                await _apiOptimization.flushAllBatches();
                _showSuccessSnackbar('All batches flushed');
              },
            ),
          ]),
        ],
      ),
    );
  }

  /// Build Offline Mode tab
  Widget _buildOfflineModeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '📱 Offline Mode',
            'Basic functionality without internet',
          ),
          const SizedBox(height: 16),

          // Connection Status
          _buildMetricCard(
            title: 'Connection Status',
            icon:
                _offlineStats['is_online'] == true
                    ? Icons.wifi
                    : Icons.wifi_off,
            color:
                _offlineStats['is_online'] == true ? Colors.green : Colors.red,
            child: _buildConnectionStatus(),
          ),

          const SizedBox(height: 16),

          // Cached Data
          _buildMetricCard(
            title: 'Cached Data',
            icon: Icons.storage,
            color: Colors.blue,
            child: _buildCachedDataStats(),
          ),

          const SizedBox(height: 16),

          // Pending Actions
          _buildMetricCard(
            title: 'Pending Sync',
            icon: Icons.sync,
            color: Colors.orange,
            child: _buildPendingActions(),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          _buildActionButtons([
            _ActionButton(
              label: 'Toggle Offline Mode',
              icon: Icons.offline_bolt,
              color: Colors.indigo,
              onPressed: () async {
                final enabled =
                    !(_offlineStats['offline_mode_enabled'] ?? false);
                await _offlineMode.setOfflineModeEnabled(enabled);
                await _loadDashboardData();
                _showSuccessSnackbar(
                  'Offline mode ${enabled ? 'enabled' : 'disabled'}',
                );
              },
            ),
            _ActionButton(
              label: 'Force Sync',
              icon: Icons.sync,
              color: Colors.green,
              onPressed: () async {
                if (_offlineStats['is_online'] == true) {
                  final success = await _offlineMode.forceSyncNow();
                  _showSuccessSnackbar(
                    success ? 'Sync completed' : 'Sync failed',
                  );
                  await _loadDashboardData();
                } else {
                  _showErrorSnackbar('Cannot sync while offline');
                }
              },
            ),
          ]),
        ],
      ),
    );
  }

  /// Build Analytics tab
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '📊 Analytics Integration',
            'User behavior & performance tracking',
          ),
          const SizedBox(height: 16),

          // Session Info
          _buildMetricCard(
            title: 'Current Session',
            icon: Icons.timer,
            color: Colors.purple,
            child: _buildSessionInfo(),
          ),

          const SizedBox(height: 16),

          // Feature Usage
          _buildMetricCard(
            title: 'Feature Usage',
            icon: Icons.trending_up,
            color: Colors.green,
            child: _buildFeatureUsage(),
          ),

          const SizedBox(height: 16),

          // Performance Insights
          _buildMetricCard(
            title: 'Performance Insights',
            icon: Icons.insights,
            color: Colors.orange,
            child: _buildPerformanceInsights(),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          _buildActionButtons([
            _ActionButton(
              label: 'Track Test Event',
              icon: Icons.track_changes,
              color: Colors.blue,
              onPressed: () async {
                await _analytics.trackEvent(
                  event: 'dashboard_test_event',
                  properties: {'timestamp': DateTime.now().toString()},
                );
                _showSuccessSnackbar('Test event tracked');
              },
            ),
            _ActionButton(
              label: 'Flush Events',
              icon: Icons.send,
              color: Colors.green,
              onPressed: () async {
                await _analytics.flushEvents();
                _showSuccessSnackbar('Events flushed to server');
              },
            ),
          ]),
        ],
      ),
    );
  }

  /// Build Launch Optimization tab
  Widget _buildLaunchOptimizationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '🚀 Launch Optimization',
            'App startup & memory management',
          ),
          const SizedBox(height: 16),

          // Launch Performance
          _buildMetricCard(
            title: 'Launch Performance',
            icon: Icons.speed,
            color: Colors.red,
            child: _buildLaunchPerformance(),
          ),

          const SizedBox(height: 16),

          // Memory Usage
          _buildMetricCard(
            title: 'Memory Management',
            icon: Icons.memory,
            color: Colors.purple,
            child: _buildMemoryUsage(),
          ),

          const SizedBox(height: 16),

          // Preloaded Data
          _buildMetricCard(
            title: 'Preloaded Data',
            icon: Icons.cached,
            color: Colors.blue,
            child: _buildPreloadedData(),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          _buildActionButtons([
            _ActionButton(
              label: 'Preload Data',
              icon: Icons.download,
              color: Colors.green,
              onPressed: () async {
                await _launchOptimization.preloadCriticalData();
                await _loadDashboardData();
                _showSuccessSnackbar('Data preloaded successfully');
              },
            ),
            _ActionButton(
              label: 'Memory Cleanup',
              icon: Icons.cleaning_services,
              color: Colors.orange,
              onPressed: () {
                _launchOptimization.forceMemoryCleanup();
                _showSuccessSnackbar('Memory cleanup completed');
              },
            ),
          ]),
        ],
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(subtitle, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
      ],
    );
  }

  /// Build metric card
  Widget _buildMetricCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  /// Build cache statistics
  Widget _buildCacheStats() {
    final cacheStats = _apiMetrics['cache_stats'] ?? {};

    return Column(
      children: [
        _buildStatRow(
          'Total Entries',
          cacheStats['total_entries']?.toString() ?? '0',
        ),
        _buildStatRow(
          'Memory Usage',
          '${cacheStats['memory_usage_kb'] ?? '0'} KB',
        ),
        _buildStatRow(
          'Cache Hit Rate',
          '${cacheStats['cache_hit_rate'] ?? '0'}%',
        ),
      ],
    );
  }

  /// Build performance metrics
  Widget _buildPerformanceMetrics() {
    final metrics = _apiMetrics['performance_metrics'] ?? {};

    if (metrics.isEmpty) {
      return const Text('No performance data available');
    }

    return Column(
      children:
          metrics.entries.take(3).map<Widget>((entry) {
            final metric = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    _buildStatRow(
                      'Total Requests',
                      metric['total_requests']?.toString() ?? '0',
                    ),
                    _buildStatRow(
                      'Success Rate',
                      '${metric['success_rate'] ?? '0'}%',
                    ),
                    _buildStatRow(
                      'Avg Duration',
                      '${metric['average_duration_ms'] ?? '0'} ms',
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  /// Build connection status
  Widget _buildConnectionStatus() {
    final isOnline = _offlineStats['is_online'] ?? false;
    final offlineModeEnabled = _offlineStats['offline_mode_enabled'] ?? false;

    return Column(
      children: [
        _buildStatRow('Connection Status', isOnline ? 'Online' : 'Offline'),
        _buildStatRow(
          'Offline Mode',
          offlineModeEnabled ? 'Enabled' : 'Disabled',
        ),
        _buildStatRow(
          'Cache Size',
          '${_offlineStats['cache_size_kb'] ?? '0'} KB',
        ),
      ],
    );
  }

  /// Build cached data stats
  Widget _buildCachedDataStats() {
    return Column(
      children: [
        _buildStatRow(
          'Cached Profiles',
          _offlineStats['cached_profiles']?.toString() ?? '0',
        ),
        _buildStatRow(
          'Cached Matches',
          _offlineStats['cached_matches']?.toString() ?? '0',
        ),
        _buildStatRow(
          'Total Items',
          _offlineStats['cached_items']?.toString() ?? '0',
        ),
      ],
    );
  }

  /// Build pending actions
  Widget _buildPendingActions() {
    final pendingCount = _offlineStats['pending_actions'] ?? 0;

    return Column(
      children: [
        _buildStatRow('Pending Actions', pendingCount.toString()),
        _buildStatRow(
          'Last Sync',
          _formatTimestamp(_offlineStats['last_sync']),
        ),
        if (pendingCount > 0)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$pendingCount actions waiting to sync',
              style: TextStyle(color: Colors.orange[700]),
            ),
          ),
      ],
    );
  }

  /// Build session info
  Widget _buildSessionInfo() {
    final session = _analyticsData['session'] ?? {};

    return Column(
      children: [
        _buildStatRow(
          'Session ID',
          session['session_id']?.toString().substring(0, 8) ?? 'N/A',
        ),
        _buildStatRow(
          'Duration',
          '${session['duration_minutes'] ?? 0} minutes',
        ),
        _buildStatRow(
          'Events Count',
          session['events_count']?.toString() ?? '0',
        ),
      ],
    );
  }

  /// Build feature usage
  Widget _buildFeatureUsage() {
    final featureUsage = _analyticsData['feature_usage'] ?? {};

    if (featureUsage.isEmpty) {
      return const Text('No feature usage data available');
    }

    return Column(
      children:
          featureUsage.entries.take(5).map<Widget>((entry) {
            return _buildStatRow(entry.key, entry.value.toString());
          }).toList(),
    );
  }

  /// Build performance insights
  Widget _buildPerformanceInsights() {
    return Column(
      children: [
        _buildStatRow(
          'Screen Views',
          _analyticsData['screen_metrics']?.length?.toString() ?? '0',
        ),
        _buildStatRow(
          'API Calls',
          _analyticsData['api_metrics']?.length?.toString() ?? '0',
        ),
        _buildStatRow(
          'User Journey',
          _analyticsData['user_journey']?.length?.toString() ?? '0',
        ),
      ],
    );
  }

  /// Build launch performance
  Widget _buildLaunchPerformance() {
    return Column(
      children: [
        _buildStatRow(
          'Cold Start',
          '${_launchMetrics['cold_start_ms'] ?? 'N/A'} ms',
        ),
        _buildStatRow(
          'Total Launch',
          '${_launchMetrics['total_launch_ms'] ?? 'N/A'} ms',
        ),
        _buildStatRow(
          'Post Login',
          '${_launchMetrics['post_login_ms'] ?? 'N/A'} ms',
        ),
      ],
    );
  }

  /// Build memory usage
  Widget _buildMemoryUsage() {
    return Column(
      children: [
        _buildStatRow(
          'Current Memory',
          '${_launchMetrics['current_memory_mb'] ?? 'N/A'} MB',
        ),
        _buildStatRow(
          'Memory Snapshots',
          _launchMetrics['memory_snapshots_count']?.toString() ?? '0',
        ),
        _buildStatRow(
          'Preloaded Data',
          _launchMetrics['preloaded_data_count']?.toString() ?? '0',
        ),
      ],
    );
  }

  /// Build preloaded data
  Widget _buildPreloadedData() {
    final preloadedData =
        _launchMetrics['preloaded_data'] as List<dynamic>? ?? [];

    if (preloadedData.isEmpty) {
      return const Text('No data preloaded');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          preloadedData.map<Widget>((data) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(data.toString()),
                ],
              ),
            );
          }).toList(),
    );
  }

  /// Build stat row
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(List<_ActionButton> buttons) {
    return Row(
      children:
          buttons.map((button) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton.icon(
                  onPressed: button.onPressed,
                  icon: Icon(button.icon),
                  label: Text(button.label),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: button.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  /// Format timestamp
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Never';

    try {
      final DateTime dt;
      if (timestamp is int) {
        dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is String) {
        dt = DateTime.parse(timestamp);
      } else {
        return 'Invalid';
      }

      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Invalid';
    }
  }

  /// Show success snackbar
  void _showSuccessSnackbar(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

/// Action button model
class _ActionButton {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
}
