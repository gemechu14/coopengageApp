import 'package:flutter/material.dart';
import 'package:coopengageplus/constants/app_sizes.dart';
import 'package:coopengageplus/constants/kconstant.dart';

// ignore: must_be_immutable
class CustomNavHeading extends StatelessWidget {
  CustomNavHeading(
      {super.key,
      this.fontSize,
      this.fontWeight,
      this.textOverFlow,
      this.fontStyle,
      required this.text});
  final String text;
  Color? fontColor;
  final fontSize;
  final fontWeight;
  final textOverFlow;
  final fontStyle;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: fontColor ?? primaryBlue,
        fontSize: fontSize ?? Sizes.p20,
        fontWeight: fontWeight ?? FontWeight.bold,
        fontStyle: fontStyle,
        overflow: textOverFlow,
      ),
    );
  }
}
