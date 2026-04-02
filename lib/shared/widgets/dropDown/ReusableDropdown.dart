import 'package:flutter/material.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';

class ReusableDropdown extends StatelessWidget {
  final String? selectedValue;
  final List<String> items;
  final String hintText;
  final ValueChanged<String?> onChanged;
  final IconData? prefixIcon;
  final String errorMessage;
  final bool isRequired;
  final bool isGreyBorder;
  final bool readOnly;
  final Color accentColor;

  const ReusableDropdown({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.hintText,
    required this.onChanged,
    this.prefixIcon,
    bool? isGreyBorder,
    required this.errorMessage,
    required this.isRequired,
    this.readOnly = false,
    this.accentColor = cyanblueColor,
  }) : isGreyBorder = isGreyBorder ?? false;

  @override
  Widget build(BuildContext context) {
    final mutedColor = Colors.blueGrey.shade400;
    final bool editable = !readOnly;

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 3, right: 3),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: editable ? accentColor.withOpacity(0.7) : Colors.blueGrey.shade300,
        ),
        dropdownColor: Colors.white,
        style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade900),
        hint: Text(
          hintText,
          style: TextStyle(
            fontSize: 13,
            color: mutedColor.withOpacity(0.7),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                fontSize: 14,
                color: editable ? Colors.blueGrey.shade900 : Colors.blueGrey.shade500,
              ),
            ),
          );
        }).toList(),
        onChanged: readOnly ? null : onChanged,
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return errorMessage;
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          filled: true,
          fillColor:
              editable ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
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
      ),
    );
  }
}
