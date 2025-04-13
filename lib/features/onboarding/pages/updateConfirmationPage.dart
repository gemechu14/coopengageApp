// ignore_for_file: must_be_immutable, deprecated_member_use, use_key_in_widget_constructors, avoid_print, unnecessary_to_list_in_spreads, use_build_context_synchronously

import 'dart:typed_data';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/main.dart';
import 'package:coopengageplus/pages/MainPage.dart';
import 'package:flutter/material.dart';

class UpdateConfirmationPage extends StatelessWidget {
  final Map<String, dynamic> registrationData;
  final Map<String, dynamic> registrationFormData;
  final String? userId;
  final String? className;
  UpdateConfirmationPage({
    required this.registrationData,
    required this.registrationFormData,
    this.userId,
    this.className,
  });
  NetworkHandler networkHandler = NetworkHandler();

  Widget _buildImageSection(
      BuildContext context, String title, dynamic imageData) {
    print('Residence Card Data: $imageData');
    print("dataaaaaa");
    print(registrationData);
    if (imageData == null ||
        (imageData is! Uint8List && imageData is! String)) {
      return const SizedBox.shrink();
    }

    if (imageData is Uint8List) {
      return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title),
            const SizedBox(height: 10),
            Image.memory(
              imageData,
              height: 250,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ],
        ),
      );
    } else if (imageData is String) {
      // Handle URL (if it's a string URL)
      return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title),
            const SizedBox(height: 10),
            Image.network(
              imageData,
              height: 150,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink(); // Return empty space if no valid data
  }

  @override
  Widget build(BuildContext context) {
    final Uint8List? signatureBytes = registrationFormData['signature'];
    final dynamic photoData = registrationFormData['photo'];
    final dynamic residenceCardData = registrationFormData['residenceCard'];
    final Uint8List? signatureData = registrationFormData['signature'];
    final dynamic personalPhotoData = registrationFormData['photo'];
    final dynamic residenceCard1 = registrationFormData['residenceCard'];
    final dynamic residenceCardBack1 =
        registrationFormData['residenceCardBack'];

    print("residenceCardDadddddddddta");

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
      "zoneSubCity",
      "city",
      "zipCode",
      "occupation",
      "monthlyIncome",
      "issueDate",
      "expirayDate",
      "currency",
      "percentageCompleted",
      "accountType",
    ];

    return WillPopScope(
      onWillPop: () async {
        print('Residence Card Data: $residenceCardData');
        FocusScope.of(context).unfocus();
        Navigator.pop(context, userId);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'Review & Confirm',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, userId);
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.blue.withOpacity(0.1)],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 50,
                            color: Colors.blue,
                          ),
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
                            if (registrationFormData.containsKey(field)) {
                              String displayValue;
                              if (field == 'phone') {
                                displayValue = getFormattedPhoneNumber(
                                    registrationFormData[field]);
                              } else {
                                displayValue =
                                    registrationFormData[field].toString();
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatFieldName(field),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        displayValue,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }).toList(),
                        ],
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
                                context, 'Signature', signatureData),
                            _buildImageSection(
                                context, 'Photo', personalPhotoData),
                            _buildImageSection(context, 'Residence Card Front',
                                residenceCard1),
                            _buildImageSection(context, 'Residence Card Back',
                                residenceCardBack1),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () async {
              if (className == 'update') {
                await updateUser(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Registered successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                    (route) => false,
                  );
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text(
              className == 'update' ? 'Update' : 'Submit',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  String getFormattedPhoneNumber(String? phoneNumber) {
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
      print("jdjalddahhjdhadfdudfuduudsduh");

      print(registrationData);
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
}
