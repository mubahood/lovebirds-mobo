import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/styles.dart';
import '../../../../models/LoggedInUserModel.dart';
import '../../../../models/RespondModel.dart';
import '../../../../utils/Utilities.dart';
import '../../../routing/routing.dart';
import '../../app_introduction/view/splash_screen.dart';
import '../controllers/create_account_screen_controller.dart';
import 'common_widgets/custom_button.dart';
import 'common_widgets/text_form_field.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  CreateAccountScreenController controller = CreateAccountScreenController();
  final bool _isLoaderVisible = false;
  @override
  void dispose(){
    super.dispose();
    controller.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Text(
                    'Create an Account',
                    style: AppStyles.googleFontMontserrat
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 24),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextFormField(
                            controller: controller.fullNameController,
                            labelText: 'Full Name',
                            validator: controller.validateFullName),
                        const SizedBox(height: 28.0),
                        CustomTextFormField(
                            controller: controller.emailController,
                            labelText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: controller.validateEmail),
                        const SizedBox(height: 28.0),
                        CustomTextFormField(
                            controller: controller.phoneNumberController,
                            labelText: 'Phone Number',
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            validator: controller.validatePhoneNumber),
                        const SizedBox(height: 28.0),
                        CustomTextFormField(
                            controller: controller.passwordController,
                            labelText: 'Password',
                            obscureText: true,
                            validator: controller.validatePassword),
                        const SizedBox(height: 28.0),
                        CustomTextFormField(
                            controller: controller.confirmPasswordController,
                            labelText: 'Confirm Password',
                            obscureText: true,
                            validator: controller.validateConfirmPassword),
                        const SizedBox(height: 28.0),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomElevatedButton(
                    onPressed: () async {
                      Map<String, dynamic> formDataMap = {};

                      final fullName = controller.fullNameController.text;
                      final email = controller.emailController.text;
                      final phoneNumber = controller.phoneNumberController.text;
                      final password = controller.passwordController.text;

                      //validate all
                      if (fullName.isEmpty) {
                        Utils.toast('Please enter your full name');
                        return;
                      }
                      if (email.isEmpty) {
                        Utils.toast('Please enter your email');
                        return;
                      }
                      if (phoneNumber.isEmpty) {
                        Utils.toast('Please enter your phone number');
                        return;
                      }
                      if (phoneNumber.length != 10) {
                        Utils.toast('Phone number must be 10 digits long');
                        return;
                      }
                      if (password.isEmpty) {
                        Utils.toast('Please enter a password');
                        return;
                      }
                      if (controller.confirmPasswordController.text.isEmpty) {
                        Utils.toast('Please confirm your password');
                        return;
                      }
                      if (controller.confirmPasswordController.text !=
                          controller.passwordController.text) {
                        Utils.toast('Passwords do not match');
                        return;
                      }

                      Utils.toast("Loading...");

                      formDataMap = {
                        'email': email,
                        'phone': phoneNumber,
                        'password': password,
                        'name': fullName,
                      };

                      RespondModel resp = RespondModel(
                          await Utils.http_post('register', formDataMap));

                      setState(() {});
                      if (resp.code != 1) {
                        Utils.toast(resp.message);
                        return;
                      }

                      LoggedInUserModel u =
                          LoggedInUserModel.fromJson(resp.data);

                      if (!(await u.save())) {
                        Utils.toast('failed to log you in ');
                        return;
                      }

                      LoggedInUserModel lu =
                          await LoggedInUserModel.getLoggedInUser();

                      if (lu.id < 1) {
                        Utils.toast('failed to retrieve you in');
                        return;
                      }

                      Utils.toast("Success!");

                      Get.off(() => const SplashScreen());
                    },
                    text: 'Register',
                  ),
                  const SizedBox(height: 18),
                  Wrap(children: [
                    Text(
                      'Already have an account?',
                      style: AppStyles.googleFontMontserrat
                          .copyWith(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    InkWell(
                      onTap: () {
                        AppRouter.goToLogin();
                      },
                      child: Text(
                        'Login',
                        style: AppStyles.googleFontMontserrat.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppStyles.secondaryColor),
                      ),
                    ),
                  ])
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }
}
