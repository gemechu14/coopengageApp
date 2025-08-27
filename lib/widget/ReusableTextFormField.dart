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
  final bool isEnabled;
  final bool readOnly; // New parameter for read-only mode
  final Function(String)? onChanged; // Add onChanged callback
  const ReusableTextFormField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.errorMessage,
    this.leadingIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.isEnabled = true,
    this.readOnly = false,
    this.isRequired = true, // Defaults to required
    this.onChanged, // Add onChanged parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: TextFormField(
        // textAlign: TextAlign.start,

        
        controller: controller,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onChanged: onChanged, // Add onChanged callback
        decoration: InputDecoration(
          // fillColor: Colors.white,
          enabled: isEnabled,
          filled: readOnly,
          fillColor: readOnly ? Colors.grey[100] : null,
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: readOnly ? Colors.grey[300]! : Colors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: readOnly ? Colors.grey[300]! : Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: readOnly ? Colors.grey[300]! : Colors.blue),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.red),
          ),
          prefixIcon: leadingIcon != null ? Icon(leadingIcon, color: readOnly ? Colors.grey : null) : null,
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
