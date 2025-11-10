import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:flutter/material.dart';

class ReusableDropdown extends StatelessWidget {
  final String? selectedValue;
  final List<String> items;
  final String hintText;
  final ValueChanged<String?> onChanged;
  final IconData? prefixIcon;
  final String errorMessage;
  final bool isRequired;
  final bool isGreyBorder;

  const ReusableDropdown({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.hintText,
    required this.onChanged,
    this.prefixIcon,
    this.isGreyBorder = true,
    required this.errorMessage,
    required this.isRequired,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(15);
    final Color borderColor = isGreyBorder ? Colors.grey : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 3),
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white, // Ensures dropdown background is white
        ),
        child: DropdownButtonFormField<String>(
          value: selectedValue,
          isExpanded: true,
          hint: Text(
            hintText,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          style: const TextStyle(fontSize: 15, color: Colors.black),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return errorMessage;
                  }
                  return null;
                }
              : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide:
                  BorderSide(color: (Colors.grey), width: 1.3), // bold on focus
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.red),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey[700])
                : null,
          ),
        ),
      ),
    );
  }
}
