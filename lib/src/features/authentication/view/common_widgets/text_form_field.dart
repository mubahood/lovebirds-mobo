import 'package:flutter/material.dart';

import '../../../../../core/styles.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  const CustomTextFormField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.keyboardType,
    this.maxLength,
    this.obscureText = false,
    this.validator,
  }) : super(key: key);

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: AppStyles.googleFontMontserrat.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: AppStyles.black
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.formFieldsOutlineBorderRadius),
          borderSide:const  BorderSide(color: AppStyles.formFieldsOutlineBorderColor)
        ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppStyles.formFieldsOutlineBorderRadius),
              borderSide:const  BorderSide(color: AppStyles.secondaryColor)
          ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppStyles.formFieldsContentPaddingHorizontal, vertical: AppStyles.formFieldsContentPaddingVertical),
        suffixIcon: widget.obscureText
            ? IconButton(
          padding: const EdgeInsets.only(right: 16),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
        )
            : null,
        floatingLabelBehavior: FloatingLabelBehavior.never

      ),
      keyboardType: widget.keyboardType,
      obscuringCharacter: '*',
      maxLength: widget.maxLength,
      obscureText: widget.obscureText ? _obscureText : false,
      validator: widget.validator,
    );
  }
}
