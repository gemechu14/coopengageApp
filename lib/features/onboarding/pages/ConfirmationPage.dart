// // ignore_for_file: must_be_immutable, deprecated_member_use, use_key_in_widget_constructors, avoid_print

// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:coopengageplus/NetworkHandler.dart';
// import 'package:coopengageplus/helper/databaseHelper.dart';
// import 'package:coopengageplus/main.dart';
// import 'package:coopengageplus/pages/HomePage.dart';
// import 'package:coopengageplus/pages/MainPage.dart';
// import 'package:snippet_coder_utils/FormHelper.dart';

// class ConfirmationPage extends StatelessWidget {
//   final Map<String, dynamic> registrationData;
//   final String? userId;
//   final String? className;
//   ConfirmationPage(
//       {required this.registrationData, this.userId, this.className});
//   NetworkHandler networkHandler = NetworkHandler();
//   Widget _buildImageSection(
//       BuildContext context, title, Uint8List? imageBytes) {
//     if (imageBytes == null || imageBytes.isEmpty) {
//       return const SizedBox.shrink();
//     }
//     return Padding(
//       padding: const EdgeInsets.only(top: 20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(title),
//           const SizedBox(height: 10),
//           Image.memory(
//             imageBytes,
//             height: 150,
//             width: double.infinity,
//             fit: BoxFit.contain,
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Retrieve images from registrationData
//     final Uint8List? signatureBytes = registrationData['signature'];
//     final Uint8List? photoBytes = registrationData['photo'];
//     final Uint8List? residenceCardBytes = registrationData['residenceCard'];

//     return WillPopScope(
//       onWillPop: () async {
//         FocusScope.of(context).unfocus();
//         Navigator.pop(context, userId);
//         FocusScope.of(context).unfocus(); // Pass userId back
//         return true; // Prevent the default back action
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Confirm',
//             style: TextStyle(color: Colors.blue, fontSize: 27),
//           ),
//           centerTitle: true,
//           leading: IconButton(
//               onPressed: () {
//                 Navigator.pop(context, userId);
//                 FocusScope.of(context).unfocus(); // Pass userId back
//                 // return false;
//               },
//               icon: const Icon(Icons.arrow_back)),
//         ),
//         body: SingleChildScrollView(
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 30),
//                   // Filter out the image-related entries
//                   ...registrationData.entries.where((entry) {
//                     return entry.key != 'signature' &&
//                         entry.key != 'photo' &&
//                         entry.key != 'residenceCard';
//                   }).map((entry) {
//                     return Text(
//                       '${entry.key}: ${entry.value}',
//                       textAlign: TextAlign.center,
//                     );
//                   }).toList(),
//                   const SizedBox(height: 20), // Space before the images

//                   _buildImageSection(context, 'Signature', signatureBytes),
//                   _buildImageSection(context, 'Photo', photoBytes),
//                   _buildImageSection(
//                       context, 'Residence Card', residenceCardBytes),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         bottomNavigationBar: BottomAppBar(
//           color: Colors.transparent,
//           shape: const CircularNotchedRectangle(),
//           child: Padding(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 26.0, vertical: 7.0),
//             child: FormHelper.submitButton(
//               "Submit",
//               fontSize: 19,
//               width: MediaQuery.of(context).size.width * 0.5,
//               btnColor: Colors.blueAccent,
//               borderColor: Colors.blueAccent,
//               () async {
//                 if (className == 'update') {
//                   await updateUser(context);
//                 } else {
//                   // Show SnackBar first
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Registered successfully!')),
//                   );

//                   // Delay navigation to allow SnackBar to be seen
//                   Future.delayed(const Duration(seconds: 1), () {
//                     // Navigate after delay
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const MainPage(),
//                       ),
//                       (route) => false,
//                     );
//                   });
//                 }
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> updateUser(BuildContext context) async {
//     String? data = userId;

//     if (isOnline) {
//       var response = await networkHandler.put1(
//           '/api/v1/accounts/$userId', registrationData);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Updated successfully!')),
//         );

//         // Delay navigation to allow SnackBar to be seen
//         Future.delayed(const Duration(seconds: 1), () {
//           // Navigate after delay
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const MainPage(),
//             ),
//             (route) => false,
//           );
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Unable to Update try later!')),
//         );

//         // Delay navigation to allow SnackBar to be seen
//         Future.delayed(const Duration(seconds: 1), () {
//           // Navigate after delay
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const Homepage(),
//             ),
//             (route) => false,
//           );
//         });
//       }
//     } else if (isOnline == false) {
//       int? userID; // Declare an int variable to hold the converted value

// // Convert the String? to int
//       userID = userId != null ? int.tryParse(userId!) : null;
//       print("noo data found");
//       print(userID);
//       final DatabaseHelper dbHelper = DatabaseHelper();

//       // Add User ID to the data for the update
//       int rowsAffected =
//           await dbHelper.updateCustomer(userID!, registrationData);

//       if (rowsAffected > 0) {
//         print("User updated successfully in the local database.");
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Updated successfully!')),
//         );

//         // Delay navigation to allow SnackBar to be seen
//         Future.delayed(const Duration(seconds: 1), () {
//           // Navigate after delay
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const MainPage(),
//             ),
//             (route) => false,
//           );
//         });
//       } else {
//         print("Failed to update user in the local database.");
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Unable to Update try later!')),
//         );
//       }
//     }
//   }
// }

// ignore_for_file: must_be_immutable, deprecated_member_use, use_key_in_widget_constructors, avoid_print

import 'dart:convert';
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

  NetworkHandler networkHandler = NetworkHandler();

  // Widget _buildImageSection(
  //     BuildContext context, String title, Uint8List? imageBytes) {
  //   if (imageBytes == null || imageBytes.isEmpty) {
  //     return const SizedBox.shrink();
  //   }
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 20.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Text(title),
  //         const SizedBox(height: 10),
  //         Image.memory(
  //           imageBytes,
  //           height: 150,
  //           width: double.infinity,
  //           fit: BoxFit.contain,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildImageSection(
      BuildContext context, String title, dynamic imageData) {
    print('Residence Card Data: $imageData');
    print("dataaaaaa");
    print(registrationData);
    if (imageData == null ||
        (imageData is! Uint8List && imageData is! String)) {
      return const SizedBox.shrink(); // Return empty space if no image data
    }

    if (imageData is Uint8List) {
      // Handle Uint8List data (e.g., display the image from bytes)
      return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title),
            const SizedBox(height: 10),
            Image.memory(
              imageData,
              height: 150,
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
    final Uint8List? signatureBytes = registrationData['signature'];
    final dynamic photoData = registrationData['photo'];
    final dynamic residenceCardData = registrationData['residenceCard'];
    final dynamic residenceCardBackData = registrationData['residenceCardBack'];

    print("residenceCardData");
    print(registrationData);
    print(residenceCardBackData);

    final List<String> fieldsToShow = [
      'fullName',
      'surname',
      'motherName',
      'sex',
      'dateOfBirth',
      // "phoneNumber",
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
          title: const Text(
            'Confirm',
            style: TextStyle(color: Colors.blue, fontSize: 27),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, userId);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  ...fieldsToShow.map((field) {
                    if (registrationData.containsKey(field)) {
                      String displayValue;
                      if (field == 'phone') {
                        displayValue =
                            getFormattedPhoneNumber(registrationData[field]);
                        // } else if (field == 'accountType') {
                        //   displayValue =
                        //       getAccountTypeDescription(registrationData[field]);
                      } else {
                        displayValue = registrationData[field].toString();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '${formatFieldName(field)}: $displayValue',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }).toList(),
                  const SizedBox(height: 20),
                  _buildImageSection(context, 'Signature', signatureBytes),
                  _buildImageSection(context, 'Photo', photoData),
                  _buildImageSection(
                      context, 'Residence Card Front', residenceCardData),
                  _buildImageSection(
                      context, 'Residence Card Back', residenceCardBackData),
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

  // Check if phone number needs the +251 prefix
  String getFormattedPhoneNumber(String? phoneNumber) {
    if (phoneNumber != null && !phoneNumber.startsWith('+251') ||
        phoneNumber != null && !phoneNumber.startsWith('251')) {
      return '+251 $phoneNumber';
    }
    return phoneNumber ?? '';
  }

// Account type mapping
  static const Map<String, String> accountTypeMapping = {
    "1": "Deposit Account",
    "2": "Fixed Time Deposit Account",
    "3": "Non-Repatriable Birr Account",
    "4": "ECOLFL",
    "5": "Diaspora Wadia Saving Account",
    "6": "Diaspora Mudarabah Saving Account",
    "7": "Diaspora Mudarabah Fixed Time"
  };

// Function to get the account type description based on the number
  String getAccountTypeDescription(String? accountType) {
    return accountTypeMapping[accountType] ?? "Unknown Account Type";
  }

// Helper function to convert camelCase to ALL CAPS with spaces (e.g., "fullName" to "FULL NAME")
  String formatFieldName(String fieldName) {
    final RegExp regex = RegExp(r'(?<=[a-z])[A-Z]');
    return fieldName
        .replaceAllMapped(regex, (match) => ' ${match.group(0)}')
        .toUpperCase();
  }

  void prepareRegistrationData(Map<String, dynamic> data) {
    if (data['photo'] is! Uint8List) {
      data.remove('photo');
    }
    if (data['residenceCard'] is! Uint8List) {
      data.remove('residenceCard');
    }
  }

  Future<void> updateUser(BuildContext context) async {
    if (isOnline) {
      print("registrationData");

      prepareRegistrationData(registrationData);
      var response = await networkHandler.put1(
          '/api/v1/accounts/$userId', registrationData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Updated successfully!')),
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to Update, try later!')),
        );

        Future.delayed(const Duration(seconds: 1), () {
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const Homepage(),
          //   ),
          //   (route) => false,
          // );
        });
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
}
