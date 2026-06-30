import 'package:coopengageplus/features/merchant/widgets/merchant_mycard_form_fields.dart';
import 'package:flutter/material.dart';
import '../constants/form_styles.dart';

/// Notes text area field
class NotesField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const NotesField({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Notes (optional)',
          style: FormStyles.fieldLabelStyle,
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: 3,
          style: const TextStyle(fontSize: 14),
          decoration: merchantFlowInputDecoration(
            accentColor: FormStyles.coopCyan,
            mutedColor: FormStyles.muted,
            hintText: 'e.g., High potential customer',
          ),
        ),
      ],
    );
  }
}
