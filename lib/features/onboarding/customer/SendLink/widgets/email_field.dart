import 'package:flutter/material.dart';
import '../constants/form_styles.dart';
import '../utils/form_validators.dart';
import '../models/link_generator_models.dart';

/// Email input field
class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const EmailField({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email Address *',
        hintText: 'example@email.com',
        isDense: true,
        contentPadding: FormStyles.fieldContentPadding,
        labelStyle: FormStyles.fieldLabelStyle,
        hintStyle: FormStyles.fieldHintStyle,
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: false,
      ),
      validator: (value) => FormValidators.validateEmail(value, SharePlatform.email),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

