import 'package:coopengageplus/features/home/widgets/mycard_registration/mycard_registration_step_panel.dart';
import 'package:coopengageplus/features/merchant/widgets/merchant_mycard_form_fields.dart';
import 'package:flutter/material.dart';
import '../constants/form_styles.dart';
import '../helpers/clipboard_helper.dart';
import '../helpers/share_helper.dart';
import '../models/link_generator_models.dart';
import 'qr_code_display.dart';

/// Link result content (used inside success modal)
class LinkResultContent extends StatelessWidget {
  final LinkGenerationResponse result;
  final SharePlatform platform;
  final VoidCallback? onCopyLink;
  final VoidCallback? onShare;

  const LinkResultContent({
    super.key,
    required this.result,
    required this.platform,
    this.onCopyLink,
    this.onShare,
  });

  bool get _canShare =>
      (platform == SharePlatform.whatsapp ||
          platform == SharePlatform.telegram) &&
      result.platformSpecificUrl != null &&
      result.platformSpecificUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MerchantFlowSubheading(
          accentColor: FormStyles.coopCyan,
          mutedColor: FormStyles.muted,
          title: 'Shareable link',
          icon: Icons.link_rounded,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: FormStyles.coopCyan.withOpacity(0.2)),
          ),
          child: SelectableText(
            result.shareableLink,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.blueGrey.shade900,
              fontFamily: 'monospace',
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onCopyLink ??
              () => ClipboardHelper.copyToClipboard(
                    context,
                    result.shareableLink,
                  ),
          style: FilledButton.styleFrom(
            backgroundColor: FormStyles.coopCyan,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.copy_all_outlined, size: 17),
          label: const Text(
            'Copy link',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ),
        if (_canShare) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onShare ??
                () => ShareHelper.shareViaPlatform(
                      context,
                      result.platformSpecificUrl!,
                    ),
            style: OutlinedButton.styleFrom(
              foregroundColor: platform.color,
              side: BorderSide(color: platform.color.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(platform.iconData, size: 17, color: platform.color),
            label: Text(
              'Share via ${platform.displayName}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: platform.color,
              ),
            ),
          ),
        ],
        if (result.qrCodeUrl != null && result.qrCodeUrl!.isNotEmpty) ...[
          const SizedBox(height: 16),
          MerchantFlowSubheading(
            accentColor: FormStyles.coopCyan,
            mutedColor: FormStyles.muted,
            title: 'QR code',
            subtitle: 'Scan to open the invitation link',
            icon: Icons.qr_code_2_outlined,
          ),
          const SizedBox(height: 12),
          QrCodeDisplay(qrCodeUrl: result.qrCodeUrl!),
        ],
      ],
    );
  }
}

/// @deprecated Use [LinkResultContent] inside [LinkFlowModal.showLinkSuccess].
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

  @override
  Widget build(BuildContext context) {
    return MycardFlowCard(
      accentColor: FormStyles.coopCyan,
      child: LinkResultContent(
        result: result,
        platform: platform,
        onCopyLink: onCopyLink,
        onShare: onShare,
      ),
    );
  }
}
