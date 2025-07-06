// import 'package:flutter/material.dart';

// class ReusableDropdown extends StatelessWidget {
//   final String? selectedValue;
//   final List<String> items;
//   final String hintText;
//   final ValueChanged<String?> onChanged;
//   final IconData? prefixIcon;

//   const ReusableDropdown({
//     Key? key,
//     required this.selectedValue,
//     required this.items,
//     required this.hintText,
//     required this.onChanged,
//     this.prefixIcon,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
//       child: DropdownButtonFormField<String>(
//         value: selectedValue,
//         hint: Text(
//           hintText,
//           style: const TextStyle(
//             fontSize: 13,
//             color: Colors.black,
//           ),
//         ),
//         items: items.map((String state) {
//           return DropdownMenuItem<String>(
//             value: state,
//             child: Text(state),
//           );
//         }).toList(),
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           isDense: true,
//           border: const OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(10)),
//             borderSide: BorderSide(color: Colors.black),
//           ),
//           prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
//         ),
//       ),
//     );
//   }
// }

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
  })  : isGreyBorder = isGreyBorder ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: DropdownButtonFormField<String>(
        value: selectedValue, 
        isExpanded: true,
        dropdownColor: Colors.white,
        menuMaxHeight: 300,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        iconSize: 24,
        hint: Text(
          hintText,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black,
          ),
        ),
        style: const TextStyle(fontSize: 15, color: Colors.black),
        items: items.asMap().entries.map((entry) {
          final index = entry.key;
          final state = entry.value;
          
          return DropdownMenuItem<String>(
            value: state,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: index < items.length - 1 
                  ? const Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    )
                  : null,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                state,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
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
            : null, // No validation if isRequired is false
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: isGreyBorder ? Colors.grey : Colors.black,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}
