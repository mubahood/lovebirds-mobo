import 'package:flutter/material.dart';
import '../../services/milestone_gift_service.dart';
import '../../theme/dating_theme.dart';

class MilestoneGiftSuggestionsWidget extends StatefulWidget {
  final String partnerId;
  final String partnerName;
  final String? relationshipStartDate;

  const MilestoneGiftSuggestionsWidget({
    Key? key,
    required this.partnerId,
    required this.partnerName,
    this.relationshipStartDate,
  }) : super(key: key);

  @override
  State<MilestoneGiftSuggestionsWidget> createState() =>
      _MilestoneGiftSuggestionsWidgetState();
}

class _MilestoneGiftSuggestionsWidgetState
    extends State<MilestoneGiftSuggestionsWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  List<MilestoneEvent> _upcomingMilestones = [];
  Map<String, dynamic>? _currentSuggestions;
  List<MilestoneGiftItem> _recommendedItems = [];

  bool _isLoading = false;
  String _selectedMilestoneType = 'general';
  String _selectedBudget = 'medium';

  final List<String> _budgetOptions = ['low', 'medium', 'high', 'luxury'];
  final Map<String, String> _budgetLabels = {
    'low': 'Budget Friendly (\$25-75)',
    'medium': 'Moderate (\$75-200)',
    'high': 'Premium (\$200-500)',
    'luxury': 'Luxury (\$500+)',
  };

  final Map<String, IconData> _milestoneIcons = {
    'first_date': Icons.favorite_outline,
    '1_month': Icons.cake_outlined,
    '3_months': Icons.favorite,
    '6_months': Icons.card_giftcard,
    '1_year': Icons.diamond,
    'birthday': Icons.celebration,
    'valentine': Icons.favorite,
    'christmas': Icons.card_giftcard,
    'general': Icons.card_giftcard,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      // Load upcoming milestones
      _upcomingMilestones = await MilestoneGiftService.getUpcomingMilestones(
        relationshipStartDate: widget.relationshipStartDate,
      );

      // Suggest appropriate milestone type
      _selectedMilestoneType = MilestoneGiftService.suggestMilestoneType(
        widget.relationshipStartDate,
      );

      // Load initial gift suggestions
      await _loadGiftSuggestions();
    } catch (e) {
      _showErrorSnackBar('Failed to load milestone data: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGiftSuggestions() async {
    setState(() => _isLoading = true);

    try {
      final result = await MilestoneGiftService.getMilestoneGiftSuggestions(
        partnerId: widget.partnerId,
        milestoneType: _selectedMilestoneType,
        relationshipStartDate: widget.relationshipStartDate,
        budget: _selectedBudget,
      );

      if (result['success']) {
        setState(() {
          _currentSuggestions = result['data'];
          _recommendedItems =
              (result['data']['recommended_items'] as List)
                  .map((item) => MilestoneGiftItem.fromJson(item))
                  .toList();
        });
      } else {
        _showErrorSnackBar(result['error']);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load gift suggestions: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMilestoneReminder(MilestoneEvent milestone) async {
    try {
      final result = await MilestoneGiftService.saveMilestoneReminder(
        partnerId: widget.partnerId,
        milestoneType: milestone.type,
        milestoneDate: milestone.date.toIso8601String().split('T')[0],
        reminderDays: 7,
      );

      if (result['success']) {
        _showSuccessSnackBar(result['message']);
      } else {
        _showErrorSnackBar(result['error']);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to save reminder: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DatingTheme.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DatingTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gift Ideas for ${widget.partnerName}',
          style: DatingTheme.headingStyle.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: DatingTheme.primaryPink,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.card_giftcard), text: 'Suggestions'),
            Tab(icon: Icon(Icons.event), text: 'Milestones'),
            Tab(icon: Icon(Icons.tune), text: 'Preferences'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSuggestionsTab(),
          _buildMilestonesTab(),
          _buildPreferencesTab(),
        ],
      ),
    );
  }

  Widget _buildSuggestionsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentSuggestions == null) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Milestone Info Card
          _buildMilestoneInfoCard(),

          const SizedBox(height: 20),

          // Budget & Filter Controls
          _buildFilterControls(),

          const SizedBox(height: 20),

          // Recommended Items
          _buildRecommendedItems(),

          const SizedBox(height: 20),

          // Relationship Insights
          if (_currentSuggestions!['relationship_insights'] != null)
            _buildInsightsCard(),
        ],
      ),
    );
  }

  Widget _buildMilestoneInfoCard() {
    final milestoneInfo = _currentSuggestions!['milestone_info'];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DatingTheme.primaryPink.withValues(alpha: 0.1),
            DatingTheme.secondaryPurple.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DatingTheme.primaryPink.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _milestoneIcons[_selectedMilestoneType] ?? Icons.card_giftcard,
                color: DatingTheme.primaryPink,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestoneInfo['title'] ?? 'Gift Suggestions',
                      style: DatingTheme.headingStyle.copyWith(
                        fontSize: 20,
                        color: DatingTheme.primaryPink,
                      ),
                    ),
                    Text(
                      milestoneInfo['subtitle'] ?? '',
                      style: DatingTheme.bodyStyle.copyWith(
                        color: DatingTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(milestoneInfo['message'] ?? '', style: DatingTheme.bodyStyle),

          if (_currentSuggestions!['budget_note'] != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DatingTheme.accentGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: DatingTheme.accentGold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: DatingTheme.accentGold,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentSuggestions!['budget_note'],
                      style: DatingTheme.captionStyle.copyWith(
                        color: DatingTheme.accentGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Range',
          style: DatingTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          children:
              _budgetOptions.map((budget) {
                final isSelected = budget == _selectedBudget;
                return FilterChip(
                  label: Text(_budgetLabels[budget]!),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedBudget = budget;
                      });
                      _loadGiftSuggestions();
                    }
                  },
                  selectedColor: DatingTheme.primaryPink.withValues(alpha: 0.2),
                  checkmarkColor: DatingTheme.primaryPink,
                  labelStyle: TextStyle(
                    color:
                        isSelected
                            ? DatingTheme.primaryPink
                            : DatingTheme.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecommendedItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Perfect Gift Ideas',
              style: DatingTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '${_recommendedItems.length} items',
              style: DatingTheme.captionStyle,
            ),
          ],
        ),

        const SizedBox(height: 12),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recommendedItems.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = _recommendedItems[index];
            return _buildGiftItemCard(item);
          },
        ),
      ],
    );
  }

  Widget _buildGiftItemCard(MilestoneGiftItem item) {
    return Container(
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: DatingTheme.surfaceColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child:
                item.imageUrl.isNotEmpty
                    ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                _buildImagePlaceholder(item),
                      ),
                    )
                    : _buildImagePlaceholder(item),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Name and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: DatingTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: DatingTheme.primaryPink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '\$${item.price.toStringAsFixed(2)} CAD',
                        style: DatingTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: DatingTheme.primaryPink,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Description
                Text(item.description, style: DatingTheme.bodyStyle),

                const SizedBox(height: 12),

                // Milestone Relevance
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DatingTheme.accentGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: DatingTheme.accentGold,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.milestoneRelevance,
                          style: DatingTheme.captionStyle.copyWith(
                            color: DatingTheme.accentGold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Personalization Options
                if (item.personalizationOptions.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'Personalization Options:',
                        style: DatingTheme.captionStyle.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children:
                            item.personalizationOptions
                                .map(
                                  (option) => Chip(
                                    label: Text(
                                      option,
                                      style: DatingTheme.captionStyle,
                                    ),
                                    backgroundColor: DatingTheme.surfaceColor,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showGiftDetailsDialog(item),
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DatingTheme.primaryPink,
                          side: BorderSide(color: DatingTheme.primaryPink),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _addToCart(item),
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add to Cart'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DatingTheme.primaryPink,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(MilestoneGiftItem item) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: DatingTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.card_giftcard, size: 48, color: DatingTheme.textSecondary),
          const SizedBox(height: 8),
          Text(
            item.category.toUpperCase(),
            style: DatingTheme.captionStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    final insights = _currentSuggestions!['relationship_insights'] as List;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DatingTheme.secondaryPurple.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: DatingTheme.secondaryPurple),
              const SizedBox(width: 8),
              Text(
                'Relationship Insights',
                style: DatingTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.favorite,
                    size: 16,
                    color: DatingTheme.primaryPink,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(insight, style: DatingTheme.bodyStyle)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesTab() {
    if (_upcomingMilestones.isEmpty) {
      return _buildEmptyMilestonesState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _upcomingMilestones.length,
      itemBuilder: (context, index) {
        final milestone = _upcomingMilestones[index];
        return _buildMilestoneCard(milestone);
      },
    );
  }

  Widget _buildMilestoneCard(MilestoneEvent milestone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: DatingTheme.primaryPink.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    _milestoneIcons[milestone.type] ?? Icons.event,
                    color: DatingTheme.primaryPink,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone.title,
                        style: DatingTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        milestone.description,
                        style: DatingTheme.captionStyle,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${milestone.daysUntil} days',
                      style: DatingTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DatingTheme.primaryPink,
                      ),
                    ),
                    Text('until', style: DatingTheme.captionStyle),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _saveMilestoneReminder(milestone),
                    icon: const Icon(Icons.notifications_none),
                    label: const Text('Set Reminder'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DatingTheme.primaryPink,
                      side: BorderSide(color: DatingTheme.primaryPink),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewMilestoneGifts(milestone.type),
                    icon: const Icon(Icons.card_giftcard),
                    label: const Text('View Gifts'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DatingTheme.primaryPink,
                      foregroundColor: Colors.white,
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

  Widget _buildPreferencesTab() {
    final budgetGuide = MilestoneGiftService.getBudgetRecommendations(
      _selectedMilestoneType,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Milestone Type Selection
          Text(
            'Milestone Type',
            style: DatingTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 12),

          _buildMilestoneTypeSelector(),

          const SizedBox(height: 24),

          // Budget Guide
          _buildBudgetGuideCard(budgetGuide),

          const SizedBox(height: 24),

          // Delivery Options
          _buildDeliveryOptionsCard(),
        ],
      ),
    );
  }

  Widget _buildMilestoneTypeSelector() {
    final milestoneTypes = [
      {'type': 'first_date', 'label': 'First Date Anniversary'},
      {'type': '1_month', 'label': 'One Month Together'},
      {'type': '3_months', 'label': 'Three Months'},
      {'type': '6_months', 'label': 'Six Months'},
      {'type': '1_year', 'label': 'One Year Anniversary'},
      {'type': 'birthday', 'label': 'Birthday'},
      {'type': 'valentine', 'label': 'Valentine\'s Day'},
      {'type': 'christmas', 'label': 'Christmas'},
      {'type': 'general', 'label': 'Just Because'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          milestoneTypes.map((milestone) {
            final isSelected = milestone['type'] == _selectedMilestoneType;
            return FilterChip(
              label: Text(milestone['label']!),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedMilestoneType = milestone['type']!;
                  });
                  _loadGiftSuggestions();
                }
              },
              selectedColor: DatingTheme.primaryPink.withValues(alpha: 0.2),
              checkmarkColor: DatingTheme.primaryPink,
              labelStyle: TextStyle(
                color:
                    isSelected
                        ? DatingTheme.primaryPink
                        : DatingTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
    );
  }

  Widget _buildBudgetGuideCard(Map<String, dynamic> budgetGuide) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DatingTheme.accentGold.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: DatingTheme.accentGold),
              const SizedBox(width: 8),
              Text(
                'Budget Guide',
                style: DatingTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Recommended: ${budgetGuide['recommended']}',
            style: DatingTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: DatingTheme.accentGold,
            ),
          ),

          const SizedBox(height: 8),

          Text(budgetGuide['explanation'], style: DatingTheme.bodyStyle),

          const SizedBox(height: 12),

          Text(
            'Price Ranges:',
            style: DatingTheme.captionStyle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          ...(budgetGuide['ranges'] as Map<String, dynamic>).entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.toUpperCase(),
                    style: DatingTheme.captionStyle,
                  ),
                  Text(
                    entry.value,
                    style: DatingTheme.captionStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOptionsCard() {
    final deliveryOptions =
        _currentSuggestions?['delivery_options'] ??
        {
          'standard': '3-5 business days',
          'express': '1-2 business days',
          'same_day': 'Available in select cities',
        };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DatingTheme.secondaryPurple.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: DatingTheme.secondaryPurple),
              const SizedBox(width: 8),
              Text(
                'Delivery Options',
                style: DatingTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...deliveryOptions.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: DatingTheme.successGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${entry.key.toUpperCase()}: ${entry.value}',
                      style: DatingTheme.bodyStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            size: 64,
            color: DatingTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No gift suggestions available',
            style: DatingTheme.bodyStyle.copyWith(
              color: DatingTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your preferences or check back later',
            style: DatingTheme.captionStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMilestonesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_outlined,
            size: 64,
            color: DatingTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No upcoming milestones',
            style: DatingTheme.bodyStyle.copyWith(
              color: DatingTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your relationship start date to see milestone suggestions',
            style: DatingTheme.captionStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showGiftDetailsDialog(MilestoneGiftItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item.name, style: DatingTheme.headingStyle),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.imageUrl.isNotEmpty)
                  Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: DatingTheme.surfaceColor,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                _buildImagePlaceholder(item),
                      ),
                    ),
                  ),

                Text(
                  'Description',
                  style: DatingTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(item.description, style: DatingTheme.bodyStyle),

                const SizedBox(height: 16),

                Text(
                  'Why This Gift?',
                  style: DatingTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(item.milestoneRelevance, style: DatingTheme.bodyStyle),

                if (item.personalizationOptions.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Personalization Options',
                        style: DatingTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...item.personalizationOptions.map(
                        (option) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                size: 16,
                                color: DatingTheme.successGreen,
                              ),
                              const SizedBox(width: 8),
                              Text(option, style: DatingTheme.bodyStyle),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DatingTheme.primaryPink.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price',
                        style: DatingTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${item.price.toStringAsFixed(2)} CAD',
                        style: DatingTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: DatingTheme.primaryPink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addToCart(item);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DatingTheme.primaryPink,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add to Cart'),
            ),
          ],
        );
      },
    );
  }

  void _addToCart(MilestoneGiftItem item) {
    // TODO: Implement add to cart functionality
    _showSuccessSnackBar('${item.name} added to cart!');
  }

  void _viewMilestoneGifts(String milestoneType) {
    setState(() {
      _selectedMilestoneType = milestoneType;
    });
    _loadGiftSuggestions();
    _tabController.animateTo(0); // Switch to suggestions tab
  }
}
