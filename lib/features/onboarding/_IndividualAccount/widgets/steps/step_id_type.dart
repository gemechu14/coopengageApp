import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StepIdType extends ConsumerWidget {
  const StepIdType({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Text('ID Type Step'),
        // Add your form fields here
      ],
    );
  }
} 