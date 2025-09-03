import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../services/app_update_service.dart';

class UpdateCheckerWidget extends StatelessWidget {
  final bool showAsMenuItem;
  final VoidCallback? onPressed;

  const UpdateCheckerWidget({
    Key? key,
    this.showAsMenuItem = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showAsMenuItem) {
      return ListTile(
        leading: const Icon(FeatherIcons.download, color: Colors.blue),
        title: const Text('Check for Updates'),
        subtitle: const Text('See if a newer version is available'),
        onTap: () => _checkForUpdates(),
        trailing: const Icon(Icons.chevron_right),
      );
    }

    return InkWell(
      onTap: () => _checkForUpdates(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                FeatherIcons.download,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Check for Updates',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'See if a newer version is available',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.blue, size: 20),
          ],
        ),
      ),
    );
  }

  void _checkForUpdates() {
    if (onPressed != null) {
      onPressed!();
    } else {
      AppUpdateService.checkForUpdates(showNoUpdateDialog: true);
    }
  }
}

class AppUpdateWrapper extends StatefulWidget {
  final Widget child;
  final bool checkOnStart;

  const AppUpdateWrapper({
    Key? key,
    required this.child,
    this.checkOnStart = true,
  }) : super(key: key);

  @override
  _AppUpdateWrapperState createState() => _AppUpdateWrapperState();
}

class _AppUpdateWrapperState extends State<AppUpdateWrapper> {
  @override
  void initState() {
    super.initState();
    if (widget.checkOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeUpdateService();
      });
    }
  }

  Future<void> _initializeUpdateService() async {
    try {
      await AppUpdateService.initialize();
    } catch (e) {
      print('Failed to initialize update service: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
