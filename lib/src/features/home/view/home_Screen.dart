import "package:flutter/material.dart";
import "package:get/get.dart";

import "../../../../core/styles.dart";
import "../../../routing/routing.dart";

class HomeScreenOld extends StatelessWidget {
  const HomeScreenOld({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    return Scaffold(
      backgroundColor: AppStyles.primaryColor,
      body: SafeArea(
          child:   Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 35),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 38,
                            // Adjust this value to control the size of the image inside the circle
                            backgroundImage: NetworkImage(
                              'https://www.woolha.com/media/2020/03/eevee.png',
                            ),
                          ),
                        ),
                        const SizedBox(width: 25),
                        Column(
                          mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Text(arguments['userModel'].name,
                style: AppStyles.googleFontMontserrat.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: AppStyles.backgroundWhite)),
             const SizedBox(height:8),
             Text(arguments['userModel'].email,
                style: AppStyles.googleFontMontserrat.copyWith(fontSize: 14, fontWeight: FontWeight.w400, color: AppStyles.backgroundWhite)),

    ],),

    ],
    ),


         ),
            const SizedBox(height: 45,),
           const GridWidget()
      ])),
    );
  }
}


class GridWidget extends StatelessWidget {
  const GridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(top:50),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white, // Replace this with your desired background color
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 4,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
               _navigateToScreen(index);
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _getContainerColor(index), // Replace this with your desired container colors
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIconData(index), // Replace this with your desired icons for each container
                      size: 36,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getLabelText(index), // Replace this with your desired text for each container
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method to get container colors based on the index
  Color _getContainerColor(int index) {
    switch (index) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        Get.toNamed(AppRouter.selectResourceCategory); // Replace ResourcesScreen with your desired screen for index 0
        break;
      case 1:
        Get.toNamed(AppRouter.home); // Replace TrainingSessionsScreen with your desired screen for index 1
        break;
      case 2:
        Get.toNamed(AppRouter.home); // Replace FarmersScreen with your desired screen for index 2
        break;
      case 3:
        Get.toNamed(AppRouter.updateProfile); // Replace ProfileScreen with your desired screen for index 3
        break;
      default:
        break;
    }
  }

  // Helper method to get icons based on the index
  IconData _getIconData(int index) {
    switch (index) {
      case 0:
        return Icons.file_copy_rounded;
      case 1:
        return Icons.handyman_outlined;
      case 2:
        return Icons.supervisor_account_rounded;
      case 3:
        return Icons.person;
      default:
        return Icons.error;
    }
  }

  // Helper method to get labels for each container based on the index
  String _getLabelText(int index) {
    switch (index) {
      case 0:
        return 'Resources';
      case 1:
        return 'Training Sessions';
      case 2:
        return 'Farmers';
      case 3:
        return 'Profile';
      default:
        return 'Unknown';
    }
  }
}




// const PhotoItemWidget(
//   title: 'Beautiful Sunset',
//   description:
//   'This is a breathtaking view of the sunset at the beach.',
//   createdBy: 'Jane Doe',
//   postedAt: '2023-06-12',
// ),
// const   DocumentItemWidget(
// title: 'Project Report',
// description: 'The quarterly project report for Q3 2023.',
// createdBy: 'John Smith',
// postedAt: '2023-06-15',
// ),
// VideoItemWidget(
// title: 'Funny Cat Compilation',
// description: 'A collection of the funniest cat videos.',
// createdBy: 'Alice Johnson',
// postedAt: '2023-06-10',
// ),
