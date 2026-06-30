import 'package:coopengageplus/features/merchant/widgets/merchant_mycard_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/form_styles.dart';
import '../models/link_generator_models.dart';
import '../utils/form_validators.dart';

/// Phone number input field with contact picker button
class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  final SharePlatform platform;
  final bool enabled;
  final VoidCallback? onPickContact;

  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.platform,
    this.enabled = true,
    this.onPickContact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Phone number *',
          style: FormStyles.fieldLabelStyle,
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 14),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: merchantFlowInputDecoration(
            accentColor: FormStyles.coopCyan,
            mutedColor: FormStyles.muted,
            hintText: '0912345678',
            helperText: '10 digits only',
            prefixIcon: Icons.phone_outlined,
            counterText: '',
          ).copyWith(
            suffixIcon: IconButton(
              tooltip: 'Pick from contacts',
              onPressed: enabled ? onPickContact : null,
              icon: Icon(
                Icons.contacts_rounded,
                color: enabled ? FormStyles.coopCyan : FormStyles.muted,
                size: 20,
              ),
            ),
          ),
          validator: (value) => FormValidators.validatePhone(value, platform),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }
}
