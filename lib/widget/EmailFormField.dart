// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class EmailFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isValid; // Flag to validate email format
  final String? errorMessage;

  const EmailFormField({
    Key? key,
    required this.controller,
    this.hintText = "Email",
    this.isValid = true,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 13, color: Colors.black),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
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
          prefixIcon: const Icon(Icons.email),
        ),
        controller: controller,
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            if (!isValid) {
              return errorMessage ?? "Email is not valid";
            }
          }
          return null;
        },
      ),
    );
  }
}
