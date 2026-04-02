import 'package:flutter/material.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';

class AppLabel extends StatelessWidget {
  final String text;
  final bool isRequired;
  final EdgeInsetsGeometry padding;

  const AppLabel(
    this.text, {
    super.key,
    this.isRequired = false,
    this.padding = const EdgeInsets.only(top: 12, bottom: 6, left: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade800,
            ),
          ),
          if (isRequired) ...[
            const SizedBox(width: 3),
            const Text(
              '*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.redAccent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
