import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import '../../utils/CustomTheme.dart';

class MatchFilterWidget extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final Map<String, int> filterCounts;

  const MatchFilterWidget({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.filterCounts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            'all',
            'All Matches',
            Icons.favorite,
            filterCounts['all'] ?? 0,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'new',
            'New',
            Icons.fiber_new,
            filterCounts['new'] ?? 0,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'messaged',
            'Chatting',
            Icons.chat_bubble,
            filterCounts['messaged'] ?? 0,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'recent',
            'Recent',
            Icons.access_time,
            filterCounts['recent'] ?? 0,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'super_likes',
            'Super Likes',
            Icons.star,
            filterCounts['super_likes'] ?? 0,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String filter,
    String label,
    IconData icon,
    int count,
  ) {
    final isSelected = selectedFilter == filter;

    return GestureDetector(
      onTap: () => onFilterChanged(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? CustomTheme.primary : CustomTheme.card,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? CustomTheme.primary : CustomTheme.cardDark,
            width: 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: CustomTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : CustomTheme.color,
            ),
            const SizedBox(width: 6),
            FxText.bodyMedium(
              label,
              color: isSelected ? Colors.white : CustomTheme.color,
              fontWeight: isSelected ? 600 : 400,
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : CustomTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FxText.bodySmall(
                  count.toString(),
                  color: isSelected ? Colors.white : Colors.white,
                  fontWeight: 600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
