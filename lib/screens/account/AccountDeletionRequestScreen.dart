import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/models/RespondModel.dart';
import 'package:lovebirds_app/utils/Utilities.dart';
import 'package:lovebirds_app/utils/my_colors.dart';

import '../../src/features/app_introduction/view/onboarding_screens.dart';

class AccountDeletionRequestScreen extends StatefulWidget {
  const AccountDeletionRequestScreen({Key? key}) : super(key: key);

  @override
  _AccountDeletionRequestScreenState createState() =>
      _AccountDeletionRequestScreenState();
}

class _AccountDeletionRequestScreenState
    extends State<AccountDeletionRequestScreen> {
  void _showConfirmationPopup() {
    Get.defaultDialog(
      title: 'Confirm Account Deletion',
      titleStyle: TextStyle(
        color: MyColors.accent,
        fontWeight: FontWeight.bold,
      ),
      middleText:
      'Are you absolutely sure you want to permanently delete your account?\n\n'
          'All your profile information, settings, and content will be deleted immediately and cannot be recovered.\n\n'
          'This action cannot be undone.',
      textCancel: 'Cancel',
      textConfirm: 'Delete Account',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        _submitDeletionRequest();
      },
      onCancel: () {},
    );
  }

  void _submitDeletionRequest() async {
    Utils.showLoader(true);

    RespondModel? resp;

    try {
      // Call the delete-account endpoint instead of disable-account
      resp = RespondModel(await Utils.http_post('delete-account', {}));
    } catch (e) {
      Utils.hideLoader();
      Utils.toast('Failed to delete account. Please try again later.');
      return;
    } finally {
      Utils.hideLoader();
    }

    if (resp == null || resp.code != 1) {
      Utils.toast('Failed to delete account. Please try again later.');
      return;
    }

    Utils.toast(resp.message, isLong: true);

    Utils.logout();
    Utils.toast('You have been logged out.', isLong: true);
    Get.offAll(() => OnBoardingScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.primary,
      appBar: AppBar(
        title: const Text('Delete Account'),
        backgroundColor: MyColors.primary,
        iconTheme: const IconThemeData(color: MyColors.accent),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delete Account Permanently',
              style: TextStyle(
                color: MyColors.accent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Pressing "Delete Account" will permanently delete your account and all associated data immediately. This action cannot be undone or recovered. You will need to create a new account if you wish to use the service again.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: FxButton.block(
                backgroundColor: Colors.red,
                onPressed: _showConfirmationPopup,
                child: FxText.titleLarge(
                  'Delete Account',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}