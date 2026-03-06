import 'package:flutter/material.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import '../models/link_generator_models.dart';
import '../helpers/clipboard_helper.dart';
import '../helpers/share_helper.dart';
import 'qr_code_display.dart';

/// Link result card showing generated link, QR code, and actions
class LinkResultCard extends StatelessWidget {
  final LinkGenerationResponse result;
  final SharePlatform platform;
  final VoidCallback? onCopyLink;
  final VoidCallback? onShare;

  const LinkResultCard({
    super.key,
    required this.result,
    required this.platform,
    this.onCopyLink,
    this.onShare,
  });

  bool get _canShare =>
      (platform == SharePlatform.whatsapp || platform == SharePlatform.telegram) &&
      result.platformSpecificUrl != null &&
      result.platformSpecificUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Header
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: cyanblueColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Link Generated Successfully',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cyanblueColor,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Shareable Link Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shareable Link:',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    result.shareableLink,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // Copy Link Button
                FilledButton.icon(
                  onPressed: onCopyLink ??
                      () => ClipboardHelper.copyToClipboard(
                            context,
                            result.shareableLink,
                          ),
                  icon: const Icon(Icons.copy_all_outlined),
                  label: const Text('Copy Link'),
                  style: FilledButton.styleFrom(
                    backgroundColor: cyanblueColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // Share Button (conditional)
                if (_canShare)
                  OutlinedButton.icon(
                    onPressed: onShare ??
                        () => ShareHelper.shareViaPlatform(
                              context,
                              result.platformSpecificUrl!,
                            ),
                    icon: Icon(
                      platform.iconData,
                      color: platform.color,
                    ),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),

            // QR Code Section
            if (result.qrCodeUrl != null && result.qrCodeUrl!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'QR Code:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              QrCodeDisplay(qrCodeUrl: result.qrCodeUrl!),
            ],
          ],
        ),
      ),
    );
  }
}

