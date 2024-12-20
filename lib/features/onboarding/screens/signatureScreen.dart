// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:signature/signature.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'dart:ui' as ui;

// class SignatureScreen extends StatefulWidget {
//   @override
//   _SignatureScreenState createState() => _SignatureScreenState();
// }

// class _SignatureScreenState extends State<SignatureScreen> {
//   late SignatureController _signatureController1,
//       _signatureController2,
//       _signatureController3;
//   final ImagePicker _picker = ImagePicker();
//   List<XFile>? _signatureImages = [];
//   bool _isSigning = false; // To toggle between sign and upload

//   @override
//   void initState() {
//     super.initState();
//     // Initialize Signature controllers inside initState
//     _signatureController1 = SignatureController(
//       penColor: Colors.black,
//       penStrokeWidth: 5,
//       exportBackgroundColor: Colors.transparent,
//     );
//     _signatureController2 = SignatureController(
//       penColor: Colors.black,
//       penStrokeWidth: 5,
//       exportBackgroundColor: Colors.transparent,
//     );
//     _signatureController3 = SignatureController(
//       penColor: Colors.black,
//       penStrokeWidth: 1,
//       exportBackgroundColor: Colors.transparent,
//     );
//   }

//   @override
//   void dispose() {
//     _signatureController1.dispose();
//     _signatureController2.dispose();
//     _signatureController3.dispose();
//     super.dispose();
//   }

//   Future<void> _pickSignatureImage() async {
//     final XFile? pickedFile =
//         await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _signatureImages!.add(pickedFile);
//       });
//     }
//   }

//   void clearSignature(int index) {
//     setState(() {
//       switch (index) {
//         case 1:
//           _signatureController1.clear();
//           break;
//         case 2:
//           _signatureController2.clear();
//           break;
//         case 3:
//           _signatureController3.clear();
//           break;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Signature Screen"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(10),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Buttons to select between sign or upload
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _isSigning = true; // Show signature pads
//                       });
//                     },
//                     child: const Text("Sign"),
//                   ),
//                   const SizedBox(width: 20),
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _isSigning = false; // Show upload option
//                       });
//                     },
//                     child: const Text("Upload"),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               // If signing, show signature pads styled as lines
//               if (_isSigning)
//                 SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       Center(
//                         child: Column(
//                           children: [
//                             Container(
//                               width: MediaQuery.of(context).size.width * 0.65,
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               decoration: const BoxDecoration(
//                                 border: Border(
//                                     bottom: BorderSide(
//                                         width: 2,
//                                         color: Colors
//                                             .black)), // Line below the signature pad
//                               ),
//                               child: Signature(
//                                   controller: _signatureController1,
//                                   height: 150,
//                                   backgroundColor: Colors
//                                       .transparent), // Adjust height for smaller pad
//                             ),
//                             const SizedBox(height: 10),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Text("Signature 1",
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold)),
//                                 const SizedBox(
//                                   width: 10,
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () => clearSignature(1),
//                                   child: const Text("Clear"),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Center(
//                         child: Column(
//                           children: [
//                             // Signature Pad with center-aligned line
//                             Container(
//                               width: MediaQuery.of(context).size.width *
//                                   0.65, // Adjust the width as needed (80% of screen width)
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               decoration: const BoxDecoration(
//                                 border: Border(
//                                     bottom: BorderSide(
//                                         width: 2,
//                                         color: Colors
//                                             .black)), // Line below the signature pad
//                               ),
//                               child: Signature(
//                                   controller: _signatureController2,
//                                   height: 150,
//                                   backgroundColor: Colors
//                                       .transparent), // Adjust height for smaller pad
//                             ),
//                             const SizedBox(height: 10),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Text("Signature 2",
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold)),
//                                 const SizedBox(
//                                   width: 10,
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () => clearSignature(2),
//                                   child: const Text("Clear"),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Center(
//                         child: Column(
//                           children: [
//                             // Signature Pad with center-aligned line
//                             Container(
//                               width: MediaQuery.of(context).size.width * 0.65,
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               decoration: const BoxDecoration(
//                                 border: Border(
//                                     bottom: BorderSide(
//                                         width: 2, color: Colors.black)),
//                               ),
//                               child: Signature(
//                                   controller: _signatureController3,
//                                   height: 150,
//                                   backgroundColor: Colors.transparent),
//                             ),
//                             const SizedBox(height: 10),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Text("Signature 3",
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold)),
//                                 const SizedBox(
//                                   width: 10,
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () => clearSignature(3),
//                                   child: const Text("Clear"),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ElevatedButton(
//                 onPressed: _saveCombinedSignature,
//                 child: const Text("Save Combined Signature"),
//               ),
//               if (!_isSigning)
//                 Column(
//                   children: [
//                     ElevatedButton(
//                       onPressed: _pickSignatureImage,
//                       child: const Text("Upload Signature"),
//                     ),
//                     const SizedBox(height: 20),
//                     // Display uploaded images
//                     _signatureImages!.isEmpty
//                         ? const Text("No signatures uploaded yet.")
//                         : Column(
//                             children: _signatureImages!
//                                 .map((file) => Image.file(File(file.path),
//                                     width: 150, height: 100))
//                                 .toList(),
//                           ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<Uint8List?> _combineSignatures() async {
//     // Get individual signature bytes
//     final signature1 = await _signatureController1.toPngBytes();
//     final signature2 = await _signatureController2.toPngBytes();
//     final signature3 = await _signatureController3.toPngBytes();

//     if (signature1 == null || signature2 == null || signature3 == null) {
//       print("One or more signatures are empty!");
//       return null;
//     }

//     // Decode the individual images
//     final ui.Image image1 = await decodeImageFromList(signature1);
//     final ui.Image image2 = await decodeImageFromList(signature2);
//     final ui.Image image3 = await decodeImageFromList(signature3);

//     // Calculate the total height and width (maximum width of all signatures)
//     final int totalHeight =
//         image1.height + image2.height + image3.height + 20; // Add spacing
//     final int maxWidth = [image1.width, image2.width, image3.width]
//         .reduce((a, b) => a > b ? a : b);

//     // Draw the images onto a single canvas
//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder,
//         Rect.fromLTWH(0, 0, maxWidth.toDouble(), totalHeight.toDouble()));

//     double currentY = 0;

//     // Draw signature 1
//     canvas.drawImage(image1, Offset(0, currentY), Paint());
//     currentY += image1.height.toDouble() + 10; // Add spacing

//     // Draw signature 2
//     canvas.drawImage(image2, Offset(0, currentY), Paint());
//     currentY += image2.height.toDouble() + 10;

//     // Draw signature 3
//     canvas.drawImage(image3, Offset(0, currentY), Paint());

//     // End the recording
//     final picture = recorder.endRecording();
//     final combinedImage = await picture.toImage(maxWidth, totalHeight);

//     // Convert the combined image to bytes
//     final byteData =
//         await combinedImage.toByteData(format: ui.ImageByteFormat.png);
//     return byteData?.buffer.asUint8List();
//   }

//   void _saveCombinedSignature() async {
//     final Uint8List? combinedImage = await _combineSignatures();
//     if (combinedImage != null) {
//       // Save the combined image or do further processing
//       print("Combined signature image generated successfully.");

//       // Example: Save to a file
//       final file = File('${Directory.systemTemp.path}/combined_signature.png');
//       await file.writeAsBytes(combinedImage);
//       print("Saved combined image at: ${file.path}");
//     } else {
//       print("Failed to generate combined signature image.");
//     }
//   }
// }

// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:signature/signature.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'dart:ui' as ui;

// class SignatureScreen extends StatefulWidget {
//   @override
//   _SignatureScreenState createState() => _SignatureScreenState();
// }

// class _SignatureScreenState extends State<SignatureScreen> {
//   late SignatureController _signatureController1,
//       _signatureController2,
//       _signatureController3;
//   final ImagePicker _picker = ImagePicker();
//   List<XFile>? _signatureImages = [];
//   bool _isSigning = false; // To toggle between sign and upload
//   Uint8List? _combinedSignature;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize Signature controllers inside initState
//     _signatureController1 = SignatureController(
//       penColor: Colors.black,
//       penStrokeWidth: 5,
//       exportBackgroundColor: Colors.transparent,
//     );
//     _signatureController2 = SignatureController(
//       penColor: Colors.black,
//       penStrokeWidth: 5,
//       exportBackgroundColor: Colors.transparent,
//     );
//     _signatureController3 = SignatureController(
//       penColor: Colors.black,
//       penStrokeWidth: 1,
//       exportBackgroundColor: Colors.transparent,
//     );
//   }

//   @override
//   void dispose() {
//     _signatureController1.dispose();
//     _signatureController2.dispose();
//     _signatureController3.dispose();
//     super.dispose();
//   }

//   Future<void> _pickSignatureImage() async {
//     final XFile? pickedFile =
//         await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _signatureImages!.add(pickedFile);
//       });
//     }
//   }

//   void clearSignature(int index) {
//     setState(() {
//       switch (index) {
//         case 1:
//           _signatureController1.clear();
//           break;
//         case 2:
//           _signatureController2.clear();
//           break;
//         case 3:
//           _signatureController3.clear();
//           break;
//       }
//     });
//   }

//   Future<Uint8List?> _combineSignatures() async {
//     // Get individual signature bytes
//     final signature1 = await _signatureController1.toPngBytes();
//     final signature2 = await _signatureController2.toPngBytes();
//     final signature3 = await _signatureController3.toPngBytes();

//     if (signature1 == null || signature2 == null || signature3 == null) {
//       print("One or more signatures are empty!");
//       return null;
//     }

//     // Decode the individual images
//     final ui.Image image1 = await decodeImageFromList(signature1);
//     final ui.Image image2 = await decodeImageFromList(signature2);
//     final ui.Image image3 = await decodeImageFromList(signature3);

//     // Calculate the total height and width (maximum width of all signatures)
//     final int totalHeight =
//         image1.height + image2.height + image3.height + 20; // Add spacing
//     final int maxWidth = [image1.width, image2.width, image3.width]
//         .reduce((a, b) => a > b ? a : b);

//     // Draw the images onto a single canvas
//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder,
//         Rect.fromLTWH(0, 0, maxWidth.toDouble(), totalHeight.toDouble()));

//     double currentY = 0;

//     // Draw signature 1
//     canvas.drawImage(image1, Offset(0, currentY), Paint());
//     currentY += image1.height.toDouble() + 10; // Add spacing

//     // Draw signature 2
//     canvas.drawImage(image2, Offset(0, currentY), Paint());
//     currentY += image2.height.toDouble() + 10;

//     // Draw signature 3
//     canvas.drawImage(image3, Offset(0, currentY), Paint());

//     // End the recording
//     final picture = recorder.endRecording();
//     final combinedImage = await picture.toImage(maxWidth, totalHeight);

//     // Convert the combined image to bytes
//     final byteData =
//         await combinedImage.toByteData(format: ui.ImageByteFormat.png);
//     return byteData?.buffer.asUint8List();
//   }

//   void _saveCombinedSignature() async {
//     final Uint8List? combinedImage = await _combineSignatures();
//     if (combinedImage != null) {
//       setState(() {
//         _combinedSignature = combinedImage; // Store the combined signature
//       });
//       // Example: Save to a file
//       final file = File('${Directory.systemTemp.path}/combined_signature.png');
//       await file.writeAsBytes(combinedImage);
//       print("Saved combined image at: ${file.path}");
//     } else {
//       print("Failed to generate combined signature image.");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Signature Screen"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(10),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Buttons to select between sign or upload
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _isSigning = true; // Show signature pads
//                       });
//                     },
//                     child: const Text("Sign"),
//                   ),
//                   const SizedBox(width: 20),
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _isSigning = false; // Show upload option
//                       });
//                     },
//                     child: const Text("Upload"),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               // If signing, show signature pads styled as lines
//               if (_isSigning)
//                 SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       Center(
//                         child: Column(
//                           children: [
//                             Container(
//                               width: MediaQuery.of(context).size.width * 0.65,
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               decoration: const BoxDecoration(
//                                 border: Border(
//                                     bottom: BorderSide(
//                                         width: 2,
//                                         color: Colors
//                                             .black)), // Line below the signature pad
//                               ),
//                               child: Signature(
//                                   controller: _signatureController1,
//                                   height: 150,
//                                   backgroundColor: Colors
//                                       .transparent), // Adjust height for smaller pad
//                             ),
//                             const SizedBox(height: 10),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Text("Signature 1",
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold)),
//                                 const SizedBox(
//                                   width: 10,
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () => clearSignature(1),
//                                   child: const Text("Clear"),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Center(
//                         child: Column(
//                           children: [
//                             // Signature Pad with center-aligned line
//                             Container(
//                               width: MediaQuery.of(context).size.width *
//                                   0.65, // Adjust the width as needed (80% of screen width)
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               decoration: const BoxDecoration(
//                                 border: Border(
//                                     bottom: BorderSide(
//                                         width: 2,
//                                         color: Colors
//                                             .black)), // Line below the signature pad
//                               ),
//                               child: Signature(
//                                   controller: _signatureController2,
//                                   height: 150,
//                                   backgroundColor: Colors
//                                       .transparent), // Adjust height for smaller pad
//                             ),
//                             const SizedBox(height: 10),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Text("Signature 2",
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold)),
//                                 const SizedBox(
//                                   width: 10,
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () => clearSignature(2),
//                                   child: const Text("Clear"),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Center(
//                         child: Column(
//                           children: [
//                             // Signature Pad with center-aligned line
//                             Container(
//                               width: MediaQuery.of(context).size.width * 0.65,
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               decoration: const BoxDecoration(
//                                 border: Border(
//                                     bottom: BorderSide(
//                                         width: 2, color: Colors.black)),
//                               ),
//                               child: Signature(
//                                   controller: _signatureController3,
//                                   height: 150,
//                                   backgroundColor: Colors.transparent),
//                             ),
//                             const SizedBox(height: 10),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Text("Signature 3",
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold)),
//                                 const SizedBox(
//                                   width: 10,
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () => clearSignature(3),
//                                   child: const Text("Clear"),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ElevatedButton(
//                 onPressed: _saveCombinedSignature,
//                 child: const Text("Save Combined Signature"),
//               ),
//               if (_combinedSignature != null) ...[
//                 const SizedBox(height: 20),
//                 Image.memory(
//                   _combinedSignature!,
//                   width: 300,
//                   height: 200,
//                 ),
//               ],
//               if (!_isSigning)
//                 Column(
//                   children: [
//                     ElevatedButton(
//                       onPressed: _pickSignatureImage,
//                       child: const Text("Upload Signature"),
//                     ),
//                     const SizedBox(height: 20),
//                     // Display uploaded images
//                     _signatureImages!.isEmpty
//                         ? const Text("No signatures uploaded yet.")
//                         : Column(
//                             children: _signatureImages!
//                                 .map((file) => Image.file(File(file.path),
//                                     width: 150, height: 100))
//                                 .toList(),
//                           ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;

class SignatureScreen extends StatefulWidget {
  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  late SignatureController _signatureController1,
      _signatureController2,
      _signatureController3;
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _signatureImages = [];
  bool _isSigning = false; // To toggle between sign and upload
  Uint8List? _combinedSignature;

  @override
  void initState() {
    super.initState();
    // Initialize Signature controllers inside initState
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
      penStrokeWidth: 1,
      exportBackgroundColor: Colors.transparent,
    );
  }

  @override
  void dispose() {
    _signatureController1.dispose();
    _signatureController2.dispose();
    _signatureController3.dispose();
    super.dispose();
  }

  Future<void> _pickSignatureImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _signatureImages!.add(pickedFile);
      });
    }
  }

  void clearSignature(int index) {
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
        .reduce((a, b) => a > b ? a : b);

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

  void _saveCombinedSignature() async {
    final Uint8List? combinedImage = await _combineSignatures();
    if (combinedImage != null) {
      setState(() {
        _combinedSignature = combinedImage; // Store the combined signature
      });
      // Example: Save to a file
      final file = File('${Directory.systemTemp.path}/combined_signature.png');
      await file.writeAsBytes(combinedImage);
      print("Saved combined image at: ${file.path}");
    } else {
      print("Failed to generate combined signature image.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Signature Screen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Buttons to select between sign or upload
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isSigning = true; // Show signature pads
                      });
                    },
                    child: const Text("Sign"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isSigning = false; // Show upload option
                      });
                    },
                    child: const Text("Upload"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // If signing, show signature pads styled as lines
              if (_isSigning)
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 2,
                                        color: Colors
                                            .black)), // Line below the signature pad
                              ),
                              child: Signature(
                                  controller: _signatureController1,
                                  height: 150,
                                  backgroundColor: Colors
                                      .transparent), // Adjust height for smaller pad
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Signature 1",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () => clearSignature(1),
                                  child: const Text("Clear"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            // Signature Pad with center-aligned line
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  0.65, // Adjust the width as needed (80% of screen width)
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 2,
                                        color: Colors
                                            .black)), // Line below the signature pad
                              ),
                              child: Signature(
                                  controller: _signatureController2,
                                  height: 150,
                                  backgroundColor: Colors
                                      .transparent), // Adjust height for smaller pad
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Signature 2",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () => clearSignature(2),
                                  child: const Text("Clear"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            // Signature Pad with center-aligned line
                            Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 2, color: Colors.black)),
                              ),
                              child: Signature(
                                  controller: _signatureController3,
                                  height: 150,
                                  backgroundColor: Colors.transparent),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Signature 3",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () => clearSignature(3),
                                  child: const Text("Clear"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ElevatedButton(
                onPressed: _saveCombinedSignature,
                child: const Text("Save Combined Signature"),
              ),
              if (_combinedSignature != null) ...[
                const SizedBox(height: 20),
                Image.memory(
                  _combinedSignature!,
                  width: 300,
                  height: 150,
                ),
              ],
              if (!_isSigning)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _pickSignatureImage,
                      child: const Text("Upload Signature"),
                    ),
                    const SizedBox(height: 20),
                    // Display uploaded images
                    _signatureImages!.isEmpty
                        ? const Text("No signatures uploaded yet.")
                        : Column(
                            children: _signatureImages!
                                .map((file) => Image.file(File(file.path),
                                    width: 150, height: 100))
                                .toList(),
                          ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
