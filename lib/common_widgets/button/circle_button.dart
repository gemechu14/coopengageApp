import 'package:flutter/material.dart';
import 'package:coopengageplus/constants/app_sizes.dart';
import 'package:coopengageplus/constants/kconstant.dart';

class CircleButton extends StatelessWidget {
  const CircleButton({
    super.key,
    required this.handleAction,
    this.width,
    this.height,
    this.padding,
    this.bgColor,
    this.iconColor,
    required this.icon,
    this.size,
    this.addShadow,
  });

  final VoidCallback handleAction; // Use VoidCallback for no-argument functions
  final Icon icon;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Color? bgColor;
  final Color? iconColor;
  final double? size;
  final bool? addShadow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: handleAction, // Trigger the action on tap
      child: Container(
        width: width ?? Sizes.p22,
        height: height ?? Sizes.p22,
        alignment: Alignment.center,
        padding: padding ?? EdgeInsets.all(Sizes.p4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor ?? blueColor,
          boxShadow: addShadow == true
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(0, 2),
                    blurRadius: 5,
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon.icon,
          color: iconColor ?? Colors.white,
          size: size ?? Sizes.p14,
        ), // Use icon.icon
      ),
    );
  }
}
