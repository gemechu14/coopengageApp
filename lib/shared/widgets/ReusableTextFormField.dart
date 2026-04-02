import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';

class ReusableTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String? errorMessage;
  final IconData? leadingIcon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired;
  final bool isEnabled;
  final bool readOnly;
  final Function(String)? onChanged;
  final Color accentColor;

  const ReusableTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    this.errorMessage,
    this.leadingIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.isEnabled = true,
    this.readOnly = false,
    this.isRequired = true,
    this.onChanged,
    this.accentColor = cyanblueColor,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor = Colors.blueGrey.shade400;
    final bool editable = isEnabled && !readOnly;

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 3, right: 3),
      child: TextFormField(
        controller: controller,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        readOnly: readOnly,
        enabled: isEnabled,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade900),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 13,
            color: mutedColor.withOpacity(0.7),
          ),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          filled: true,
          fillColor:
              editable ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
          prefixIcon: leadingIcon != null
              ? Icon(
                  leadingIcon,
                  size: 20,
                  color: editable ? accentColor.withOpacity(0.7) : Colors.blueGrey.shade300,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: accentColor.withOpacity(0.30)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: accentColor.withOpacity(0.30)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: accentColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.3),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueGrey.shade100),
          ),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return errorMessage ?? 'This field is required';
          }
          return null;
        },
      ),
    );
  }
}
