import 'package:flutter/material.dart';
import 'package:coopengageplus/constants/text_styles.dart';

class ConfirmPasswordTextField extends StatelessWidget {
  const ConfirmPasswordTextField({
    super.key,
    required this.title,
    required this.hint,
    required this.textEditingController,
    required this.hidePassword,
    required this.togglePasswordVisibility,
    required this.passwordController,
  });

  final String title;
  final String hint;
  final TextEditingController textEditingController;
  final bool hidePassword;
  final VoidCallback togglePasswordVisibility;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 6), // Vertical padding for centering
        child: TextFormField(
          obscureText: hidePassword,
          controller: textEditingController,
          keyboardType: TextInputType.text,
          autofocus: false,
          style: titleStyle,
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: subtitleStyle,
            suffixIcon: IconButton(
              icon:
                  Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: togglePasswordVisibility, // Toggle Password
            ),
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide:
                    BorderSide(color: Color.fromRGBO(176, 198, 214, 1))),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.grey),
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
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Confirm Password cannot be empty';
            }
            if (value != passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ),
    );
  }
}
