import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

// Enums for safety functionality
enum EmergencyAction {
  quickExit,
  blockAndReport,
  safetyAlert,
  callSupport,
  emergencyServices,
}

enum ReportReason {
  inappropriateMessages,
  harassment,
  spam,
  fakeProfile,
  unsafeRequest,
  other,
}

class EmergencySafetyOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final EmergencyAction action;
  final int priority;

  EmergencySafetyOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.action,
    required this.priority,
  });
}

// Mock SafetyService for this widget
class MockSafetyService {
  Future<Map<String, dynamic>> reportUnsafeBehavior(
    String reportedUserId,
    String reportingUserId,
    ReportReason reason,
    String description,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'success': true,
      'message':
          'Report submitted successfully. Our safety team will review it within 24 hours.',
      'report_id': 'RPT${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  List<EmergencySafetyOption> getEmergencySafetyOptions() {
    return [
      EmergencySafetyOption(
        id: 'quick_exit',
        title: 'Quick Exit',
        description: 'Immediately exit the app',
        icon: Icons.exit_to_app,
        action: EmergencyAction.quickExit,
        priority: 1,
      ),
      EmergencySafetyOption(
        id: 'block_report',
        title: 'Block & Report',
        description: 'Block and report this user',
        icon: Icons.block,
        action: EmergencyAction.blockAndReport,
        priority: 2,
      ),
      EmergencySafetyOption(
        id: 'safety_alert',
        title: 'Safety Alert',
        description: 'Alert your emergency contacts',
        icon: Icons.warning,
        action: EmergencyAction.safetyAlert,
        priority: 3,
      ),
      EmergencySafetyOption(
        id: 'call_support',
        title: 'Call Support',
        description: 'Call our safety support line',
        icon: Icons.phone,
        action: EmergencyAction.callSupport,
        priority: 4,
      ),
      EmergencySafetyOption(
        id: 'emergency_services',
        title: 'Emergency Services',
        description: 'Call emergency services (911)',
        icon: Icons.local_hospital,
        action: EmergencyAction.emergencyServices,
        priority: 5,
      ),
    ];
  }
}

/// Emergency Safety Button Widget
/// Provides quick access to safety features when users feel uncomfortable
class EmergencySafetyButton extends StatefulWidget {
  final String? currentChatUserId;
  final VoidCallback? onQuickExit;

  const EmergencySafetyButton({
    super.key,
    this.currentChatUserId,
    this.onQuickExit,
  });

  @override
  State<EmergencySafetyButton> createState() => _EmergencySafetyButtonState();
}

class _EmergencySafetyButtonState extends State<EmergencySafetyButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _expandController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _expandAnimation;

  bool _isExpanded = false;
  final MockSafetyService _safetyService = MockSafetyService();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeOutBack),
    );

    // Start pulsing animation
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _expandController.forward();
      _pulseController.stop();
    } else {
      _expandController.reverse();
      _pulseController.repeat(reverse: true);
    }
  }

  void _handleEmergencyAction(EmergencyAction action) async {
    // Provide haptic feedback
    HapticFeedback.heavyImpact();

    switch (action) {
      case EmergencyAction.quickExit:
        await _handleQuickExit();
        break;
      case EmergencyAction.blockAndReport:
        await _handleBlockAndReport();
        break;
      case EmergencyAction.safetyAlert:
        await _handleSafetyAlert();
        break;
      case EmergencyAction.callSupport:
        await _handleCallSupport();
        break;
      case EmergencyAction.emergencyServices:
        await _handleEmergencyServices();
        break;
    }
  }

  Future<void> _handleQuickExit() async {
    // Close the safety options first
    _toggleExpansion();

    // Brief delay for animation
    await Future.delayed(const Duration(milliseconds: 200));

    // Call the quick exit callback or navigate away
    if (widget.onQuickExit != null) {
      widget.onQuickExit!();
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _handleBlockAndReport() async {
    if (widget.currentChatUserId == null) {
      _showErrorDialog('No user to block');
      return;
    }

    final confirmed = await _showConfirmationDialog(
      'Block and Report User',
      'This will block this user and report them to our safety team. This action cannot be undone.',
      confirmText: 'Block & Report',
      isDestructive: true,
    );

    if (confirmed) {
      await _showReportDialog();
    }
  }

  Future<void> _handleSafetyAlert() async {
    await _showSafetyAlertDialog();
  }

  Future<void> _handleCallSupport() async {
    const supportNumber = 'tel:+1-800-LOVEBRD'; // Example support number
    final uri = Uri.parse(supportNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showErrorDialog('Unable to make phone call');
    }
  }

  Future<void> _handleEmergencyServices() async {
    final confirmed = await _showConfirmationDialog(
      'Call Emergency Services',
      'This will call local emergency services (911). Only use this if you are in immediate danger.',
      confirmText: 'Call 911',
      isDestructive: true,
    );

    if (confirmed) {
      const emergencyNumber = 'tel:911';
      final uri = Uri.parse(emergencyNumber);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorDialog('Unable to call emergency services');
      }
    }
  }

  Future<bool> _showConfirmationDialog(
    String title,
    String message, {
    String confirmText = 'Confirm',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: Text(message, style: const TextStyle(fontSize: 16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDestructive ? Colors.red : Colors.pink,
                  foregroundColor: Colors.white,
                ),
                child: Text(confirmText),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  Future<void> _showReportDialog() async {
    ReportReason? selectedReason;
    String reportDescription = '';
    bool isSubmitting = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text(
                    'Report User',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Why are you reporting this user?',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        ...ReportReason.values.map(
                          (reason) => RadioListTile<ReportReason>(
                            title: Text(_getReasonDisplayText(reason)),
                            value: reason,
                            groupValue: selectedReason,
                            onChanged: (value) {
                              setState(() {
                                selectedReason = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Additional details (optional):',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Describe what happened...',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            reportDescription = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isSubmitting
                              ? null
                              : () {
                                Navigator.of(context).pop();
                              },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed:
                          isSubmitting || selectedReason == null
                              ? null
                              : () async {
                                setState(() {
                                  isSubmitting = true;
                                });

                                final result = await _safetyService
                                    .reportUnsafeBehavior(
                                      widget.currentChatUserId!,
                                      'current_user_id', // This would be actual user ID
                                      selectedReason!,
                                      reportDescription,
                                    );

                                setState(() {
                                  isSubmitting = false;
                                });

                                Navigator.of(context).pop();

                                if (result['success']) {
                                  _showSuccessDialog(
                                    'Report Submitted',
                                    result['message'],
                                  );
                                } else {
                                  _showErrorDialog(result['message']);
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child:
                          isSubmitting
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text('Submit Report'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _showSafetyAlertDialog() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Safety Alert',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield, size: 48, color: Colors.pink),
                SizedBox(height: 16),
                Text(
                  'Your safety alert has been sent to your emergency contacts.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'Emergency contacts have been notified that you may need assistance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  String _getReasonDisplayText(ReportReason reason) {
    switch (reason) {
      case ReportReason.inappropriateMessages:
        return 'Inappropriate Messages';
      case ReportReason.harassment:
        return 'Harassment';
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.fakeProfile:
        return 'Fake Profile';
      case ReportReason.unsafeRequest:
        return 'Unsafe Request';
      case ReportReason.other:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Safety options menu
        if (_isExpanded)
          Positioned(
            bottom: 80,
            right: 0,
            child: AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _expandAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children:
                          _safetyService
                              .getEmergencySafetyOptions()
                              .map((option) => _buildSafetyOption(option))
                              .toList(),
                    ),
                  ),
                );
              },
            ),
          ),

        // Main emergency button
        Positioned(
          bottom: 16,
          right: 16,
          child: GestureDetector(
            onTap: _toggleExpansion,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isExpanded ? 1.0 : _pulseAnimation.value,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isExpanded ? Icons.close : Icons.emergency,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyOption(EmergencySafetyOption option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleEmergencyAction(option.action),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            width: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        option.action == EmergencyAction.emergencyServices
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.pink.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    option.icon,
                    color:
                        option.action == EmergencyAction.emergencyServices
                            ? Colors.red
                            : Colors.pink,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        option.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
