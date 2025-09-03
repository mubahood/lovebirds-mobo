import "package:flutter/material.dart";
import 'package:get/get.dart';

import '../../../../models/LoggedInUserModel.dart';
import '../../../../models/RespondModel.dart';
import '../../../../utils/Utilities.dart';
import '../../app_introduction/view/onboarding_screens.dart';
import 'base_controller.dart';

class LoginScreenController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());
  void dispose() {
    // Dispose the controllers when they are no longer needed

    emailController.dispose();
    passwordController.dispose();
  }

  String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter your email';
    }
    // Add additional email validation logic if needed
    return null;
  }

  String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter a password';
    }
    // Add additional password validation logic if needed
    return null;
  }

  Future<void> loginUser() async {
    final email = emailController.text;
    final password = passwordController.text;

    Map<String, dynamic> formDataMap = {};
    formDataMap = {'username': email, 'password': password};
    RespondModel resp = RespondModel(
      await Utils.http_post('login', formDataMap),
    );
    if (resp.code != 1) {
      Utils.toast(resp.message);
      return;
    }

    LoggedInUserModel u = LoggedInUserModel.fromJson(resp.data);

    if (!(await u.save())) {
      Utils.toast('failed to log you in ');
      return;
    }

    LoggedInUserModel lu = await LoggedInUserModel.getLoggedInUser();

    if (lu.id < 1) {
      Utils.toast('failed to retrieve you in');
      return;
    }

    Utils.toast("Success!");

    Get.off(() => const OnBoardingScreen());
  }
}
