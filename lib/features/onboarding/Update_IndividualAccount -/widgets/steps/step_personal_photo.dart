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

  void _loadExistingPhoto() {
    final registrationData = ref.read(registrationDataProvider);
    if (registrationData.photo != null) {
      // If we have photo data, we need to save it temporarily to display
      // For now, we'll just mark that we have a photo
      setState(() {
        profilePath = 'has_photo'; // Placeholder to indicate photo exists
      });
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
    final registrationData = ref.watch(registrationDataProvider);
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
                child: (() {
                  final photo = registrationData.photo;
                  if (profilePath.isEmpty && photo == null) {
                    return _buildPlaceholderIcon();
                  }
                  Widget imageWidget;
                  if (profilePath == 'has_photo' && photo != null) {
                    if (photo is Uint8List) {
                      imageWidget = Image.memory(
                        photo,
                        height: 200.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    } else if (photo is String) {
                      imageWidget = Image.network(
                        photo,
                        height: 200.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    } else {
                      imageWidget = _buildPlaceholderIcon();
                    }
                  } else if (profilePath.isNotEmpty && profilePath != 'has_photo') {
                    if (profilePath.startsWith('http')) {
                      imageWidget = Image.network(
                        profilePath,
                        height: 200.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    } else {
                      imageWidget = Image.file(
                        File(profilePath),
                        height: 200.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    }
                  } else {
                    imageWidget = _buildPlaceholderIcon();
                  }
                  // Add overlay icons
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: imageWidget,
                      ),
                      // Full screen button (top left)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: GestureDetector(
                          onTap: () => _showFullScreenImage(context, profilePath),
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
                      // Change image button (top right)
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
                    ],
                  );
                })(),
              ),
            ),
            // const SizedBox(height: 40.0),
          ])
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
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Check permissions first - simplified flow
      bool hasPermission = await _checkPermission(source);
      if (!hasPermission) {
        // Just show a simple message and return
        _showErrorSnackBar('Permission required to continue');
        return;
      }

      // Show loading indicator
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

      // Dismiss loading indicator
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (image != null) {
        final bytes = await _getImageBytes(image.path, 'temp_photo.jpg');
        if (bytes != null) {
          // Update registration data with the uploaded photo
          ref.read(registrationDataProvider.notifier).updatePhoto(photo: bytes);
          
          // Update local state to show the photo
          setState(() {
            profilePath = image.path;
            _photoBytes = bytes;
          });
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Clear any validation errors
          ref.read(formValidationProvider.notifier).clearError('photo');
        } else {
          _showErrorSnackBar('Failed to read image bytes');
        }
      } else {
        // User cancelled, do nothing
      }
    } catch (e) {
      // Dismiss loading indicator if still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      String errorMessage = 'Failed to pick image';
      if (e.toString().contains('permission')) {
        errorMessage =
            'Permission denied. Please grant camera permission in settings.';
      } else if (e.toString().contains('camera')) {
        errorMessage = 'Camera not available. Please try again or use gallery.';
      } else if (e.toString().contains('cancel')) {
        // User cancelled, don't show error
        return;
      } else {
        errorMessage = 'Failed to pick image: ${e.toString()}';
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
      if (profilePath.isNotEmpty && profilePath != 'has_photo') {
        final Uint8List? profileBytes =
            await _getImageBytes(profilePath, "profile.png");

        if (profileBytes != null) {
          // Update registration data
          ref
              .read(registrationDataProvider.notifier)
              .updatePhoto(photo: profileBytes);

          // Clear any validation errors
          ref.read(formValidationProvider.notifier).clearError('photo');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

      print("✅ Saved temporary photo at: ${tempFile.path}");
      print("📤 Photo Bytes Length: ${bytes.length}");
      return bytes; // Return the image bytes
    } else {
      print("❌ File does not exist at: $path");
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

    print(
        "📤 Profile Bytes: ${profileBytes != null ? 'Available' : 'Not available'}");

    // Get current user ID
    final userId = ref.read(userIdProvider);

    print("👤 User ID: $userId");
    print("🌐 Is Online: $isOnline");

    // Call controller method
    final success =
        await ref.read(registrationControllerProvider).handlePersonalPhotoStep(
              photo: profileBytes,
              isOnline: isOnline,
              userId: userId,
            );

    if (success) {
      print("✅ Personal Photo Step completed successfully!");
      print("📊 Progress: 50%");
      print("📋 Form Status: INITIAL");
    } else {
      print("❌ Personal Photo Step failed!");
      // Error is already handled by the controller and shown via SnackBar
    }
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    final registrationData = ref.read(registrationDataProvider);
    final photo = registrationData.photo;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: (() {
                    if (imagePath == 'has_photo' && photo != null) {
                      if (photo is Uint8List) {
                        return Image.memory(
                          photo,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        );
                      } else if (photo is String) {
                        return Image.network(
                          photo,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        );
                      }
                    }
                    if (imagePath.isNotEmpty && imagePath != 'has_photo') {
                      if (imagePath.startsWith('http')) {
                        return Image.network(
                          imagePath,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        );
                      } else {
                        return Image.file(
                          File(imagePath),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        );
                      }
                    }
                    return _buildPlaceholderIcon();
                  })(),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 36),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
              ),
            ),
          ],
        );
      },
    );
  }

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
