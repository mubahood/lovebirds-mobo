import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';

import '../../models/UserModel.dart';
import '../../utils/CustomTheme.dart';
import '../common/responsive_dialog_wrapper.dart';

class SuperLikeDialog extends StatefulWidget {
  final UserModel user;
  final VoidCallback? onSuperLike;
  final VoidCallback? onCancel;
  final bool showUpgrade;

  const SuperLikeDialog({
    Key? key,
    required this.user,
    this.onSuperLike,
    this.onCancel,
    this.showUpgrade = false,
  }) : super(key: key);

  @override
  _SuperLikeDialogState createState() => _SuperLikeDialogState();
}

class _SuperLikeDialogState extends State<SuperLikeDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: ResponsiveDialogWrapper(
              backgroundColor: CustomTheme.card,
              child: _buildDialogContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogContent() {
    if (widget.showUpgrade) {
      return _buildUpgradeDialog();
    }
    return _buildSuperLikeDialog();
  }

  Widget _buildSuperLikeDialog() {
    return ResponsiveDialogColumn(
      children: [
        // Header with gradient background
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: ResponsiveDialogPadding(
            child: Column(
              children: [
                // Star icon with animation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.star, color: Colors.white, size: 40),
                ),

                const SizedBox(height: 16),

                // Title
                FxText.titleLarge(
                  'Super Like ${widget.user.name}!',
                  color: Colors.white,
                  fontWeight: 700,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Subtitle
                FxText.bodyMedium(
                  'Send a message to stand out and increase your chances of matching!',
                  color: Colors.white.withValues(alpha: 0.9),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        // Content area
        ResponsiveDialogPadding(
          child: Column(
            children: [
              // Message input
              Container(
                decoration: BoxDecoration(
                  color: CustomTheme.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 3,
                  maxLength: 200,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Write something that shows your interest...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    counterStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {}); // Rebuild to update button state
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: FxButton.block(
                      onPressed: _isLoading ? null : () => _handleCancel(),
                      backgroundColor: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(25),
                      child: FxText.bodyMedium(
                        'Cancel',
                        color: CustomTheme.color,
                        fontWeight: 600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    flex: 2,
                    child: FxButton.block(
                      onPressed: _isLoading ? null : () => _handleSuperLike(),
                      backgroundColor: Colors.blue,
                      borderRadius: BorderRadius.circular(25),
                      child:
                          _isLoading
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : FxText.bodyMedium(
                                'Send Super Like ⭐',
                                color: Colors.white,
                                fontWeight: 700,
                              ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeDialog() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomTheme.primary, CustomTheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crown icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.workspace_premium, color: Colors.white, size: 40),
          ),

          const SizedBox(height: 16),

          // Title
          FxText.titleLarge(
            'Out of Super Likes!',
            color: Colors.white,
            fontWeight: 700,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          FxText.bodyMedium(
            'Upgrade to Premium for unlimited super likes and more features!',
            color: Colors.white.withValues(alpha: 0.9),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Premium features
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildFeatureItem('Unlimited super likes'),
                _buildFeatureItem('Unlimited daily swipes'),
                _buildFeatureItem('See who liked you'),
                _buildFeatureItem('Undo swipes'),
                _buildFeatureItem('Profile boost'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Pricing
          FxText.bodyMedium(
            'Starting at \$10 CAD/week',
            color: Colors.white,
            fontWeight: 600,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: FxButton.block(
                  onPressed: () => _handleCancel(),
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(25),
                  child: FxText.bodyMedium(
                    'Maybe Later',
                    color: Colors.white,
                    fontWeight: 600,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 2,
                child: FxButton.block(
                  onPressed: () => _handleUpgrade(),
                  backgroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: CustomTheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      FxText.bodyMedium(
                        'Upgrade Now',
                        color: CustomTheme.primary,
                        fontWeight: 700,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          FxText.bodySmall(feature, color: Colors.white),
        ],
      ),
    );
  }

  void _handleSuperLike() {
    setState(() {
      _isLoading = true;
    });

    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Navigator.pop(context, {
          'action': 'super_like',
          'message': _messageController.text.trim(),
        });

        widget.onSuperLike?.call();
      }
    });
  }

  void _handleCancel() {
    Navigator.pop(context);
    widget.onCancel?.call();
  }

  void _handleUpgrade() {
    Navigator.pop(context, {'action': 'upgrade'});
    // TODO: Navigate to subscription screen
  }
}
