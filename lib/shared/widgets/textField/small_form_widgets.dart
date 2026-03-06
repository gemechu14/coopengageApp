import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Small reusable label widget
class SmallLabel extends StatelessWidget {
  final String text;
  final EdgeInsets? padding;

  const SmallLabel({
    Key? key,
    required this.text,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}

/// Small reusable text form field widget
class SmallTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? errorMessage;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired;
  final int? exactLength;
  final bool isPhoneOrEmail;
  final double? widthFactor;

  const SmallTextFormField({
    Key? key,
    required this.controller,
    this.hintText,
    this.errorMessage,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.isRequired = true,
    this.exactLength,
    this.isPhoneOrEmail = false,
    this.widthFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double formWidth = width < 600
        ? double.infinity
        : (widthFactor ?? 0.5) * width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: SizedBox(
        width: formWidth,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return errorMessage ?? 'This field is required';
            }
            
            if (value != null && value.isNotEmpty) {
              if (isPhoneOrEmail) {
                final phoneRegex = RegExp(r'^[0-9]{10}$');
                final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                if (!phoneRegex.hasMatch(value) && !emailRegex.hasMatch(value)) {
                  return 'Enter a valid 10-digit phone number or a valid email';
                }
              }
              
              if (exactLength != null && value.length != exactLength) {
                return 'Must be exactly $exactLength characters';
              }
            }
            
            return null;
          },
        ),
      ),
    );
  }
}

/// Small reusable password field widget
class SmallPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool hidePassword;
  final VoidCallback togglePasswordVisibility;
  final String? hintText;
  final double? widthFactor;

  const SmallPasswordField({
    Key? key,
    required this.controller,
    required this.hidePassword,
    required this.togglePasswordVisibility,
    this.hintText,
    this.widthFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double formWidth = width < 600
        ? double.infinity
        : (widthFactor ?? 0.5) * width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: SizedBox(
        width: formWidth,
        child: TextFormField(
          obscureText: hidePassword,
          controller: controller,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            suffixIcon: GestureDetector(
              onTap: togglePasswordVisibility,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  hidePassword ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password cannot be empty';
            }
            return null;
          },
        ),
      ),
    );
  }
}

/// Small reusable confirm password field widget
class SmallConfirmPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController passwordController;
  final bool hidePassword;
  final VoidCallback togglePasswordVisibility;
  final String? hintText;
  final double? widthFactor;

  const SmallConfirmPasswordField({
    Key? key,
    required this.controller,
    required this.passwordController,
    required this.hidePassword,
    required this.togglePasswordVisibility,
    this.hintText,
    this.widthFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double formWidth = width < 600
        ? double.infinity
        : (widthFactor ?? 0.5) * width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: SizedBox(
        width: formWidth,
        child: TextFormField(
          obscureText: hidePassword,
          controller: controller,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            suffixIcon: GestureDetector(
              onTap: togglePasswordVisibility,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  hidePassword ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            errorBorder: const OutlineInputBorder(
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

/// Small reusable button widget
class SmallButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? widthFactor;

  const SmallButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.widthFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double buttonWidth = width < 600
        ? double.infinity
        : (widthFactor ?? 0.5) * width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: SizedBox(
        width: buttonWidth,
        height: 40,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.blue,
            foregroundColor: textColor ?? Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

