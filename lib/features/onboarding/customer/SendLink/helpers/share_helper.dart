import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'snackbar_helper.dart';

/// Share helper utilities
class ShareHelper {
  /// Share via platform-specific URL
  static Future<void> shareViaPlatform(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          SnackbarHelper.showWarning(
            context,
            'Could not open the app. Please try again.',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(
          context,
          'Error opening app: ${e.toString()}',
        );
      }
    }
  }
}

