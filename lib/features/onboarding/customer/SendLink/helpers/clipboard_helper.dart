import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'snackbar_helper.dart';

/// Clipboard helper utilities
class ClipboardHelper {
  /// Copy text to clipboard and show success message
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      SnackbarHelper.showSuccess(context, 'Link copied to clipboard');
    }
  }
}

