import 'package:flutter/material.dart';
import '../models/link_generator_models.dart';
import '../constants/form_styles.dart';

/// Account type dropdown widget
class AccountTypeDropdown extends StatelessWidget {
  final AccountType value;
  final ValueChanged<AccountType?>? onChanged;
  final bool enabled;

  const AccountTypeDropdown({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<AccountType>(
      value: value,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: 'Account Type',
        isDense: true,
        contentPadding: FormStyles.fieldContentPadding,
        labelStyle: FormStyles.fieldLabelStyle,
        prefixIcon: const Icon(Icons.account_circle_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: false,
      ),
      items: AccountType.values.map((type) {
        final displayName = type == AccountType.organization
            ? 'CORPORATE'
            : type.displayName;
        return DropdownMenuItem(
          value: type,
          child: Text(
            displayName,
            style: const TextStyle(fontSize: FormStyles.fieldFontSize),
          ),
        );
      }).toList(),
    );
  }
}

