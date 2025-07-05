import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';
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
                          '3 of 8',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.375,
                      backgroundColor: Colors.grey.shade300,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '37.5% Complete',
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

  Widget _buildSignatureCard(Uint8List? signature) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
        child: Container(
          height: 200,
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
              ),
            ],
          ),
          child: signature != null
              ? Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.memory(
                      signature,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
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
                    onTap: () {
                      // Handle gallery selection
                      Navigator.pop(context);
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
                    onTap: () {
                      // Handle camera selection
                      Navigator.pop(context);
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
    final signature1 = await _signatureController1.toPngBytes();
    final signature2 = await _signatureController2.toPngBytes();
    final signature3 = await _signatureController3.toPngBytes();

    if (signature1 == null || signature2 == null || signature3 == null) {
      return null;
    }

    // TODO: Implement signature combination logic
    // This is a placeholder that returns the first signature
    return signature1;
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
