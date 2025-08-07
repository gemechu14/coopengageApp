import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignaturePad extends StatelessWidget {
  final SignatureController controller;
  final String label;
  final VoidCallback onClear;

  const SignaturePad({
    Key? key,
    required this.controller,
    required this.label,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: onClear,
              tooltip: 'Clear signature',
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1), // Minimized border
            borderRadius: BorderRadius.circular(4), // Smaller radius
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4), // Smaller radius
            child: Signature(
              controller: controller,
              backgroundColor: Colors.white,
              height: 150, // Reduced height
              width: double.infinity,
            ),
          ),
        ),
      ],
    );
  }
} 