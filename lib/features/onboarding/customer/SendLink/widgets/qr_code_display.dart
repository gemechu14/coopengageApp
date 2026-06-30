import 'package:flutter/material.dart';
import '../constants/form_styles.dart';

/// QR Code display widget with error handling
class QrCodeDisplay extends StatelessWidget {
  final String qrCodeUrl;

  const QrCodeDisplay({
    super.key,
    required this.qrCodeUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: FormStyles.coopCyan.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.network(
            qrCodeUrl,
            fit: BoxFit.contain,
            height: 220,
            width: 220,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 220,
                width: 220,
                color: const Color(0xFFF8FAFC),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: FormStyles.muted.withOpacity(0.7),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load QR code',
                      style: TextStyle(
                        color: FormStyles.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 220,
                width: 220,
                alignment: Alignment.center,
                color: const Color(0xFFF8FAFC),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: FormStyles.coopCyan,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
