import 'package:get/get.dart';

import '../../screens/auth/login_screen.dart';
import '../../screens/shop/screens/shop/full_app/full_app.dart';
import '../../screens/shop/screens/shop/full_app/guest/GuestHomeScreen.dart';
import '../../screens/subscription/subscription_selection_screen.dart';
import '../../screens/subscription/subscription_history_screen.dart';
import '../features/app_introduction/view/onboarding_screens.dart';
import '../features/authentication/view/signup_screen.dart';
import '../features/home/view/resource_category_screen.dart';
import '../features/home/view/resource_subcategory_screen.dart';

import '../features/home/view/update_profile.dart';
import '../../features/moderation/screens/moderation_home_screen.dart';

class AppRouter {
  static const String onBoarding = '/';
  static const String register = '/register';
  static const String login = '/login';
  static const String home = '/homeScreen';
  static const String guest = '/guestMode';
  static const String resource = '/resources';
  static const String selectResourceCategory = '/selectResourceCategory';
  static const String updateProfile = '/updateProfile';
  static const String moderation = '/moderation';
  static const String subscription = '/subscription';
  static const String subscriptionHistory = '/subscription-history';
  static const String searchSubCategory = '/subCategory';
  static const String trainingSession = '/trainingSession';
  static const String trainingListScreen = '/trainingListScreen';
  static const String farmerProfilingScreenTwo = '/farmerScreenTwo';
  static const String farmerProfilingScreenThree = '/farmerScreenThree';
  static final List<GetPage> routes = [
    GetPage(name: onBoarding, page: () => const OnBoardingScreen()),
    GetPage(name: register, page: () => const CreateAccountScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: guest, page: () => const GuestHomeScreen()),
    GetPage(
      name: selectResourceCategory,
      page: () => const SelectCategoryScreen(),
    ),
    GetPage(name: updateProfile, page: () => UpdateProfileScreen()),
    GetPage(name: moderation, page: () => const ModerationHomeScreen()),
    GetPage(
      name: subscription,
      page: () => const SubscriptionSelectionScreen(),
    ),
    GetPage(
      name: subscriptionHistory,
      page: () => const SubscriptionHistoryScreen(),
    ),
    GetPage(name: searchSubCategory, page: () => SearchSubCategoryScreen()),
  ];

  static void goToSplash() {
    Get.offAllNamed(onBoarding);
  }

  static void goToOnBoarding() {
    Get.offAllNamed(onBoarding);
  }

  static void goToRegister() {
    Get.toNamed(register);
  }

  static void goToLogin() {
    Get.toNamed(login);
  }

  static void goToHome() {
    Get.toNamed(home);
  }

  static void goToUpdateProfile() {
    Get.toNamed(updateProfile);
  }

  static void goToModeration() {
    Get.toNamed(moderation);
  }

  static void goToGuest() {
    Get.offAllNamed(guest);
  }
}
