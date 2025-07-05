import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StepSignature extends ConsumerWidget {
  const StepSignature({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Text('Signature Step'),
        // Add your form fields here
      ],
    );
  }
} 