import 'package:flutter/material.dart';
import '../models/link_generator_models.dart';
import '../constants/form_styles.dart';

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
    return DropdownButtonFormField<SharePlatform>(
      value: value,
      onChanged: enabled
          ? (newValue) {
              if (newValue != null) {
                onChanged?.call(newValue);
                onPlatformChanged?.call();
              }
            }
          : null,
      decoration: InputDecoration(
        labelText: 'Platform',
        isDense: true,
        contentPadding: FormStyles.fieldContentPadding,
        labelStyle: FormStyles.fieldLabelStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: false,
      ),
      items: SharePlatform.values.map((platform) {
        return DropdownMenuItem(
          value: platform,
          child: Row(
            children: [
              Icon(platform.iconData, color: platform.color, size: 20),
              const SizedBox(width: 12),
              Text(
                platform.displayName,
                style: const TextStyle(fontSize: FormStyles.fieldFontSize),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

