import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../services/smart_search_service.dart';
import '../../utils/dating_theme.dart';
import '../../widgets/compatibility/compatibility_integration.dart';

/// Enhanced search result card with compatibility and match reasons
class SearchResultCard extends StatelessWidget {
  final SearchCandidate candidate;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onMessage;

  const SearchResultCard({
    Key? key,
    required this.candidate,
    this.onTap,
    this.onLike,
    this.onMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              DatingTheme.cardBackground,
              DatingTheme.cardBackground.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildContent(),
            _buildMatchReasons(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Profile image
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CachedNetworkImage(
              imageUrl:
                  candidate.user.avatar.isEmpty ? '' : candidate.user.avatar,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    width: 60,
                    height: 60,
                    color: DatingTheme.surfaceColor,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    width: 60,
                    height: 60,
                    color: DatingTheme.surfaceColor,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
            ),
          ),

          const SizedBox(width: 12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FxText.titleMedium(
                        '${candidate.user.first_name}, ${_calculateAge(candidate.user.dob)}',
                        color: Colors.white,
                        fontWeight: 700,
                      ),
                    ),
                    if (candidate.user.isVerified)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: DatingTheme.successGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FxText.bodySmall(
                          'Verified',
                          color: Colors.white,
                          fontWeight: 600,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 4),

                if (candidate.user.occupation.isNotEmpty)
                  FxText.bodyMedium(
                    candidate.user.occupation,
                    color: DatingTheme.secondaryText,
                  ),

                if (candidate.user.city.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: DatingTheme.secondaryText,
                      ),
                      const SizedBox(width: 4),
                      FxText.bodySmall(
                        candidate.user.city,
                        color: DatingTheme.secondaryText,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Compatibility indicator
          CompatibilityIndicator(targetUser: candidate.user, size: 40),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (candidate.user.bio.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        candidate.user.bio,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 14,
          height: 1.4,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMatchReasons() {
    if (candidate.matchReasons.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_outline,
                size: 16,
                color: DatingTheme.primaryPink,
              ),
              const SizedBox(width: 6),
              FxText.bodyMedium(
                'Why you match:',
                color: DatingTheme.primaryPink,
                fontWeight: 600,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                candidate.matchReasons.map((reason) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: DatingTheme.primaryPink.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: DatingTheme.primaryPink.withValues(alpha: 0.5),
                      ),
                    ),
                    child: FxText.bodySmall(
                      reason,
                      color: DatingTheme.primaryPink,
                      fontWeight: 500,
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Compatibility score display
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _getCompatibilityColor().withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  FxText.headlineSmall(
                    '${candidate.compatibilityScore.round()}%',
                    color: _getCompatibilityColor(),
                    fontWeight: 700,
                  ),
                  FxText.bodySmall(
                    'Compatible',
                    color: _getCompatibilityColor(),
                    fontWeight: 500,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Action buttons
          if (onMessage != null)
            _buildActionButton(
              icon: Icons.message_outlined,
              color: DatingTheme.primaryPink,
              onPressed: onMessage!,
            ),

          const SizedBox(width: 8),

          if (onLike != null)
            _buildActionButton(
              icon: Icons.favorite,
              color: DatingTheme.likeGreen,
              onPressed: onLike!,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Color _getCompatibilityColor() {
    if (candidate.compatibilityScore >= 80) return const Color(0xFF4CAF50);
    if (candidate.compatibilityScore >= 60) return const Color(0xFFFF9800);
    if (candidate.compatibilityScore >= 40) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  String _calculateAge(String dob) {
    if (dob.isEmpty) return 'N/A';

    try {
      final birthDate = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - birthDate.year;

      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }

      return age.toString();
    } catch (e) {
      return 'N/A';
    }
  }
}

/// Grid view for search results
class SearchResultsGrid extends StatelessWidget {
  final List<SearchCandidate> candidates;
  final Function(SearchCandidate)? onTap;
  final Function(SearchCandidate)? onLike;
  final Function(SearchCandidate)? onMessage;

  const SearchResultsGrid({
    Key? key,
    required this.candidates,
    this.onTap,
    this.onLike,
    this.onMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: candidates.length,
      itemBuilder: (context, index) {
        final candidate = candidates[index];
        return _buildGridCard(candidate);
      },
    );
  }

  Widget _buildGridCard(SearchCandidate candidate) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background image
            Container(
              height: double.infinity,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl:
                    candidate.user.avatar.isEmpty ? '' : candidate.user.avatar,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: DatingTheme.cardBackground,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: DatingTheme.cardBackground,
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
              ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // Compatibility indicator
            Positioned(
              top: 8,
              right: 8,
              child: CompatibilityIndicator(
                targetUser: candidate.user,
                size: 32,
              ),
            ),

            // User info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FxText.titleSmall(
                      '${candidate.user.first_name}, ${_calculateAge(candidate.user.dob)}',
                      color: Colors.white,
                      fontWeight: 700,
                    ),
                    if (candidate.user.city.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      FxText.bodySmall(
                        candidate.user.city,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateAge(String dob) {
    if (dob.isEmpty) return 'N/A';

    try {
      final birthDate = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - birthDate.year;

      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }

      return age.toString();
    } catch (e) {
      return 'N/A';
    }
  }
}
