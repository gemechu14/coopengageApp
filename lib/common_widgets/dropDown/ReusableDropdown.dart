
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
    bool? isGreyBorder,
    required this.errorMessage,
    required this.isRequired,
  })  : isGreyBorder = isGreyBorder ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      isExpanded: true,
      hint: Text(hintText),
      items: items.map((item) {
        //   return DropdownMenuItem<String>(
        //     value: item,
        //     child: Text(item),
        //   );
        // }).toList(),
        return DropdownMenuItem<String>(
          value: item,
          child: Container(
            width: MediaQuery.of(context).size.width -
                32, // 👈 full width minus horizontal padding
            padding: const EdgeInsets.symmetric(
                horizontal: 16), // 👈 padding inside container
            child: Text(item),
          ),
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
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.blueGrey)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(
            color: isGreyBorder ? Colors.grey.shade300 : Colors.black,
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(
            color: isGreyBorder ? Colors.grey.shade300 : Colors.black,
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
