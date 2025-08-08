import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/customerOnboarding/JointNationalIdentification/providers/stepper_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:coopengageplus/constants/listConstants.dart';
// import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:coopengageplus/customerOnboarding/_IndividualAccount/widgets/common/signature_pad.dart';
import 'package:signature/signature.dart';

class SignatureStep extends ConsumerStatefulWidget {
  const SignatureStep({Key? key}) : super(key: key);

  @override
  ConsumerState<SignatureStep> createState() => _SignatureStepStepState();
}

class _SignatureStepStepState extends ConsumerState<SignatureStep> {
  List<List<SignatureController>> _memberSignatureControllers = [];
  List<Uint8List?> _signatureData = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Controllers will be initialized in build based on member count
  }

  @override
  Widget build(BuildContext context) {
    final stepperState = ref.watch(stepperProvider);
    final memberCount = stepperState.members.length;

    // Ensure controllers and data lists are up to date
    while (_memberSignatureControllers.length < memberCount) {
      _memberSignatureControllers.add([
        SignatureController(
            penStrokeWidth: 5, exportBackgroundColor: Colors.white),
        SignatureController(
            penStrokeWidth: 5, exportBackgroundColor: Colors.white),
        SignatureController(
            penStrokeWidth: 5, exportBackgroundColor: Colors.white),
      ]);
      _signatureData.add(null);
    }
    while (_memberSignatureControllers.length > memberCount) {
      _memberSignatureControllers.removeLast();
      _signatureData.removeLast();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Signatures',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ...List.generate(memberCount, (memberIndex) {
            final member = stepperState.members[memberIndex];
            final signature =
                member.signature as Uint8List? ?? _signatureData[memberIndex];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Member ${memberIndex + 1}: ${member.fullName ?? ''}'),
                _buildSignatureCard(signature),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _showSignaturePadDialog(context, memberIndex),
                      child: const Text(
                        '   Sign   ',
                        style: TextStyle(
                          color: cyanblueColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _showImagePicker(context, memberIndex),
                      child: const Text('  Upload  ',
                          style: TextStyle(color: cyanblueColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showSignaturePadDialog(BuildContext context, int memberIndex) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero, // ✅ Remove default padding
          backgroundColor: Colors.white, // ✅ Ensure background fills
          child: SizedBox.expand(
            // ✅ Expand to fill the screen
            child: Scaffold(
              appBar: AppBar(
                title: Text('Draw Signatures for Member ${memberIndex + 1}'),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                automaticallyImplyLeading: false,
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ...List.generate(
                      3,
                      (padIndex) => Column(
                        children: [
                          SignaturePad(
                            controller: _memberSignatureControllers[memberIndex]
                                [padIndex],
                            label: 'Signature ${padIndex + 1}',
                            onClear: () =>
                                _memberSignatureControllers[memberIndex]
                                        [padIndex]
                                    .clear(),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final combinedSignature = await _combineSignatures(
                            _memberSignatureControllers[memberIndex]);
                        if (combinedSignature != null) {
                          setState(() {
                            _signatureData[memberIndex] = combinedSignature;
                          });
                          ref
                              .read(stepperProvider.notifier)
                              .updateMemberSignature(
                                  memberIndex, combinedSignature);
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cyanblueColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: whiteColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // void _showSignaturePadDialog(BuildContext context, int memberIndex) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         child: SingleChildScrollView(
  //           child: Container(
  //             padding: const EdgeInsets.all(1),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 const SizedBox(height: 10),
  //                 Text('Draw Signatures for Member ${memberIndex + 1}',
  //                     style: const TextStyle(
  //                         fontSize: 17,
  //                         color: Colors.blue,
  //                         fontWeight: FontWeight.bold)),
  //                 const SizedBox(height: 20),
  //                 ...List.generate(
  //                     3,
  //                     (padIndex) => Column(
  //                           children: [
  //                             SignaturePad(
  //                               controller:
  //                                   _memberSignatureControllers[memberIndex]
  //                                       [padIndex],
  //                               label: 'Signature ${padIndex + 1}',
  //                               onClear: () =>
  //                                   _memberSignatureControllers[memberIndex]
  //                                           [padIndex]
  //                                       .clear(),
  //                             ),
  //                             const SizedBox(height: 20),
  //                           ],
  //                         )),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   children: [
  //                     TextButton(
  //                       onPressed: () => Navigator.pop(context),
  //                       child: const Text('Cancel'),
  //                     ),
  //                     ElevatedButton(
  //                       onPressed: () async {
  //                         final combinedSignature = await _combineSignatures(
  //                             _memberSignatureControllers[memberIndex]);
  //                         if (combinedSignature != null) {
  //                           setState(() {
  //                             _signatureData[memberIndex] = combinedSignature;
  //                           });
  //                           ref
  //                               .read(stepperProvider.notifier)
  //                               .updateMemberSignature(
  //                                   memberIndex, combinedSignature);
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

  void _showImagePicker(BuildContext context, int memberIndex) {
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
                      await _pickImage(ImageSource.gallery, memberIndex);
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
                      await _pickImage(ImageSource.camera, memberIndex);
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

  Future<void> _pickImage(ImageSource source, int memberIndex) async {
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
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (image != null) {
        final bytes = await File(image.path).readAsBytes();
        setState(() {
          _signatureData[memberIndex] = bytes;
        });
        ref
            .read(stepperProvider.notifier)
            .updateMemberSignature(memberIndex, bytes);
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showErrorSnackBar('Failed to pick image: ${e.toString()}');
    }
  }

  Future<Uint8List?> _combineSignatures(
      List<SignatureController> controllers) async {
    final signature1 = await controllers[0].toPngBytes();
    final signature2 = await controllers[1].toPngBytes();
    final signature3 = await controllers[2].toPngBytes();
    if (signature1 == null || signature2 == null || signature3 == null) {
      return null;
    }
    final ui.Image image1 = await decodeImageFromList(signature1);
    final ui.Image image2 = await decodeImageFromList(signature2);
    final ui.Image image3 = await decodeImageFromList(signature3);
    final int totalWidth = image1.width + image2.width + image3.width + 20;
    final int maxHeight = [image1.height, image2.height, image3.height]
        .reduce((a, b) => a > b ? a : b);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromLTWH(0, 0, totalWidth.toDouble(), maxHeight.toDouble()));
    double currentX = 0;
    canvas.drawImage(image1, Offset(currentX, 0), Paint());
    currentX += image1.width.toDouble() + 10;
    canvas.drawImage(image2, Offset(currentX, 0), Paint());
    currentX += image2.width.toDouble() + 10;
    canvas.drawImage(image3, Offset(currentX, 0), Paint());
    final picture = recorder.endRecording();
    final combinedImage = await picture.toImage(totalWidth, maxHeight);
    final byteData =
        await combinedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Widget _buildSignatureCard(Uint8List? signature) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
        child: Container(
          height: 150,
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 4,
              ),
            ],
          ),
          child: signature != null
              ? Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.memory(
                      signature,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
}
