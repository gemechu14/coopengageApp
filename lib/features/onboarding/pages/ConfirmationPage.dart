// ignore_for_file: must_be_immutable, deprecated_member_use, use_key_in_widget_constructors, avoid_print, use_build_context_synchronously
import 'dart:typed_data';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/main.dart';
import 'package:coopengageplus/pages/MainPage.dart';
import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

class ConfirmationPage extends StatelessWidget {
  final Map<String, dynamic> registrationData;
  final String? userId;
  final String? className;

  ConfirmationPage({
    required this.registrationData,
    this.userId,
    this.className,
  });

  final NetworkHandler networkHandler = NetworkHandler();

  Widget _buildImageSection(
      BuildContext context, String title, dynamic imageData) {
    if (imageData == null ||
        (imageData is! Uint8List && imageData is! String)) {
      return const SizedBox.shrink();
    }

    Widget imageWidget;

    if (imageData is Uint8List) {
      imageWidget = Image.memory(imageData, fit: BoxFit.fill);
    } else {
      imageWidget = Image.network(imageData, fit: BoxFit.fill);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
                color: Colors.blue, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
              ]),
              child: imageWidget,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Uint8List? signatureBytes = registrationData['signature'];
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
      'email',
      'country',
      'state',
      'zoneSubCity',
      'city',
      'zipCode',
      'occupation',
      'monthlyIncome',
      'issueDate',
      'expirayDate',
      'currency',
      'percentageCompleted',
      'accountType',
    ];

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, userId);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Confirmation',
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.blue,
            ),
            onPressed: () => Navigator.pop(context, userId),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
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
                          if (!registrationData.containsKey(field)) {
                            return const SizedBox.shrink();
                          }
                          String value = (field == 'phone')
                              ? getFormattedPhoneNumber(registrationData[field])
                              : registrationData[field].toString();
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${formatFieldName(field)}: ',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: value,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ]

                      // fieldsToShow.map((field) {
                      //   if (!registrationData.containsKey(field)) {
                      //     return const SizedBox.shrink();
                      //   }
                      //   String value = (field == 'phone')
                      //       ? getFormattedPhoneNumber(registrationData[field])
                      //       : registrationData[field].toString();
                      //   return Padding(
                      //     padding: const EdgeInsets.symmetric(vertical: 4.0),
                      //     child: Text.rich(
                      //       TextSpan(
                      //         children: [
                      //           TextSpan(
                      //             text: '${formatFieldName(field)}: ',
                      //             style: const TextStyle(
                      //                 fontSize: 16, fontWeight: FontWeight.bold),
                      //           ),
                      //           TextSpan(
                      //             text: value,
                      //             style: const TextStyle(fontSize: 16),
                      //           ),
                      //         ],
                      //       ),
                      //     ),

                      //     // child: Text(
                      //     //   '${formatFieldName(field)}: $value',
                      //     //   style: const TextStyle(fontSize: 16),
                      //     // ),
                      //   );
                      // }).toList(),
                      ),
                ),
              ),
              const SizedBox(height: 20),
              if (signatureBytes != null ||
                  photoData != null ||
                  residenceCardData != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
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
                            context, 'Residence Card Front', residenceCardData),
                        _buildImageSection(context, 'Residence Card Back',
                            residenceCardBackData),
                      ],
                    ),
                  ),
                ),
              //   Text(
              //     'Documents',
              //     style: TextStyle(
              //         color: Colors.blue,
              //         fontSize: 20,
              //         fontWeight: FontWeight.bold),
              //   ),
              // _buildImageSection(context, 'Signature', signatureBytes),
              // _buildImageSection(context, 'Photo', photoData),
              // _buildImageSection(
              //     context, 'Residence Card Front', residenceCardData),
              // _buildImageSection(
              //     context, 'Residence Card Back', residenceCardBackData),
              // const SizedBox(height: 40),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 26.0, vertical: 7.0),
            child: FormHelper.submitButton(
              "Submit",
              fontSize: 19,
              width: MediaQuery.of(context).size.width * 0.5,
              btnColor: Colors.blueAccent,
              borderColor: Colors.blueAccent,
              () async {
                if (className == 'update') {
                  await updateUser(context);
                } else {
                  // Show SnackBar first
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registered successfully!')),
                  );

                  // Delay navigation to allow SnackBar to be seen
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainPage(),
                      ),
                      (route) => false,
                    );
                  });
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  String getFormattedPhoneNumber(String? phoneNumber) {
    if (phoneNumber != null &&
        !phoneNumber.startsWith('+251') &&
        !phoneNumber.startsWith('251')) {
      return phoneNumber;
    }
    return phoneNumber ?? '';
  }

  String formatFieldName(String fieldName) {
    final RegExp regex = RegExp(r'(?<=[a-z])[A-Z]');
    return fieldName
        .replaceAllMapped(regex, (match) => ' ${match.group(0)}')
        .toUpperCase();
  }

  Future<void> updateUser(BuildContext context) async {
    if (isOnline) {
      print("registrationData");

      prepareRegistrationData(registrationData);
      var response = await networkHandler.put1(
          '/api/v1/accounts/individual/$userId', registrationData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Updated successfully!')),
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainPage(),
            ),
            (route) => false,
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to Update, try later!')),
        );

        Future.delayed(const Duration(seconds: 1), () {});
      }
    } else if (isOnline == false) {
      int? userID = userId != null ? int.tryParse(userId!) : null;
      print("no data found");
      print(userID);
      final DatabaseHelper dbHelper = DatabaseHelper();

      // Add User ID to the data for the update
      int rowsAffected =
          await dbHelper.updateCustomer(userID!, registrationData);

      if (rowsAffected > 0) {
        print("User updated successfully in the local database.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Updated successfully!')),
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainPage(),
            ),
            (route) => false,
          );
        });
      } else {
        print("Failed to update user in the local database.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to Update, try later!')),
        );
      }
    }
  }

  void prepareRegistrationData(Map<String, dynamic> data) {
    if (data['photo'] is! Uint8List) {
      data.remove('photo');
    }
    if (data['residenceCard'] is! Uint8List) {
      data.remove('residenceCard');
    }
  }
}
