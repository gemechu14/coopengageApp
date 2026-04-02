import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/core/common_widgets/signature_pad_card.dart';
import '../providers/stepper_provider.dart';
import 'package:signature/signature.dart';

class SignatureStep extends ConsumerStatefulWidget {
  const SignatureStep({super.key});

  @override
  ConsumerState<SignatureStep> createState() => _SignatureStepState();
}

class _SignatureStepState extends ConsumerState<SignatureStep> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _localSignature;
  bool _isProcessing = false;

  late final SignatureController _signatureController1;
  late final SignatureController _signatureController2;
  late final SignatureController _signatureController3;

  static const _signatureLabels = [
    'Signature 1',
    'Signature 2',
    'Signature 3',
  ];

  static const _signatureSubtitles = [
    'Primary signature',
    'Secondary signature',
    'Tertiary signature',
  ];

  @override
  void initState() {
    super.initState();
    _signatureController1 = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 3,
      exportBackgroundColor: Colors.white,
    );
    _signatureController2 = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 3,
      exportBackgroundColor: Colors.white,
    );
    _signatureController3 = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 3,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _signatureController1.dispose();
    _signatureController2.dispose();
    _signatureController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSignature =
        ref.watch(stepperProvider).signature ?? _localSignature;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildPads(),
          if (currentSignature != null) ...[
            const SizedBox(height: 16),
            _buildPreview(currentSignature),
            const SizedBox(height: 16),
          ],
          _buildActions(),
          if (_isProcessing) ...[
            const SizedBox(height: 16),
            _buildProcessingIndicator(),
          ],
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cyanblueColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cyanblueColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cyanblueColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.draw_rounded,
                color: cyanblueColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Specimen Signatures',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cyanblueColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Draw your signatures or upload an image',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPads() {
    return Column(
      children: [
        SignaturePadCard(
          controller: _signatureController1,
          label: _signatureLabels[0],
          subtitle: _signatureSubtitles[0],
          onClear: () => setState(() {}),
        ),
        const SizedBox(height: 14),
        SignaturePadCard(
          controller: _signatureController2,
          label: _signatureLabels[1],
          subtitle: _signatureSubtitles[1],
          onClear: () => setState(() {}),
        ),
        const SizedBox(height: 14),
        SignaturePadCard(
          controller: _signatureController3,
          label: _signatureLabels[2],
          subtitle: _signatureSubtitles[2],
          onClear: () => setState(() {}),
        ),
      ],
    );
  }

  // ── Signature preview ────────────────────────────────────────────────────

  Widget _buildPreview(Uint8List? signature) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFDFE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cyanblueColor.withOpacity(0.20), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: signature != null
            ? Image.memory(signature, fit: BoxFit.contain)
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.draw_outlined, size: 44, color: Colors.blueGrey.shade200),
          const SizedBox(height: 8),
          Text(
            'No signature added yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey.shade400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Use the buttons below to get started',
            style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade300),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ───────────────────────────────────────────────────────

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Save Signatures',
            icon: Icons.check_rounded,
            onPressed: _isProcessing ? null : _saveSignatures,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            label: 'Upload Image',
            icon: Icons.upload_rounded,
            outlined: true,
            onPressed: _isProcessing ? null : _openImagePicker,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingIndicator() {
    return const Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: cyanblueColor),
          ),
          SizedBox(width: 8),
          Text('Processing…', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ── Upload flow ──────────────────────────────────────────────────────────

  void _openImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ImageSourceSheet(
        onGallery: () => _pickImage(ImageSource.gallery),
        onCamera: () => _pickImage(ImageSource.camera),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isProcessing = true);

      final image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null && mounted) {
        final bytes = await File(image.path).readAsBytes();
        setState(() => _localSignature = bytes);
        ref.read(stepperProvider.notifier).updateSignature(bytes);
        _showSnackBar('Signature uploaded successfully', Colors.green);
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('cancel')) return;
      _showSnackBar(
        msg.contains('permission')
            ? 'Permission denied. Please grant access in settings.'
            : 'Failed to pick image',
        Colors.redAccent,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _saveSignatures() async {
    final isComplete = _signatureController1.isNotEmpty &&
        _signatureController2.isNotEmpty &&
        _signatureController3.isNotEmpty;
    if (!isComplete) {
      _showSnackBar('Please complete all 3 signature pads', Colors.redAccent);
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final combined = await _combineSignatures();
      if (combined == null) {
        _showSnackBar('Failed to combine signatures', Colors.redAccent);
        return;
      }

      if (!mounted) return;
      setState(() => _localSignature = combined);
      ref.read(stepperProvider.notifier).updateSignature(combined);
      _showSnackBar('Signatures saved successfully', Colors.green);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<Uint8List?> _combineSignatures() async {
    final signature1 = await _signatureController1.toPngBytes();
    final signature2 = await _signatureController2.toPngBytes();
    final signature3 = await _signatureController3.toPngBytes();

    if (signature1 == null || signature2 == null || signature3 == null) {
      return null;
    }

    final image1 = await _decodeImageFromList(signature1);
    final image2 = await _decodeImageFromList(signature2);
    final image3 = await _decodeImageFromList(signature3);

    const spacing = 10;
    final totalWidth =
        image1.width + image2.width + image3.width + (spacing * 2);
    final maxHeight =
        [image1.height, image2.height, image3.height].reduce((a, b) => a > b ? a : b);

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      ui.Rect.fromLTWH(0, 0, totalWidth.toDouble(), maxHeight.toDouble()),
    );

    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, totalWidth.toDouble(), maxHeight.toDouble()),
      ui.Paint()..color = Colors.white,
    );

    double currentX = 0;
    canvas.drawImage(image1, ui.Offset(currentX, 0), ui.Paint());
    currentX += image1.width.toDouble() + spacing;

    canvas.drawImage(image2, ui.Offset(currentX, 0), ui.Paint());
    currentX += image2.width.toDouble() + spacing;

    canvas.drawImage(image3, ui.Offset(currentX, 0), ui.Paint());

    final picture = recorder.endRecording();
    final combinedImage = await picture.toImage(totalWidth, maxHeight);
    final byteData =
        await combinedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<ui.Image> _decodeImageFromList(Uint8List bytes) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, (image) => completer.complete(image));
    return completer.future;
  }
}

// ── Small private widgets ──────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool outlined;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: cyanblueColor,
          side: BorderSide(color: cyanblueColor.withOpacity(0.4)),
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: FilledButton.styleFrom(
        backgroundColor: cyanblueColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _ImageSourceSheet extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  const _ImageSourceSheet({
    required this.onGallery,
    required this.onCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Upload Signature Image',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.blueGrey.shade800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SourceCard(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    onGallery();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SourceCard(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    onCamera();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: cyanblueColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cyanblueColor.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: cyanblueColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
