import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangeLanguagePage extends StatelessWidget {
  const ChangeLanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Change Language'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.white),
            onPressed: () {
              // Log out if desired
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
              title: const Text('English'),
              trailing: const Icon(Icons.language),
              onTap: () {
                _changeLanguage(Locale('en', ''));
              },
            ),
            ListTile(
              title: const Text('Amharic'),
              trailing: const Icon(Icons.language),
              onTap: () {
                _changeLanguage(Locale('am', ''));
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to update the app's language
  void _changeLanguage(Locale locale) {
    Get.updateLocale(locale); // Update the language using GetX
    Get.back(); // Go back to the previous page after changing the language
  }

  // Log out function
  void _logout(BuildContext context) {
    // Clear session and navigate to login
    Get.snackbar('Logged out', 'You have successfully logged out.',
        snackPosition: SnackPosition.BOTTOM);
    Get.offAllNamed('/login'); // Adjust the route as needed
  }
}
