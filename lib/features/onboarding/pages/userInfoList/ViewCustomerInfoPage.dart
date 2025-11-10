// ignore_for_file: must_be_immutable, deprecated_member_use, use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'package:coopengageplus/core/network/network_handler.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/features/home/main_page.dart';
import 'package:flutter/material.dart';

import 'package:snippet_coder_utils/FormHelper.dart';

class ViewCustomerInfo extends StatefulWidget {
  final Map<String, dynamic> registrationData;
  String title;
  final String? userId;
  final String? className;

  ViewCustomerInfo({
    super.key,
    required this.registrationData,
    required this.title,
    this.userId,
    this.className,
  });

  @override
  State<ViewCustomerInfo> createState() => _ViewCustomerInfoState();
}

class _ViewCustomerInfoState extends State<ViewCustomerInfo> {
  NetworkHandler networkHandler = NetworkHandler();

  // @override
  // void initState() {
  //   _initializeGlobal();
  // }

  List<Map<String, dynamic>> accountTypes = [];

  @override
  Widget build(BuildContext context) {
    final dynamic signatureBytes = widget.registrationData['signature'];
    final dynamic photoData = widget.registrationData['photo'];
    final dynamic residenceCardData = widget.registrationData['residenceCard'];
    final dynamic residenceCardBackData =
        widget.registrationData['residenceCardBack'];

    final List<String> fieldsToShow = [
      'fullName',
      'surname',
      'motherName',
      'sex',
      'dateOfBirth',
      'phone',
      'branch',
      'customerType',
      'email',
      'country',
      'state',
      'city',
      "zoneSubCity",
      'zipCode',
      'occupation',
      'monthlyIncome',
      "documentName",
      // 'streetAddress': 'Woreda',
      'currency',
      "issueDate",
      "expirayDate",
      // 'percentageCompleted',
      'accountType',
      'accountNumber'
    ];

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Customer Information',
            style: TextStyle(
                color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              size: 25,
              color: Colors.blue,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 5),
                  Card(
                    elevation: 5,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const Divider(thickness: 1.5),
                          const SizedBox(height: 15),
                          ...fieldsToShow.map((field) {
                            if (widget.registrationData.containsKey(field) &&
                                widget.registrationData[field] != null) {
                              String displayValue;
                              if (field == 'phone') {
                                displayValue = getFormattedPhoneNumber(
                                    widget.registrationData[field]);
                              } else if (field == 'dateOfBirth') {
                                displayValue = formatDateOfBirth(
                                    widget.registrationData[field]);
                              }
                              //else if (field == 'accountType') {
                              //   displayValue = accountTypeName;
                              // }
                              else {
                                displayValue =
                                    widget.registrationData[field].toString();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${formatFieldName(field)}: ',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: displayValue,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          }),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Card(
                      elevation: 5,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text(
                              'Documents & Photos',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Divider(thickness: 1.5),
                            _buildImageSection(
                                context, 'Signature', signatureBytes),
                            _buildImageSection(context, 'Photo', photoData),
                            _buildImageSection(
                                context, 'Residence Card', residenceCardData),
                            _buildImageSection(context, 'Residence Card Back',
                                residenceCardBackData),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 26.0, vertical: 5.0),
            child: FormHelper.submitButton(
              "Go to Home",
              fontSize: 19,
              width: MediaQuery.of(context).size.width * 0.5,
              btnColor: Colors.blue,
              borderColor: Colors.blue,
              () async {
                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainPage(),
                    ),
                    (route) => false,
                  );
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  String formatFieldName(String fieldName) {
    final RegExp regex = RegExp(r'(?<=[a-z])[A-Z]');
    return fieldName
        .replaceAllMapped(regex, (match) => ' ${match.group(0)}')
        .toUpperCase();
  }

  String getFormattedPhoneNumber(String? phoneNumber) {
    if (phoneNumber != null && !phoneNumber.startsWith('+251')) {
      return '$phoneNumber';
    }
    return phoneNumber ?? '';
  }

  String formatDateOfBirth(String? dateOfBirth) {
    if (dateOfBirth == null) return '';
    try {
      final date = DateTime.parse(dateOfBirth);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateOfBirth;
    }
  }

  Widget _buildImageSection(
      BuildContext context, String title, dynamic imageData) {
    if (imageData == null) {
      return const SizedBox.shrink();
    }

    try {
      if (imageData is Uint8List) {
        return _buildImageWidget(
          title,
          Image.memory(
            imageData,
            height: 150,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        );
      }

      if (imageData is String &&
          (imageData.startsWith('http') || imageData.startsWith('https'))) {
        return _buildImageWidget(
          title,
          Image.network(
            imageData,
            height: 200,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Text('Failed to load image'),
          ),
        );
      }

      if (imageData is String &&
          (imageData.startsWith('/9j/') ||
              imageData.startsWith('data:image/jpeg;base64,'))) {
        final base64Str = imageData.startsWith('data:image/jpeg;base64,')
            ? imageData.replaceFirst('data:image/jpeg;base64,', '')
            : imageData;
        final imageBytes = base64Decode(base64Str);

        return _buildImageWidget(
          title,
          Image.memory(
            imageBytes,
            height: 200,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.contain,
          ),
        );
      }
    } catch (e) {
      print("Error processing image data for '$title': $e");
    }

    return const SizedBox.shrink();
  }

  Widget _buildImageWidget(String title, Widget imageWidget) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 15, color: Colors.blue),
          ),
          const SizedBox(height: 10),
          imageWidget,
        ],
      ),
    );
  }

  Future<void> _initializeGlobal() async {
    List<Map<String, dynamic>> fetchedAccountTypes =
        await networkHandler.fetchAccountTypesFromDatabase();

    setState(() {
      accountTypes = fetchedAccountTypes;
    });
  }
}
