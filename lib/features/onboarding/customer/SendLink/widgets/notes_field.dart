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
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Notes (Optional)',
        hintText: 'e.g., High potential customer',
        isDense: true,
        contentPadding: FormStyles.fieldContentPadding,
        labelStyle: FormStyles.fieldLabelStyle,
        hintStyle: FormStyles.fieldHintStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: false,
      ),
    );
  }
}

