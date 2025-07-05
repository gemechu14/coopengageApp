import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import '../common/button_upload_take_photo.dart';
import '../../providers/registration_providers.dart';

class StepPersonalPhoto extends ConsumerStatefulWidget {
  const StepPersonalPhoto({super.key});

  @override
  ConsumerState<StepPersonalPhoto> createState() => _StepPersonalPhotoState();
}

class _StepPersonalPhotoState extends ConsumerState<StepPersonalPhoto> {
  String profilePath = '';
  final ImagePicker _picker = ImagePicker();

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

              // Progress indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Step Progress',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '5 of 8',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.625,
                      backgroundColor: Colors.grey.shade300,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '62.5% Complete',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
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
          child: Column(
            children: [
              const SizedBox(height: 10.0),
              Container(
                height: 200.0,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: profilePath.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(
                              'assets/photo1.png',
                              height: 170.0,
                              width: MediaQuery.of(context).size.width * 0.6,
                              fit: BoxFit.fill,
                            ),
                          )
                        ],
                      )
                    : GestureDetector(
                        onTap: () => _showFullScreenImage(context, profilePath),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: profilePath == 'has_photo'
                              ? FutureBuilder<Uint8List?>(
                                  future: _getImageBytesFromData(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData && snapshot.data != null) {
                                      return Image.memory(
                                        snapshot.data!,
                                        height: MediaQuery.of(context).size.height * 0.7,
                                        width: MediaQuery.of(context).size.width * 0.7,
                                        fit: BoxFit.fill,
                                      );
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  },
                                )
                              : Image.file(
                                  File(profilePath),
                                  height: MediaQuery.of(context).size.height * 0.7,
                                  width: MediaQuery.of(context).size.width * 0.7,
                                  fit: BoxFit.fill,
                                ),
                        ),
                      ),
              ),
              const SizedBox(height: 40.0),
              ButtonUploadTakePhoto(
                onUploadPressed: () => _imgFromGallery("profile"),
                onCapturePressed: () => _imgFromCamera("profile"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Future<void> _imgFromGallery(String type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          profilePath = image.path;
        });
        
        // Update registration data
        await _updatePhotoData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _imgFromCamera(String type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          profilePath = image.path;
        });
        
        // Update registration data
        await _updatePhotoData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updatePhotoData() async {
    try {
      if (profilePath.isNotEmpty && profilePath != 'has_photo') {
        final Uint8List? profileBytes = await _getImageBytes(profilePath, "profile.png");
        
        if (profileBytes != null) {
          // Update registration data
          ref.read(registrationDataProvider.notifier).updatePhoto(photo: profileBytes);
          
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

  Future<Uint8List?> _getImageBytes(String imagePath, String filename) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        return await imageFile.readAsBytes();
      }
      return null;
    } catch (e) {
      print('Error reading image bytes: $e');
      return null;
    }
  }

  Future<Uint8List?> _getImageBytesFromData() async {
    final registrationData = ref.read(registrationDataProvider);
    return registrationData.photo;
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Expanded(
                  child: imagePath == 'has_photo'
                      ? FutureBuilder<Uint8List?>(
                          future: _getImageBytesFromData(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.contain,
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        )
                      : Image.file(
                          File(imagePath),
                          fit: BoxFit.contain,
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 