// lib/widgets/dating/swipe_shimmer.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/CustomTheme.dart';

/// A reusable shimmer placeholder box
class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius radius;

  const _ShimmerBox({
    this.width,
    required this.height,
    this.radius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: CustomTheme.cardDark,
      highlightColor: CustomTheme.card.withOpacity(0.2),
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: CustomTheme.cardDark,
          borderRadius: radius,
        ),
      ),
    );
  }
}

/// Shimmer placeholder for a swipe card
class SwipeCardShimmer extends StatelessWidget {
  const SwipeCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(20);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: border,
        child: Column(
          children: [
            // Image area
            Expanded(
              flex: 3,
              child: _ShimmerBox(
                height: double.infinity,
                radius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            // Info area
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & age
                  _ShimmerBox(width: 160, height: 24),
                  const SizedBox(height: 12),
                  // Bio lines
                  _ShimmerBox(height: 16),
                  const SizedBox(height: 8),
                  _ShimmerBox(width: 200, height: 16),
                  const SizedBox(height: 16),
                  // Tags
                  Row(
                    children: const [
                      _ShimmerBox(
                        width: 80,
                        height: 24,
                        radius: BorderRadius.all(Radius.circular(12)),
                      ),
                      SizedBox(width: 12),
                      _ShimmerBox(
                        width: 100,
                        height: 24,
                        radius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen loading interface with shimmer for swipe feature
class SwipeLoadingInterface extends StatelessWidget {
  const SwipeLoadingInterface({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardBorder = BorderRadius.circular(25);

    return Column(
      children: [
        // Top stats bar
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: CustomTheme.card,
            borderRadius: cardBorder,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _ShimmerBox(width: 100, height: 16),
              _ShimmerBox(width: 120, height: 16),
            ],
          ),
        ),

        // Card stack
        Expanded(
          child: Stack(
            children: [
              // Background card
              Positioned.fill(
                child: Transform.scale(
                  scale: 0.94,
                  child: Opacity(opacity: 0.6, child: const SwipeCardShimmer()),
                ),
              ),
              // Foreground card
              const Positioned.fill(child: SwipeCardShimmer()),
            ],
          ),
        ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Pass
              _ShimmerBox(
                width: 50,
                height: 50,
                radius: BorderRadius.circular(25),
              ),
              // Super like
              _ShimmerBox(
                width: 50,
                height: 50,
                radius: BorderRadius.circular(25),
              ),
              // Like
              _ShimmerBox(
                width: 60,
                height: 60,
                radius: BorderRadius.circular(30),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
