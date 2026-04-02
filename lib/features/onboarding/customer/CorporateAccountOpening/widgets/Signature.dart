import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/core/common_widgets/signature_drawer_dialog.dart';
import '../providers/stepper_provider.dart';

class SignatureStep extends ConsumerStatefulWidget {
  const SignatureStep({Key? key}) : super(key: key);

  @override
  ConsumerState<SignatureStep> createState() => _SignatureStepState();
}

class _SignatureStepState extends ConsumerState<SignatureStep> {
  final ImagePicker _picker = ImagePicker();
  final Map<int, bool> _processingMap = {};

  @override
  Widget build(BuildContext context) {
    final stepperState = ref.watch(stepperProvider);
    final memberCount = stepperState.members.length;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          ...List.generate(memberCount, (index) {
            final member = stepperState.members[index];
            final signature = member.signature as Uint8List?;
            final isProcessing = _processingMap[index] ?? false;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: signature != null
                                ? cyanblueColor.withOpacity(0.1)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            signature != null
                                ? Icons.check_circle
                                : Icons.draw_outlined,
                            color: signature != null
                                ? cyanblueColor
                                : Colors.grey.shade400,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.fullName ?? 'Member ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                signature != null
                                    ? 'Signature added'
                                    : 'No signature yet',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: signature != null
                                      ? cyanblueColor
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildPreview(signature),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: isProcessing
                                ? null
                                : () => _openDrawer(index, member.fullName),
                            icon: const Icon(Icons.draw_rounded, size: 16),
                            label: const Text(
                              'Draw Signature',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: cyanblueColor,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isProcessing
                                ? null
                                : () => _openImagePicker(index),
                            icon: const Icon(Icons.upload_rounded, size: 16),
                            label: const Text(
                              'Upload Image',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: cyanblueColor,
                              side: BorderSide(
                                  color: cyanblueColor.withOpacity(0.4)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isProcessing) ...[
                      const SizedBox(height: 10),
                      const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: cyanblueColor),
                            ),
                            SizedBox(width: 8),
                            Text('Processing\u2026',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

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
                  'Draw signatures or upload an image for each member',
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

  Widget _buildPreview(Uint8List? signature) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFDFE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: signature != null
              ? cyanblueColor.withOpacity(0.30)
              : cyanblueColor.withOpacity(0.12),
          width: signature != null ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: signature != null
            ? Image.memory(signature, fit: BoxFit.contain)
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.draw_outlined,
                        size: 36, color: Colors.blueGrey.shade200),
                    const SizedBox(height: 6),
                    Text(
                      'No signature added yet',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _openDrawer(int memberIndex, String? memberName) async {
    final result = await SignatureDrawerDialog.show(
      context: context,
      title: memberName ?? 'Member ${memberIndex + 1}',
      pads: const [
        SignaturePadConfig(
            label: 'Signature 1', subtitle: 'Primary signature'),
        SignaturePadConfig(
            label: 'Signature 2', subtitle: 'Secondary signature'),
        SignaturePadConfig(
            label: 'Signature 3', subtitle: 'Tertiary signature'),
      ],
    );

    if (result != null && mounted) {
      ref
          .read(stepperProvider.notifier)
          .updateMemberSignature(memberIndex, result);
    }
  }

  void _openImagePicker(int memberIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
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
                  child: _buildSourceCard(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery, memberIndex);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSourceCard(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera, memberIndex);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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

  Future<void> _pickImage(ImageSource source, int memberIndex) async {
    try {
      setState(() => _processingMap[memberIndex] = true);

      final image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null && mounted) {
        final bytes = await File(image.path).readAsBytes();
        ref
            .read(stepperProvider.notifier)
            .updateMemberSignature(memberIndex, bytes);
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
      if (mounted) setState(() => _processingMap[memberIndex] = false);
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
