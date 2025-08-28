import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/features/legal/views/community_guidelines_screen.dart';
import 'package:lovebirds_app/features/legal/views/privacy_policy_screen.dart';
import 'package:lovebirds_app/features/legal/views/terms_of_service_screen.dart';

import '../../utils/Utilities.dart';
import 'modern_login_screen.dart';

/// Modern, Beautiful Register Screen with Enhanced UI/UX
class ModernRegisterScreen extends StatefulWidget {
  const ModernRegisterScreen({Key? key}) : super(key: key);

  @override
  ModernRegisterScreenState createState() => ModernRegisterScreenState();
}

class ModernRegisterScreenState extends State<ModernRegisterScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  // Form State
  final RxBool _isLoading = false.obs;
  final RxBool _obscurePassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;
  final RxInt _currentStep = 0.obs;

  // Legal acceptance
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _guidelinesAccepted = false;
  bool _ageVerified = false;

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    Utils.checkUpdate();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();

        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) _bounceController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep.value < 1) {
      _currentStep.value++;
      _pageController.animateToPage(
        _currentStep.value,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _register();
    }
  }

  void _previousStep() {
    if (_currentStep.value > 0) {
      _currentStep.value--;
      _pageController.animateToPage(
        _currentStep.value,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentStep.value > 0) {
      _previousStep();
      return false;
    }

    final shouldPop = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                FeatherIcons.alertCircle,
                color: Color(0xFFE91E63),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Cancel Registration?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to cancel the registration process?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(result: false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Color(0xFF718096),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

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
        body: Stack(
          children: [
            // Animated Background
            _buildAnimatedBackground(),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Header with progress
                  _buildHeader(),

                  // Form Pages
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (page) => _currentStep.value = page,
                      children: [
                        _buildAccountInfoPage(),
                        _buildLegalConsentPage(),
                      ],
                    ),
                  ),

                  // Navigation Buttons
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9C27B0),
            Color(0xFFE91E63),
            Color(0xFFFF6B9D),
            Color(0xFFFFB74D),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Floating elements
          ...List.generate(20, (index) {
            return Positioned(
              left: (index * 50.0) % MediaQuery.of(context).size.width,
              top: (index * 80.0) % MediaQuery.of(context).size.height,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),

          // Glass morphism overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
            child: Container(color: Colors.black.withValues(alpha: 0.05)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Back button and step indicator
            Row(
              children: [
                Obx(
                  () => AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _currentStep.value > 0 ? 1.0 : 0.5,
                    child: GestureDetector(
                      onTap:
                          _currentStep.value > 0
                              ? _previousStep
                              : () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          FeatherIcons.chevronLeft,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Step indicator
                Obx(
                  () => Row(
                    children: List.generate(2, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentStep.value == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              _currentStep.value >= index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Logo and title
            ScaleTransition(
              scale: _bounceAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFFFF8DC)],
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: const Icon(
                  FeatherIcons.heart,
                  color: Color(0xFFE91E63),
                  size: 40,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Obx(
              () => Text(
                _currentStep.value == 0 ? 'Create Account' : 'Legal Agreement',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Obx(
              () => Text(
                _currentStep.value == 0
                    ? 'Join thousands finding love in Canada'
                    : 'Please review and accept our terms',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoPage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name Field
                  _buildInputField(
                    name: 'name',
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    icon: FeatherIcons.user,
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(2),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Email Field
                  _buildInputField(
                    name: 'email',
                    label: 'Email Address',
                    hint: 'Enter your email',
                    icon: FeatherIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Password Field
                  Obx(
                    () => _buildInputField(
                      name: 'password',
                      label: 'Password',
                      hint: 'Create a strong password',
                      icon: FeatherIcons.lock,
                      obscureText: _obscurePassword.value,
                      suffixIcon: GestureDetector(
                        onTap: () => _obscurePassword.toggle(),
                        child: Icon(
                          _obscurePassword.value
                              ? FeatherIcons.eyeOff
                              : FeatherIcons.eye,
                          color: const Color(0xFF9CA3AF),
                          size: 20,
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
                    () => _buildInputField(
                      name: 'confirm_password',
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      icon: FeatherIcons.lock,
                      obscureText: _obscureConfirmPassword.value,
                      suffixIcon: GestureDetector(
                        onTap: () => _obscureConfirmPassword.toggle(),
                        child: Icon(
                          _obscureConfirmPassword.value
                              ? FeatherIcons.eyeOff
                              : FeatherIcons.eye,
                          color: const Color(0xFF9CA3AF),
                          size: 20,
                        ),
                      ),
                      validators: [
                        FormBuilderValidators.required(),
                        (value) {
                          final password =
                              _formKey.currentState?.fields['password']?.value;
                          if (value != password) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Date of Birth Field
                  _buildDateField(),

                  const SizedBox(height: 16),

                  // Password Requirements
                  _buildPasswordRequirements(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegalConsentPage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Legal Agreement',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Please review and accept our terms to create your account.',
                style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
              ),

              const SizedBox(height: 32),

              // Age Verification
              _buildConsentCheckbox(
                value: _ageVerified,
                text: 'I confirm that I am 18 years or older',
                onChanged: (value) => setState(() => _ageVerified = value),
                isRequired: true,
              ),

              const SizedBox(height: 20),

              // Terms of Service
              _buildConsentCheckbox(
                value: _termsAccepted,
                text: 'I agree to the ',
                linkText: 'Terms of Service',
                onChanged: (value) => setState(() => _termsAccepted = value),
                onTap: () => Get.to(() => const TermsOfServiceScreen()),
                isRequired: true,
              ),

              const SizedBox(height: 16),

              // Privacy Policy
              _buildConsentCheckbox(
                value: _privacyAccepted,
                text: 'I agree to the ',
                linkText: 'Privacy Policy',
                onChanged: (value) => setState(() => _privacyAccepted = value),
                onTap: () => Get.to(() => const PrivacyPolicyScreen()),
                isRequired: true,
              ),

              const SizedBox(height: 16),

              // Community Guidelines
              _buildConsentCheckbox(
                value: _guidelinesAccepted,
                text: 'I agree to the ',
                linkText: 'Community Guidelines',
                onChanged:
                    (value) => setState(() => _guidelinesAccepted = value),
                onTap: () => Get.to(() => const CommunityGuidelinesScreen()),
                isRequired: true,
              ),

              const SizedBox(height: 32),

              // Privacy Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      FeatherIcons.shield,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your privacy is our priority. We use industry-standard encryption to protect your data.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String name,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    List<String? Function(String?)>? validators,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        FormBuilderTextField(
          name: name,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: FormBuilderValidators.compose(validators ?? []),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
            ),
            suffixIcon:
                suffixIcon != null
                    ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: suffixIcon,
                    )
                    : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE91E63), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        FormBuilderDateTimePicker(
          name: 'date_of_birth',
          inputType: InputType.date,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            (value) {
              if (value != null) {
                final age = DateTime.now().difference(value).inDays / 365;
                if (age < 18) {
                  return 'You must be 18 or older to register';
                }
              }
              return null;
            },
          ]),
          decoration: InputDecoration(
            hintText: 'Select your date of birth',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                FeatherIcons.calendar,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE91E63), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password must contain:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirement('At least 8 characters'),
          _buildRequirement('One uppercase letter'),
          _buildRequirement('One lowercase letter'),
          _buildRequirement('One number'),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF9CA3AF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentCheckbox({
    required bool value,
    required String text,
    String? linkText,
    required Function(bool) onChanged,
    VoidCallback? onTap,
    bool isRequired = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? const Color(0xFFE91E63) : Colors.transparent,
              border: Border.all(
                color:
                    value ? const Color(0xFFE91E63) : const Color(0xFFD1D5DB),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child:
                value
                    ? const Icon(
                      FeatherIcons.check,
                      color: Colors.white,
                      size: 12,
                    )
                    : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              linkText != null
                  ? RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                      children: [
                        TextSpan(text: text),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: onTap,
                            child: Text(
                              linkText,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFFE91E63),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        if (isRequired)
                          const TextSpan(
                            text: ' *',
                            style: TextStyle(color: Color(0xFFEF4444)),
                          ),
                      ],
                    ),
                  )
                  : Text(
                    text + (isRequired ? ' *' : ''),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Main action button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading.value ? null : _getButtonAction(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  disabledBackgroundColor: const Color(
                    0xFFE91E63,
                  ).withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child:
                    _isLoading.value
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentStep.value == 0
                                  ? 'Continue'
                                  : 'Create Account',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentStep.value == 0
                                  ? FeatherIcons.arrowRight
                                  : FeatherIcons.heart,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sign in link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  VoidCallback? _getButtonAction() {
    if (_currentStep.value == 0) {
      return () {
        if (_formKey.currentState!.saveAndValidate()) {
          HapticFeedback.lightImpact();
          _nextStep();
        }
      };
    } else {
      return _canCreateAccount() ? _register : null;
    }
  }

  bool _canCreateAccount() {
    return _ageVerified &&
        _termsAccepted &&
        _privacyAccepted &&
        _guidelinesAccepted;
  }

  void _register() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    if (!_canCreateAccount()) {
      Get.snackbar(
        'Agreement Required',
        'Please accept all required terms and conditions',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    _isLoading.value = true;
    HapticFeedback.mediumImpact();

    try {
      final formData = _formKey.currentState!.value;

      // Add your registration logic here
      await _performRegistration(formData);
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _performRegistration(Map<String, dynamic> formData) async {
    // Simulate registration process
    await Future.delayed(const Duration(seconds: 2));

    // Add actual registration API call here
    // Example:
    // final response = await ApiService.register(formData);
    // if (response.success) {
    //   // Navigate to profile setup or main app
    //   Get.offAll(() => ProfileSetupScreen());
    // } else {
    //   throw Exception(response.message);
    // }

    // For now, just show success
    Get.snackbar(
      'Success!',
      'Welcome to Lovebirds! Please check your email for verification.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
