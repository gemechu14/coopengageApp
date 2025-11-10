
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
  final bool readOnly; // New parameter for read-only mode

  const ReusableDropdown({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.hintText,
    required this.onChanged,
    this.prefixIcon,
    bool? isGreyBorder,
    required this.errorMessage,
    required this.isRequired,
    this.readOnly = false,
  })  : isGreyBorder = isGreyBorder ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      isExpanded: true,
      hint: Text(
        hintText,
        style: TextStyle(
          color: readOnly ? Colors.grey[600] : Colors.black,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Container(
            width: MediaQuery.of(context).size.width -
                32, // 👈 full width minus horizontal padding
            padding: const EdgeInsets.symmetric(
                horizontal: 16), // 👈 padding inside container
            child: Text(
              item,
              style: TextStyle(
                color: readOnly ? Colors.grey[600] : Colors.black,
              ),
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
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[100] : null,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon, 
                color: readOnly ? Colors.grey[400] : Colors.blueGrey
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(
            color: readOnly 
                ? Colors.grey.shade300 
                : (isGreyBorder ? Colors.grey.shade300 : Colors.black),
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(
            color: readOnly 
                ? Colors.grey.shade300 
                : (isGreyBorder ? Colors.grey.shade300 : Colors.black),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Colors.red, width: 1.2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Colors.red, width: 1.2),
        ),
      ),
    );
  }
}
