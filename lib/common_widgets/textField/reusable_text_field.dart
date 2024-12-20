import 'package:flutter/material.dart';
import 'package:coopengageplus/constants/app_sizes.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/constants/text_styles.dart';

// class InputTextField extends StatelessWidget {
//   const InputTextField(
//       {super.key,
//       required this.title,
//       required this.hint,
//       required this.textEditingController,
//       this.widget,
//       required this.textInputType,
//       this.isDate,
//       this.dateAction});
//   final String title;
//   final String hint;
//   final TextEditingController textEditingController;
//   final TextInputType textInputType;
//   final Widget? widget;
//   final String? isDate;
//   final VoidCallback? dateAction;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(top: Sizes.p4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: titleStyle,
//           ),
//           Container(
//             height: 50,
//             margin: EdgeInsets.only(
//               top: Sizes.p4,
//             ),
//             padding: EdgeInsets.only(left: Sizes.p8),
//             decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey, width: 1),
//                 borderRadius: BorderRadius.circular(Sizes.p12)),
//             child: Row(
//               children: [
//                 Expanded(
//                     child: TextFormField(
//                   onTap: isDate == null ? dateAction : null,
//                   autofocus: false,
//                   keyboardType: textInputType,
//                   readOnly: widget == null ? false : true,
//                   cursorColor: Colors.grey[700],
//                   controller: textEditingController,
//                   style: titleStyle,
//                   decoration: InputDecoration(
//                       hintText: hint,
//                       hintStyle: subtitleStyle,
//                       border: InputBorder.none,
//                       focusedBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(color: primaryBlue, width: 0)),
//                       enabledBorder: InputBorder.none),
//                 )),
//                 widget == null ? Container() : Container(child: widget)
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

class InputTextField extends StatefulWidget {
  const InputTextField({
    super.key,
    required this.title,
    required this.hint,
    required this.textEditingController,
    this.widget,
    required this.textInputType,
    this.isDate,
    this.dateAction,
    this.isRequired = false,
    this.errorMessage,
  });

  final String title;
  final String hint;
  final TextEditingController textEditingController;
  final TextInputType textInputType;
  final Widget? widget;
  final String? isDate;
  final VoidCallback? dateAction;
  final bool isRequired;
  final String? errorMessage;

  @override
  _InputTextFieldState createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: Sizes.p4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: titleStyle,
          ),
          TextFormField(
            focusNode: _focusNode,
            autofocus: false,
            keyboardType: widget.textInputType,
            controller: widget.textEditingController,
            style: titleStyle,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: subtitleStyle,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(Sizes.p12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: primaryBlue, width: 1),
                borderRadius: BorderRadius.circular(Sizes.p12),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 1),
                borderRadius: BorderRadius.circular(Sizes.p12),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 1),
                borderRadius: BorderRadius.circular(Sizes.p12),
              ),
            ),
            validator: (value) {
              if (widget.isRequired && (value == null || value.isEmpty)) {
                return widget.errorMessage ?? 'This field is required';
              }
              return null;
            },
          ),
          widget.widget ?? Container(),
        ],
      ),
    );
  }
}
