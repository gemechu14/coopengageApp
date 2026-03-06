import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import '../constants/form_styles.dart';
import '../utils/form_validators.dart';
import '../models/link_generator_models.dart';

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
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        labelText: 'Phone Number*',
        hintText: '09xxxxxxxx or 07xxxxxxxx',
        isDense: true,
        contentPadding: FormStyles.fieldContentPadding,
        labelStyle: FormStyles.fieldLabelStyle,
        hintStyle: FormStyles.fieldHintStyle,
        prefixIcon: const Icon(Icons.phone_outlined),
        suffixIcon: IconButton(
          tooltip: 'Pick from contacts',
          onPressed: enabled ? onPickContact : null,
          icon: const Icon(
            Icons.contacts_rounded,
            color: cyanblueColor,
            size: 20,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: false,
      ),
      validator: (value) => FormValidators.validatePhone(value, platform),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

