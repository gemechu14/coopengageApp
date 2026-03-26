// ignore_for_file: use_build_context_synchronously
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/core/constants/mycard_link_constants.dart';
import 'package:coopengageplus/features/home/pages/mycard_link_stats_page.dart';
import 'package:coopengageplus/shared/services/link_share_stats_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Gradient circular button: MyCard + share — opens WhatsApp, Telegram, email, etc.
class MycardShareFab extends StatelessWidget {
  const MycardShareFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Share MyCard signup link',
      child: Material(
        elevation: 6,
        shadowColor: primaryBlue.withOpacity(0.4),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showMycardShareSheet(context),
          child: Ink(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.add_card_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showMycardShareSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _MycardShareSheet(),
  );
}

class _MycardShareSheet extends StatelessWidget {
  const _MycardShareSheet();

  static const _wa = Color(0xFF25D366);
  static const _tg = Color(0xFF0088CC);
  static const _mail = Color(0xFFEA4335);

  Future<void> _launch(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not complete the action.')),
        );
      }
    }
  }

  Future<void> _whatsapp(BuildContext context) async {
    final uri = Uri.https('wa.me', '/', {
      'text': MycardLinkConstants.shareMessage,
    });
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      await LinkShareStatsService.recordShareAction();
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _telegram(BuildContext context) async {
    final uri = Uri(
      scheme: 'https',
      host: 't.me',
      pathSegments: const ['share', 'url'],
      queryParameters: {
        'url': MycardLinkConstants.newCardUrl,
        'text': 'CoopBank MyCard',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      await LinkShareStatsService.recordShareAction();
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _email(BuildContext context) async {
    final subject = Uri.encodeComponent('CoopBank MyCard');
    final body = Uri.encodeComponent(MycardLinkConstants.shareMessage);
    final uri = Uri.parse('mailto:?subject=$subject&body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      await LinkShareStatsService.recordShareAction();
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: MycardLinkConstants.shareMessage),
    );
    await LinkShareStatsService.recordShareAction();
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copied to clipboard'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _systemShare(BuildContext context) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        text: MycardLinkConstants.shareMessage,
        subject: 'CoopBank MyCard',
      ),
    );
    if (result.status == ShareResultStatus.success) {
      await LinkShareStatsService.recordShareAction();
    }
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _openInBrowser(BuildContext context) async {
    final uri = Uri.parse(MycardLinkConstants.newCardUrl);
    await LinkShareStatsService.recordLinkOpenFromApp();
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.credit_card_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 14),
              const Text(
                'Share MyCard link',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: blackColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Invite customers to open a digital card',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: graybackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: SelectableText(
                  MycardLinkConstants.newCardUrl,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SharePill(
                      label: 'WhatsApp',
                      color: _wa,
                      icon: Icons.chat_rounded,
                      onTap: () => _launch(context, () => _whatsapp(context)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SharePill(
                      label: 'Telegram',
                      color: _tg,
                      icon: Icons.send_rounded,
                      onTap: () => _launch(context, () => _telegram(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SharePill(
                      label: 'Email',
                      color: _mail,
                      icon: Icons.email_outlined,
                      onTap: () => _launch(context, () => _email(context)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SharePill(
                      label: 'Copy',
                      color: darkBlue,
                      icon: Icons.copy_rounded,
                      onTap: () => _launch(context, () => _copy(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _launch(context, () => _systemShare(context)),
                  icon: const Icon(Icons.share_outlined, size: 20),
                  label: const Text('More apps…'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: BorderSide(color: primaryBlue.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _launch(context, () => _openInBrowser(context)),
                icon: const Icon(Icons.open_in_new_rounded, size: 20),
                label: const Text('Open link in browser'),
                style: TextButton.styleFrom(foregroundColor: secondaryBlue),
              ),
              const Divider(height: 28),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.bar_chart_rounded, color: primaryBlue.withOpacity(0.9)),
                title: const Text(
                  'View share statistics',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Share actions & opens from this app',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MycardLinkStatsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SharePill extends StatelessWidget {
  const _SharePill({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color.withOpacity(0.12),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: color.withOpacity(0.92),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
