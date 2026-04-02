import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';

/// Reusable full-screen authentication dialog with WebView.
/// Used by Individual, Joint, and Corporate account flows.
class FullScreenAuthDialog {
  /// Shows a full-screen dialog containing a WebView for National ID auth.
  ///
  /// [context] - Parent build context.
  /// [webViewController] - Pre-configured WebViewController to display.
  /// [title] - Dialog header title.
  /// [pageLoading] - Optional ValueNotifier to show/hide a loading overlay.
  /// [onClose] - Called when the dialog is dismissed (via close button or pop).
  static Future<void> show({
    required BuildContext context,
    required WebViewController webViewController,
    String title = 'National ID Authentication',
    ValueNotifier<bool>? pageLoading,
    VoidCallback? onClose,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (dialogContext) {
        final size = MediaQuery.sizeOf(dialogContext);
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Material(
              color: const Color(0xFFF4F8FF),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SafeArea(
                    bottom: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: cyanblueColor,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.security, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            icon:
                                const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SafeArea(
                      top: false,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          WebViewWidget(controller: webViewController),
                          if (pageLoading != null)
                            ValueListenableBuilder<bool>(
                              valueListenable: pageLoading,
                              builder: (context, loading, _) {
                                if (!loading) return const SizedBox.shrink();
                                return ColoredBox(
                                  color: const Color(0xFFF4F8FF),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: CircularProgressIndicator(
                                            color: cyanblueColor,
                                            strokeWidth: 3,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Opening secure verification\u2026',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: blueColor,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          'This may take a few seconds',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: textInfoColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      onClose?.call();
    });
  }
}
