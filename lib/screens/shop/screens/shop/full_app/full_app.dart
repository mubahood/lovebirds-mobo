import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/screens/dating/SwipeScreen.dart';
import 'package:lovebirds_app/screens/dating/MatchesScreen.dart';
import 'package:lovebirds_app/screens/shop/screens/shop/full_app/section/AccountSection.dart';
import 'package:lovebirds_app/screens/shop/screens/shop/chat/ChatsScreen.dart';

import '../../../../../controllers/MainController.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/app_theme.dart';
import '../../full_app_controller.dart';
import '../ProductsScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
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
    for (int i = 0; i < controller.navItems.length; i++) {
      tabs.add(
        Container(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Icon(
                controller.navItems[i].iconData,
                size: controller.navItems[i].title.length < 10 ? 22 : 25,
                color:
                    (controller.currentIndex == i)
                        ? CustomTheme.primary
                        : CustomTheme.secondary,
              ),
              const SizedBox(height: 3),
              FxText.bodySmall(
                controller.navItems[i].title,
                fontSize: controller.navItems[i].title.length < 10 ? 12 : 8,
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
          appBar: AppBar(toolbarHeight: 0),
          body: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: controller.tabController,
                          children: <Widget>[
                            const SwipeScreen(),
                            const MatchesScreen(),
                            ProductsScreen(const {}),
                            const ChatsScreen(),
                            const AccountSection(),
                          ],
                        ),
                      ),
                      FxContainer(
                        bordered: false,
                        enableBorderRadius: false,
                        borderRadiusAll: 20,
                        padding: FxSpacing.xy(0, 5),
                        child: TabBar(
                          labelPadding: EdgeInsets.zero,
                          controller: controller.tabController,
                          onTap: (index) {
                            /*if(index == 1){
                                Get.to(() => const ProductSearchScreen());
                                controller.tabController.animateTo(0);
                              }*/
                          },
                          indicator: const FxTabIndicator(
                            indicatorColor: CustomTheme.primary,
                            indicatorHeight: 8,
                            radius: 10,
                            width: 30,
                            indicatorStyle: FxTabIndicatorStyle.rectangle,
                            yOffset: -10,
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorColor: CustomTheme.accent,
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
