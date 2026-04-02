import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/core/common_widgets/signature_drawer_dialog.dart';
import '../providers/stepper_provider.dart';

class SignatureStep extends ConsumerStatefulWidget {
  const SignatureStep({super.key});

  @override
  ConsumerState<SignatureStep> createState() => _SignatureStepState();
}

class _SignatureStepState extends ConsumerState<SignatureStep> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _localSignature;
  bool _isProcessing = false;

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
          const SizedBox(height: 20),
          _buildPreview(currentSignature),
          const SizedBox(height: 20),
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

  // ── Preview ──────────────────────────────────────────────────────────────

  Widget _buildPreview(Uint8List? signature) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFDFE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: signature != null
              ? cyanblueColor.withOpacity(0.30)
              : cyanblueColor.withOpacity(0.15),
          width: signature != null ? 1.5 : 1,
        ),
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
            label: 'Draw Signature',
            icon: Icons.draw_rounded,
            onPressed: _isProcessing ? null : _openDrawer,
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

  // ── Draw flow (opens full-screen dialog) ─────────────────────────────────

  Future<void> _openDrawer() async {
    final result = await SignatureDrawerDialog.show(
      context: context,
      pads: const [
        SignaturePadConfig(label: 'Signature 1', subtitle: 'Primary signature'),
        SignaturePadConfig(label: 'Signature 2', subtitle: 'Secondary signature'),
        SignaturePadConfig(label: 'Signature 3', subtitle: 'Tertiary signature'),
      ],
    );

    if (result != null && mounted) {
      setState(() => _localSignature = result);
      ref.read(stepperProvider.notifier).updateSignature(result);
    }
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
