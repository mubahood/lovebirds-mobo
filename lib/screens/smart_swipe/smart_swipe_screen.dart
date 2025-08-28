import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:provider/provider.dart';

import '../../models/UserModel.dart';
import '../../providers/user_provider.dart';
import '../../services/enhanced_swipe_service.dart';
import '../../utils/dating_theme.dart';
import '../compatibility/compatibility_score_widget.dart';
import '../swipe/enhanced_swipe_card.dart';

/// Enhanced swipe screen with compatibility scoring integration
class SmartSwipeScreen extends StatefulWidget {
  const SmartSwipeScreen({Key? key}) : super(key: key);

  @override
  _SmartSwipeScreenState createState() => _SmartSwipeScreenState();
}

class _SmartSwipeScreenState extends State<SmartSwipeScreen>
    with TickerProviderStateMixin {
  List<SwipeCandidate> _candidates = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  late AnimationController _swipeController;
  late AnimationController _compatibilityController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCandidates();
  }

  void _initializeAnimations() {
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _compatibilityController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _compatibilityController.dispose();
    super.dispose();
  }

  Future<void> _loadCandidates() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;

      if (currentUser != null) {
        final candidates = await SwipeService.getSwipeCandidates(
          limit: 20,
          currentUser: currentUser,
        );

        setState(() {
          _candidates = candidates;
          _currentIndex = 0;
          _isLoading = false;
        });

        // Start compatibility animation for first card
        if (candidates.isNotEmpty) {
          _compatibilityController.forward();
        }
      }
    } catch (e) {
      print('Error loading candidates: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performSwipe(String action) async {
    if (_currentIndex >= _candidates.length) return;

    final candidate = _candidates[_currentIndex];
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) return;

    try {
      final result = await SwipeService.performSwipe(
        targetUserId: candidate.user.id,
        action: action,
        compatibilityScore: candidate.compatibilityScore,
      );

      if (result.success) {
        if (result.isMatch) {
          await _showMatchDialog(candidate);
        }

        await _animateSwipe();
        _moveToNextCandidate();
      } else {
        _showErrorSnackBar(result.message);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to process swipe: $e');
    }
  }

  Future<void> _animateSwipe() async {
    await _swipeController.forward();
    _swipeController.reset();
  }

  void _moveToNextCandidate() {
    setState(() {
      _currentIndex++;
    });

    // Reset and restart compatibility animation for new card
    _compatibilityController.reset();
    if (_currentIndex < _candidates.length) {
      _compatibilityController.forward();
    }

    // Load more candidates if running low
    if (_currentIndex >= _candidates.length - 3) {
      _loadMoreCandidates();
    }
  }

  Future<void> _loadMoreCandidates() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    if (currentUser != null) {
      final newCandidates = await SwipeService.getSwipeCandidates(
        limit: 10,
        currentUser: currentUser,
      );

      setState(() {
        _candidates.addAll(newCandidates);
      });
    }
  }

  Future<void> _showMatchDialog(SwipeCandidate candidate) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: DatingTheme.heartGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, color: Colors.white, size: 80),
                const SizedBox(height: 20),
                FxText.headlineMedium(
                  'It\'s a Match!',
                  color: Colors.white,
                  fontWeight: 700,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FxText.bodyLarge(
                  'You and ${candidate.user.first_name} have ${candidate.compatibilityScore.round()}% compatibility!',
                  color: Colors.white.withValues(alpha: 0.9),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Keep Swiping'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Navigate to chat
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: DatingTheme.primaryPink,
                        ),
                        child: const Text('Say Hello'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: DatingTheme.errorRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DatingTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FxText.titleLarge(
          'Discover',
          color: Colors.white,
          fontWeight: 600,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadCandidates,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    DatingTheme.primaryPink,
                  ),
                ),
              )
              : _buildSwipeContent(),
    );
  }

  Widget _buildSwipeContent() {
    if (_candidates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            FxText.headlineSmall(
              'No More Profiles',
              color: Colors.white,
              fontWeight: 600,
            ),
            const SizedBox(height: 8),
            FxText.bodyLarge(
              'Check back later for new matches!',
              color: Colors.white.withValues(alpha: 0.7),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCandidates,
              style: ElevatedButton.styleFrom(
                backgroundColor: DatingTheme.primaryPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    if (_currentIndex >= _candidates.length) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(DatingTheme.primaryPink),
        ),
      );
    }

    final candidate = _candidates[_currentIndex];
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text('User not found', style: TextStyle(color: Colors.white)),
      );
    }

    return Stack(
      children: [
        // Next card preview
        if (_currentIndex + 1 < _candidates.length)
          Positioned.fill(
            child: Transform.scale(
              scale: 0.95,
              child: Opacity(
                opacity: 0.7,
                child: EnhancedSwipeCard(
                  candidate: _candidates[_currentIndex + 1],
                  currentUser: currentUser,
                ),
              ),
            ),
          ),

        // Current card
        AnimatedBuilder(
          animation: _swipeController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                _swipeController.value * MediaQuery.of(context).size.width,
                0,
              ),
              child: Transform.rotate(
                angle: _swipeController.value * 0.3,
                child: EnhancedSwipeCard(
                  candidate: candidate,
                  currentUser: currentUser,
                  onLike: () => _performSwipe('like'),
                  onSuperLike: () => _performSwipe('super_like'),
                  onPass: () => _performSwipe('pass'),
                  onViewProfile: () => _showProfileDetails(candidate),
                ),
              ),
            );
          },
        ),

        // Smart recommendations overlay
        Positioned(
          top: 100,
          left: 20,
          right: 20,
          child: AnimatedBuilder(
            animation: _compatibilityController,
            builder: (context, child) {
              return Opacity(
                opacity: _compatibilityController.value,
                child: _buildSmartRecommendation(candidate),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSmartRecommendation(SwipeCandidate candidate) {
    final recommendation = SwipeService.getSuggestedAction(
      Provider.of<UserProvider>(context, listen: false).currentUser!,
      candidate.user,
    );

    String message = '';
    Color color = DatingTheme.primaryPink;
    IconData icon = Icons.favorite;

    switch (recommendation) {
      case 'super_like':
        message = 'Highly Compatible! Consider Super Like ⭐';
        color = DatingTheme.superLikePurple;
        icon = Icons.star;
        break;
      case 'like':
        message = 'Great Match Potential! 💖';
        color = DatingTheme.likeGreen;
        icon = Icons.favorite;
        break;
      default:
        return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          FxText.bodyMedium(message, color: Colors.white, fontWeight: 600),
        ],
      ),
    );
  }

  void _showProfileDetails(SwipeCandidate candidate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: DatingTheme.cardBackground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      // Profile info
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            FxText.headlineMedium(
                              candidate.user.first_name,
                              color: Colors.white,
                              fontWeight: 700,
                            ),
                            const SizedBox(height: 20),

                            // Detailed compatibility display
                            CompatibilityScoreWidget(
                              user1:
                                  Provider.of<UserProvider>(
                                    context,
                                  ).currentUser!,
                              user2: candidate.user,
                              showDetails: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
