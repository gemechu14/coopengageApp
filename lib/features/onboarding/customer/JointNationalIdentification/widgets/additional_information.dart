import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'dart:io';

import 'package:coopengageplus/shared/widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/shared/widgets/dropDown/branch_selector.dart';
import 'package:coopengageplus/core/constants/listConstants.dart';
// import 'package:coopengageplus/features/onboarding/customer/_IndividualAccount/widgets/common/signature_pad.dart';
import 'package:coopengageplus/shared/widgets/ReusableTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';
import '../providers/stepper_provider.dart';

class PhoneFanWidget extends ConsumerStatefulWidget {
  const PhoneFanWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<PhoneFanWidget> createState() => _PhoneFanWidgetState();
}

class _PhoneFanWidgetState extends ConsumerState<PhoneFanWidget> {
  final TextEditingController motherNameController = TextEditingController();
  final TextEditingController initialdepositController =
      TextEditingController();
  late SignatureController _signatureController1;
  late SignatureController _signatureController2;
  late SignatureController _signatureController3;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _signatureData;
  // Mock data - replace with your actual data
  final List<String> productTypes = [
    'Savings Account',
    'Current Account',
    'Fixed Deposit',
    'Business Account',
  ];

  final List<String> branches = [
    'Addis Ababa Main Branch',
    'Bole Branch',
    'Kazanchis Branch',
    'Meskel Square Branch',
  ];

  @override
  void initState() {
    super.initState();
    _signatureController1 = SignatureController(
      penStrokeWidth: 5,
      exportBackgroundColor: Colors.white,
    );
    _signatureController2 = SignatureController(
      penStrokeWidth: 5,
      exportBackgroundColor: Colors.white,
    );
    _signatureController3 = SignatureController(
      penStrokeWidth: 5,
      exportBackgroundColor: Colors.white,
    );

    // Initialize with existing values from state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      
      final stepperState = ref.read(stepperProvider);
      if (stepperState.motherName != null &&
          stepperState.motherName!.isNotEmpty) {
        motherNameController.text = stepperState.motherName!;
      }
      if (stepperState.initialDeposit != null &&
          initialdepositController.text !=
              stepperState.initialDeposit.toString()) {
        initialdepositController.text = stepperState.initialDeposit.toString();
      }
    });
  }

  @override
  void dispose() {
    motherNameController.dispose();
    _signatureController1.dispose();
    _signatureController2.dispose();
    _signatureController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepperState = ref.watch(stepperProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textLabel("Mother Name"),
        ReusableTextFormField(
          hintText: "Mother Name",
          controller: motherNameController,
          keyboardType: TextInputType.text,
          errorMessage: "Mother Name cannot be empty",
          leadingIcon: Icons.person,
          isRequired: false,
          onChanged: (value) {
            // Save to stepper state
            ref.read(stepperProvider.notifier).updateMotherName(value);
          },
        ),
        textLabel("Branch"),
        BranchSelector(
          initialValue: stepperState.selectedBranch,
          onChanged: (value) {
            ref.read(stepperProvider.notifier).updateBranch(value);
          },
        ),
        textLabel("Initial Amount"),
        ReusableTextFormField(
          hintText: "Initial Amount",
          controller: initialdepositController,
          keyboardType: TextInputType.number,
          errorMessage: "Initial amount cannot be empty",
          leadingIcon: Icons.balance,
          isRequired: true,
          onChanged: (value) {
            // Save to stepper state
            ref
                .read(stepperProvider.notifier)
                .updateInitialDeposit(double.tryParse(value));
          },
        ),
        textLabel("Product Type"),
        ReusableDropdown(
          selectedValue: stepperState.selectedProductType,
          items: ListContants.productType,
          hintText: 'Select Product Type',
          onChanged: (newStatus) {
            if (newStatus != null) {
              ref.read(stepperProvider.notifier).updateProductType(newStatus);
            }
          },
          prefixIcon: Icons.business,
          errorMessage: 'Please select a product type',
          isRequired: true,
        ),

        textLabel("Title"),
        ReusableDropdown(
          selectedValue: stepperState.selectedTitle,
          items: ListContants.title,
          hintText: 'Select Title',
          onChanged: (newStatus) {
            if (newStatus != null) {
              ref.read(stepperProvider.notifier).updateTitle(newStatus);
            }
          },
          prefixIcon: Icons.person,
          errorMessage: 'Please select a title',
          isRequired: true,
        ),

        textLabel("Marital Status"),
        ReusableDropdown(
          selectedValue: stepperState.selectedMaritalStatus,
          items: ListContants.maritalStatuses,
          hintText: 'Select Marital status',
          onChanged: (newStatus) {
            if (newStatus != null) {
              ref.read(stepperProvider.notifier).updateMaritalStatus(newStatus);
            }
          },
          prefixIcon: Icons.family_restroom,
          errorMessage: 'Please select a marital status',
          isRequired: true,
        ),
        // _buildSignatureCard(stepperState.signature ?? _signatureData),
        // _buildSignaturePadSelection(),
      ],
    );
  }

  Padding textLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 10, right: 3),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget _buildSignatureCard(Uint8List? signature) {
  //   return Center(
  //     child: Padding(
  //       padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
  //       child: Container(
  //         height: 150, // Reduced height
  //         width: MediaQuery.of(context).size.width * 0.8,
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(8.0), // Smaller radius
  //           border: Border.all(
  //               color: Colors.grey.shade300, width: 1), // Minimized border
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.grey.withOpacity(0.1),
  //               spreadRadius: 2, // Reduced spread
  //               blurRadius: 4, // Reduced blur
  //             ),
  //           ],
  //         ),
  //         child: signature != null
  //             ? Center(
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(8.0), // Smaller radius
  //                   child: Image.memory(
  //                     signature,
  //                     fit: BoxFit.cover,
  //                   ),
  //                 ),
  //               )
  //             : ClipRRect(
  //                 borderRadius: BorderRadius.circular(8.0), // Smaller radius
  //                 child: Image.asset(
  //                   'assets/signature.png',
  //                   height: 10.0,
  //                   width: MediaQuery.of(context).size.width * 0.1,
  //                   fit: BoxFit.contain,
  //                 ),
  //               ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildSignaturePadSelection() {
  //   return Padding(
  //     padding: const EdgeInsets.all(10),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         ElevatedButton(
  //           onPressed: () => _showSignaturePadDialog(context),
  //           style: ElevatedButton.styleFrom(
  //             foregroundColor: Colors.white,
  //             backgroundColor: Colors.black,
  //           ),
  //           child: const Text("      Sign     "),
  //         ),
  //         const SizedBox(width: 20),
  //         ElevatedButton(
  //           onPressed: () => _showImagePicker(context),
  //           style: ElevatedButton.styleFrom(
  //             foregroundColor: Colors.white,
  //             backgroundColor: Colors.black,
  //           ),
  //           child: const Text("Upload"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _showImagePicker(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (builder) {
  //       return Card(
  //         child: Container(
  //           width: MediaQuery.of(context).size.width,
  //           height: MediaQuery.of(context).size.height / 5.2,
  //           margin: const EdgeInsets.only(top: 8.0),
  //           padding: const EdgeInsets.all(12),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Expanded(
  //                 child: InkWell(
  //                   onTap: () async {
  //                     Navigator.pop(context);
  //                     await _pickImage(ImageSource.gallery);
  //                   },
  //                   child: const Column(
  //                     children: [
  //                       Icon(Icons.image, size: 60.0),
  //                       SizedBox(height: 12.0),
  //                       Text(
  //                         "Gallery",
  //                         textAlign: TextAlign.center,
  //                         style: TextStyle(fontSize: 16, color: Colors.black),
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               Expanded(
  //                 child: InkWell(
  //                   onTap: () async {
  //                     Navigator.pop(context);
  //                     await _pickImage(ImageSource.camera);
  //                   },
  //                   child: const Column(
  //                     children: [
  //                       Icon(Icons.camera_alt, size: 60.0),
  //                       SizedBox(height: 12.0),
  //                       Text(
  //                         "Camera",
  //                         textAlign: TextAlign.center,
  //                         style: TextStyle(fontSize: 16, color: Colors.black),
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _showSignaturePadDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         insetPadding: const EdgeInsets.symmetric(horizontal: 20),
  //         child: SingleChildScrollView(
  //           child: Container(
  //             padding: const EdgeInsets.all(16),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 const Text(
  //                   'Draw Signatures',
  //                   style: TextStyle(
  //                     fontSize: 20,
  //                     color: Colors.blue,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 20),
  //                 SignaturePad(
  //                   controller: _signatureController1,
  //                   label: "Signature 1",
  //                   onClear: () => _clearSignature(1),
  //                 ),
  //                 const SizedBox(height: 20),
  //                 SignaturePad(
  //                   controller: _signatureController2,
  //                   label: "Signature 2",
  //                   onClear: () => _clearSignature(2),
  //                 ),
  //                 const SizedBox(height: 20),
  //                 SignaturePad(
  //                   controller: _signatureController3,
  //                   label: "Signature 3",
  //                   onClear: () => _clearSignature(3),
  //                 ),
  //                 const SizedBox(height: 20),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   children: [
  //                     TextButton(
  //                       onPressed: () => Navigator.pop(context),
  //                       child: const Text('Cancel'),
  //                     ),
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         if (_areAllSignaturesCompleted()) {
  //                           _saveCombinedSignature();
  //                           Navigator.pop(context);
  //                         } else {
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                             const SnackBar(
  //                               content: Text('Please complete all signatures'),
  //                               backgroundColor: Colors.red,
  //                             ),
  //                           );
  //                         }
  //                       },
  //                       child: const Text('Save'),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // Future<void> _pickImage(ImageSource source) async {
  //   try {
  //     // Check permissions first
  //     bool hasPermission = await _checkPermission(source);
  //     if (!hasPermission) {
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

  //     if (image != null) {
  //       await _cropAndProcessImage(File(image.path));
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
  //       return; // User cancelled, no need to show error
  //     } else {
  //       errorMessage = 'Failed to pick image: ${e.toString()}';
  //     }

  //     _showErrorSnackBar(errorMessage);
  //   }
  // }

  // bool _areAllSignaturesCompleted() {
  //   return _signatureController1.isNotEmpty &&
  //       _signatureController2.isNotEmpty &&
  //       _signatureController3.isNotEmpty;
  // }

  // Future<void> _saveCombinedSignature() async {
  //   final combinedSignature = await _combineSignatures();
  //   if (combinedSignature != null) {
  //     setState(() {
  //       _signatureData = combinedSignature;
  //     });
  //     // Update the stepper provider with signature data
  //     ref.read(stepperProvider.notifier).updateSignature(combinedSignature);
  //   }
  // }

  // Future<void> _cropAndProcessImage(File imageFile) async {
  //   try {
  //     // Read the image file
  //     final bytes = await imageFile.readAsBytes();
  //     setState(() {
  //       _signatureData = bytes;
  //     });
  //     // Update the stepper provider with signature data
  //     ref.read(stepperProvider.notifier).updateSignature(bytes);
  //   } catch (e) {
  //     _showErrorSnackBar('Failed to process image: ${e.toString()}');
  //   }
  // }

  // void _showErrorSnackBar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: Colors.red,
  //       behavior: SnackBarBehavior.floating,
  //     ),
  //   );
  // }

  // Future<Uint8List?> _combineSignatures() async {
  //   // Get individual signature bytes
  //   final signature1 = await _signatureController1.toPngBytes();
  //   final signature2 = await _signatureController2.toPngBytes();
  //   final signature3 = await _signatureController3.toPngBytes();

  //   if (signature1 == null || signature2 == null || signature3 == null) {
  //     return null;
  //   }

  //   // Decode the individual images
  //   final ui.Image image1 = await decodeImageFromList(signature1);
  //   final ui.Image image2 = await decodeImageFromList(signature2);
  //   final ui.Image image3 = await decodeImageFromList(signature3);

  //   // Calculate the total width and height (maximum height of all signatures)
  //   final int totalWidth =
  //       image1.width + image2.width + image3.width + 20; // Add spacing
  //   final int maxHeight = [image1.height, image2.height, image3.height]
  //       .reduce((a, b) => a > b ? a : b);

  //   // Draw the images onto a single canvas
  //   final recorder = ui.PictureRecorder();
  //   final canvas = Canvas(recorder,
  //       Rect.fromLTWH(0, 0, totalWidth.toDouble(), maxHeight.toDouble()));

  //   double currentX = 0;

  //   // Draw signature 1
  //   canvas.drawImage(image1, Offset(currentX, 0), Paint());
  //   currentX += image1.width.toDouble() + 10; // Add spacing

  //   // Draw signature 2
  //   canvas.drawImage(image2, Offset(currentX, 0), Paint());
  //   currentX += image2.width.toDouble() + 10;

  //   // Draw signature 3
  //   canvas.drawImage(image3, Offset(currentX, 0), Paint());

  //   // End the recording
  //   final picture = recorder.endRecording();
  //   final combinedImage = await picture.toImage(totalWidth, maxHeight);

  //   // Convert the combined image to bytes
  //   final byteData =
  //       await combinedImage.toByteData(format: ui.ImageByteFormat.png);
  //   return byteData?.buffer.asUint8List();
  // }

  // void _clearSignature(int index) {
  //   setState(() {
  //     switch (index) {
  //       case 1:
  //         _signatureController1.clear();
  //         break;
  //       case 2:
  //         _signatureController2.clear();
  //         break;
  //       case 3:
  //         _signatureController3.clear();
  //         break;
  //     }
  //   });
  // }

  // Future<bool> _checkPermission(ImageSource source) async {
  //   if (source == ImageSource.camera) {
  //     final status = await Permission.camera.status;
  //     if (status.isDenied) {
  //       final result = await Permission.camera.request();
  //       return result.isGranted;
  //     }
  //     return status.isGranted;
  //   } else {
  //     final status = await Permission.photos.status;
  //     if (status.isDenied) {
  //       final result = await Permission.photos.request();
  //       return result.isGranted;
  //     }
  //     return status.isGranted;
  //   }
  // }
}
