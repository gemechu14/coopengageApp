import 'dart:typed_data';
import 'dart:convert';

import 'package:coopengageplus/features/onboarding/customer/CorporateAccountOpening/model/account_type.dart';
import 'package:flutter/material.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import '../model/registration_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/account_type_provider.dart';
// import 'package:coopengageplus/features/onboarding/IndividualNationalIdentification/model/account_type.dart';
import 'dart:io';

class RegistrationSummaryScreen extends ConsumerWidget {
  final RegistrationData registrationData;
  final VoidCallback onConfirm;

  const RegistrationSummaryScreen({
    super.key,
    required this.registrationData,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print(registrationData.toMap());
    // Get the list of account types from the provider
    final accountTypes =
        ref.watch(accountTypeStepProvider).availableAccountTypes;
    String? getAccountTypeNameById(String? id) {
      if (id == null) return null;
      final found = accountTypes.firstWhere(
        (type) => type.id.toString() == id,
        orElse: () => AccountType(
            id: 0,
            name: '',
            minAge: 0,
            maxAge: 0,
            minAmount: 0,
            sex: '',
            bankingType: '',
            type: '',
            category: ''),
      );
      return found.name.isNotEmpty ? found.name : null;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cyanblueColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(1),
                  topRight: Radius.circular(1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.summarize, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Registration Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Joint Account Info Section (once, at the end)
                    _buildSection(
                      'Company  Information',
                      Icons.account_balance,
                      [
                        _buildSummaryItem('Branch',
                            registrationData.branch ?? 'Not provided'),
                        _buildSummaryItem(
                            'Account Type',
                            getAccountTypeNameById(
                                    registrationData.accountType) ??
                                'Not selected'),
                        _buildSummaryItem('Initial Deposit',
                            registrationData.initialDeposit ?? 'Not provided'),
                        _buildSummaryItem('Product Type',
                            registrationData.productType ?? 'Not provided'),
                        _buildSummaryItem('Company Name',
                            registrationData.companyName ?? 'Not provided'),
                        _buildSummaryItem(
                            'Company Phone Number',
                            registrationData.companyPhoneNumber ??
                                'Not provided'),
                        _buildSummaryItem('Company Email',
                            registrationData.companyEmail ?? 'Not provided'),
                        _buildSummaryItem(
                            'Company TIN',
                            registrationData.companyTinNumber ??
                                'Not provided'),
                        _buildSummaryItem(
                            'Date of Establishment',
                            registrationData.companyDateOfEstablishment ??
                                'Not provided'),
                        _buildSummaryItem('State',
                            registrationData.companyState ?? 'Not provided'),
                        _buildSummaryItem(
                            'Zone Sub City',
                            registrationData.companyZoneSubCity ??
                                'Not provided'),
                        _buildSummaryItem('Woreda',
                            registrationData.companyWoreda ?? 'Not provided'),
                        _buildSummaryItem(
                            'License Files',
                            (registrationData.licenseFiles != null &&
                                    registrationData.licenseFiles!.isNotEmpty)
                                ? registrationData.licenseFiles!
                                    .map((f) => f.split('/').last)
                                    .join(', ')
                                : 'Not provided'),
                        _buildSummaryItem(
                            'Article Files',
                            (registrationData.articleFiles != null &&
                                    registrationData.articleFiles!.isNotEmpty)
                                ? registrationData.articleFiles!
                                    .map((f) => f.split('/').last)
                                    .join(', ')
                                : 'Not provided'),
                        _buildSummaryItem(
                            'Letter of Request Files',
                            (registrationData.letterOfRequestFiles != null &&
                                    registrationData.letterOfRequestFiles!.isNotEmpty)
                                ? registrationData.letterOfRequestFiles!
                                    .map((f) => f.split('/').last)
                                    .join(', ')
                                : 'Not provided'),
                        _buildSummaryItem(
                            'TIN Number Photos',
                            (registrationData.tinNumberPhotos != null &&
                                    registrationData.tinNumberPhotos!.isNotEmpty)
                                ? registrationData.tinNumberPhotos!
                                    .map((f) => f.split('/').last)
                                    .join(', ')
                                : 'Not provided'),
                        _buildSummaryItem('Trade Name Files',
                            (registrationData.tradeNameFiles != null &&
                                    registrationData.tradeNameFiles!.isNotEmpty)
                                ? registrationData.tradeNameFiles!
                                    .map((f) => f.split('/').last)
                                    .join(', ')
                                : 'Not provided'),
                        _buildSummaryItem(
                            'Other Files',
                            (registrationData.otherFiles != null &&
                                    registrationData.otherFiles!.isNotEmpty)
                                ? registrationData.otherFiles!
                                    .map((f) => f.split('/').last)
                                    .join(', ')
                                : 'Not provided'),
                      ],
                    ),
                    // 1. Show each member in their own section with all fields
                    if (registrationData.members != null &&
                        registrationData.members!.isNotEmpty)
                      ...registrationData.members!.asMap().entries.map((entry) {
                        final i = entry.key;
                        final member = entry.value;
                        return _buildSection(
                          'Member ${i + 1}',
                          Icons.person,
                          [
                            _buildSummaryItem(
                                'Full Name', member.fullName ?? 'Not provided'),

                            _buildSummaryItem(
                                'Title', member.title ?? 'Not provided'),
                            _buildSummaryItem(
                                'Sex', member.sex ?? 'Not provided'),
                            // _buildSummaryItem('Marital Status',
                            //     member.maritalStatus ?? 'Not provided'),
                            _buildSummaryItem(
                                'Phone Number', member.phone ?? 'Not provided'),

                            _buildSummaryItem(
                                'Email', member.email ?? 'Not provided'),
                            _buildSummaryItem('Document Name',
                                member.documentType ?? 'Not provided'),
                            _buildSummaryItem(
                                'Legal ID', member.legalId ?? 'Not provided'),
                            _buildSummaryItem('Issue Authority',
                                member.issueAuthority ?? 'Not provided'),
                            _buildSummaryItem('Issue Date',
                                member.issueDate ?? 'Not provided'),
                            _buildSummaryItem('Expiry Date',
                                member.expirayDate ?? 'Not provided'),
                             _buildSummaryItem('State',
                                member.state ?? 'Not provided'),
                            _buildSummaryItem('Verified',
                                member.isVerified ? 'Yes' : 'No'),
                            
                            // National ID Front Image - Extract from verifiedData if available
                            _buildNationalIdImage(
                              'National ID Front',
                              member,
                              'idFront', // Key in verifiedData for front image
                              member.residentPath,
                              context,
                            ),
                            
                            // National ID Back Image - Extract from verifiedData if available
                            _buildNationalIdImage(
                              'National ID Back',
                              member,
                              'idBack', // Key in verifiedData for back image
                              member.residentCardBackPath,
                              context,
                            ),
                            
                            // Profile Photo - Extract from verifiedData['picture'] if available
                            _buildProfilePhoto(
                              member,
                              member.profilePath,
                              context,
                            ),

                            if (member.signature != null &&
                                member.signature is Uint8List)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Signature',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    Image.memory(
                                      member.signature,
                                      width: MediaQuery.of(context).size.width *
                                          0.85,
                                      height: 200,
                                      fit: BoxFit.fill,
                                    ),
                                  ],
                                ),
                              )
                            else
                              _buildSummaryItem('Signature', 'Not provided'),
                     
                          ],
                        );
                      }),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cyanblueColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Complete',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: cyanblueColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: value == 'Not provided' ||
                        value == 'Not uploaded' ||
                        value == 'Not selected'
                    ? Colors.grey.shade600
                    : Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget buildImageSummary(
  //     String label, String? filePath, BuildContext context) {
  //   if (filePath != null && filePath.isNotEmpty) {
  //     return Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 0.0),
  //       child: Card(
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //         elevation: 2,
  //         child: Padding(
  //           padding: const EdgeInsets.all(0.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             children: [
  //               Text(
  //                 label,
  //                 style: const TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 16,
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //               ClipRRect(
  //                 borderRadius: BorderRadius.circular(8),
  //                 child: Image.file(
  //                   File(filePath),
  //                   width: MediaQuery.of(context).size.width * 0.85,
  //                   height: 200,
  //                   fit: BoxFit.fill,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   } else {
  //     return _buildSummaryItem(label, 'Not provided');
  //   }
  // }

  Widget buildImageSummary(
      String label, String? filePath, BuildContext context) {
    if (filePath != null && filePath.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: InteractiveViewer(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(filePath),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(filePath),
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 200,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return _buildSummaryItem(label, 'Not provided');
    }
  }

  // Helper method to extract base64 image bytes from verifiedData
  Uint8List? _extractBase64Image(Map<String, dynamic>? verifiedData, String key) {
    if (verifiedData == null || !verifiedData.containsKey(key)) {
      return null;
    }

    final imageData = verifiedData[key];
    if (imageData is! String || imageData.isEmpty) {
      return null;
    }

    try {
      // Check if it's base64 data URI
      if (imageData.startsWith('data:image')) {
        final base64String = imageData.split(',').last;
        return base64Decode(base64String);
      } else {
        // Assume it's already base64 string
        return base64Decode(imageData);
      }
    } catch (e) {
      print('Error decoding $key from verifiedData: $e');
      return null;
    }
  }

  // Build National ID image (front or back) - checks verifiedData first, then file path
  Widget _buildNationalIdImage(
    String label,
    JointMemberInfo member,
    String verifiedDataKey,
    String? filePath,
    BuildContext context,
  ) {
    // Try to extract from verifiedData first - check multiple possible keys
    Uint8List? imageBytes;
    if (member.verifiedData != null) {
      // Try the provided key first
      imageBytes = _extractBase64Image(member.verifiedData, verifiedDataKey);
      
      // If not found, try alternative keys
      if (imageBytes == null) {
        // For front image, try: idFront, residenceCard, id_front, residence_card
        if (verifiedDataKey == 'idFront') {
          imageBytes = _extractBase64Image(member.verifiedData, 'residenceCard') ??
                       _extractBase64Image(member.verifiedData, 'id_front') ??
                       _extractBase64Image(member.verifiedData, 'residence_card');
        }
        // For back image, try: idBack, residenceCardBack, id_back, residence_card_back
        else if (verifiedDataKey == 'idBack') {
          imageBytes = _extractBase64Image(member.verifiedData, 'residenceCardBack') ??
                       _extractBase64Image(member.verifiedData, 'id_back') ??
                       _extractBase64Image(member.verifiedData, 'residence_card_back');
        }
      }
    }
    
    // If not in verifiedData, try file path
    if (imageBytes == null && filePath != null && filePath.isNotEmpty) {
      final file = File(filePath);
      if (file.existsSync()) {
        return buildImageSummary(label, filePath, context);
      }
    }

    // Display image from verifiedData
    if (imageBytes != null) {
      return _buildImageFromBytes(label, imageBytes, context);
    }

    // No image available
    return _buildSummaryItem(label, 'Not provided');
  }

  // Build Profile Photo - extracts from verifiedData['picture'] first, then file path
  Widget _buildProfilePhoto(
    JointMemberInfo member,
    String? filePath,
    BuildContext context,
  ) {
    // Extract photo from verifiedData['picture'] (base64) if available
    Uint8List? photoBytes;
    if (member.verifiedData != null && member.verifiedData!.containsKey('picture')) {
      final picture = member.verifiedData!['picture'];
      if (picture is String && picture.isNotEmpty) {
        try {
          // Check if it's base64 data URI
          if (picture.startsWith('data:image')) {
            final base64String = picture.split(',').last;
            photoBytes = base64Decode(base64String);
          } else {
            // Assume it's already base64 string
            photoBytes = base64Decode(picture);
          }
        } catch (e) {
          print('Error decoding picture: $e');
        }
      }
    }

    // If not in verifiedData, try file path
    if (photoBytes == null && filePath != null && filePath.isNotEmpty) {
      final file = File(filePath);
      if (file.existsSync()) {
        return buildImageSummary('Profiler', filePath, context);
      }
    }

    // Display image from verifiedData
    if (photoBytes != null) {
      return _buildImageFromBytes(' Photo', photoBytes, context);
    }

    // No image available
    return _buildSummaryItem(' Photo', 'Not provided');
  }

  // Build image widget from Uint8List bytes
  Widget _buildImageFromBytes(
    String label,
    Uint8List imageBytes,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              // const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: InteractiveViewer(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              imageBytes,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    imageBytes,
                    width: MediaQuery.of(context).size.width * 0.70,
                    height: 250,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
