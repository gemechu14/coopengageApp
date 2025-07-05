import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import '../../providers/registration_providers.dart';
import '../common/button_upload_take_photo.dart';
import '../common/image_preview.dart';
import '../common/branch_selector.dart';

class IdTypeStep extends ConsumerStatefulWidget {
  const IdTypeStep({Key? key}) : super(key: key);

  @override
  ConsumerState<IdTypeStep> createState() => _IdTypeStepState();
}

class _IdTypeStepState extends ConsumerState<IdTypeStep>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  String? _selectedBranch;
  String? _selectedDocumentType;
  
  // Image paths
  String _frontImagePath = '';
  String _backImagePath = '';
  
  // Image bytes for API
  Uint8List? _frontImageBytes;
  Uint8List? _backImageBytes;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final registrationData = ref.read(registrationDataProvider);
    _selectedBranch = registrationData.branch;
    _selectedDocumentType = registrationData.documentName;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    final validationErrors = ref.watch(formValidationProvider);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: graybackgroundColor,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Header
                _buildHeader(),
                
                const SizedBox(height: 24),
                
                // Branch Selection
                _buildBranchSelection(validationErrors),
                
                const SizedBox(height: 20),
                
                // Document Type
                _buildDocumentTypeSelection(validationErrors),
                
                const SizedBox(height: 20),
                
                // ID Card Photos
                _buildIdCardPhotos(),
                
                const SizedBox(height: 30),
                
                // Progress indicator
                _buildProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'ID Type & Documents',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          Text(
            'Please select your branch and upload your identification documents.',
            style: TextStyle(
              fontSize: 10,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchSelection(Map<String, String?> validationErrors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Branch *"),
        BranchSelector(
          initialValue: _selectedBranch,
          onChanged: (value) {
            setState(() {
              _selectedBranch = value;
            });
            ref.read(registrationDataProvider.notifier).updateIdTypeInfo(
              branch: value,
              documentName: _selectedDocumentType,
            );
            ref.read(formValidationProvider.notifier).clearError('branch');
          },
        ),
        if (validationErrors['branch'] != null)
          _buildErrorText(validationErrors['branch']!),
      ],
    );
  }

  Widget _buildDocumentTypeSelection(Map<String, String?> validationErrors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Document Type *"),
        ReusableDropdown(
          selectedValue: _selectedDocumentType,
          items: ListContants.documentName,
          hintText: 'Select Document Type',
          onChanged: (value) {
            setState(() {
              _selectedDocumentType = value;
            });
            ref.read(registrationDataProvider.notifier).updateIdTypeInfo(
              branch: _selectedBranch,
              documentName: value,
            );
            ref.read(formValidationProvider.notifier).clearError('documentType');
          },
          prefixIcon: Icons.document_scanner,
          errorMessage: validationErrors['documentType'] ?? '',
          isRequired: true,
        ),
        if (validationErrors['documentType'] != null)
          _buildErrorText(validationErrors['documentType']!),
      ],
    );
  }

  Widget _buildIdCardPhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Front Photo of ${_selectedDocumentType ?? 'ID'}"),
        _buildImageUploadSection(
          _frontImagePath,
          'front',
          'assets/id_front.png',
          onImageSelected: (path, bytes) {
            setState(() {
              _frontImagePath = path;
              _frontImageBytes = bytes;
            });
            _updateRegistrationData();
          },
        ),
        const SizedBox(height: 20),
        _buildLabel("Back Photo of ${_selectedDocumentType ?? 'ID'}"),
        _buildImageUploadSection(
          _backImagePath,
          'back',
          'assets/backpage.png',
          onImageSelected: (path, bytes) {
            setState(() {
              _backImagePath = path;
              _backImageBytes = bytes;
            });
            _updateRegistrationData();
          },
        ),
      ],
    );
  }

  Widget _buildImageUploadSection(
    String imagePath,
    String imageType,
    String placeholderAsset, {
    required Function(String path, Uint8List bytes) onImageSelected,
  }) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20.0),
          Container(
            height: 150.0,
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
            child: imagePath.isEmpty
                ? _buildPlaceholderImage(placeholderAsset)
                : _buildCapturedImage(imagePath),
          ),
          const SizedBox(height: 20.0),
          ButtonUploadTakePhoto(
            onUploadPressed: () => _pickImage(ImageSource.gallery, imageType, onImageSelected),
            onCapturePressed: () => _pickImage(ImageSource.camera, imageType, onImageSelected),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(String assetPath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Image.asset(
            assetPath,
            height: 150.0,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }

  Widget _buildCapturedImage(String imagePath) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context, imagePath),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Image.file(
          File(imagePath),
          height: 150.0,
          width: double.infinity,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
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
                '2 of 8',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.25,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 4),
          Text(
            '25% Complete',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildErrorText(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 12.0),
      child: Text(
        error,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }

  // Image handling methods
  Future<void> _pickImage(
    ImageSource source,
    String imageType,
    Function(String path, Uint8List bytes) onImageSelected,
  ) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        await _cropAndProcessImage(File(image.path), imageType, onImageSelected);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _cropAndProcessImage(
    File imageFile,
    String imageType,
    Function(String path, Uint8List bytes) onImageSelected,
  ) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Crop image
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "Crop ID Card",
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: "Crop ID Card"),
        ],
      );

      // Dismiss loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      if (croppedFile != null) {
        final file = File(croppedFile.path);
        final bytes = await file.readAsBytes();
        
        onImageSelected(croppedFile.path, bytes);
        _showSuccessSnackBar('Image captured successfully!');
      }
    } catch (e) {
      // Dismiss loading dialog if still showing
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      _showErrorSnackBar('Failed to process image: $e');
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

  void _updateRegistrationData() {
    ref.read(registrationDataProvider.notifier).updateIdTypeInfo(
      branch: _selectedBranch,
      documentName: _selectedDocumentType,
      residenceCard: _frontImageBytes,
      residenceCardBack: _backImageBytes,
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
