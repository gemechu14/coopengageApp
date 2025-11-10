import 'package:flutter/material.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import '../../providers/national_id_provider.dart';

/// Loading state UI component
class AuthLoadingState extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onTestApi;
  
  const AuthLoadingState({
    Key? key,
    this.onRetry,
    this.onTestApi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
                  const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(cyanblueColor),
        ),
          const SizedBox(height: 16),
          const Text(
            'Initializing National ID Authentication...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            _ActionButton(
              onPressed: onRetry!,
              label: 'Retry API Call',
              backgroundColor: Colors.orange,
            ),
          ],
          if (onTestApi != null) ...[
            const SizedBox(height: 16),
            _ActionButton(
              onPressed: onTestApi!,
              label: 'Test API',
              backgroundColor: Colors.blue,
            ),
          ],
        ],
      ),
    );
  }
}

/// Success state UI component
class AuthSuccessState extends StatelessWidget {
  const AuthSuccessState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified, color: cyanblueColor, size: 80),
          const SizedBox(height: 24),
          const Text(
            'National ID Verified!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: cyanblueColor,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'You have successfully completed National ID authentication.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Error state UI component
class AuthErrorState extends StatelessWidget {
  final NationalIdState state;
  final VoidCallback? onRetry;
  final VoidCallback? onReset;

  const AuthErrorState({
    Key? key,
    required this.state,
    this.onRetry,
    this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading authentication',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (onRetry != null)
                                     _ActionButton(
                     onPressed: onRetry!,
                     label: 'Retry',
                     backgroundColor: cyanblueColor,
                   ),
                if (onReset != null)
                  _ActionButton(
                    onPressed: onReset!,
                    label: 'Reset All',
                    backgroundColor: Colors.orange,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// WebView loading overlay
class WebViewLoadingOverlay extends StatelessWidget {
  const WebViewLoadingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.75),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(cyanblueColor),
            ),
            SizedBox(height: 20),
            Text(
              'Loading National ID Authentication Page...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable action button component
class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Color backgroundColor;

  const _ActionButton({
    required this.onPressed,
    required this.label,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }
} 