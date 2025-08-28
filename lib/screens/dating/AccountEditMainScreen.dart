// lib/screens/account/AccountEditMainScreen.dart

import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../models/LoggedInUserModel.dart';
import '../../utils/CustomTheme.dart';
import '../gardens/AccountEditContactScreen.dart';
import '../account/blocked_users_screen.dart';
import 'AccountEditLifestyleScreen.dart';
import 'AccountEditPersonalScreen.dart';
import 'PhotoManagementScreen.dart';
import 'ProfileEditScreen.dart';
import 'ProfileSetupWizardScreen.dart';

class AccountEditMainScreen extends StatefulWidget {
  const AccountEditMainScreen({Key? key}) : super(key: key);

  @override
  _AccountEditMainScreenState createState() => _AccountEditMainScreenState();
}

class _AccountEditMainScreenState extends State<AccountEditMainScreen> {
  late LoggedInUserModel _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    _user = await LoggedInUserModel.getLoggedInUser();
    setState(() => _loading = false);
  }

  int get _profileCompletionPercentage {
    int completed = 0;
    int total = 8;

    if (_user.first_name.isNotEmpty) completed++;
    if (_user.last_name.isNotEmpty) completed++;
    if (_user.email.isNotEmpty) completed++;
    if (_user.phone_number.isNotEmpty) completed++;
    if (_user.bio.isNotEmpty) completed++;
    if (_user.dob.isNotEmpty) completed++;
    if (_user.sex.isNotEmpty) completed++;
    if (_user.avatar.isNotEmpty || _user.profile_photos.isNotEmpty) completed++;

    return ((completed / total) * 100).round();
  }

  bool get _accountComplete =>
      _user.email.isNotEmpty && _user.phone_number.isNotEmpty;

  bool get _personalComplete =>
      _user.first_name.isNotEmpty &&
      _user.last_name.isNotEmpty &&
      _user.dob.isNotEmpty &&
      _user.sex.isNotEmpty;

  bool get _lifestyleComplete =>
      _user.looking_for.isNotEmpty &&
      _user.interested_in.isNotEmpty &&
      _user.age_range_min.isNotEmpty &&
      _user.max_distance_km.isNotEmpty;

  bool get _photosComplete =>
      _user.avatar.isNotEmpty || _user.profile_photos.isNotEmpty;

  Future<void> _go<T>(Widget screen) async {
    await Get.to(() => screen);
    _user = await LoggedInUserModel.getLoggedInUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.background,
        iconTheme: const IconThemeData(color: CustomTheme.accent),
        elevation: 1,
        title: FxText.titleLarge(
          'Edit Profile',
          color: CustomTheme.accent,
          fontWeight: 700,
        ),
        centerTitle: true,
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(CustomTheme.accent),
                ),
              )
              : ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                children: [
                  // Profile completion card
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: CustomTheme.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CustomTheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FxText.titleMedium(
                              'Profile Completion',
                              color: Colors.white,
                              fontWeight: 600,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _profileCompletionPercentage >= 80
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : _profileCompletionPercentage >= 50
                                        ? Colors.orange.withValues(alpha: 0.2)
                                        : Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: FxText.bodyMedium(
                                '${_profileCompletionPercentage}%',
                                color:
                                    _profileCompletionPercentage >= 80
                                        ? Colors.green
                                        : _profileCompletionPercentage >= 50
                                        ? Colors.orange
                                        : Colors.red,
                                fontWeight: 700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _profileCompletionPercentage / 100,
                            backgroundColor: CustomTheme.color3.withOpacity(
                              0.2,
                            ),
                            valueColor: AlwaysStoppedAnimation(
                              _profileCompletionPercentage >= 80
                                  ? Colors.green
                                  : _profileCompletionPercentage >= 50
                                  ? Colors.orange
                                  : Colors.red,
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FxText.bodySmall(
                          _profileCompletionPercentage >= 80
                              ? 'Great! Your profile is looking fantastic!'
                              : _profileCompletionPercentage >= 50
                              ? 'Good progress! Complete your profile for more matches.'
                              : 'Complete your profile to get 3x more matches!',
                          color: CustomTheme.color2,
                        ),
                      ],
                    ),
                  ),

                  // Featured Profile Management
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FxText.bodyMedium(
                      'Profile Setup',
                      color: CustomTheme.accent,
                      fontWeight: 600,
                    ),
                  ),
                  _buildCard(
                    title: 'Complete Profile Wizard',
                    subtitle: 'Step-by-step comprehensive profile setup',
                    icon: Icons.auto_awesome,
                    done:
                        (_user.bio.isNotEmpty && _user.looking_for.isNotEmpty),
                    onTap:
                        () => _go(
                          ProfileSetupWizardScreen(
                            user: _user,
                            isEditing: true,
                          ),
                        ),
                  ),
                  _buildCard(
                    title: 'Quick Profile Edit',
                    subtitle: 'Basic profile information & photos',
                    icon: Icons.edit,
                    done:
                        (_user.first_name.isNotEmpty &&
                            _user.last_name.isNotEmpty),
                    onTap: () => _go(ProfileEditScreen(user: _user)),
                  ),
                  _buildCard(
                    title: 'Manage Photos',
                    subtitle: 'Upload, reorder & delete profile photos',
                    icon: Icons.photo_library,
                    done: _photosComplete,
                    onTap: () => _go(PhotoManagementScreen(user: _user)),
                  ),
                  const SizedBox(height: 16),

                  // Detailed Sections
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FxText.bodyMedium(
                      'Profile Details',
                      color: CustomTheme.accent,
                      fontWeight: 600,
                    ),
                  ),
                  _buildCard(
                    title: 'Account & Contact',
                    subtitle: 'Email, phone & address',
                    icon: Icons.contact_mail,
                    done: _accountComplete,
                    onTap: () => _go(AccountEditContactScreen(user: _user)),
                  ),
                  _buildCard(
                    title: 'Personal Details',
                    subtitle: 'Name, DOB & more',
                    icon: Icons.person,
                    done: _personalComplete,
                    onTap: () => _go(AccountEditPersonalScreen(user: _user)),
                  ),
                  _buildCard(
                    title: 'Lifestyle & Preferences',
                    subtitle: 'Your interests & habits',
                    icon: Icons.favorite,
                    done: _lifestyleComplete,
                    onTap: () => _go(AccountEditLifestyleScreen(user: _user)),
                  ),

                  const SizedBox(height: 16),

                  // Privacy & Safety Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FxText.bodyMedium(
                      'Privacy & Safety',
                      color: CustomTheme.accent,
                      fontWeight: 600,
                    ),
                  ),
                  _buildCard(
                    title: 'Blocked Users',
                    subtitle: 'Manage users you have blocked',
                    icon: Icons.block,
                    done: false, // Not completion-based
                    onTap: () => Get.to(() => const BlockedUsersScreen()),
                  ),
                  _buildCard(
                    title: 'Privacy Settings',
                    subtitle: 'Control who can see your profile',
                    icon: Icons.privacy_tip,
                    done: false, // Not completion-based
                    onTap: () {
                      // TODO: Navigate to privacy settings
                      Get.snackbar(
                        'Coming Soon',
                        'Privacy settings will be available in the next update',
                        backgroundColor: Colors.blue[100],
                        colorText: Colors.blue[800],
                        duration: const Duration(seconds: 2),
                      );
                    },
                  ),
                  _buildCard(
                    title: 'Safety Center',
                    subtitle: 'Safety tips and reporting tools',
                    icon: Icons.security,
                    done: false, // Not completion-based
                    onTap: () {
                      // TODO: Navigate to safety center
                      Get.snackbar(
                        'Coming Soon',
                        'Safety center will be available in the next update',
                        backgroundColor: Colors.blue[100],
                        colorText: Colors.blue[800],
                        duration: const Duration(seconds: 2),
                      );
                    },
                  ),
                ],
              ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool done,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          done ? CustomTheme.primary : CustomTheme.card,
                      child: Icon(
                        icon,
                        size: 20,
                        color: done ? Colors.white : CustomTheme.color2,
                      ),
                    ),
                    if (done)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: CustomTheme.accent,
                          child: const Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.bodyLarge(
                        title,
                        color: Colors.white,
                        fontWeight: 600,
                      ),
                      const SizedBox(height: 4),
                      FxText.bodySmall(subtitle, color: CustomTheme.color2),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: CustomTheme.color3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
