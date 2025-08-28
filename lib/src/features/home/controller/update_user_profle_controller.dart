import "package:get/get.dart";
import "package:flutter/material.dart";
import "../../authentication/controllers/base_controller.dart";
import "../../authentication/models/user_update_form_data.dart";
class UpdateProfileController extends GetxController {
  final UserProfile userProfile = UserProfile();

  // TextEditingController instances for dialog fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Method to update the name in the UserProfile
  void updateName(String newName) {
    userProfile.name = newName;
  }
  void updatePhoto(String? photo){
    userProfile.photo = photo;
  }

  // Method to update other profile fields similarly
  void updatePhone(String newPhone) {
    userProfile.phone = newPhone;
  }

  void updateEmail(String newEmail) {
    userProfile.email = newEmail;
  }

  void updatePassword(String newPassword) {
    userProfile.password = newPassword;
  }

  // Method to update the user profile on the API
  Future<void> updateUserProfile() async {
    // Perform the API request using the userProfile data
    // ...

    // For example, you can use the UserController class to handle the API request
    AuthController authController = Get.find();
    await authController.updateUserProfile(userProfile: userProfile);
  }

  @override
  void onClose() {
    // Dispose of the TextEditingController instances when not needed anymore
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}