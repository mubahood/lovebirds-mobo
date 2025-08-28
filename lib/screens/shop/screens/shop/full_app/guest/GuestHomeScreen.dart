import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../../../controllers/MainController.dart';
import '../../../../../../utils/CustomTheme.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../full_app_controller.dart';
import '../../ProductsScreen.dart';
import 'GuestDashboard.dart';
import 'GuestAccountSection.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({Key? key}) : super(key: key);

  @override
  _GuestHomeScreenState createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen>
    with SingleTickerProviderStateMixin {
  late ThemeData theme;
  late FullAppController controller;
  final MainController mainController = Get.put(MainController());

  @override
  void initState() {
    super.initState();
    theme = AppTheme.darkTheme;
    controller = FxControllerStore.putOrFind(FullAppController(this));
    mainController.initialized;
    mainController.init();
  }

  List<Widget> buildTab() {
    List<Widget> tabs = [];
    // Only show guest-accessible tabs
    final guestNavItems = [
      controller.navItems[0], // Dashboard (Movies)
      controller.navItems[2], // Products (if applicable)
      controller.navItems[4], // Account (Guest version)
    ];

    for (int i = 0; i < guestNavItems.length; i++) {
      tabs.add(
        Container(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Icon(
                guestNavItems[i].iconData,
                size: guestNavItems[i].title.length < 10 ? 22 : 25,
                color:
                    (controller.currentIndex == i)
                        ? CustomTheme.primary
                        : CustomTheme.secondary,
              ),
              const SizedBox(height: 3),
              FxText.bodySmall(
                guestNavItems[i].title,
                fontSize: guestNavItems[i].title.length < 10 ? 12 : 8,
                color:
                    (controller.currentIndex == i)
                        ? CustomTheme.primary
                        : CustomTheme.secondary,
              ),
            ],
          ),
        ),
      );
    }
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    return FxBuilder<FullAppController>(
      controller: controller,
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            backgroundColor: CustomTheme.background,
          ),
          body: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Guest Mode Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FxText.bodySmall(
                                'Browsing as Guest • Sign in for favorites, playlists, and more',
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.snackbar(
                                  'Sign In',
                                  'Create an account or sign in to unlock all features',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: CustomTheme.primary,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 3),
                                  mainButton: TextButton(
                                    onPressed: () {
                                      Get.back(); // Close snackbar
                                      Get.toNamed(
                                        '/login',
                                      ); // Navigate to login
                                    },
                                    child: FxText.bodySmall(
                                      'Sign In',
                                      color: Colors.white,
                                      fontWeight: 600,
                                    ),
                                  ),
                                );
                              },
                              child: FxText.bodySmall(
                                'Sign In',
                                color: Colors.white,
                                fontWeight: 600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: controller.tabController,
                          children: <Widget>[
                            const GuestDashboard(), // Guest movie dashboard
                            ProductsScreen(const {}), // Products (limited)
                            const GuestAccountSection(), // Guest account options
                          ],
                        ),
                      ),

                      // Bottom Navigation Bar
                      FxContainer(
                        bordered: false,
                        enableBorderRadius: false,
                        color: CustomTheme.background,
                        padding: FxSpacing.fromLTRB(0, 12, 0, 12),
                        child: TabBar(
                          controller: controller.tabController,
                          indicator: const BoxDecoration(),
                          indicatorColor: Colors.transparent,
                          tabs: buildTab(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
