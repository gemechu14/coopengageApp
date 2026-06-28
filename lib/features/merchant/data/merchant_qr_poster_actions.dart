import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

const _coopCyan = Color(0xFF00AEEF);
const _errorRed = Color(0xFFD32F2F);

/// Bottom toast banner — cyan for success, red for errors.
void showTopBanner(
  BuildContext context, {
  required String message,
  required bool success,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _MerchantToastBanner(
      message: message,
      success: success,
      duration: duration,
      onDone: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

class _MerchantToastBanner extends StatefulWidget {
  const _MerchantToastBanner({
    required this.message,
    required this.success,
    required this.duration,
    required this.onDone,
  });

  final String message;
  final bool success;
  final Duration duration;
  final VoidCallback onDone;

  @override
  State<_MerchantToastBanner> createState() => _MerchantToastBannerState();
}

class _MerchantToastBannerState extends State<_MerchantToastBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 250),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _ctrl.forward();

    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _ctrl.reverse();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final isSuccess = widget.success;
    final accent = isSuccess ? _coopCyan : _errorRed;

    return Positioned(
      bottom: bottom + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess
                          ? Icons.check_circle_rounded
                          : Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
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

/// Save / share helpers for merchant QR poster images.
class MerchantQrPosterActions {
  MerchantQrPosterActions._();

  /// Saves the poster to the device gallery (Photos on iOS, Gallery on Android).
  /// Falls back to the Downloads folder on Android when gallery save fails.
  static Future<MerchantQrPosterSaveResult> downloadToDevice({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return MerchantQrPosterSaveResult.failure(
        'Download is only supported on mobile devices.',
      );
    }

    final granted = await _ensureSavePermission();
    if (!granted) {
      return MerchantQrPosterSaveResult.failure(
        'Permission denied. Allow storage/photos access to save the poster.',
      );
    }

    final safeName = _safeFileName(fileName);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$safeName');
    await tempFile.writeAsBytes(bytes);

    final savedToGallery = await GallerySaver.saveImage(
      tempFile.path,
      albumName: 'Merchant QR',
    );
    if (savedToGallery == true) {
      return MerchantQrPosterSaveResult.success(
        Platform.isIOS
            ? 'Poster saved to Photos.'
            : 'Poster saved to your Gallery.',
      );
    }

    if (Platform.isAndroid) {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        final dest = File('${downloadsDir.path}/$safeName');
        await dest.writeAsBytes(bytes);
        return MerchantQrPosterSaveResult.success(
          'Poster saved to Downloads ($safeName).',
        );
      }
    }

    return MerchantQrPosterSaveResult.failure(
      'Could not save poster. Try Share instead.',
    );
  }

  /// Opens the system share sheet with the poster image attached.
  static Future<void> sharePoster({
    required Uint8List bytes,
    required String fileName,
    required String subject,
  }) async {
    final safeName = _safeFileName(fileName);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$safeName');
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        subject: subject,
      ),
    );
  }

  static String _safeFileName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'qr-poster.png';
    return trimmed.replaceAll(RegExp(r'[^\w\-.]'), '_');
  }

  static Future<bool> _ensureSavePermission() async {
    if (Platform.isIOS) {
      var status = await Permission.photosAddOnly.status;
      if (!status.isGranted && !status.isLimited) {
        status = await Permission.photosAddOnly.request();
      }
      if (status.isGranted || status.isLimited) return true;

      status = await Permission.photos.status;
      if (!status.isGranted && !status.isLimited) {
        status = await Permission.photos.request();
      }
      return status.isGranted || status.isLimited;
    }

    if (Platform.isAndroid) {
      var status = await Permission.photos.status;
      if (!status.isGranted) {
        status = await Permission.photos.request();
      }
      if (status.isGranted) return true;

      status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      return status.isGranted;
    }

    return false;
  }
}

class MerchantQrPosterSaveResult {
  const MerchantQrPosterSaveResult._({
    required this.success,
    this.message,
  });

  final bool success;
  final String? message;

  factory MerchantQrPosterSaveResult.success(String message) {
    return MerchantQrPosterSaveResult._(success: true, message: message);
  }

  factory MerchantQrPosterSaveResult.failure(String message) {
    return MerchantQrPosterSaveResult._(success: false, message: message);
  }
}
