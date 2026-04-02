import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'signature_pad_card.dart';

/// Configuration for a single signature pad inside the drawer.
class SignaturePadConfig {
  final String label;
  final String? subtitle;

  const SignaturePadConfig({required this.label, this.subtitle});
}

/// A full-screen dialog that presents one or more [SignaturePadCard]s,
/// lets the user draw, then combines and returns the result as PNG bytes.
///
/// Usage:
/// ```dart
/// final bytes = await SignatureDrawerDialog.show(
///   context: context,
///   title: 'Draw Signatures',
///   pads: [
///     SignaturePadConfig(label: 'Full Signature', subtitle: 'Sign with your full name'),
///     SignaturePadConfig(label: 'Short Signature', subtitle: 'Initials or abbreviated'),
///     SignaturePadConfig(label: 'Confirmation Signature'),
///   ],
/// );
/// ```
class SignatureDrawerDialog {
  SignatureDrawerDialog._();

  static Future<Uint8List?> show({
    required BuildContext context,
    required List<SignaturePadConfig> pads,
    String title = 'Draw Your Signatures',
    double penStrokeWidth = 3,
    Color penColor = Colors.black,
  }) {
    return showGeneralDialog<Uint8List?>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Signature Drawer',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim, secondAnim) {
        return _SignatureDrawerPage(
          pads: pads,
          title: title,
          penStrokeWidth: penStrokeWidth,
          penColor: penColor,
        );
      },
    );
  }
}

class _SignatureDrawerPage extends StatefulWidget {
  final List<SignaturePadConfig> pads;
  final String title;
  final double penStrokeWidth;
  final Color penColor;

  const _SignatureDrawerPage({
    required this.pads,
    required this.title,
    required this.penStrokeWidth,
    required this.penColor,
  });

  @override
  State<_SignatureDrawerPage> createState() => _SignatureDrawerPageState();
}

class _SignatureDrawerPageState extends State<_SignatureDrawerPage> {
  late final List<SignatureController> _controllers;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.pads.length,
      (_) => SignatureController(
        penStrokeWidth: widget.penStrokeWidth,
        penColor: widget.penColor,
        exportBackgroundColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _allCompleted => _controllers.every((c) => c.isNotEmpty);

  Future<void> _onSave() async {
    if (!_allCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please complete all signature pads'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final combined = await _combineSignatures();
      if (mounted) Navigator.of(context).pop(combined);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<Uint8List?> _combineSignatures() async {
    final pngList = <Uint8List>[];
    for (final c in _controllers) {
      final bytes = await c.toPngBytes();
      if (bytes == null) return null;
      pngList.add(bytes);
    }

    final images = <ui.Image>[];
    for (final png in pngList) {
      images.add(await decodeImageFromList(png));
    }

    const spacing = 10;
    final totalWidth =
        images.fold<int>(0, (sum, img) => sum + img.width) +
            (spacing * (images.length - 1));
    final maxHeight = images.map((i) => i.height).reduce((a, b) => a > b ? a : b);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, totalWidth.toDouble(), maxHeight.toDouble()),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, totalWidth.toDouble(), maxHeight.toDouble()),
      Paint()..color = Colors.white,
    );

    double x = 0;
    for (final img in images) {
      canvas.drawImage(img, Offset(x, 0), Paint());
      x += img.width.toDouble() + spacing;
    }

    final picture = recorder.endRecording();
    final combined = await picture.toImage(totalWidth, maxHeight);
    final byteData =
        await combined.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: cyanblueColor),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: cyanblueColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (int i = 0; i < widget.pads.length; i++) ...[
                      if (i > 0) const SizedBox(height: 16),
                      SignaturePadCard(
                        controller: _controllers[i],
                        label: widget.pads[i].label,
                        subtitle: widget.pads[i].subtitle,
                        onClear: () => setState(() => _controllers[i].clear()),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.of(context).pop(null),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blueGrey.shade600,
                side: BorderSide(color: Colors.blueGrey.shade200),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _onSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(
                _isSaving ? 'Saving…' : 'Save Signatures',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: cyanblueColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: cyanblueColor.withOpacity(0.6),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
