import 'package:coopengageplus/features/merchant/widgets/merchant_mycard_form_fields.dart';
import 'package:flutter/material.dart';
import '../constants/form_styles.dart';
import '../models/link_generator_models.dart';
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
    final isRequired = platform == SharePlatform.email;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isRequired ? 'Recipient name *' : 'Recipient name (optional)',
          style: FormStyles.fieldLabelStyle,
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          style: const TextStyle(fontSize: 14),
          decoration: merchantFlowInputDecoration(
            accentColor: FormStyles.coopCyan,
            mutedColor: FormStyles.muted,
            hintText: 'Enter recipient name',
            prefixIcon: Icons.person_outline,
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) =>
              FormValidators.validateNameForEmail(value, platform),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }
}
