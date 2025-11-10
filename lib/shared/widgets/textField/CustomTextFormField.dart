// // ignore_for_file: unused_local_variable, use_super_parameters

// import 'package:flutter/material.dart';
// import 'package:coopengageplus/core/constants/text_styles.dart';

// class CustomTextFormField extends StatelessWidget {
//   final String hintText;
//   final TextEditingController controller;
//   final String? errorMessage;
//   final IconData? leadingIcon;
//   final TextInputType keyboardType;
//   final TextStyle? hintStyle;
//   final double? widthFactor;
//   final bool isRequired;
//   const CustomTextFormField({
//     Key? key,
//     required this.hintText,
//     required this.controller,
//     this.errorMessage,
//     this.leadingIcon,
//     this.keyboardType = TextInputType.text,
//     this.hintStyle,
//     this.widthFactor, // Optional width factor for responsive layouts
//     this.isRequired =
//         true, // Default is true, assuming most fields are required
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double formWidth = width < 600
//         ? double.infinity
//         : (widthFactor ?? 0.5) * width; // Handle responsive design

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           decoration: InputDecoration(
//             hintText: hintText,
//             hintStyle: subtitleStyle,
//             labelStyle: const TextStyle(fontSize: 15),
//             isDense: true,
//             border: const OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(12)),
//             ),
//             enabledBorder: const OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(12)),
//               borderSide: BorderSide(color: Colors.grey),
//             ),
//             focusedBorder: const OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(12)),
//               borderSide: BorderSide(color: Colors.grey),
//             ),
//             errorBorder: const OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(12)),
//               borderSide: BorderSide(color: Colors.red),
//             ),
//             focusedErrorBorder: const OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(12)),
//               borderSide: BorderSide(color: Colors.red),
//             ),
//             prefixIcon: leadingIcon != null ? Icon(leadingIcon) : null,
//           ),
//           validator: (value) {
//             // If isRequired is true, validate the field to ensure it's not empty
//             if (isRequired && (value == null || value.isEmpty)) {
//               return errorMessage ?? 'This field is required';
//             }
//             return null; // Return null if validation passes
//           },
//         ),
//       ],
//     );
//   }
// }
// ignore_for_file: unused_local_variable, use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coopengageplus/core/constants/text_styles.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String? errorMessage;
  final IconData? leadingIcon;
  final TextInputType keyboardType;
  final TextStyle? hintStyle;
  final double? widthFactor;
  final bool isRequired;
  final bool isPhoneNumber;
  final bool isPhoneOrEmail;

  /// NEW: input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// NEW: validation options
  final int? exactLength;
  final int? minLength;
  final int? maxLength;

  const CustomTextFormField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.errorMessage,
    this.leadingIcon,
    this.keyboardType = TextInputType.text,
    this.hintStyle,
    this.widthFactor,
    this.isRequired = true,
    this.inputFormatters,
    this.exactLength,
    this.minLength,
    this.maxLength,
    this.isPhoneNumber = false,
    this.isPhoneOrEmail = false,
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
          inputFormatters: inputFormatters,
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
            // Field is optional
            if (value == null || value.isEmpty) {
              return null; // empty is allowed
            }

            if (isPhoneOrEmail) {
              final phoneRegex = RegExp(r'^[0-9]{10}$'); // 10 digits
              final emailRegex = RegExp(
                r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
              ); // basic email pattern

              if (!phoneRegex.hasMatch(value) && !emailRegex.hasMatch(value)) {
                return 'Enter a valid 10-digit phone number or a valid email';
              }
            }

            // Exact length check (optional)
            if (exactLength != null && value.length != exactLength) {
              return 'Must be exactly $exactLength characters';
            }

            // Min/Max length checks
            if (minLength != null && value.length < minLength!) {
              return 'Must be at least $minLength characters';
            }

            if (maxLength != null && value.length > maxLength!) {
              return 'Must not exceed $maxLength characters';
            }

            return null;
          },
        )
        // validator: (value) {
        //   if (isRequired && (value == null || value.isEmpty)) {
        //     return errorMessage ?? 'This field is required';
        //   }

        //   if (value != null && value.isNotEmpty) {
        //     // ✅ Phone number validation
        //     if (isPhoneNumber) {
        //       final phoneRegex = RegExp(r'^[0-9]{10}$'); // 10 digits only
        //       if (!phoneRegex.hasMatch(value)) {
        //         return 'Phone number must be exactly 10 digits';
        //       }
        //     }

        //     // ✅ Exact length
        //     if (exactLength != null && value.length != exactLength) {
        //       return 'Must be exactly $exactLength characters';
        //     }

        //     // ✅ Min length
        //     if (minLength != null && value.length < minLength!) {
        //       return 'Must be at least $minLength characters';
        //     }

        //     // ✅ Max length
        //     if (maxLength != null && value.length > maxLength!) {
        //       return 'Must not exceed $maxLength characters';
        //     }
        //   }

        //   return null;

        //   // validator: (value) {
        //   //   if (isRequired && (value == null || value.isEmpty)) {
        //   //     return errorMessage ?? 'This field is required';
        //   //   }

        //   //   if (value != null && value.isNotEmpty) {
        //   //     // ✅ Exact length
        //   //     if (exactLength != null && value.length != exactLength) {
        //   //       return 'Must be exactly $exactLength characters';
        //   //     }

        //   //     // ✅ Min length
        //   //     if (minLength != null && value.length < minLength!) {
        //   //       return 'Must be at least $minLength characters';
        //   //     }

        //   //     // ✅ Max length
        //   //     if (maxLength != null && value.length > maxLength!) {
        //   //       return 'Must not exceed $maxLength characters';
        //   //     }
        //   //   }

        //   //   return null;
        //   // },
        // })
      ],
    );
  }
}
