import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:coopengageplus/features/onboarding/customer/_IndividualAccount/widgets/common/signature_pad.dart';
import '../providers/stepper_provider.dart';

/// Signature Step Widget
///
/// Handles signature collection through:
/// - Digital signature pads (3 signatures combined)
/// - Image upload from gallery or camera
/// - Modern permission handling with standard UI
class SignatureStep extends ConsumerStatefulWidget {
  const SignatureStep({Key? key}) : super(key: key);

  @override
  ConsumerState<SignatureStep> createState() => _SignatureStepState();
}

class _SignatureStepState extends ConsumerState<SignatureStep> {
  // Signature controllers
  late SignatureController _signatureController1;
  late SignatureController _signatureController2;
  late SignatureController _signatureController3;

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // Local state
  Uint8List? _localSignatureData;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeSignatureControllers();
  }

  @override
  void dispose() {
    _cleanupControllers();
    super.dispose();
  }

  /// Initialize signature controllers
  void _initializeSignatureControllers() {
    _signatureController1 = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    _signatureController2 = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    _signatureController3 = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  /// Clean up controllers
  void _cleanupControllers() {
    _signatureController1.dispose();
    _signatureController2.dispose();
    _signatureController3.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepperState = ref.watch(stepperProvider);
    final currentSignature = stepperState.signature ?? _localSignatureData;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSignatureDisplay(currentSignature),
          const SizedBox(height: 24),
          _buildActionButtons(),
          if (_isProcessing) ...[
            const SizedBox(height: 16),
            _buildProcessingIndicator(),
          ],
        ],
      ),
    );
  }

  /// Build header section
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.edit, color: Colors.blue, size: 24),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Draw your signature or upload an image',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build signature display area
  Widget _buildSignatureDisplay(Uint8List? signature) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: signature != null
            ? Image.memory(
                signature,
                fit: BoxFit.contain,
              )
            : _buildPlaceholder(),
      ),
    );
  }

  /// Build placeholder when no signature
  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No signature added yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Draw or upload your signature',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'Draw Signature',
            icon: Icons.edit,
            color: Colors.blue,
            onPressed: () => _showSignaturePadDialog(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            label: 'Upload Image',
            icon: Icons.upload,
            color: Colors.blue,
            onPressed: () => _showImagePickerDialog(context),
          ),
        ),
      ],
    );
  }

  /// Build individual action button
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: _isProcessing ? null : onPressed,
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    );
  }

  /// Build processing indicator
  Widget _buildProcessingIndicator() {
    return const Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text(
            'Processing signature...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Show image picker dialog
  void _showImagePickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
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
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _handleImageSelection(ImageSource.gallery);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _handleImageSelection(ImageSource.camera);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Build image source option
  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignaturePadDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Signature Pad',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Draw Your Signatures'),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SignaturePad(
                            controller: _signatureController1,
                            label: "Primary Signature",
                            onClear: () => _clearSignature(1),
                          ),
                          const SizedBox(height: 16),
                          SignaturePad(
                            controller: _signatureController2,
                            label: "Secondary Signature",
                            onClear: () => _clearSignature(2),
                          ),
                          const SizedBox(height: 16),
                          SignaturePad(
                            controller: _signatureController3,
                            label: "Tertiary Signature",
                            onClear: () => _clearSignature(3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_areAllSignaturesCompleted()) {
                              _saveCombinedSignature();
                              Navigator.pop(context);
                            } else {
                              _showErrorMessage(
                                  'Please complete all three signatures');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Save Signatures'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Handle image selection with modern permission handling
  Future<void> _handleImageSelection(ImageSource source) async {
    try {
      setState(() => _isProcessing = true);

      // For modern approach, let the image_picker handle permissions directly
      // This will show the standard system permission dialog
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        await _processImageFile(File(image.path));
      }
    } catch (e) {
      _handleImagePickerError(e);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }







  /// Process image file
  Future<void> _processImageFile(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      if (mounted) {
        setState(() => _localSignatureData = bytes);
        ref.read(stepperProvider.notifier).updateSignature(bytes);
        _showSuccessMessage('Signature uploaded successfully');
      }
    } catch (e) {
      _showErrorMessage('Failed to process image: ${e.toString()}');
    }
  }

  /// Handle image picker errors
  void _handleImagePickerError(dynamic error) {
    String message = 'Failed to pick image';

    if (error.toString().contains('permission')) {
      message = 'Permission denied. Please grant access in settings.';
    } else if (error.toString().contains('camera')) {
      message = 'Camera not available. Please try gallery instead.';
    } else if (error.toString().contains('cancel')) {
      return; // User cancelled, no error needed
    }

    _showErrorMessage(message);
  }

  /// Check if all signatures are completed
  bool _areAllSignaturesCompleted() {
    return _signatureController1.isNotEmpty &&
        _signatureController2.isNotEmpty &&
        _signatureController3.isNotEmpty;
  }

  /// Save combined signature
  Future<void> _saveCombinedSignature() async {
    try {
      setState(() => _isProcessing = true);

      final combinedSignature = await _combineSignatures();
      if (combinedSignature != null && mounted) {
        setState(() => _localSignatureData = combinedSignature);
        ref.read(stepperProvider.notifier).updateSignature(combinedSignature);
      }
    } catch (e) {
      _showErrorMessage('Failed to save signatures: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Combine multiple signatures into one
  Future<Uint8List?> _combineSignatures() async {
    try {
      final signature1 = await _signatureController1.toPngBytes();
      final signature2 = await _signatureController2.toPngBytes();
      final signature3 = await _signatureController3.toPngBytes();

      if (signature1 == null || signature2 == null || signature3 == null) {
        return null;
      }

      final image1 = await decodeImageFromList(signature1);
      final image2 = await decodeImageFromList(signature2);
      final image3 = await decodeImageFromList(signature3);

      const spacing = 10;
      final totalWidth =
          image1.width + image2.width + image3.width + (spacing * 2);
      final maxHeight = [image1.height, image2.height, image3.height]
          .reduce((a, b) => a > b ? a : b);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, totalWidth.toDouble(), maxHeight.toDouble()),
      );

      // Draw white background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, totalWidth.toDouble(), maxHeight.toDouble()),
        Paint()..color = Colors.white,
      );

      // Draw signatures
      double currentX = 0;
      canvas.drawImage(image1, Offset(currentX, 0), Paint());
      currentX += image1.width.toDouble() + spacing;

      canvas.drawImage(image2, Offset(currentX, 0), Paint());
      currentX += image2.width.toDouble() + spacing;

      canvas.drawImage(image3, Offset(currentX, 0), Paint());

      final picture = recorder.endRecording();
      final combinedImage = await picture.toImage(totalWidth, maxHeight);
      final byteData =
          await combinedImage.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error combining signatures: $e');
      return null;
    }
  }

  /// Clear specific signature
  void _clearSignature(int index) {
    switch (index) {
      case 1:
        _signatureController1.clear();
        break;
      case 2:
        _signatureController2.clear();
        break;
      case 3:
        _signatureController3.clear();
        break;
    }
  }

  /// Show error message
  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
