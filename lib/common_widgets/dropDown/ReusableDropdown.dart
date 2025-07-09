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


// import 'package:flutter/material.dart';

// class ReusableDropdown extends StatelessWidget {
//   final String? selectedValue;
//   final List<String> items;
//   final String hintText;
//   final ValueChanged<String?> onChanged;
//   final IconData? prefixIcon;
//   final String errorMessage; // Error message for validation
//   final bool isRequired; // Whether the field is required
//   final bool isGreyBorder;
//   const ReusableDropdown({
//     Key? key,
//     required this.selectedValue,
//     required this.items,
//     required this.hintText,
//     required this.onChanged,
//     this.prefixIcon,
//     bool? isGreyBorder,
//     required this.errorMessage,
//     required this.isRequired, // Add the required flag
//   })  : isGreyBorder = isGreyBorder ?? false,
//         super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 10, left: 3, right: 3, bottom: 10),
//       child: Material(
//         elevation: 2,
//         borderRadius: BorderRadius.circular(14),
//         shadowColor: Colors.black12,
//         child: DropdownButtonFormField<String>(
//           value: selectedValue, 
//           isExpanded: true,
//           dropdownColor: const Color(0xFFF7F7F9), // subtle light grey
//           menuMaxHeight: 300,
//           icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 28),
//           iconSize: 28,
//           hint: Text(
//             hintText,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//               fontSize: 15,
//               color: Colors.black54,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
//           items: items.asMap().entries.map((entry) {
//             final index = entry.key;
//             final state = entry.value;
//             final isSelected = state == selectedValue;
//             return DropdownMenuItem<String>(
//               value: state,
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
//                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//                 decoration: BoxDecoration(
//                   // color: isSelected ? Colors.black87 : const Color(0xFFF7F7F9),
//                   // border: Border.all(color: Colors.grey.shade300, width: 1),
//                   // borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: Text(
//                   state,
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: isSelected ?Colors.black87 : Colors.black87,
//                     fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//           onChanged: onChanged,
//           validator: isRequired
//               ? (value) {
//                   if (value == null || value.isEmpty) {
//                     return errorMessage;
//                   }
//                   return null;
//                 }
//               : null, // No validation if isRequired is false
//           decoration: InputDecoration(
//             isDense: true,
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(14)),
//               borderSide: BorderSide(
//                 color: isGreyBorder ? Colors.grey.shade300 : Colors.black,
//                 width: 1.2,
//               ),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(14)),
//               borderSide: BorderSide(
//                 color: isGreyBorder ? Colors.grey.shade300 : Colors.black,
//                 width: 1.2,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(14)),
//               borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
//             ),
//             errorBorder: const OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(14)),
//               borderSide: BorderSide(color: Colors.red, width: 1.2),
//             ),
//             focusedErrorBorder: const OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(14)),
//               borderSide: BorderSide(color: Colors.red, width: 1.2),
//             ),
//             prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.blueGrey) : null,
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           ),
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
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.blueGrey) : null,
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
