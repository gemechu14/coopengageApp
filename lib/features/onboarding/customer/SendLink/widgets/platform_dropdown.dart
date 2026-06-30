import 'package:coopengageplus/features/merchant/widgets/merchant_mycard_form_fields.dart';
import 'package:flutter/material.dart';
import '../constants/form_styles.dart';
import '../models/link_generator_models.dart';

/// Platform dropdown widget
class PlatformDropdown extends StatelessWidget {
  final SharePlatform value;
  final ValueChanged<SharePlatform?>? onChanged;
  final bool enabled;
  final VoidCallback? onPlatformChanged;

  const PlatformDropdown({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.onPlatformChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dropdown = MerchantFlowDropdown<SharePlatform>(
      accentColor: FormStyles.coopCyan,
      mutedColor: FormStyles.muted,
      label: 'Platform',
      sheetTitle: 'Delivery platform',
      sheetSubtitle: 'How the invitation will be sent',
      prefixIcon: Icons.send_outlined,
      value: value,
      options: SharePlatform.values
          .map(
            (platform) => MerchantFlowSelectOption(
              value: platform,
              title: platform.displayName,
              icon: platform.iconData,
            ),
          )
          .toList(),
      onChanged: (platform) {
        onChanged?.call(platform);
        onPlatformChanged?.call();
      },
    );

    if (enabled) return dropdown;

    return Opacity(
      opacity: 0.55,
      child: IgnorePointer(child: dropdown),
    );
  }
}
