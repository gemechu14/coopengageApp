import 'package:flutter/material.dart';
import '../constants/form_styles.dart';
import '../models/link_generator_models.dart';
import '../widgets/email_success_card.dart';
import '../widgets/link_result_card.dart';

enum _LinkFlowModalType { success, error }

/// Merchant-style modals for link generation outcomes.
class LinkFlowModal {
  LinkFlowModal._();

  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return _show(
      context,
      type: _LinkFlowModalType.error,
      title: title,
      message: message,
    );
  }

  static Future<void> showLinkSuccess(
    BuildContext context, {
    required LinkGenerationResponse result,
    required SharePlatform platform,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, _, __) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, _, __) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
            child: _ScrollableResultModal(
              title: 'Link generated',
              subtitle: 'Your shareable invitation link is ready',
              child: LinkResultContent(
                result: result,
                platform: platform,
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> showEmailSuccess(
    BuildContext context, {
    required String recipientName,
    required String recipientEmail,
    required AccountType accountType,
    String? notes,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, _, __) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, _, __) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
            child: _ScrollableResultModal(
              title: 'Email sent',
              subtitle: 'The invitation was delivered successfully',
              child: EmailSuccessContent(
                recipientName: recipientName,
                recipientEmail: recipientEmail,
                accountType: accountType,
                notes: notes,
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> _show(
    BuildContext context, {
    required _LinkFlowModalType type,
    required String title,
    required String message,
  }) {
    final isError = type == _LinkFlowModalType.error;

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: !isError,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, _, __) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, _, __) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
            child: Center(
              child: _SimpleModal(
                type: type,
                title: title,
                message: message,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SimpleModal extends StatelessWidget {
  const _SimpleModal({
    required this.type,
    required this.title,
    required this.message,
  });

  final _LinkFlowModalType type;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isError = type == _LinkFlowModalType.error;
    final accent = isError ? const Color(0xFFDC2626) : FormStyles.coopCyan;
    final iconBg = isError
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFFFC107).withOpacity(0.25);
    final iconFg =
        isError ? const Color(0xFFB91C1C) : const Color(0xFFC9A227);
    final icon = isError
        ? Icons.error_outline_rounded
        : Icons.check_rounded;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withOpacity(0.22)),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.12),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBg,
                    boxShadow: isError
                        ? null
                        : [
                            BoxShadow(
                              color: const Color(0xFFFFC107).withOpacity(0.35),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                  ),
                  child: Icon(icon, color: iconFg, size: 34),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isError
                        ? const Color(0xFF991B1B)
                        : Colors.amber.shade800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: FormStyles.muted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          isError ? const Color(0xFFDC2626) : FormStyles.coopCyan,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isError ? 'Try again' : 'Done',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
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

class _ScrollableResultModal extends StatelessWidget {
  const _ScrollableResultModal({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.88;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Center(
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420, maxHeight: maxH),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: FormStyles.coopCyan.withOpacity(0.22),
              ),
              boxShadow: [
                BoxShadow(
                  color: FormStyles.coopCyan.withOpacity(0.14),
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 12, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFC107).withOpacity(0.25),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Color(0xFFC9A227),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.amber.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: FormStyles.muted,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: FormStyles.muted.withOpacity(0.8),
                        ),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 4, 20, 12 + bottom),
                    child: child,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottom),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: FormStyles.coopCyan,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
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
