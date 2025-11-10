// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:coopengageplus/core/constants/listConstants.dart';
// import 'package:coopengageplus/shared/widgets/dropDown/ReusableDropdown.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:coopengageplus/features/onboarding/_IndividualAccount/widgets/common/signature_pad.dart';
// import 'package:signature/signature.dart';

// class MaritalStatusStep extends ConsumerStatefulWidget {
//   const MaritalStatusStep({Key? key}) : super(key: key);

//   @override
//   ConsumerState<MaritalStatusStep> createState() => _MaritalStatusStepState();
// }

// class _MaritalStatusStepState extends ConsumerState<MaritalStatusStep> {
//   Uint8List? _signatureData;

//   Future<void> _handleSign() async {
//     final controller = SignatureController(penStrokeWidth: 2, penColor: Colors.black);
//     Uint8List? signatureBytes;
//     final result = await showDialog<Uint8List>(
//       context: context,
//       builder: (context) => Dialog(
//         child: StatefulBuilder(
//           builder: (context, setState) => SizedBox(
//             width: MediaQuery.of(context).size.width * 0.9,
//             height: 350,
//             child: Column(
//               children: [
//                 SignaturePad(
//                   controller: controller,
//                   label: 'Draw your signature',
//                   onClear: () {
//                     controller.clear();
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: () async {
//                         if (controller.isNotEmpty) {
//                           final export = await controller.toPngBytes();
//                           Navigator.of(context).pop(export);
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
//       ),
//     );
//     controller.dispose();
//     if (result != null) {
//       setState(() {
//         _signatureData = result;
//       });
//     }
//   }

//   Future<void> _handleUpload() async {
//     final status = await Permission.photos.request();
//     if (!status.isGranted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Permission denied to access photos.')),
//       );
//       return;
//     }
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       final bytes = await pickedFile.readAsBytes();
//       setState(() {
//         _signatureData = bytes;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Signature',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           _signatureData != null
//               ? Center(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8.0),
//                     child: Image.memory(
//                       _signatureData!,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 )
//               : ClipRRect(
//                   borderRadius: BorderRadius.circular(8.0),
//                   child: Image.asset(
//                     'assets/signature.png',
//                     height: 100.0,
//                     width: MediaQuery.of(context).size.width * 0.5,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: _handleSign,
//                 style: ElevatedButton.styleFrom(
//                   foregroundColor: Colors.white,
//                   backgroundColor: Colors.black,
//                 ),
//                 child: const Text("      Sign     "),
//               ),
//               const SizedBox(width: 20),
//               ElevatedButton(
//                 onPressed: _handleUpload,
//                 style: ElevatedButton.styleFrom(
//                   foregroundColor: Colors.white,
//                   backgroundColor: Colors.black,
//                 ),
//                 child: const Text("Upload"),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
