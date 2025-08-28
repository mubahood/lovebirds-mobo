import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/my_colors.dart';
import '../screens/report_content_screen.dart';
import 'block_user_dialog_responsive.dart' as ResponsiveDialog;

/// Clear, visible moderation action buttons (not hidden in popups)
class ModerationActionButtons extends StatelessWidget {
  final String? contentType;
  final String? contentId;
  final String? contentTitle;
  final String? userId;
  final String? userName;
  final bool showReportButton;
  final bool showBlockButton;
  final bool compact;

  const ModerationActionButtons({
    Key? key,
    this.contentType,
    this.contentId,
    this.contentTitle,
    this.userId,
    this.userName,
    this.showReportButton = true,
    this.showBlockButton = true,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showReportButton && !showBlockButton) {
      return const SizedBox.shrink();
    }

    if (compact) {
      return _buildCompactButtons();
    } else {
      return _buildFullButtons();
    }
  }

  Widget _buildCompactButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showReportButton && contentType != null && contentId != null)
          IconButton(
            onPressed: () => _handleReport(),
            icon: const Icon(Icons.flag, color: Colors.orange, size: 20),
            tooltip: 'Report Content',
            visualDensity: VisualDensity.compact,
          ),
        if (showBlockButton && userId != null)
          IconButton(
            onPressed: () => _handleBlock(),
            icon: const Icon(Icons.block, color: Colors.red, size: 20),
            tooltip: 'Block User',
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  Widget _buildFullButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showReportButton && contentType != null && contentId != null) ...[
            ElevatedButton.icon(
              onPressed: () => _handleReport(),
              icon: const Icon(Icons.flag, size: 18),
              label: const Text('Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (showBlockButton && userId != null)
            ElevatedButton.icon(
              onPressed: () => _handleBlock(),
              icon: const Icon(Icons.block, size: 18),
              label: const Text('Block User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleReport() {
    Get.to(
      () => ReportContentScreen(
        initialContentType: contentType!,
        initialContentId: contentId!,
        initialContentTitle: contentTitle ?? 'Content',
        initialReportedUserId: userId,
      ),
    );
  }

  void _handleBlock() {
    if (userId != null) {
      ResponsiveDialog.BlockUserDialog.show(
        context: Get.context!,
        userId: userId!,
        userName: userName ?? 'User',
      );
    }
  }
}

/// Quick report button for easy integration
class QuickReportButton extends StatelessWidget {
  final String contentType;
  final String contentId;
  final String contentTitle;
  final String? reportedUserId;
  final bool showLabel;
  final Color? color;

  const QuickReportButton({
    Key? key,
    required this.contentType,
    required this.contentId,
    required this.contentTitle,
    this.reportedUserId,
    this.showLabel = false,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showLabel) {
      return TextButton.icon(
        onPressed: _handleReport,
        icon: Icon(Icons.flag, color: color ?? Colors.orange, size: 18),
        label: Text('Report', style: TextStyle(color: color ?? Colors.orange)),
      );
    } else {
      return IconButton(
        onPressed: _handleReport,
        icon: Icon(Icons.flag, color: color ?? Colors.orange),
        tooltip: 'Report Content',
      );
    }
  }

  void _handleReport() {
    Get.to(
      () => ReportContentScreen(
        initialContentType: contentType,
        initialContentId: contentId,
        initialContentTitle: contentTitle,
        initialReportedUserId: reportedUserId,
      ),
    );
  }
}

/// Quick block user button
class QuickBlockButton extends StatelessWidget {
  final String userId;
  final String userName;
  final bool showLabel;
  final Color? color;

  const QuickBlockButton({
    Key? key,
    required this.userId,
    required this.userName,
    this.showLabel = false,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showLabel) {
      return TextButton.icon(
        onPressed: _handleBlock,
        icon: Icon(Icons.block, color: color ?? Colors.red, size: 18),
        label: Text('Block', style: TextStyle(color: color ?? Colors.red)),
      );
    } else {
      return IconButton(
        onPressed: _handleBlock,
        icon: Icon(Icons.block, color: color ?? Colors.red),
        tooltip: 'Block User',
      );
    }
  }

  void _handleBlock() {
    showDialog(
      context: Get.context!,
      builder:
          (context) => ResponsiveDialog.BlockUserDialog(
            userId: userId,
            userName: userName,
          ),
    );
  }
}

/// Content moderation banner for showing status
class ContentModerationBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;

  const ContentModerationBanner({
    Key? key,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, color: textColor, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Floating action menu for moderation (alternative to hidden popups)
class ModerationFloatingMenu extends StatefulWidget {
  final String? contentType;
  final String? contentId;
  final String? contentTitle;
  final String? userId;
  final String? userName;

  const ModerationFloatingMenu({
    Key? key,
    this.contentType,
    this.contentId,
    this.contentTitle,
    this.userId,
    this.userName,
  }) : super(key: key);

  @override
  State<ModerationFloatingMenu> createState() => _ModerationFloatingMenuState();
}

class _ModerationFloatingMenuState extends State<ModerationFloatingMenu>
    with TickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.contentType != null && widget.contentId != null)
                _buildFloatingButton(
                  onPressed: () {
                    _toggle();
                    Get.to(
                      () => ReportContentScreen(
                        initialContentType: widget.contentType!,
                        initialContentId: widget.contentId!,
                        initialContentTitle: widget.contentTitle ?? 'Content',
                        initialReportedUserId: widget.userId,
                      ),
                    );
                  },
                  icon: Icons.flag,
                  label: 'Report',
                  backgroundColor: Colors.orange,
                ),
              const SizedBox(height: 8),
              if (widget.userId != null)
                _buildFloatingButton(
                  onPressed: () {
                    _toggle();
                    showDialog(
                      context: context,
                      builder:
                          (context) => ResponsiveDialog.BlockUserDialog(
                            userId: widget.userId!,
                            userName: widget.userName ?? 'User',
                          ),
                    );
                  },
                  icon: Icons.block,
                  label: 'Block',
                  backgroundColor: Colors.red,
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: MyColors.primary,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isOpen ? Icons.close : Icons.shield,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
  }) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
