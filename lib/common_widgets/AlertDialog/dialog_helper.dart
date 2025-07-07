import 'package:flutter/material.dart';

enum DialogType { error, success, info }

class DialogHelper {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    DialogType type = DialogType.info,
    String buttonText = "OK",
    VoidCallback? onPressed,
  }) {
    IconData iconData;
    Color iconColor;
    Color titleColor;

    switch (type) {
      case DialogType.error:
        iconData = Icons.error_outline;
        iconColor = Colors.orange; // Secondary color
        titleColor = Colors.blue;  // Primary color
        break;
      case DialogType.success:
        iconData = Icons.check_circle_outline;
        iconColor = Colors.green;
        titleColor = Colors.blue;
        break;
      case DialogType.info:
      iconData = Icons.info_outline;
        iconColor = Colors.blue;
        titleColor = Colors.blue;
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(iconData, color: iconColor),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue, // Primary color
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              if (onPressed != null) onPressed();
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
