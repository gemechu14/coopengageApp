import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? Function(String?)? validator;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool isGreyBorder;
  final bool isRequired; // Add isRequired to the constructor
  final String errorMessage; // Add errorMessage to the constructor

  const DatePickerField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    bool? isGreyBorder,
    required this.isRequired, // Add isRequired parameter
    required this.errorMessage, // Add errorMessage parameter
  })  : isGreyBorder = isGreyBorder ?? false, // Default to false if null
        super(key: key);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(1940),
          lastDate: lastDate ?? DateTime(2024, 12, 31),
        )) ??
        DateTime.now();

    // Update the controller text with the selected date
    controller.text = picked.toLocal().toString().split(" ")[0];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: TextFormField(
        controller: controller,
        onTap: () => _selectDate(context),
        readOnly: true, // Prevent typing directly into the field
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return errorMessage; // Return the error message if not selected
                }
                return null;
              }
            : null, // No validation if isRequired is false
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 13,
            color: isGreyBorder ? Colors.grey : Colors.black,
          ),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          labelStyle: const TextStyle(fontSize: 15),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: isGreyBorder ? Colors.grey : Colors.black,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
