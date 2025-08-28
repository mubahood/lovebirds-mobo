import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/models/RespondModel.dart';
import 'package:lovebirds_app/screens/auth/login_screen.dart';
import 'package:lovebirds_app/utils/AppConfig.dart';
import 'package:lovebirds_app/utils/lovebirds_theme.dart';

import '../../models/LoggedInUserModel.dart';
import '../../src/features/app_introduction/view/splash_screen.dart';
import '../../utils/Utilities.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Utils.checkUpdate(); // Commented out to avoid errors
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
                        _buildTextField(
                          name: 'password',
                          label: 'Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            onPressed:
                                () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                            icon: Icon(
                              _obscurePassword
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

                        const SizedBox(height: 20),

                        // Confirm Password Field
                        _buildTextField(
                          name: 'password_confirm',
                          label: 'Confirm Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            onPressed:
                                () => setState(
                                  () =>
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword,
                                ),
                            icon: Icon(
                              _obscureConfirmPassword
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

                        const SizedBox(height: 32),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: LovebirdsTheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child:
                                _isLoading
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

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    String name = '';
    String email = '';
    String password_1 = '';
    String password_2 = '';

    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    name = _formKey.currentState?.fields['name']?.value ?? '';
    email = _formKey.currentState?.fields['email']?.value ?? '';
    password_1 = _formKey.currentState?.fields['password']?.value ?? '';
    password_2 = _formKey.currentState?.fields['password_confirm']?.value ?? '';

    setState(() => _isLoading = true);
    RespondModel? resp;
    try {
      resp = RespondModel(
        await Utils.http_post('auth/register', {
          'name': name,
          'email': email,
          'username': email,
          'password': password_1,
          'password_1': password_2,
        }),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
      return;
    } finally {
      setState(() => _isLoading = false);
    }
    if (resp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (resp.code != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resp.message ?? 'Registration failed. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }
    print("=================");
    print(resp.code.toString());
    print(resp.message.toString());
    print(resp.data.toString());
    print("=================");

    LoggedInUserModel user = LoggedInUserModel.fromJson(resp.data['user']);
    if (user.id < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = false);
    await user.save();
    Utils.toast('Welcome to ${AppConfig.APP_NAME}!');
    Get.offAll(() => const SplashScreen());

    return;
    try {
      // For now, just show success and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully! Welcome to Lovebirds!'),
          backgroundColor: LovebirdsTheme.primary,
        ),
      );

      Get.offAll(() => const SplashScreen());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
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
