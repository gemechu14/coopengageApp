import 'package:flutter/material.dart';

Padding reusableTextFormField({
  required BuildContext context,
  required String hintText,
  required TextEditingController controller,
  String? errorMessage,
  IconData? leadingIcon,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Colors.black,
            ),
            labelStyle: const TextStyle(fontSize: 5),
            isDense: true,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: Colors.blue),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: Colors.red),
            ),
            prefixIcon: leadingIcon != null ? Icon(leadingIcon) : null,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return errorMessage ?? 'This field is required';
            }
            return null;
          },
        ),
      ],
    ),
  );
}
