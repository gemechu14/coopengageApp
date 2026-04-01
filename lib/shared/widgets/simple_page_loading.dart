import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:flutter/material.dart';

/// Reusable simple loading widget aligned with app theme.
class SimplePageLoading extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SimplePageLoading({
    Key? key,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: cyanblueColor,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: blueColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: textInfoColor,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
