import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/features/legal/managers/legal_consent_manager.dart';
import 'package:lovebirds_app/features/legal/views/community_guidelines_screen.dart';
import 'package:lovebirds_app/features/legal/views/privacy_policy_screen.dart';
import 'package:lovebirds_app/features/legal/views/terms_of_service_screen.dart';
import 'package:lovebirds_app/screens/auth/login_screen.dart';
import 'package:lovebirds_app/src/features/app_introduction/view/onboarding_screens.dart';
import 'package:lovebirds_app/utils/lovebirds_theme.dart';

import '../../models/LoggedInUserModel.dart';
import '../../models/RespondModel.dart';
import '../../utils/AppConfig.dart';
import '../../utils/Utilities.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final RxBool _isLoading = false.obs;
  final RxBool _obscurePassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;

  // Legal acceptance checkboxes
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _guidelinesAccepted = false;

  @override
  void initState() {
    super.initState();
    Utils.checkUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: LovebirdsTheme.background,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                LovebirdsTheme.primary,
                LovebirdsTheme.primary.withOpacity(0.8),
                LovebirdsTheme.background,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),

                  const SizedBox(height: 24),

                  // Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join Lovebirds and start your dating journey',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Registration Form
                  FormBuilder(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Full Name Field
                        _buildTextField(
                          name: 'name',
                          label: 'Full Name',
                          prefixIcon: Icons.person_outline,
                          keyboardType: TextInputType.name,
                          validators: [
                            FormBuilderValidators.required(),
                            FormBuilderValidators.minLength(2),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Email Field
                        _buildTextField(
                          name: 'email',
                          label: 'Email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validators: [
                            FormBuilderValidators.required(),
                            FormBuilderValidators.email(),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Password Field
                        Obx(
                          () => _buildTextField(
                            name: 'password',
                            label: 'Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword.value,
                            suffixIcon: IconButton(
                              onPressed: () => _obscurePassword.toggle(),
                              icon: Icon(
                                _obscurePassword.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            validators: [
                              FormBuilderValidators.required(),
                              FormBuilderValidators.minLength(8),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Confirm Password Field
                        Obx(
                          () => _buildTextField(
                            name: 'password_confirm',
                            label: 'Confirm Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscureConfirmPassword.value,
                            suffixIcon: IconButton(
                              onPressed: () => _obscureConfirmPassword.toggle(),
                              icon: Icon(
                                _obscureConfirmPassword.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            validators: [
                              FormBuilderValidators.required(),
                              (value) {
                                final password =
                                    _formKey
                                        .currentState
                                        ?.fields['password']
                                        ?.value;
                                if (value != password) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Age Verification
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified_user,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'By creating an account, you confirm that you are 18 years or older.',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Legal Consent Section
                        _buildLegalConsentSection(),

                        const SizedBox(height: 32),

                        // Register Button
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading.value ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: LovebirdsTheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: 0,
                              ),
                              child:
                                  _isLoading.value
                                      ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                LovebirdsTheme.primary,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Sign In Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.off(() => const LoginScreen());
                              },
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String name,
    required String label,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    required List<String? Function(String?)> validators,
  }) {
    return FormBuilderTextField(
      name: name,
      style: TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        floatingLabelStyle: TextStyle(color: Colors.white),
        prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.7)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade300, width: 2),
        ),
        errorStyle: TextStyle(color: Colors.red.shade300),
      ),
      validator: FormBuilderValidators.compose(validators),
    );
  }

  Widget _buildLegalConsentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legal Agreements',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'To create your account, please accept our terms:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          _buildCheckboxRow(
            'Terms of Service',
            _termsAccepted,
            (value) => setState(() => _termsAccepted = value ?? false),
            () => Get.to(() => const TermsOfServiceScreen()),
          ),
          _buildCheckboxRow(
            'Privacy Policy',
            _privacyAccepted,
            (value) => setState(() => _privacyAccepted = value ?? false),
            () => Get.to(() => const PrivacyPolicyScreen()),
          ),
          _buildCheckboxRow(
            'Community Guidelines',
            _guidelinesAccepted,
            (value) => setState(() => _guidelinesAccepted = value ?? false),
            () => Get.to(() => const CommunityGuidelinesScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(
    String text,
    bool value,
    ValueChanged<bool?> onChanged,
    VoidCallback onViewDocument,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            checkColor: LovebirdsTheme.primary,
            side: BorderSide(color: Colors.white.withOpacity(0.5)),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(!value),
              child: Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
          TextButton(
            onPressed: onViewDocument,
            child: Text(
              'Read',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    if (!_termsAccepted || !_privacyAccepted || !_guidelinesAccepted) {
      Utils.toast('Please accept all legal agreements to continue');
      return;
    }

    _isLoading(true);

    try {
      final formData = Map<String, dynamic>.from(_formKey.currentState!.value);

      // Remove confirm password field as it's not needed for API
      formData.remove('password_confirm');

      final response = await Utils.http_post('auth/register', formData);
      final responseModel = RespondModel(response);

      if (responseModel.code == 1) {
        final userData = responseModel.data['user'];
        LoggedInUserModel user = LoggedInUserModel.fromJson(userData);
        await user.save();

        // Update legal consent status
        await LegalConsentManager.setLocalConsent(
          userId: user.id.toString(),
          documentType: 'terms',
          accepted: true,
        );
        await LegalConsentManager.setLocalConsent(
          userId: user.id.toString(),
          documentType: 'privacy',
          accepted: true,
        );

        Utils.toast('Account created successfully! Welcome to Lovebirds!');
        Get.offAll(() => const OnBoardingScreen());
      } else {
        Utils.toast(responseModel.message ?? 'Registration failed');
      }
    } catch (e) {
      Utils.toast('Network error. Please try again.');
    } finally {
      _isLoading(false);
    }
  }

  Future<bool> _onWillPop() async {
    return await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: LovebirdsTheme.surface,
            title: Text(
              'Cancel Registration',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Are you sure you want to cancel registration?',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(
                  'Continue',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: LovebirdsTheme.primary),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
