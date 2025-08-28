import 'dart:convert';
import 'package:flutx/flutx.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

import '../../../../core/styles.dart';
import '../../../../utils/CustomTheme.dart';
import '../../../../widgets/common/responsive_dialog_wrapper.dart';
import '../../../../features/moderation/screens/my_reports_screen.dart';
import '../../../../features/moderation/screens/blocked_users_screen.dart';
import '../../../../features/moderation/screens/report_content_screen.dart';
import '../../../../features/moderation/screens/legal_consent_screen.dart';
import '../controller/update_user_profle_controller.dart';
// Import the UpdateProfileController

class UpdateProfileScreen extends StatelessWidget {
  final UpdateProfileController _controller = Get.put(
    UpdateProfileController(),
  ); // Initialize the UpdateProfileController

  UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: FxText.titleLarge('My Profile', color: Colors.white),
        backgroundColor: CustomTheme.primary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: CustomTheme.primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const ProfilePicturePicker(),
              const SizedBox(height: 24),
              ProfileField(
                icon: Icons.person,
                label: 'Name',
                currentValue: 'John Doe', // Replace with user's current name
                onEditTapped: () {
                  _showEditDialog(context, 'Name', _controller.nameController, (
                    newValue,
                  ) {
                    _controller.updateName(newValue);
                  });
                },
              ),
              ProfileField(
                icon: Icons.phone,
                label: 'Phone Number',
                currentValue:
                    '+1 123 456 7890', // Replace with user's current phone number
                onEditTapped: () {
                  _showEditDialog(
                    context,
                    'Phone Number',
                    _controller.phoneController,
                    (newValue) {
                      _controller.updatePhone(newValue);
                    },
                  );
                },
              ),
              ProfileField(
                icon: Icons.email,
                label: 'Email',
                currentValue:
                    'john.doe@example.com', // Replace with user's current email
                onEditTapped: () {
                  _showEditDialog(
                    context,
                    'Email',
                    _controller.emailController,
                    (newValue) {
                      _controller.updateEmail(newValue);
                    },
                  );
                },
              ),
              ProfileField(
                icon: Icons.lock,
                label: 'Password',
                currentValue: 'romina',
                onEditTapped: () {
                  _showEditDialog(
                    context,
                    'Password',
                    _controller.passwordController,
                    (newValue) {
                      _controller.updatePassword(newValue);
                    },
                  );
                },
                isPassword: true,
              ),
              const SizedBox(height: 24),

              // User ID and Moderation Section
              _buildUserInfoSection(),
              const SizedBox(height: 16),
              _buildModerationSection(),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryColor,
                  surfaceTintColor: AppStyles.primaryColor,
                ),
                onPressed: () {
                  _controller
                      .updateUserProfile(); // Handle the form submission and update the profile
                },
                child: const Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_circle,
                  color: CustomTheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Account Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.badge, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User ID',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '#123456', // This should be replaced with actual user ID
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Report This User Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.to(
                    () => const ReportContentScreen(
                      initialContentType: 'user',
                      initialContentId: '123456', // Replace with actual user ID
                      initialContentTitle: 'User Profile Report',
                    ),
                  );
                },
                icon: Icon(Icons.flag, color: Colors.red[600]),
                label: Text(
                  'Report This User',
                  style: TextStyle(color: Colors.red[600]),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red[600]!),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModerationSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: CustomTheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Safety & Moderation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildModerationTile(
              icon: Icons.history,
              title: 'My Reports',
              subtitle: 'View reports you have submitted',
              onTap: () {
                Get.to(() => const MyReportsScreen());
              },
            ),
            _buildModerationTile(
              icon: Icons.block,
              title: 'Blocked Users',
              subtitle: 'Manage users you have blocked',
              onTap: () {
                Get.to(() => const BlockedUsersScreen());
              },
            ),
            _buildModerationTile(
              icon: Icons.report_problem,
              title: 'Report Content',
              subtitle: 'Report inappropriate content or users',
              onTap: () {
                Get.to(() => const ReportContentScreen());
              },
            ),
            _buildModerationTile(
              icon: Icons.policy,
              title: 'Legal Preferences',
              subtitle: 'Manage your legal consent preferences',
              onTap: () {
                Get.to(() => const LegalConsentScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModerationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: CustomTheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showEditDialog(
    BuildContext context,
    String label,
    TextEditingController controller,
    Function(String) onSave,
  ) {
    String newValue = controller.text;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ResponsiveDialogWrapper(
          backgroundColor: CustomTheme.card,
          child: ResponsiveDialogPadding(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.edit, color: CustomTheme.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Edit $label',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, color: Colors.grey[400]),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Text field
                TextFormField(
                  controller: controller,
                  onChanged: (value) {
                    newValue = value;
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: CustomTheme.primary),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[600]!),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onSave(newValue);
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProfileField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String currentValue;
  final Function() onEditTapped;
  final bool isPassword;

  const ProfileField({
    super.key,
    required this.icon,
    required this.label,
    required this.currentValue,
    required this.onEditTapped,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(currentValue, style: const TextStyle(fontSize: 16)),
        ),
        IconButton(onPressed: onEditTapped, icon: const Icon(Icons.edit)),
      ],
    );
  }
}

class ProfilePicturePicker extends StatefulWidget {
  const ProfilePicturePicker({super.key});

  @override
  _ProfilePicturePickerState createState() => _ProfilePicturePickerState();
}

class _ProfilePicturePickerState extends State<ProfilePicturePicker> {
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showImagePicker(context);
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          ClipOval(
            child: CircleAvatar(
              radius: 60,
              backgroundImage:
                  _imageFile != null
                      ? Image(image: FileImage(_imageFile!)).image
                      : const NetworkImage(
                        'https://www.woolha.com/media/2020/03/eevee.png',
                      ),
              // backgroundImage:NetworkImage('https://www.woolha.com/media/2020/03/eevee.png') ,
              // Replace with the URL of the user's profile picture
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImagePicker(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    ); // You can also use ImageSource.camera for the camera.

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      List<int> photoBytes = await _imageFile!.readAsBytes();
      final photoBase64 = base64Encode(photoBytes);
      Get.find<UpdateProfileController>().updatePhoto(photoBase64);
    }
  }
}
