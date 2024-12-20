// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReusableTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String? errorMessage;
  final IconData? leadingIcon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired; // New parameter to handle required validation

  const ReusableTextFormField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.errorMessage,
    this.leadingIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.isRequired = true, // Defaults to required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: TextFormField(
        controller: controller,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.red),
          ),
          prefixIcon: leadingIcon != null ? Icon(leadingIcon) : null,
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return errorMessage ?? 'This field is required';
          }
          return null; // Return null if validation passes
        },
      ),
    );
  }
}
