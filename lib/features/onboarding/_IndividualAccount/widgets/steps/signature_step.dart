import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import '../common/signature_pad.dart';
import '../../providers/registration_providers.dart';

class SignatureStep extends ConsumerStatefulWidget {
  const SignatureStep({Key? key}) : super(key: key);

  @override
  ConsumerState<SignatureStep> createState() => _SignatureStepState();
}

class _SignatureStepState extends ConsumerState<SignatureStep> {
  late SignatureController _signatureController1;
  late SignatureController _signatureController2;
  late SignatureController _signatureController3;
  late TextEditingController _motherNameController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeSignatureControllers();
    _initializeControllers();
  }

  void _initializeControllers() {
    _motherNameController = TextEditingController();
    
    // Initialize with existing data if available
    final registrationData = ref.read(registrationDataProvider);
    if (registrationData.motherName != null) {
      _motherNameController.text = registrationData.motherName!;
    }
    
    // Add listener to update registration data when text changes
    _motherNameController.addListener(() {
      ref.read(registrationDataProvider.notifier).updatePersonalInfo(
        motherName: _motherNameController.text,
      );
      // Clear validation error when user types
      if (_motherNameController.text.isNotEmpty) {
        ref.read(formValidationProvider.notifier).clearError('motherName');
      }
    });
  }

  void _initializeSignatureControllers() {
    _signatureController1 = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 5,
      exportBackgroundColor: Colors.transparent,
    );
    _signatureController2 = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 5,
      exportBackgroundColor: Colors.transparent,
    );
    _signatureController3 = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 5,
      exportBackgroundColor: Colors.transparent,
    );
  }

  @override
  void dispose() {
    _signatureController1.dispose();
    _signatureController2.dispose();
    _signatureController3.dispose();
    _motherNameController.dispose();
    super.dispose();
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
                        Icon(Icons.edit, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Signature & Mother Name',
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
                      'Please provide your mother\'s name and draw your signature.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Mother Name
              _buildLabel("Mother Name"),
              ReusableTextFormField(
                hintText: "Enter Mother Name",
                controller: _motherNameController,
                keyboardType: TextInputType.text,
                errorMessage: validationErrors['motherName'] ?? '',
                leadingIcon: Icons.person,
                isRequired: true,
              ),


              const SizedBox(height: 20),

              // Signature
              _buildLabel("Signature"),
              _buildSignatureCard(registrationData.signature),
              _buildSignaturePadSelection(),

              const SizedBox(height: 30),

   
          
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignatureCard(Uint8List? signature) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
        child: Container(
          height: 150, // Reduced height
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0), // Smaller radius
            border: Border.all(color: Colors.grey.shade300, width: 1), // Minimized border
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2, // Reduced spread
                blurRadius: 4, // Reduced blur
              ),
            ],
          ),
          child: signature != null
              ? Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0), // Smaller radius
                    child: Image.memory(
                      signature,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8.0), // Smaller radius
                  child: Image.asset(
                    'assets/signature.png',
                    height: 10.0,
                    width: MediaQuery.of(context).size.width * 0.1,
                    fit: BoxFit.contain,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSignaturePadSelection() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _showSignaturePadDialog(context),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
            ),
            child: const Text("      Sign     "),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () => _showImagePicker(context),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
            ),
            child: const Text("Upload"),
          ),
        ],
      ),
    );
  }

  void _showSignaturePadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Draw Signatures',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SignaturePad(
                    controller: _signatureController1,
                    label: "Signature 1",
                    onClear: () => _clearSignature(1),
                  ),
                  const SizedBox(height: 20),
                  SignaturePad(
                    controller: _signatureController2,
                    label: "Signature 2",
                    onClear: () => _clearSignature(2),
                  ),
                  const SizedBox(height: 20),
                  SignaturePad(
                    controller: _signatureController3,
                    label: "Signature 3",
                    onClear: () => _clearSignature(3),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_areAllSignaturesCompleted()) {
                            _saveCombinedSignature();
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please complete all signatures'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text('Save'),
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

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Card(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 5.2,
            margin: const EdgeInsets.only(top: 8.0),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      await _pickImage(ImageSource.gallery);
                    },
                    child: const Column(
                      children: [
                        Icon(Icons.image, size: 60.0),
                        SizedBox(height: 12.0),
                        Text(
                          "Gallery",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      await _pickImage(ImageSource.camera);
                    },
                    child: const Column(
                      children: [
                        Icon(Icons.camera_alt, size: 60.0),
                        SizedBox(height: 12.0),
                        Text(
                          "Camera",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Image handling methods - similar to IdTypeStep
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Check permissions first
      bool hasPermission = await _checkPermission(source);
      if (!hasPermission) {
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
        await _cropAndProcessImage(File(image.path));
      }
    } catch (e) {
      // Dismiss loading indicator if still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      String errorMessage = 'Failed to pick image';
      if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please grant camera permission in settings.';
      } else if (e.toString().contains('camera')) {
        errorMessage = 'Camera not available. Please try again or use gallery.';
      } else if (e.toString().contains('cancel')) {
        return; // User cancelled, no need to show error
      } else {
        errorMessage = 'Failed to pick image: ${e.toString()}';
      }
      
      _showErrorSnackBar(errorMessage);
    }
  }

  Future<bool> _checkPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.status;
      if (status.isDenied) {
        final result = await Permission.camera.request();
        return result.isGranted;
      }
      return status.isGranted;
    } else {
      final status = await Permission.photos.status;
      if (status.isDenied) {
        final result = await Permission.photos.request();
        return result.isGranted;
      }
      return status.isGranted;
    }
  }

  Future<void> _cropAndProcessImage(File imageFile) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Crop the image
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Signature',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
            showCropGrid: true,
            cropGridColor: Colors.blue,
            cropFrameColor: Colors.blue,
            backgroundColor: Colors.white,
            statusBarColor: Colors.blue,
            activeControlsWidgetColor: Colors.blue,
            cropGridColumnCount: 3,
            cropGridRowCount: 3,
          ),
          IOSUiSettings(
            title: 'Crop Signature',
            aspectRatioLockEnabled: false,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
          ),
        ],
      );

      // Dismiss loading dialog
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (croppedFile != null) {
        // Read the file bytes directly
        final bytes = await croppedFile.readAsBytes();
        
        if (bytes.isNotEmpty) {
          // For uploaded signatures, we'll just store the bytes directly
          // since we can't import into signature controllers easily
          
          // Update registration data
          ref.read(registrationDataProvider.notifier).updateSignature(signature: bytes);
          
          // Clear validation error
          ref.read(formValidationProvider.notifier).clearError('signature');
          
          _showSuccessSnackBar('Signature uploaded successfully!');
        } else {
          _showErrorSnackBar('Failed to process signature');
        }
      }
    } catch (e) {
      // Dismiss loading dialog if still showing
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      String errorMessage = 'Failed to process signature';
      if (e.toString().contains('crop')) {
        errorMessage = 'Signature cropping was cancelled';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied for signature processing';
      } else {
        errorMessage = 'Failed to process signature: ${e.toString()}';
      }
      
      _showErrorSnackBar(errorMessage);
    }
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearSignature(int index) {
    setState(() {
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
    });
  }
  Widget _buildPlaceholderIcon(String imageType) {
    
    final title  = 'Personal Photo';
    
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

  bool _areAllSignaturesCompleted() {
    return _signatureController1.isNotEmpty &&
        _signatureController2.isNotEmpty &&
        _signatureController3.isNotEmpty;
  }

  Future<void> _saveCombinedSignature() async {
    final Uint8List? combinedImage = await _combineSignatures();
    if (combinedImage != null) {
      ref.read(registrationDataProvider.notifier).updateSignature(signature: combinedImage);
    }
  }

  Future<Uint8List?> _combineSignatures() async {
    // Get individual signature bytes
    final signature1 = await _signatureController1.toPngBytes();
    final signature2 = await _signatureController2.toPngBytes();
    final signature3 = await _signatureController3.toPngBytes();

    if (signature1 == null || signature2 == null || signature3 == null) {
      print("One or more signatures are empty!");
      return null;
    }

    // Decode the individual images
    final ui.Image image1 = await decodeImageFromList(signature1);
    final ui.Image image2 = await decodeImageFromList(signature2);
    final ui.Image image3 = await decodeImageFromList(signature3);

    // Calculate the total width and height (maximum height of all signatures)
    final int totalWidth =
        image1.width + image2.width + image3.width + 20; // Add spacing
    final int maxHeight = [image1.height, image2.height, image3.height]
        .reduce((a, b) => a > b ? a : b)!;

    // Draw the images onto a single canvas
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromLTWH(0, 0, totalWidth.toDouble(), maxHeight.toDouble()));

    double currentX = 0;

    // Draw signature 1
    canvas.drawImage(image1, Offset(currentX, 0), Paint());
    currentX += image1.width.toDouble() + 10; // Add spacing

    // Draw signature 2
    canvas.drawImage(image2, Offset(currentX, 0), Paint());
    currentX += image2.width.toDouble() + 10;

    // Draw signature 3
    canvas.drawImage(image3, Offset(currentX, 0), Paint());

    // End the recording
    final picture = recorder.endRecording();
    final combinedImage = await picture.toImage(totalWidth, maxHeight);

    // Convert the combined image to bytes
    final byteData =
        await combinedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  // Convert image to bytes - same as IdTypeStep implementation
  Future<Uint8List?> _getImageBytes(Uint8List imageBytes, String tempFileName) async {
    try {
      // Save the bytes as a temporary file
      final tempFile = File('${Directory.systemTemp.path}/$tempFileName');
      await tempFile.writeAsBytes(imageBytes);

      print("✅ Saved temporary signature at: ${tempFile.path}");
      print("📤 Signature Bytes Length: ${imageBytes.length}");
      return imageBytes; // Return the image bytes
    } catch (e) {
      print("❌ Error saving signature: $e");
      return null;
    }
  }

  // Handle signature step completion - using controller like other steps
  Future<void> handleSignatureStep() async {
    print("🔄 Starting Signature Step Registration...");
    
    // Get connectivity status
    final isOnline = ref.read(connectivityProvider);
    
    // Get signature bytes - check for uploaded signature first, then drawn signatures
    Uint8List? signatureBytes;
    final registrationData = ref.read(registrationDataProvider);
    
    if (registrationData.signature != null && registrationData.signature!.isNotEmpty) {
      // Use uploaded signature if available
      signatureBytes = registrationData.signature;
      print("📤 Using uploaded signature");
    } else {
      // Try to combine drawn signatures
      signatureBytes = await _combineSignatures();
      print("📤 Combined Signature Bytes: ${signatureBytes != null ? 'Available' : 'Not available'}");
    }

    // Get current user ID
    final userId = ref.read(userIdProvider);

    print("👤 User ID: $userId");
    print("🌐 Is Online: $isOnline");

    // Call controller method
    final success = await ref.read(registrationControllerProvider)
        .handleSignatureStep(
      signature: signatureBytes ?? Uint8List(0), // Provide empty bytes if null
      isOnline: isOnline,
      userId: userId,
    );

    if (success) {
      print("✅ Signature Step completed successfully!");
      print("📊 Progress: 37.5%");
      print("📋 Form Status: INITIAL");
    } else {
      print("❌ Signature Step failed!");
      // Error is already handled by the controller and shown via SnackBar
    }
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
}
