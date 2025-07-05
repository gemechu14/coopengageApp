import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

class LoginWidgets {
  // Input decoration for all text fields
  static InputDecoration inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.black),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red),
      ),
      suffixIcon: suffixIcon,
    );
  }

  // Username input field
  static Widget usernameField({
    required TextEditingController controller,
    required double width,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SizedBox(
        width: width < 600 ? double.infinity : width * 0.5,
        child: TextFormField(
          controller: controller,
          decoration: inputDecoration(hintText: 'Username'),
          validator: (value) =>
              (value == null || value.isEmpty) ? 'Username cannot be empty' : null,
        ),
      ),
    );
  }

  // Password input field with show/hide toggle
  static Widget passwordField({
    required TextEditingController controller,
    required bool hidePassword,
    required VoidCallback togglePasswordVisibility,
    required double width,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SizedBox(
        width: width < 600 ? double.infinity : width * 0.5,
        child: TextFormField(
          controller: controller,
          obscureText: hidePassword,
          decoration: inputDecoration(
            hintText: 'Password',
            suffixIcon: IconButton(
              icon:
                  Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: togglePasswordVisibility,
            ),
          ),
          validator: (value) =>
              (value == null || value.isEmpty) ? 'Password cannot be empty' : null,
        ),
      ),
    );
  }

  // Login button
  static Widget loginButton({
    required double width,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SizedBox(
        width: width < 600 ? double.infinity : width * 0.5,
        child: FormHelper.submitButton(
          "Login",
          txtColor: Colors.white,
          btnColor: Colors.blue,
          borderColor: const Color.fromARGB(255, 102, 163, 238),
          onPressed,
        ),
      ),
    );
  }

  // Registration link row
  static Widget registerLink({
    required BuildContext context,
    required VoidCallback onRegisterPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Want to register as an agent? ",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        TextButton(
          onPressed: onRegisterPressed,
          child: const Text(
            "Register",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
