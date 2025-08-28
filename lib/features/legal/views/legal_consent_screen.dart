import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/models/LoggedInUserModel.dart';
import 'package:lovebirds_app/features/legal/managers/legal_consent_manager.dart';
import 'package:lovebirds_app/features/legal/views/terms_of_service_screen.dart';
import 'package:lovebirds_app/features/legal/views/privacy_policy_screen.dart';
import 'package:lovebirds_app/features/legal/views/community_guidelines_screen.dart';
import '../../../utils/CustomTheme.dart';
import '../../../utils/Utilities.dart';

class LegalConsentScreen extends StatefulWidget {
  final LoggedInUserModel user;
  final List<String> missingAcceptances;

  const LegalConsentScreen({
    Key? key,
    required this.user,
    required this.missingAcceptances,
  }) : super(key: key);

  @override
  State<LegalConsentScreen> createState() => _LegalConsentScreenState();
}

class _LegalConsentScreenState extends State<LegalConsentScreen> {
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _guidelinesAccepted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAcceptanceStatus();
  }

  void _initializeAcceptanceStatus() {
    _termsAccepted = widget.user.terms_of_service_accepted == "Yes";
    _privacyAccepted = widget.user.privacy_policy_accepted == "Yes";
    _guidelinesAccepted = widget.user.community_guidelines_accepted == "Yes";
  }

  bool get _allRequiredAccepted {
    bool termsNeeded = widget.missingAcceptances.contains("Terms of Service");
    bool privacyNeeded = widget.missingAcceptances.contains("Privacy Policy");
    bool guidelinesNeeded = widget.missingAcceptances.contains(
      "Community Guidelines",
    );

    return (!termsNeeded || _termsAccepted) &&
        (!privacyNeeded || _privacyAccepted) &&
        (!guidelinesNeeded || _guidelinesAccepted);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: CustomTheme.background,
        appBar: AppBar(
          backgroundColor: CustomTheme.background,
          automaticallyImplyLeading: false,
          title: const Text(
            'Welcome! Quick Setup',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 32),
              _buildLegalDocumentsSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CustomTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: CustomTheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Quick Setup',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Just check the boxes below to accept our agreements and continue using the app.',
            style: TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'You can read the full documents anytime by tapping "Read" next to each agreement.',
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Legal Agreements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Simply check the boxes below to accept and continue:',
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 16),

        if (widget.missingAcceptances.contains("Terms of Service"))
          _buildSimpleCheckboxTile(
            'Terms of Service',
            'I agree to the Terms of Service',
            () async {
              await Get.to(() => const TermsOfServiceScreen(isRequired: false));
            },
            _termsAccepted,
            (value) => setState(() => _termsAccepted = value ?? false),
          ),

        if (widget.missingAcceptances.contains("Privacy Policy"))
          _buildSimpleCheckboxTile(
            'Privacy Policy',
            'I agree to the Privacy Policy',
            () async {
              await Get.to(() => const PrivacyPolicyScreen(isRequired: false));
            },
            _privacyAccepted,
            (value) => setState(() => _privacyAccepted = value ?? false),
          ),

        if (widget.missingAcceptances.contains("Community Guidelines"))
          _buildSimpleCheckboxTile(
            'Community Guidelines',
            'I agree to the Community Guidelines',
            () async {
              await Get.to(
                () => const CommunityGuidelinesScreen(isRequired: false),
              );
            },
            _guidelinesAccepted,
            (value) => setState(() => _guidelinesAccepted = value ?? false),
          ),
      ],
    );
  }

  Widget _buildSimpleCheckboxTile(
    String title,
    String checkboxText,
    VoidCallback onReadMore,
    bool isAccepted,
    ValueChanged<bool?> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isAccepted
                  ? Colors.green.withValues(alpha: 0.5)
                  : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isAccepted ? Colors.green : Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: onReadMore,
                child: const Text(
                  'Read',
                  style: TextStyle(
                    color: CustomTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: isAccepted,
                onChanged: onChanged,
                activeColor: Colors.green,
                checkColor: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(!isAccepted),
                  child: Text(
                    checkboxText,
                    style: TextStyle(
                      fontSize: 14,
                      color: isAccepted ? Colors.green : Colors.white70,
                      fontWeight:
                          isAccepted ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _allRequiredAccepted && !_isLoading ? _handleAcceptAll : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _allRequiredAccepted ? Colors.green : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text(
                      _allRequiredAccepted
                          ? 'Continue to App'
                          : 'Please check all boxes above',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _isLoading ? null : _handleDecline,
          child: const Text(
            'I do not accept - Log me out.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAcceptAll() async {
    setState(() => _isLoading = true);

    try {
      // Update user's legal acceptance status
      await LegalConsentManager.updateAllLegalAcceptances(
        widget.user,
        _termsAccepted,
        _privacyAccepted,
        _guidelinesAccepted,
      );

      Utils.toast('Legal agreements accepted successfully!');
      Get.back(result: true);
    } catch (e) {
      Utils.toast('Error saving acceptance status. Please try again.');
      Utils.log('Error saving legal acceptance: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleDecline() {
    Get.dialog(
      AlertDialog(
        backgroundColor: CustomTheme.card,
        title: const Text(
          'Logout Required',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'You must accept our legal agreements to use Lovebirds Dating. Declining will log you out of the app.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Utils.logout();
              Get.back(); // Close dialog
              Get.back(result: false); // Close legal consent screen
              Utils.toast('You have been logged out.');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
