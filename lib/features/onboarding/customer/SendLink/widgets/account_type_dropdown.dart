import 'package:coopengageplus/features/merchant/widgets/merchant_mycard_form_fields.dart';
import 'package:flutter/material.dart';
import '../constants/form_styles.dart';
import '../models/link_generator_models.dart';

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
    final dropdown = MerchantFlowDropdown<AccountType>(
      accentColor: FormStyles.coopCyan,
      mutedColor: FormStyles.muted,
      label: 'Account type',
      sheetTitle: 'Account type',
      sheetSubtitle: 'Type of account for the invitation',
      prefixIcon: Icons.account_circle_outlined,
      value: value,
      options: AccountType.values.map((type) {
        final displayName = type == AccountType.organization
            ? 'CORPORATE'
            : type.displayName;
        return MerchantFlowSelectOption(
          value: type,
          title: displayName,
          icon: Icons.badge_outlined,
        );
      }).toList(),
      onChanged: (type) => onChanged?.call(type),
    );

    if (enabled) return dropdown;

    return Opacity(
      opacity: 0.55,
      child: IgnorePointer(child: dropdown),
    );
  }
}
