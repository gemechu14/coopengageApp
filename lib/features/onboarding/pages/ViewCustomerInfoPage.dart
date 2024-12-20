import 'dart:convert';
import 'dart:typed_data';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/pages/MainPage.dart';
import 'package:flutter/material.dart';

import 'package:snippet_coder_utils/FormHelper.dart';

class ViewCustomerInfo extends StatelessWidget {
  final Map<String, dynamic> registrationData;
  String title;
  final String? userId;
  final String? className;

  ViewCustomerInfo({
    required this.registrationData,
    required this.title,
    this.userId,
    this.className,
  });

  NetworkHandler networkHandler = NetworkHandler();

  @override
  Widget build(BuildContext context) {
    final dynamic signatureBytes = registrationData['signature'];
    final dynamic photoData = registrationData['photo'];
    final dynamic residenceCardData = registrationData['residenceCard'];
    final dynamic residenceCardBackData = registrationData['residenceCardBack'];

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
      'percentageCompleted',
      'accountType',
    ];

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(),
          ),
          (route) => false,
        );

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Customer Information',
            style: TextStyle(color: Colors.blue, fontSize: 19),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MainPage(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
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
                        ...fieldsToShow.map((field) {
                          if (registrationData.containsKey(field) &&
                              registrationData[field] != null) {
                            String displayValue;
                            if (field == 'phone') {
                              displayValue = getFormattedPhoneNumber(
                                  registrationData[field]);
                              // } else if (field == 'accountType') {
                              //   displayValue = getAccountTypeDescription(
                              //       registrationData[field]);
                            } else if (field == 'dateOfBirth') {
                              displayValue =
                                  formatDateOfBirth(registrationData[field]);
                            } else {
                              displayValue = registrationData[field].toString();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          '${formatFieldName(field)}: ', // Bold part
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.bold, // Bold style
                                        color: Colors
                                            .black, // Text color (required for RichText)
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$displayValue', // Normal part
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors
                                            .black, // Text color (required for RichText)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          //   return Padding(
                          //     padding: const EdgeInsets.only(bottom: 8.0),
                          //     child: Text(
                          //       '${formatFieldName(field)}: $displayValue',
                          //       style: const TextStyle(fontSize: 16),
                          //     ),
                          //   );
                          // }
                          return const SizedBox.shrink();
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                _buildImageSection(context, 'Signature', signatureBytes),
                _buildImageSection(context, 'Photo', photoData),
                _buildImageSection(
                    context, 'Residence Card', residenceCardData),
                _buildImageSection(
                    context, 'Residence Card Back', residenceCardBackData),
              ],
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

  static const Map<String, String> accountTypeMapping = {
    "1": "Deposit Account",
    "2": "Fixed Time Deposit Account",
    "3": "Non-Repatriable Birr Account",
    "4": "ECOLFL",
    "5": "Diaspora Wadia Saving Account",
    "6": "Diaspora Mudarabah Saving Account",
    "7": "Diaspora Mudarabah Fixed Time"
  };

  String formatFieldName(String fieldName) {
    final RegExp regex = RegExp(r'(?<=[a-z])[A-Z]');
    return fieldName
        .replaceAllMapped(regex, (match) => ' ${match.group(0)}')
        .toUpperCase();
  }

  String getAccountTypeDescription(String? accountType) {
    print("accountType");
    print(accountType == null);
    print(accountTypeMapping[accountType]);

    return accountType == null
        ? ''
        : accountTypeMapping[accountType] ?? "Unknown Account Type";
  }

  String getFormattedPhoneNumber(String? phoneNumber) {
    if (phoneNumber != null && !phoneNumber.startsWith('+251')) {
      return '+ $phoneNumber';
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
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title),
          const SizedBox(height: 10),
          imageWidget,
        ],
      ),
    );
  }
}
