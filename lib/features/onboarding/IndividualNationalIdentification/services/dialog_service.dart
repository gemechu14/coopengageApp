import 'package:flutter/material.dart';
import 'package:coopengageplus/constants/kconstant.dart';

/// Service to handle dialog management
class DialogService {
  
  /// Shows a verification success dialog
  static Future<void> showVerificationSuccessDialog({
    required BuildContext context,
    required Map<String, dynamic>? responseData,
    required VoidCallback onContinue,
  }) async {
    await _showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Success!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'National ID Authentication Complete',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildInfoContainer(
              'Your authentication data has been saved successfully.',
              Colors.green,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onContinue();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cyanblueColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  /// Shows a verification error dialog
  static Future<void> showVerificationErrorDialog({
    required BuildContext context,
    required String errorMessage,
    required VoidCallback onRetry,
    required VoidCallback onCancel,
  }) async {
    await _showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Verification Failed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onCancel();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Shows a generic error dialog
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onOk,
  }) async {
    await _showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onOk?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Shows an API test result dialog
  static Future<void> showApiTestResultDialog({
    required BuildContext context,
    required bool isSuccess,
    required int statusCode,
    required String responseBody,
  }) async {
    final title = isSuccess ? 'API Test Successful!' : 'API Test Failed!';
    final message = 'Status: $statusCode\nResponse: $responseBody';
    
    await showErrorDialog(
      context: context,
      title: title,
      message: message,
    );
  }

  /// Helper method to show dialog with proper error handling
  static Future<T?> _showDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) async {
    try {
      return await showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: builder,
      );
    } catch (e) {
      debugPrint('Error showing dialog: $e');
      return null;
    }
  }

  /// Helper to build info container
  static Widget _buildInfoContainer(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: color.withOpacity(0.8), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 