import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/features/legal/views/community_guidelines_screen.dart';
import 'package:lovebirds_app/features/legal/views/privacy_policy_screen.dart';
import 'package:lovebirds_app/features/legal/views/terms_of_service_screen.dart';
import 'package:lovebirds_app/screens/auth/password_reset_screen.dart';
import 'package:lovebirds_app/screens/auth/register_screen.dart';
import 'package:lovebirds_app/utils/lovebirds_theme.dart';

import '../../models/LoggedInUserModel.dart';
import '../../models/RespondModel.dart';
import '../../src/features/app_introduction/view/onboarding_screens.dart';
import '../../utils/Utilities.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final RxBool _isLoading = false.obs;
  final RxBool _obscurePassword = true.obs;

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
          if (shouldPop && context.mounted) Navigator.of(context).pop();
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
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue your dating journey',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 25),
                  FormBuilder(
                    key: _formKey,
                    child: Column(
                      children: [
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
                        const SizedBox(height: 24),
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
                              FormBuilderValidators.minLength(4),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        _buildLegalConsentSection(),

                        const SizedBox(height: 32),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading.value ? null : _handleLogin,
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
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed:
                                () => Get.to(() => const PasswordResetScreen()),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account? ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                            TextButton(
                              onPressed:
                                  () => Get.to(() => const RegisterScreen()),
                              child: Text(
                                'Sign Up',
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
            'By signing in, you agree to our updated terms:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          _buildCheckboxRow(
            'Terms of Service',
            _termsAccepted,
            (v) => setState(() => _termsAccepted = v ?? false),
            () => Get.to(() => const TermsOfServiceScreen()),
          ),
          _buildCheckboxRow(
            'Privacy Policy',
            _privacyAccepted,
            (v) => setState(() => _privacyAccepted = v ?? false),
            () => Get.to(() => const PrivacyPolicyScreen()),
          ),
          _buildCheckboxRow(
            'Community Guidelines',
            _guidelinesAccepted,
            (v) => setState(() => _guidelinesAccepted = v ?? false),
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
    VoidCallback onView,
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
            onPressed: onView,
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

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.saveAndValidate()) return;
    if (!_termsAccepted || !_privacyAccepted || !_guidelinesAccepted) {
      Utils.toast('Please accept all legal agreements to continue');
      return;
    }

    _isLoading(true);

    try {
      final formData = _formKey.currentState!.value;
      final response = await Utils.http_post('auth/login', formData);
      final respModel = RespondModel(response);

      if (respModel.code == 1) {
        final user = LoggedInUserModel.fromJson(respModel.data['user']);

        // Save the auth token separately using new token management system
        if (user.token.isNotEmpty) {
          await LoggedInUserModel.saveToken(user.token);
          debugPrint('🔑 Login successful, token saved to SharedPreferences');
        }

        await user.save();
        Utils.toast('Welcome back!');
        Get.offAll(() => const OnBoardingScreen());
      } else {
        // **Show alert with server message**
        await showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                backgroundColor: LovebirdsTheme.surface,
                title: Text(
                  'Login Failed',
                  style: TextStyle(color: LovebirdsTheme.error),
                ),
                content: Text(
                  respModel.message,
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'OK',
                      style: TextStyle(color: LovebirdsTheme.primary),
                    ),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              backgroundColor: LovebirdsTheme.surface,
              title: Text(
                'Error',
                style: TextStyle(color: LovebirdsTheme.error),
              ),
              content: Text(
                'An unexpected error occurred.\n$e',
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'OK',
                    style: TextStyle(color: LovebirdsTheme.primary),
                  ),
                ),
              ],
            ),
      );
    } finally {
      _isLoading(false);
    }
  }

  Future<bool> _onWillPop() async {
    return await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: LovebirdsTheme.surface,
            title: Text('Exit', style: TextStyle(color: Colors.white)),
            content: Text(
              'Are you sure you want to exit?',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text(
                  'Exit',
                  style: TextStyle(color: LovebirdsTheme.primary),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
