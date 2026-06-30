import 'package:coopengageplus/features/merchant/widgets/merchant_mycard_form_fields.dart';
import 'package:flutter/material.dart';
import '../constants/form_styles.dart';
import '../models/link_generator_models.dart';
import '../utils/form_validators.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Email address *',
          style: FormStyles.fieldLabelStyle,
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 14),
          decoration: merchantFlowInputDecoration(
            accentColor: FormStyles.coopCyan,
            mutedColor: FormStyles.muted,
            hintText: 'merchant@example.com',
            prefixIcon: Icons.email_outlined,
          ),
          validator: (value) =>
              FormValidators.validateEmail(value, SharePlatform.email),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }
}
