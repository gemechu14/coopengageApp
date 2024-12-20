import 'package:flutter/material.dart';
import 'package:coopengageplus/constants/app_sizes.dart';
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
      child: Container(
        margin: const EdgeInsets.only(top: Sizes.p4),
        width: width < 600 ? double.infinity : width * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: titleStyle,
            ),
            const SizedBox(
                height: Sizes.p4), // Space between title and text field
            Container(
              height: 40, // Container height remains 40
              padding: const EdgeInsets.only(left: Sizes.p8, right: Sizes.p8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(Sizes.p12),
              ),
              child: Row(
                children: [
                  Expanded(
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
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed:
                                togglePasswordVisibility, // Toggle Password
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
