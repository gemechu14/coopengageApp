import 'package:flutter/material.dart';

class ReusableDropdown extends StatelessWidget {
  final String? selectedValue;
  final List<String> items;
  final String hintText;
  final ValueChanged<String?> onChanged;
  final IconData? prefixIcon;
  final String errorMessage; // Error message for validation
  final bool isRequired; // Whether the field is required
  final bool isGreyBorder;
  final bool isEnabled; // Whether the field is enabled
  const ReusableDropdown({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.hintText,
    required this.onChanged,
    this.prefixIcon,
    bool? isGreyBorder,
    required this.errorMessage,
    required this.isRequired, // Add the required flag
    this.isEnabled = true, // Default to enabled
  })  : isGreyBorder = isGreyBorder ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: DropdownButtonFormField<String>(
        value: selectedValue, isExpanded: true,
        hint: Text(
          hintText,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black,
          ),
        ),
        style: const TextStyle(fontSize: 15, color: Colors.black),
        items: items.map((String state) {
          return DropdownMenuItem<String>(
            value: state,
            child: Text(
              state,
            ),
          );
        }).toList(),
        onChanged: isEnabled ? onChanged : null,
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return errorMessage;
                }
                return null;
              }
            : null, // No validation if isRequired is false
        decoration: InputDecoration(
          isDense: true,
          filled: !isEnabled,
          fillColor: !isEnabled ? Colors.grey[100] : null,
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: isGreyBorder ? Colors.grey : Colors.black,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: isGreyBorder ? Colors.grey : Colors.black,
            ),
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
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        ),
      ),
    );
  }
} 