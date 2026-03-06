import 'package:flutter/material.dart';
import '../models/link_generator_models.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';

/// Submit button with loading states
class SubmitButton extends StatelessWidget {
  final bool isLoading;
  final bool isLinkGenerated;
  final bool isEmailSent;
  final SharePlatform platform;
  final VoidCallback? onPressed;

  const SubmitButton({
    super.key,
    required this.isLoading,
    required this.isLinkGenerated,
    required this.isEmailSent,
    required this.platform,
    this.onPressed,
  });

  String _getButtonText() {
    if (isLoading) {
      return platform == SharePlatform.email ? 'Sending Email...' : 'Generating...';
    }
    if (isLinkGenerated) {
      return isEmailSent ? 'Email Sent' : 'Link Generated';
    }
    return platform == SharePlatform.email ? 'Send Invitation' : 'Generate Link';
  }

  IconData _getIcon() {
    if (isLoading) {
      return Icons.link; // Will be replaced by CircularProgressIndicator
    }
    return isLinkGenerated ? Icons.check_circle : Icons.link;
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: (isLoading || isLinkGenerated) ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(_getIcon()),
      label: Text(
        _getButtonText(),
        style: const TextStyle(fontSize: 13),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: isLinkGenerated ? Colors.grey : cyanblueColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

