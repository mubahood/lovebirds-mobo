import "package:flutter/material.dart";
import 'package:flutter_easyloading/flutter_easyloading.dart';
import "package:get/get.dart";

import "../src/features/app_introduction/view/onboarding_screens.dart";
import "../src/routing/routing.dart";
import "../utils/lovebirds_app_theme.dart";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    LovebirdsAppTheme.init();

    return GetMaterialApp(
      title: 'Lovebirds Dating',
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      theme: LovebirdsAppTheme.datingTheme,
      home: const OnBoardingScreen(),
      initialRoute: AppRouter.onBoarding,
      getPages: AppRouter.routes,
    );
  }
}
