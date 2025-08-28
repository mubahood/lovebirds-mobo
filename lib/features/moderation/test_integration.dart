// Test file to verify BlockUserDialog integration works
// This file demonstrates how to integrate BlockUserDialog in different screens

import 'package:flutter/material.dart';
import 'widgets/block_user_dialog.dart';
import 'widgets/report_content_dialog.dart';

class ModerationIntegrationTest {
  // Test showing BlockUserDialog in ProfileViewScreen
  static void showBlockDialogFromProfile(
    BuildContext context,
    String userName,
    String userId,
    String? userAvatar,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => BlockUserDialog(
            userName: userName,
            userId: userId,
            userAvatar: userAvatar,
          ),
    );
  }

  // Test showing ReportContentDialog in ProfileViewScreen
  static void showReportDialogFromProfile(
    BuildContext context,
    String userName,
    String userId,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => ReportContentDialog(
            contentType: 'User',
            contentPreview: userName,
            contentId: userId,
            reportedUserId: userId,
          ),
    );
  }

  // Test showing BlockUserDialog in ChatScreen
  static void showBlockDialogFromChat(
    BuildContext context,
    String otherUserName,
    String otherUserId,
    String otherUserAvatar,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => BlockUserDialog(
            userName: otherUserName,
            userId: otherUserId,
            userAvatar: otherUserAvatar,
          ),
    );
  }

  // Test showing ReportContentDialog in ChatScreen
  static void showReportDialogFromChat(
    BuildContext context,
    String otherUserName,
    String otherUserId,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => ReportContentDialog(
            contentType: 'User',
            contentPreview: otherUserName,
            contentId: otherUserId,
            reportedUserId: otherUserId,
          ),
    );
  }
}
