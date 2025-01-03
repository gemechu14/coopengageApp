// import 'package:coopengageplus/helper/databaseHelper.dart';
// import 'package:coopengageplus/pages/MainPage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ChangeLanguagePage extends StatelessWidget {
//   const ChangeLanguagePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => const MainPage()),
//           (route) => false,
//         );
//         return true; // Prevent the default back action
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: const Text('Change Language'),
//           backgroundColor: Colors.white,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.black),
//             onPressed: () {
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (context) => const MainPage()),
//                 (route) => false,
//               );
//             },
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.power_settings_new, color: Colors.white),
//               onPressed: () {
//                 _logout(context);
//               },
//             ),
//           ],
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               ListTile(
//                 title: const Text('English'),
//                 trailing: const Icon(Icons.language),
//                 onTap: () {
//                   _changeLanguage(Locale('en', ''));
//                 },
//               ),
//               ListTile(
//                 title: const Text('Amharic'),
//                 trailing: const Icon(Icons.language),
//                 onTap: () {
//                   _changeLanguage(Locale('am', ''));
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _changeLanguage(Locale locale) async {
//     final dbHelper = DatabaseHelper();
//     await dbHelper
//         .insertLanguage(locale.languageCode); // Save selected language

//     Get.updateLocale(locale); // Dynamically update the app's locale
//     Get.back(); // Go back to the previous page
//   }

//   // Log out function
//   void _logout(BuildContext context) {
//     // Clear session and navigate to login
//     Get.snackbar('Logged out', 'You have successfully logged out.',
//         snackPosition: SnackPosition.BOTTOM);
//     Get.offAllNamed('/login'); // Adjust the route as needed
//   }
// }

import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/pages/MainPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/language_store.dart';

class ChangeLanguagePage extends StatelessWidget {
  const ChangeLanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getSelectedLanguage(), // Fetch selected language from DB
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator()); // Show loading while fetching
        }

        final selectedLanguage =
            snapshot.data ?? 'en'; // Default to 'en' if not found

        return WillPopScope(
          onWillPop: () async {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainPage()),
              (route) => false,
            );
            return true; // Prevent the default back action
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(translation(context).changeLanguage),
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                    (route) => false,
                  );
                },
              ),
              actions: [
                IconButton(
                  icon:
                      const Icon(Icons.power_settings_new, color: Colors.white),
                  onPressed: () {
                    _logout(context);
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'English',
                      style: TextStyle(
                        color: selectedLanguage == 'en'
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                    trailing: selectedLanguage == 'en'
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      _changeLanguage(Locale('en', ''));
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Amharic',
                      style: TextStyle(
                        color: selectedLanguage == 'am'
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                    trailing: selectedLanguage == 'am'
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      _changeLanguage(Locale('am', ''));
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Afaan oromoo',
                      style: TextStyle(
                        color: selectedLanguage == 'or'
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                    trailing: selectedLanguage == 'or'
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      _changeLanguage(Locale('or', ''));
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Fetch the selected language from the database
  Future<String?> _getSelectedLanguage() async {
    final dbHelper = DatabaseHelper();
    return await dbHelper
        .getSelectedLanguage(); // Assuming this returns the selected language code
  }

  void _changeLanguage(Locale locale) async {
    final dbHelper = DatabaseHelper();
    await dbHelper
        .insertLanguage(locale.languageCode); // Save selected language

    Get.updateLocale(locale); // Dynamically update the app's locale
    Get.back(); // Go back to the previous page
  }

  // Log out function
  void _logout(BuildContext context) {
    // Clear session and navigate to login
    Get.snackbar('Logged out', 'You have successfully logged out.',
        snackPosition: SnackPosition.BOTTOM);
    Get.offAllNamed('/login'); // Adjust the route as needed
  }
}
