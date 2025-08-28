import 'package:flutter/material.dart';
import 'package:flutx/widgets/card/card.dart';
import 'package:flutx/widgets/text/text.dart';
import 'package:get/get.dart';

import '../../../../core/styles.dart';
import '../../../routing/routing.dart';


class SelectCategoryScreen extends StatelessWidget {
  const SelectCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _AppBarWithBackButton(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _CategoryGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarWithBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
          const Spacer(),
          Text(
            'Select Category',
            style: AppStyles.googleFontMontserrat.copyWith(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _CategoryCard(
          categoryName: category.name,
          iconData: category.iconData,
          onTap: (){
            _navigateToScreen(index);
          }
        );
      },
    );
  }
}

void _navigateToScreen(int index) {
  switch (index) {
    case 0:
      Get.toNamed(AppRouter.searchSubCategory); // Replace ResourcesScreen with your desired screen for index 0
      break;
    case 1:
      Get.toNamed(AppRouter.searchSubCategory); // Replace TrainingSessionsScreen with your desired screen for index 1
      break;
    case 2:
      Get.toNamed(AppRouter.searchSubCategory); // Replace FarmersScreen with your desired screen for index 2
      break;
    case 3:
      Get.toNamed(AppRouter.searchSubCategory); // Replace ProfileScreen with your desired screen for index 3
      break;
    default:
      break;
  }
}

class _CategoryCard extends StatelessWidget {
  final String categoryName;
  final IconData iconData;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.categoryName,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FxCard(
      onTap: onTap,
      paddingAll: 0,
      margin: const EdgeInsets.only(
          left: 5, right: 5, bottom: 10),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(iconData, size: 50,),
          const SizedBox(
            height: 10,
          ),
          FxText.bodyLarge(
            categoryName,
            color: Colors.black,
            textAlign: TextAlign.center,
            height: 1,
            maxLines: 2,
          )
        ],
      ),
    );
  }
}

class Category {
  final String name;
  final IconData iconData;
  final VoidCallback onTap;

  Category({required this.name, required this.iconData, required this.onTap});
}

// Sample categories
final List<Category> _categories = [
  Category(
    name: 'CATEGORY\nONE',
    iconData: Icons.category,
    onTap: () {
     Get.toNamed(AppRouter.resource);
    },
  ),
  Category(
    name: 'CATEGORY\nTWO',
    iconData: Icons.category,
    onTap: () {
    },
  ),
  Category(
    name: 'CATEGORY\nTHREE',
    iconData: Icons.category,
    onTap: () {

    },
  ),
  Category(
    name: 'CATEGORY\nFOUR',
    iconData: Icons.category,
    onTap: () {

    },
  ),
  // Add more categories here if needed.
];
