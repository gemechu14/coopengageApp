import 'package:flutter/material.dart';
import '../models/link_generator_models.dart';
import '../constants/form_styles.dart';
import '../utils/form_validators.dart';

/// Recipient name input field
class RecipientNameField extends StatelessWidget {
  final TextEditingController controller;
  final SharePlatform platform;
  final bool enabled;
  final GlobalKey<FormState>? formKey;

  const RecipientNameField({
    super.key,
    required this.controller,
    required this.platform,
    this.enabled = true,
    this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: platform == SharePlatform.email
            ? 'Recipient Name *'
            : 'Recipient Name (Optional)',
        hintText: 'Enter recipient name',
        isDense: true,
        contentPadding: FormStyles.fieldContentPadding,
        labelStyle: FormStyles.fieldLabelStyle,
        hintStyle: FormStyles.fieldHintStyle,
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: false,
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) => FormValidators.validateNameForEmail(value, platform),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

