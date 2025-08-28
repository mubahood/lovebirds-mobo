import 'package:flutter/material.dart';
import "package:get/get.dart";

import '../../../routing/routing.dart';

class SubCategory {
  final Icon icon;
  final String text;

  SubCategory({required this.icon, required this.text});
}

class SearchSubCategoryScreen extends StatelessWidget {
  final List<SubCategory> subCategories = List.generate(
    20,
        (index) => SubCategory(
      icon: const Icon(Icons.category), // Replace with your desired icon
      text: 'Subcategory ${index + 1}',
    ),
  );

  SearchSubCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    // Handle back button press here
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SearchTextField(),
            const SizedBox(height: 16),
            Expanded(child: SubCategoryGrid(subCategories: subCategories)),
          ],
        ),
      ),
    );
  }
}

class SearchTextField extends StatelessWidget {
  const SearchTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Search Subcategory',
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        suffixIcon: const Icon(Icons.search),
      ),
    );
  }
}

class SubCategoryGrid extends StatelessWidget {
  final List<SubCategory> subCategories;

  const SubCategoryGrid({super.key, required this.subCategories});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: subCategories.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _navigateToScreen(index);
          },
          child: SubCategoryItem(subCategory: subCategories[index]),
        );
      },
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
    );
  }
}

void _navigateToScreen(int index) {
  switch (index) {
    case 0:
      Get.toNamed(AppRouter.resource); // Replace ResourcesScreen with your desired screen for index 0
      break;
    case 1:
      Get.toNamed(AppRouter.resource); // Replace TrainingSessionsScreen with your desired screen for index 1
      break;
    case 2:
      Get.toNamed(AppRouter.resource); // Replace FarmersScreen with your desired screen for index 2
      break;
    case 3:
      Get.toNamed(AppRouter.resource); // Replace ProfileScreen with your desired screen for index 3
      break;
    default:
      break;
  }
}

class SubCategoryItem extends StatelessWidget {
  final SubCategory subCategory;

  const SubCategoryItem({super.key, required this.subCategory});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          subCategory.icon,
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(subCategory.text),

            ],
          ),
        ],
      ),
    );
  }
}
