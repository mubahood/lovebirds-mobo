import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../utils/dating_theme.dart';

/// Search history and preferences management screen
class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({Key? key}) : super(key: key);

  @override
  _SearchHistoryScreenState createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<SearchHistory> _searchHistory = [];
  List<SavedSearch> _savedSearches = [];
  SearchAnalytics? _analytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load search history
      final historyJson = prefs.getStringList('search_history') ?? [];
      _searchHistory =
          historyJson
              .map((json) => SearchHistory.fromJson(jsonDecode(json)))
              .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Load saved searches
      final savedJson = prefs.getStringList('saved_searches') ?? [];
      _savedSearches =
          savedJson
              .map((json) => SavedSearch.fromJson(jsonDecode(json)))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Generate analytics
      _analytics = _generateAnalytics();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading search data: $e');
    }
  }

  SearchAnalytics _generateAnalytics() {
    final totalSearches = _searchHistory.length;
    final successfulSearches =
        _searchHistory.where((h) => h.resultCount > 0).length;
    final averageResults =
        totalSearches > 0
            ? _searchHistory.map((h) => h.resultCount).reduce((a, b) => a + b) /
                totalSearches
            : 0.0;

    // Most popular search terms
    final termCounts = <String, int>{};
    for (final history in _searchHistory) {
      if (history.searchTerm.isNotEmpty) {
        termCounts[history.searchTerm] =
            (termCounts[history.searchTerm] ?? 0) + 1;
      }
    }

    final popularTerms =
        termCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Search patterns by time
    final searchesByHour = <int, int>{};
    for (final history in _searchHistory) {
      final hour = history.timestamp.hour;
      searchesByHour[hour] = (searchesByHour[hour] ?? 0) + 1;
    }

    final peakHour =
        searchesByHour.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return SearchAnalytics(
      totalSearches: totalSearches,
      successfulSearches: successfulSearches,
      averageResults: averageResults,
      popularTerms: popularTerms.take(5).map((e) => e.key).toList(),
      peakSearchHour: peakHour,
      savedSearchCount: _savedSearches.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DatingTheme.darkBackground,
      appBar: _buildAppBar(),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    DatingTheme.primaryPink,
                  ),
                ),
              )
              : Column(
                children: [
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildHistoryTab(),
                        _buildSavedSearchesTab(),
                        _buildAnalyticsTab(),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: FxText.titleLarge(
        'Search History',
        color: Colors.white,
        fontWeight: 600,
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: _handleMenuSelection,
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'clear_history',
                  child: Text('Clear History'),
                ),
                const PopupMenuItem(
                  value: 'export_data',
                  child: Text('Export Data'),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: DatingTheme.primaryPink,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: DatingTheme.secondaryText,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: const [
          Tab(text: 'History'),
          Tab(text: 'Saved'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_searchHistory.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'No Search History',
        subtitle: 'Your search history will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchHistory.length,
      itemBuilder: (context, index) {
        final history = _searchHistory[index];
        return _buildHistoryItem(history);
      },
    );
  }

  Widget _buildSavedSearchesTab() {
    if (_savedSearches.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_border,
        title: 'No Saved Searches',
        subtitle: 'Save your favorite search filters for quick access',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedSearches.length,
      itemBuilder: (context, index) {
        final saved = _savedSearches[index];
        return _buildSavedSearchItem(saved);
      },
    );
  }

  Widget _buildAnalyticsTab() {
    if (_analytics == null) {
      return const Center(child: Text('No analytics data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalyticsCard('Search Overview', [
            AnalyticsStat(
              'Total Searches',
              _analytics!.totalSearches.toString(),
            ),
            AnalyticsStat(
              'Successful Searches',
              _analytics!.successfulSearches.toString(),
            ),
            AnalyticsStat(
              'Average Results',
              _analytics!.averageResults.toStringAsFixed(1),
            ),
            AnalyticsStat(
              'Saved Searches',
              _analytics!.savedSearchCount.toString(),
            ),
          ]),
          const SizedBox(height: 16),
          _buildAnalyticsCard(
            'Popular Search Terms',
            _analytics!.popularTerms
                .map((term) => AnalyticsStat(term, ''))
                .toList(),
          ),
          const SizedBox(height: 16),
          _buildAnalyticsCard('Search Patterns', [
            AnalyticsStat(
              'Peak Search Hour',
              '${_analytics!.peakSearchHour}:00',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(SearchHistory history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.search, color: DatingTheme.primaryPink, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: FxText.bodyLarge(
                  history.searchTerm.isEmpty
                      ? 'Filter Search'
                      : history.searchTerm,
                  color: Colors.white,
                  fontWeight: 500,
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: DatingTheme.secondaryText,
                  size: 18,
                ),
                onSelected: (value) => _handleHistoryAction(value, history),
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'repeat',
                        child: Text('Repeat Search'),
                      ),
                      const PopupMenuItem(
                        value: 'save',
                        child: Text('Save Search'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: DatingTheme.secondaryText,
                size: 16,
              ),
              const SizedBox(width: 4),
              FxText.bodyMedium(
                _formatTimestamp(history.timestamp),
                color: DatingTheme.secondaryText,
              ),
              const SizedBox(width: 16),
              Icon(Icons.people, color: DatingTheme.secondaryText, size: 16),
              const SizedBox(width: 4),
              FxText.bodyMedium(
                '${history.resultCount} results',
                color: DatingTheme.secondaryText,
              ),
            ],
          ),
          if (history.filters.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  history.filters
                      .map(
                        (filter) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: DatingTheme.primaryPink.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FxText.bodySmall(
                            filter,
                            color: DatingTheme.primaryPink,
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSavedSearchItem(SavedSearch saved) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bookmark, color: DatingTheme.primaryPink, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: FxText.bodyLarge(
                  saved.name,
                  color: Colors.white,
                  fontWeight: 500,
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: DatingTheme.secondaryText,
                  size: 18,
                ),
                onSelected: (value) => _handleSavedSearchAction(value, saved),
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'use',
                        child: Text('Use Search'),
                      ),
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          FxText.bodyMedium(
            'Created ${_formatTimestamp(saved.createdAt)}',
            color: DatingTheme.secondaryText,
          ),
          if (saved.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            FxText.bodyMedium(
              saved.description,
              color: DatingTheme.secondaryText,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, List<AnalyticsStat> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.titleMedium(title, color: Colors.white, fontWeight: 600),
          const SizedBox(height: 16),
          ...stats.map((stat) => _buildStatRow(stat)).toList(),
        ],
      ),
    );
  }

  Widget _buildStatRow(AnalyticsStat stat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FxText.bodyMedium(stat.label, color: DatingTheme.secondaryText),
          if (stat.value.isNotEmpty)
            FxText.bodyMedium(stat.value, color: Colors.white, fontWeight: 500),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          FxText.headlineSmall(title, color: Colors.white, fontWeight: 600),
          const SizedBox(height: 8),
          FxText.bodyLarge(
            subtitle,
            color: DatingTheme.secondaryText,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'clear_history':
        _showClearHistoryDialog();
        break;
      case 'export_data':
        _exportData();
        break;
    }
  }

  void _handleHistoryAction(String action, SearchHistory history) {
    switch (action) {
      case 'repeat':
        _repeatSearch(history);
        break;
      case 'save':
        _saveSearch(history);
        break;
      case 'delete':
        _deleteHistory(history);
        break;
    }
  }

  void _handleSavedSearchAction(String action, SavedSearch saved) {
    switch (action) {
      case 'use':
        _useSavedSearch(saved);
        break;
      case 'edit':
        _editSavedSearch(saved);
        break;
      case 'delete':
        _deleteSavedSearch(saved);
        break;
    }
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: DatingTheme.cardBackground,
            title: const Text(
              'Clear Search History',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to clear all search history? This action cannot be undone.',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: DatingTheme.secondaryText),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _clearAllHistory();
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(color: DatingTheme.primaryPink),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
    setState(() {
      _searchHistory.clear();
      _analytics = _generateAnalytics();
    });
  }

  void _repeatSearch(SearchHistory history) {
    Navigator.pop(context, {'action': 'repeat_search', 'history': history});
  }

  void _saveSearch(SearchHistory history) {
    // Implementation for saving a search from history
    print('Save search: ${history.searchTerm}');
  }

  void _deleteHistory(SearchHistory history) {
    // Implementation for deleting a specific history item
    print('Delete history: ${history.searchTerm}');
  }

  void _useSavedSearch(SavedSearch saved) {
    Navigator.pop(context, {
      'action': 'use_saved_search',
      'saved_search': saved,
    });
  }

  void _editSavedSearch(SavedSearch saved) {
    // Implementation for editing a saved search
    print('Edit saved search: ${saved.name}');
  }

  void _deleteSavedSearch(SavedSearch saved) {
    // Implementation for deleting a saved search
    print('Delete saved search: ${saved.name}');
  }

  void _exportData() {
    // Implementation for exporting search data
    print('Export search data');
  }
}

// Data models for search history and analytics
class SearchHistory {
  final String searchTerm;
  final DateTime timestamp;
  final int resultCount;
  final List<String> filters;

  SearchHistory({
    required this.searchTerm,
    required this.timestamp,
    required this.resultCount,
    required this.filters,
  });

  factory SearchHistory.fromJson(Map<String, dynamic> json) {
    return SearchHistory(
      searchTerm: json['searchTerm'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      resultCount: json['resultCount'] ?? 0,
      filters: List<String>.from(json['filters'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'searchTerm': searchTerm,
      'timestamp': timestamp.toIso8601String(),
      'resultCount': resultCount,
      'filters': filters,
    };
  }
}

class SavedSearch {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic> filters;

  SavedSearch({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.filters,
  });

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      filters: Map<String, dynamic>.from(json['filters'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'filters': filters,
    };
  }
}

class SearchAnalytics {
  final int totalSearches;
  final int successfulSearches;
  final double averageResults;
  final List<String> popularTerms;
  final int peakSearchHour;
  final int savedSearchCount;

  SearchAnalytics({
    required this.totalSearches,
    required this.successfulSearches,
    required this.averageResults,
    required this.popularTerms,
    required this.peakSearchHour,
    required this.savedSearchCount,
  });
}

class AnalyticsStat {
  final String label;
  final String value;

  AnalyticsStat(this.label, this.value);
}
