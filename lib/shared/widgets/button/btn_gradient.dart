import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:flutter/material.dart';
import 'package:coopengageplus/shared/widgets/text/CustomText.dart';
import 'package:coopengageplus/core/constants/app_sizes.dart';


class BtnGradient extends StatelessWidget {
  const BtnGradient({
    super.key,
    required this.text,
    this.fontColor,
    this.fontSize,
    this.color,
    this.borderRadius,
    required this.action,
  });
  final String text;
  final Color? fontColor;
  final double? fontSize;
  final Color? color;
  final double? borderRadius;
  final VoidCallback action;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(Sizes.p10),
        decoration: BoxDecoration(
            color: color ?? primaryBlue,
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius ?? Sizes.p16),
            boxShadow: []),
        child: CustomText(
          text: text,
          fontColor: fontColor ?? whiteColor,
          fontSize: fontSize ?? Sizes.p16,
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';

// class BtnGradient extends StatelessWidget {
//   final String text;
//   final VoidCallback action;
//   final List<Color> colors;
//   final double width;

//   const BtnGradient({
//     super.key,
//     required this.text,
//     required this.action,
//     required this.colors,
//     this.width = 200,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: colors,
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         onPressed: action,
//         child: Text(
//           text,
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//     );
//   }
// }
//  BtnGradient(
//               text: "Create Task",
//               action: () => print("Button pressed"),
//               colors: [Color(0xFF2196F3), Color(0xFF64B5F6)], // Gradient colors
//               width: 250, // Optional custom width
//             )
