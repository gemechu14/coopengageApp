import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import '../../providers/registration_providers.dart';
import '../common/branch_selector.dart';
import '../common/image_selection_dialog.dart';

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

    // Initialize image bytes or url from provider if available
    if (registrationData.residenceCard != null) {
      if (registrationData.residenceCard is Uint8List) {
        _frontImageBytes = registrationData.residenceCard;
      } else if (registrationData.residenceCard is String) {
        _frontImageBytes = null;
        _frontImagePath = registrationData.residenceCard;
      }
    }
    if (registrationData.residenceCardBack != null) {
      if (registrationData.residenceCardBack is Uint8List) {
        _backImageBytes = registrationData.residenceCardBack;
      } else if (registrationData.residenceCardBack is String) {
        _backImageBytes = null;
        _backImagePath = registrationData.residenceCardBack;
      }
    }
  }

  void _syncWithProviderData() {
    final registrationData = ref.read(registrationDataProvider);

    // Sync branch and document type
    if (_selectedBranch != registrationData.branch) {
      _selectedBranch = registrationData.branch;
    }
    if (_selectedDocumentType != registrationData.documentName) {
      _selectedDocumentType = registrationData.documentName;
    }

    // Sync image bytes or url
    if (registrationData.residenceCard != null) {
      if (registrationData.residenceCard is Uint8List) {
        _frontImageBytes = registrationData.residenceCard;
        _frontImagePath = '';
      } else if (registrationData.residenceCard is String) {
        _frontImageBytes = null;
        _frontImagePath = registrationData.residenceCard;
      }
    }
    if (registrationData.residenceCardBack != null) {
      if (registrationData.residenceCardBack is Uint8List) {
        _backImageBytes = registrationData.residenceCardBack;
        _backImagePath = '';
      } else if (registrationData.residenceCardBack is String) {
        _backImageBytes = null;
        _backImagePath = registrationData.residenceCardBack;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    final validationErrors = ref.watch(formValidationProvider);

    // Sync with provider data
    _syncWithProviderData();

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
              const SizedBox(width: 2),
              Icon(Icons.card_giftcard, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ID Type & Documents',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
            ref
                .read(formValidationProvider.notifier)
                .clearError('documentType');
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
          onImageSelected: (path, bytes) {
            setState(() {
              _frontImagePath = path;
              _frontImageBytes = bytes;
            });
            _updateRegistrationData();
          },
        ),
        // const SizedBox(height: 20),
        _buildLabel("Back Photo of ${_selectedDocumentType ?? 'ID'}"),
        _buildImageUploadSection(
          _backImagePath,
          'back',
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
    String imageType, {
    required Function(String path, Uint8List bytes) onImageSelected,
  }) {
    // Check if we have image bytes for this type
    bool hasImageBytes = false;
    if (imageType == 'front') {
      hasImageBytes = _frontImageBytes != null;
    } else {
      hasImageBytes = _backImageBytes != null;
    }

    // Show image if we have either a path or bytes
    bool hasImage = imagePath.isNotEmpty || hasImageBytes;

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20.0),
          GestureDetector(
            onTap: () => _showImageSelectionDialog(imageType, onImageSelected),
            child: Container(
              height: 150.0,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: !hasImage ? Colors.grey.shade300 : Colors.transparent,
                  width: !hasImage ? 2 : 0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: !hasImage
                  ? _buildPlaceholderIcon(imageType)
                  : _buildCapturedImage(
                      imagePath,
                      imageType,
                      imageType == 'front'
                          ? _frontImageBytes
                          : _backImageBytes),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon(String imageType) {
    final documentType = _selectedDocumentType ?? 'ID';
    final title = imageType == 'front'
        ? 'Front Photo of $documentType'
        : 'Back Photo of $documentType';

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

  Widget _buildCapturedImage(
      String imagePath, String imageType, dynamic imageBytes) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _showFullScreenImage(context, imagePath, imageBytes),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: (() {
              if (imageBytes != null) {
                if (imageBytes is Uint8List) {
                  return Image.memory(
                    imageBytes,
                    height: 150.0,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                } else if (imageBytes is String) {
                  return Image.network(
                    imageBytes,
                    height: 150.0,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                }
              }
              if (imagePath.isNotEmpty) {
                if (imagePath.startsWith('http')) {
                  return Image.network(
                    imagePath,
                    height: 150.0,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                } else {
                  return Image.file(
                    File(imagePath),
                    height: 150.0,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                }
              }
              return Container(
                height: 150.0,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: const Icon(Icons.error, color: Colors.red),
              );
            })(),
          ),
        ),
        // Change image button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _showImageSelectionDialog(
              imageType,
              (path, bytes) {
                setState(() {
                  if (imageType == 'front') {
                    _frontImagePath = path;
                    _frontImageBytes = bytes;
                  } else {
                    _backImagePath = path;
                    _backImageBytes = bytes;
                  }
                });
                _updateRegistrationData();
              },
            ),
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
        // View full screen button
        Positioned(
          top: 8,
          left: 8,
          child: GestureDetector(
            onTap: () => _showFullScreenImage(context, imagePath, imageBytes),
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
      ],
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

  // Show image selection dialog
  void _showImageSelectionDialog(
    String imageType,
    Function(String path, Uint8List bytes) onImageSelected,
  ) {
    final title = imageType == 'front'
        ? 'Front Photo of ${_selectedDocumentType ?? 'ID'}'
        : 'Back Photo of ${_selectedDocumentType ?? 'ID'}';
    final subtitle = 'Choose how you want to add your photo';

    showDialog(
      context: context,
      builder: (context) => ImageSelectionDialog(
        title: title,
        subtitle: subtitle,
        onOptionSelected: (source) async {
          try {
            await _pickImage(source, imageType, onImageSelected);
          } catch (e) {
            // If camera fails, show option to use gallery instead
            if (source == ImageSource.camera) {
              _showCameraFallbackDialog(imageType, onImageSelected);
            }
          }
        },
      ),
    );
  }

  void _showCameraFallbackDialog(
    String imageType,
    Function(String path, Uint8List bytes) onImageSelected,
  ) {
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
              _pickImage(ImageSource.gallery, imageType, onImageSelected);
            },
            child: const Text('Use Gallery'),
          ),
        ],
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


  // Convert image to bytes - same as your previous implementation
  Future<Uint8List?> _getImageBytes(String path, String tempFileName) async {
    final imageFile = File(path);

    if (await imageFile.exists()) {
      Uint8List bytes = await imageFile.readAsBytes();

      // Save the bytes as a temporary file
      final tempFile = File('${Directory.systemTemp.path}/$tempFileName');
      await tempFile.writeAsBytes(bytes);

      print("✅ Saved temporary image at: ${tempFile.path}");
      print("📤 Image Bytes Length: ${bytes.length}");
      return bytes; // Return the image bytes
    } else {
      print("❌ File does not exist at: $path");
      return null;
    }
  }

  void _showFullScreenImage(
      BuildContext context, String imagePath, dynamic imageBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: (() {
                if (imageBytes != null) {
                  if (imageBytes is Uint8List) {
                    return Image.memory(
                      imageBytes,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    );
                  } else if (imageBytes is String) {
                    return Image.network(
                      imageBytes,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    );
                  }
                }
                if (imagePath.isNotEmpty) {
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
                return Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.error, color: Colors.red, size: 50),
                );
              })(),
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

  // Handle registration step completion - similar to your previous implementation
  Future<void> handleIdTypeStep() async {
    // Get connectivity status
    final isOnline = ref.read(connectivityProvider);

    // Get image bytes
    Uint8List? frontImageBytes;
    Uint8List? backImageBytes;

    if (_frontImagePath.isNotEmpty) {
      frontImageBytes = await _getImageBytes(
          _frontImagePath, "front_${_selectedDocumentType ?? 'id'}.png");
    }

    if (_backImagePath.isNotEmpty) {
      backImageBytes = await _getImageBytes(
          _backImagePath, "back_${_selectedDocumentType ?? 'id'}.png");
    }

    print("📤 Front Image Bytes: $frontImageBytes");
    print("📤 Back Image Bytes: $backImageBytes");

    // Update the registration data provider
    ref.read(registrationDataProvider.notifier).updateIdTypeInfo(
          branch: _selectedBranch,
          documentName: _selectedDocumentType,
          residenceCard: frontImageBytes,
          residenceCardBack: backImageBytes,
        );

    // Update progress
    ref.read(registrationDataProvider.notifier).updateProgress(25.0);

    // Update status and form completion
    final currentData = ref.read(registrationDataProvider);
    ref.read(registrationDataProvider.notifier).state = currentData.copyWith(
      status: "INITIAL",
      formCompleted: false, // Always false for this step
    );

    print("✅ ID Type Step Data Updated:");
    print("Branch: $_selectedBranch");
    print("Document Type: $_selectedDocumentType");
    print(
        "Front Image: ${frontImageBytes != null ? 'Uploaded' : 'Not uploaded'}");
    print(
        "Back Image: ${backImageBytes != null ? 'Uploaded' : 'Not uploaded'}");
    print("Is Online: $isOnline");
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: cyanblueColor,
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
