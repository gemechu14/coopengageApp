import 'package:flutter/material.dart';
import 'package:coopengageplus/constants/text_styles.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String? errorMessage;
  final IconData? leadingIcon;
  final TextInputType keyboardType;
  final TextStyle? hintStyle;
  final double? widthFactor;
  final bool isRequired;
  const CustomTextFormField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.errorMessage,
    this.leadingIcon,
    this.keyboardType = TextInputType.text,
    this.hintStyle,
    this.widthFactor, // Optional width factor for responsive layouts
    this.isRequired =
        true, // Default is true, assuming most fields are required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double formWidth = width < 600
        ? double.infinity
        : (widthFactor ?? 0.5) * width; // Handle responsive design

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: subtitleStyle,
            labelStyle: const TextStyle(fontSize: 15),
            isDense: true,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.red),
            ),
            prefixIcon: leadingIcon != null ? Icon(leadingIcon) : null,
          ),
          validator: (value) {
            // If isRequired is true, validate the field to ensure it's not empty
            if (isRequired && (value == null || value.isEmpty)) {
              return errorMessage ?? 'This field is required';
            }
            return null; // Return null if validation passes
          },
        ),
      ],
    );
  }
}
