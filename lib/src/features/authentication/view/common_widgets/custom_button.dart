import 'package:flutter/material.dart';
import '../../../../../core/styles.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const CustomElevatedButton({super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:AppStyles.buttonHeight,
      width:double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          surfaceTintColor: AppStyles.primaryColor,
          backgroundColor: AppStyles.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.buttonBorderRadius),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: AppStyles.googleFontMontserrat.copyWith(
              fontSize:16,
              fontWeight:FontWeight.w700,
              color:AppStyles.backgroundWhite
            )
          ),
        ),
      ),
    );
  }
}


