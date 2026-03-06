import 'package:flutter/material.dart';

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
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          qrCodeUrl,
          fit: BoxFit.contain,
          height: 220,
          width: 220,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Failed to load QR code'),
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
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}

