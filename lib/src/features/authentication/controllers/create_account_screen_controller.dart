import "package:flutter/material.dart";
import "package:get/get.dart";

import "base_controller.dart";
class CreateAccountScreenController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  final AuthController _authController = Get.put(AuthController());
  void dispose() {
// Dispose the controllers when they are no longer needed
    fullNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  String? validateFullName(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter your full name';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter your email';
    }
// Add additional email validation logic if needed
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter your phone number';
    }
    if (value?.length != 10) {
      return 'Phone number must be 10 digits long';
    }
// Add additional phone number validation logic if needed
    return null;
  }

  String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter a password';
    }
// Add additional password validation logic if needed
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
  Future<void> registerUser() async {
    if (formKey.currentState!.validate()) {
      final fullName = fullNameController.text;
      final email = emailController.text;
      final phoneNumber = phoneNumberController.text;
      final password = passwordController.text;

      _authController.registerUser(
        fullName: fullName,
        email: email.isNotEmpty ? email : null,
        phoneNumber: phoneNumber,
        password: password,
      );
    }
  }
}