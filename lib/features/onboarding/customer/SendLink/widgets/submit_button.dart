import 'package:flutter/material.dart';
import '../constants/form_styles.dart';
import '../models/link_generator_models.dart';

/// Submit button with loading states
class SubmitButton extends StatelessWidget {
  final bool isLoading;
  final SharePlatform platform;
  final VoidCallback? onPressed;

  const SubmitButton({
    super.key,
    required this.isLoading,
    required this.platform,
    this.onPressed,
  });

  String _getButtonText() {
    if (isLoading) {
      return platform == SharePlatform.email ? 'Sending…' : 'Generating…';
    }
    return platform == SharePlatform.email ? 'Send invitation' : 'Generate link';
  }

  IconData _getIcon() {
    if (isLoading) {
      return platform == SharePlatform.email
          ? Icons.email_outlined
          : Icons.link_rounded;
    }
    return Icons.send_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: FormStyles.coopCyan,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFCBD5E1),
        disabledForegroundColor: const Color(0xFF94A3B8),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white.withOpacity(0.95),
              ),
            )
          : Icon(_getIcon(), size: 17),
      label: Text(
        _getButtonText(),
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
      ),
    );
  }
}
