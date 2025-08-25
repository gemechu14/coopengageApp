// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import '../common/image_selection_dialog.dart';
import '../../providers/registration_providers.dart';

class StepPersonalPhoto extends ConsumerStatefulWidget {
  const StepPersonalPhoto({super.key});

  @override
  ConsumerState<StepPersonalPhoto> createState() => _StepPersonalPhotoState();
}

class _StepPersonalPhotoState extends ConsumerState<StepPersonalPhoto> {
  String profilePath = '';
  final ImagePicker _picker = ImagePicker();

  // Image bytes for API
  Uint8List? _photoBytes;

  @override
  void initState() {
    super.initState();
    _loadExistingPhoto();
  }

  @override
  void dispose() {
    _cleanupTempFiles();
    super.dispose();
  }

  void _cleanupTempFiles() {
    // Clean up temporary files created for image restoration
    if (profilePath.isNotEmpty && profilePath.contains('restored_')) {
      try {
        File(profilePath).delete();
      } catch (e) {
        debugPrint("Note: Could not delete temp photo file: $e");
      }
    }
  }

  void _clearPhoto() {
    setState(() {
      profilePath = '';
      _photoBytes = null;
    });

    // Update registration data
    ref.read(registrationDataProvider.notifier).updatePhoto(photo: null);

    // Clear validation errors
    ref.read(formValidationProvider.notifier).clearError('photo');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo cleared successfully'),
        backgroundColor: Colors.orange,
      ),
    );

    debugPrint("🗑️ Photo cleared from provider");
  }

  void _loadExistingPhoto() {
    final registrationData = ref.read(registrationDataProvider);
    debugPrint("🔄 [PersonalPhoto] Loading existing photo...");

    if (registrationData.photo != null) {
      debugPrint(
          "   - Found photo data (${registrationData.photo!.length} bytes)");
      _photoBytes = registrationData.photo;

      // Create a temporary file for display
      _createTempImageFile(registrationData.photo!, 'personal_photo')
          .then((path) {
        if (mounted && path != null) {
          setState(() {
            profilePath = path;
          });
          debugPrint("   - Photo restored successfully");
        }
      });
    } else {
      debugPrint("   - No photo data found");
    }
  }

  Future<String?> _createTempImageFile(
      Uint8List bytes, String imageType) async {
    try {
      final tempDir = Directory.systemTemp;
      final fileName =
          'restored_${imageType}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = File('${tempDir.path}/$fileName');

      await tempFile.writeAsBytes(bytes);
      debugPrint(
          "✅ Created temporary image file for $imageType: ${tempFile.path}");

      return tempFile.path;
    } catch (e) {
      debugPrint("❌ Error creating temporary image file for $imageType: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final registrationData = ref.watch(registrationDataProvider);
    final validationErrors = ref.watch(formValidationProvider);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: graybackgroundColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.camera_alt, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Personal Photo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please upload or take a clear photo of yourself.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Personal Photo Section
              _buildLabel("Personal Photo"),
              personalPhoto(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 10, right: 3),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Column personalPhoto() {
    return Column(
      children: [
        Center(
          child: Column(children: [
            const SizedBox(height: 10.0),
            GestureDetector(
              onTap: () => _showImageSelectionDialog(),
              child: Container(
                height: 180.0, // Reduced height
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0), // Smaller radius
                  border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1), // Minimized border
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05), // Reduced shadow
                      blurRadius: 5, // Reduced blur
                      offset: const Offset(0, 2), // Reduced offset
                    ),
                  ],
                ),
                child: profilePath.isEmpty
                    ? _buildPlaceholderIcon()
                    : Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: _photoBytes != null
                                ? Image.memory(
                                    _photoBytes!,
                                    height: 180.0,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(profilePath),
                                    height: 180.0,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          // Success indicator
                          Positioned(
                            top: 8,
                            right: 40,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          // Full screen button
                          Positioned(
                            top: 8,
                            left: 8,
                            child: GestureDetector(
                              onTap: () =>
                                  _showFullScreenImage(context, profilePath),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.fullscreen,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          // Change image button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => _showImageSelectionDialog(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          // Clear photo button
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => _clearPhoto(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              // const SizedBox(height: 40.0),
            )
          ]),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildPlaceholderIcon() {
    final title = 'Personal Photo';

    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cyanblueColor.withOpacity(0.05),
            cyanblueColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cyanblueColor.withOpacity(0.2),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cyanblueColor.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: cyanblueColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.add_a_photo,
              size: 40,
              color: cyanblueColor,
            ),
          ),
          // const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cyanblueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Tap to add',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: cyanblueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show image selection dialog - same as IdTypeStep
  void _showImageSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => ImageSelectionDialog(
        title: 'Personal Photo',
        subtitle: 'Choose how you want to add your photo',
        onOptionSelected: (source) async {
          try {
            await _pickImage(source);
          } catch (e) {
            // If camera fails, show option to use gallery instead
            if (source == ImageSource.camera) {
              _showCameraFallbackDialog();
            }
          }
        },
      ),
    );
  }

  void _showCameraFallbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Unavailable'),
        content: const Text(
            'Camera is not available. Would you like to select from gallery instead?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text('Use Gallery'),
          ),
        ],
      ),
    );
  }

  // Image handling methods - same as IdTypeStep
  // Future<void> _pickImage(ImageSource source) async {
  //   try {
  //     // Check permissions first - simplified flow
  //     bool hasPermission = await _checkPermission(source);
  //     if (!hasPermission) {
  //       // Just show a simple message and return
  //       _showErrorSnackBar('Permission required to continue');
  //       return;
  //     }

  //     // Show loading indicator
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => const Center(
  //         child: CircularProgressIndicator(),
  //       ),
  //     );

  //     final XFile? image = await _picker.pickImage(
  //       source: source,
  //       imageQuality: 80,
  //       maxWidth: 1920,
  //       maxHeight: 1080,
  //     );

  //     // Dismiss loading indicator
  //     if (Navigator.canPop(context)) {
  //       Navigator.pop(context);
  //     }

  //   } catch (e) {
  //     // Dismiss loading indicator if still showing
  //     if (Navigator.canPop(context)) {
  //       Navigator.pop(context);
  //     }

  //     String errorMessage = 'Failed to pick image';
  //     if (e.toString().contains('permission')) {
  //       errorMessage =
  //           'Permission denied. Please grant camera permission in settings.';
  //     } else if (e.toString().contains('camera')) {
  //       errorMessage = 'Camera not available. Please try again or use gallery.';
  //     } else if (e.toString().contains('cancel')) {
  //       // User cancelled, don't show error
  //       return;
  //     } else {
  //       errorMessage = 'Failed to pick image: ${e.toString()}';
  //     }

  //     _showErrorSnackBar(errorMessage);
  //   }
  // }

  Future<void> _pickImage(ImageSource source) async {
    try {
      bool hasPermission = await _checkPermission(source);
      if (!hasPermission) {
        _showErrorSnackBar('Permission required to continue');
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      // Dismiss loading
      if (Navigator.canPop(context)) Navigator.pop(context);

      if (image != null) {
        final bytes = await _getImageBytes(image.path, 'personal_photo.jpg');
        if (bytes != null) {
          setState(() {
            profilePath = image.path;
            _photoBytes = bytes;
          });

          // Update registration data immediately
          _updatePhotoData();

          debugPrint("✅ Personal photo updated (${bytes.length} bytes)");
        } else {
          _showErrorSnackBar('Failed to read image bytes');
        }
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      String errorMessage = 'Failed to pick image';
      if (e.toString().contains('permission')) {
        errorMessage =
            'Permission denied. Please grant camera permission in settings.';
      } else if (e.toString().contains('camera')) {
        errorMessage = 'Camera not available. Please try again or use gallery.';
      }
      _showErrorSnackBar(errorMessage);
    }
  }

  Future<bool> _checkPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      // Check camera permission status
      PermissionStatus status = await Permission.camera.status;

      // If not granted, request it
      if (!status.isGranted) {
        status = await Permission.camera.request();
      }

      return status.isGranted;
    } else {
      // Check gallery permission status
      PermissionStatus status = await Permission.photos.status;

      // If not granted, request it
      if (!status.isGranted) {
        status = await Permission.photos.request();
      }

      return status.isGranted;
    }
  }

  Future<void> _updatePhotoData() async {
    try {
      if (_photoBytes != null) {
        // Update registration data
        ref
            .read(registrationDataProvider.notifier)
            .updatePhoto(photo: _photoBytes);

        // Clear any validation errors
        ref.read(formValidationProvider.notifier).clearError('photo');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        debugPrint(
            "✅ Photo data updated in provider (${_photoBytes!.length} bytes)");
      } else if (profilePath.isNotEmpty && !profilePath.contains('restored_')) {
        final Uint8List? profileBytes =
            await _getImageBytes(profilePath, "profile.png");

        if (profileBytes != null) {
          _photoBytes = profileBytes;
          ref
              .read(registrationDataProvider.notifier)
              .updatePhoto(photo: profileBytes);
          ref.read(formValidationProvider.notifier).clearError('photo');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          debugPrint(
              "✅ Photo file converted and updated (${profileBytes.length} bytes)");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint("❌ Error updating photo data: $e");
    }
  }

  // Convert image to bytes - same as IdTypeStep implementation
  Future<Uint8List?> _getImageBytes(String path, String tempFileName) async {
    final imageFile = File(path);

    if (await imageFile.exists()) {
      Uint8List bytes = await imageFile.readAsBytes();

      // Save the bytes as a temporary file
      final tempFile = File('${Directory.systemTemp.path}/$tempFileName');
      await tempFile.writeAsBytes(bytes);

      return bytes; // Return the image bytes
    } else {
      return null;
    }
  }

  Future<Uint8List?> _getImageBytesFromData() async {
    final registrationData = ref.read(registrationDataProvider);
    return registrationData.photo;
  }

  // Handle personal photo step completion - using controller like other steps
  Future<void> handlePersonalPhotoStep() async {
    print("🔄 Starting Personal Photo Step Registration...");

    // Get connectivity status
    final isOnline = ref.read(connectivityProvider);

    // Get photo bytes
    Uint8List? profileBytes;
    if (profilePath.isNotEmpty && profilePath != 'has_photo') {
      profileBytes = await _getImageBytes(profilePath, "profile.png");
    }

    // Get current user ID
    final userId = ref.read(userIdProvider);

    // Call controller method
    final success =
        await ref.read(registrationControllerProvider).handlePersonalPhotoStep(
              photo: profileBytes,
              isOnline: isOnline,
              userId: userId,
            );

    if (success) {
    } else {
      // Error is already handled by the controller and shown via SnackBar
    }
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _showFullScreenImage(BuildContext context, String imagePath) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         child: Container(
  //           width: MediaQuery.of(context).size.width * 0.9,
  //           height: MediaQuery.of(context).size.height * 0.7,
  //           child: Column(
  //             children: [
  //               Expanded(
  //                 child: _photoBytes != null
  //                     ? Image.memory(
  //                         _photoBytes!,
  //                         fit: BoxFit.contain,
  //                       )
  //                     : Image.file(
  //                         File(imagePath),
  //                         fit: BoxFit.contain,
  //                       ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: TextButton(
  //                   onPressed: () => Navigator.of(context).pop(),
  //                   child: const Text('Close'),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
