import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/moderation_home_screen.dart';

class ModerationFloatingButton extends StatelessWidget {
  const ModerationFloatingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Get.to(() => const ModerationHomeScreen());
      },
      backgroundColor: const Color(0xFF8B1538),
      child: const Icon(Icons.security, color: Colors.white),
      tooltip: 'Safety & Moderation',
    );
  }
}

class ModerationQuickActions extends StatelessWidget {
  const ModerationQuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickAction(
            icon: Icons.security,
            label: 'Moderation',
            color: const Color(0xFF8B1538),
            onTap: () => Get.to(() => const ModerationHomeScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
