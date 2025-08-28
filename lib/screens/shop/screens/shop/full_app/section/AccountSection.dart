import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/models/LoggedInUserModel.dart';

import '../../../../../../controllers/MainController.dart';
import '../../../../../../utils/CustomTheme.dart';
import '../../../../../../utils/Utilities.dart';
import '../../../../../../utils/consent_manager.dart';
import '../../../../../account/AccountDeletionRequestScreen.dart';
import '../../../../../dating/ProfileEditScreen.dart';
import '../../../../../dating/ProfileSetupWizardScreen.dart';
import '../../../../../profile/modern_profile_screen.dart';
import '../../../../../subscription/subscription_selection_screen.dart';
import '../../movies/DownloadListScreen.dart';
import '../full_app.dart';
import '../../../../../../features/legal/views/terms_of_service_screen.dart';
import '../../../../../../features/legal/views/privacy_policy_screen.dart';
import '../../../../../../features/legal/views/community_guidelines_screen.dart';
import '../../../../../../features/moderation/screens/moderation_home_screen.dart';
import '../../../../../../features/moderation/screens/my_reports_screen.dart';
import '../../../../../../features/moderation/screens/blocked_users_screen.dart';
import '../../../../../../features/moderation/screens/legal_consent_screen.dart';
import '../../../../../../features/account/screens/how_it_works_screen.dart';
import '../../../../../../features/account/screens/contact_us_screen.dart';

class AccountSection extends StatefulWidget {
  const AccountSection({Key? key}) : super(key: key);

  @override
  _AccountSectionState createState() => _AccountSectionState();
}

class _AccountSectionState extends State<AccountSection> {
  final MainController mainController = Get.find<MainController>();

  @override
  void initState() {
    super.initState();
    mainController.getLoggedInUser().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.background,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            FxContainer(width: 12, height: 24, color: CustomTheme.primary),
            const SizedBox(width: 12),
            FxText.titleLarge(
              "My Account",
              color: CustomTheme.accent,
              fontWeight: 900,
            ),
          ],
        ),
        actions: [
          // Premium subscription button - simplified as requested
          TextButton(
            onPressed: () => Get.to(() => const SubscriptionSelectionScreen()),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [CustomTheme.primary, CustomTheme.accent],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(FeatherIcons.user, color: CustomTheme.accent),
            onPressed: () => Get.to(() => const ModernProfileScreen()),
          ),
        ],
      ),
      body: Column(
        children: [
          Divider(color: CustomTheme.primary, thickness: 1, height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  // Account Management Section
                  _buildTile(
                    icon: FeatherIcons.edit,
                    label: "Update My Profile",
                    subtitle: "Set your account details",
                    onTap: () async {
                      mainController.loggedInUser =
                          await LoggedInUserModel.getLoggedInUser();
                      await Get.to(
                        () => ProfileSetupWizardScreen(
                          user: mainController.loggedInUser,
                        ),
                      );
                      await mainController.getLoggedInUser();
                      setState(() {});
                    },
                  ),

            /*      // Account Management Section
                  _buildTile(
                    icon: FeatherIcons.edit,
                    label: "Update My Full Profile",
                    subtitle: "Set your account details",
                    onTap: () async {
                      mainController.loggedInUser =
                          await LoggedInUserModel.getLoggedInUser();
                      await Get.to(
                        () => ProfileEditScreen(
                          user: mainController.loggedInUser,
                        ),
                      );
                      await mainController.getLoggedInUser();
                      setState(() {});
                    },
                  ),*/
/*                  _buildTile(
                    icon: FeatherIcons.user,
                    label: "My Profile",
                    subtitle:
                        "View and edit your profile, photos, and preferences",
                    onTap: () => Get.to(() => const ModernProfileScreen()),
                  ),*/
                  _buildTile(
                    icon: FeatherIcons.star,
                    label: "Premium Subscription",
                    subtitle: "Unlock premium features and benefits",
                    onTap:
                        () => Get.to(() => const SubscriptionSelectionScreen()),
                  ),

                  // Legal & Privacy Section Divider
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: FxText.bodyMedium(
                      "Legal & Privacy",
                      color: CustomTheme.primary,
                      fontWeight: 700,
                    ),
                  ),

                  _buildTile(
                    icon: FeatherIcons.fileText,
                    label: "Terms of Service",
                    subtitle: "View our terms and conditions",
                    onTap: () => Get.to(() => const TermsOfServiceScreen()),
                  ),
                  _buildTile(
                    icon: FeatherIcons.shield,
                    label: "Privacy Policy",
                    subtitle: "Learn about our privacy practices",
                    onTap: () => Get.to(() => const PrivacyPolicyScreen()),
                  ),
                  _buildTile(
                    icon: FeatherIcons.users,
                    label: "Community Guidelines",
                    subtitle: "Read our community standards",
                    onTap:
                        () => Get.to(() => const CommunityGuidelinesScreen()),
                  ),
                  _buildTile(
                    icon: FeatherIcons.checkCircle,
                    label: "Legal Consent",
                    subtitle: "Manage your consent preferences",
                    onTap: () => Get.to(() => const LegalConsentScreen()),
                  ),

                  // Safety & Moderation Section Divider
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: FxText.bodyMedium(
                      "Safety & Moderation",
                      color: CustomTheme.primary,
                      fontWeight: 700,
                    ),
                  ),

                  _buildTile(
                    icon: FeatherIcons.shield,
                    label: "Safety & Moderation",
                    subtitle: "Report content and manage safety",
                    onTap: () => Get.to(() => const ModerationHomeScreen()),
                  ),
                  _buildTile(
                    icon: FeatherIcons.flag,
                    label: "My Reports",
                    subtitle: "View your content reports",
                    onTap: () => Get.to(() => const MyReportsScreen()),
                  ),
                  _buildTile(
                    icon: FeatherIcons.userX,
                    label: "Blocked Users",
                    subtitle: "Manage blocked users",
                    onTap: () => Get.to(() => const BlockedUsersScreen()),
                  ),

                  // Support & Information Section Divider
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: FxText.bodyMedium(
                      "Support & Information",
                      color: CustomTheme.primary,
                      fontWeight: 700,
                    ),
                  ),

                  _buildTile(
                    icon: FeatherIcons.info,
                    label: "How It Works",
                    subtitle: "Learn how the app works",
                    onTap: () => Get.to(() => const HowItWorksScreen()),
                  ),
                  _buildTile(
                    icon: FeatherIcons.mail,
                    label: "Contact Us",
                    subtitle: "Get in touch with us",
                    onTap: () => Get.to(() => const ContactUsScreen()),
                  ),

                  // Account Actions Section Divider
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: FxText.bodyMedium(
                      "Account Actions",
                      color: CustomTheme.primary,
                      fontWeight: 700,
                    ),
                  ),

                  _buildTile(
                    icon: FeatherIcons.trash2,
                    label: "Delete My Account",
                    subtitle: "Delete my account.",
                    onTap: () {
                      Get.to(() => AccountDeletionRequestScreen());
                    },
                  ),
                  _buildTile(
                    icon: FeatherIcons.logOut,
                    label: "Logout",
                    subtitle: "Sign out of your account",
                    onTap: () async {
                      // Clear consent when logging out
                      await ConsentManager.clearConsent();
                      Utils.logout();
                      Utils.toast("Logged you out!");
                      Navigator.pop(context);
                      do_logout();
                    },
                    tileColor: CustomTheme.cardDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> do_logout() async {
    Utils.logout();
    Utils.toast("Logged you out!");
    Get.to(() => const HomeScreen());
    //Navigator.pushNamedAndRemoveUntil(context, AppConfig.FullApp, (r) => false);
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    Color? tileColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: tileColor ?? CustomTheme.card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, size: 28, color: CustomTheme.primary),
        title: FxText.bodyLarge(
          label,
          color: CustomTheme.color,
          fontWeight: 600,
        ),
        subtitle: FxText.bodySmall(subtitle, color: CustomTheme.color2),
        trailing: Icon(
          FeatherIcons.chevronRight,
          color: CustomTheme.primary,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}
