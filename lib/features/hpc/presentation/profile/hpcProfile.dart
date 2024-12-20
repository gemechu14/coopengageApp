import 'package:coopengageplus/features/hpc/presentation/language/changeLanguage.dart';
import 'package:coopengageplus/utils/language_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common_widgets/text/custom_nav_heading.dart';

class HighClientProfilePage extends StatelessWidget {
  const HighClientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.white,
          title: CustomNavHeading(text: translation(context).profile),
          actions: [
            IconButton(
              icon: const Icon(Icons.power_settings_new, color: Colors.blue),
              onPressed: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileInfoSection(),
              const SizedBox(height: 20),
              _settingsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  // Profile Info Section
  Widget _profileInfoSection() {
    String firstName = 'Samuel'; // Example first name
    String middleName = 'Daniel'; // Example middle name

    // Get the first letter of both first and middle name
    String firstLetter = firstName.isNotEmpty ? firstName[0] : '';
    String middleLetter = middleName.isNotEmpty ? middleName[0] : '';

    // Combine the first letters of first and middle name
    String avatarText = '$firstLetter$middleLetter'.toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.1),
        //     blurRadius: 8,
        //     spreadRadius: 2,
        //   ),
        // ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.black,
            child: Text(
              avatarText, // Display the first letters of the names
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$firstName $middleName', // Client name
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'samueldaniel@gmail.com', // Email
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                '+251947539988', // Phone number
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _settingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10),
          child: const Text('Settings',
              style: TextStyle(fontSize: 18, color: Colors.black)),
        ),
        const SizedBox(height: 12),
        Container(
          // padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  radius: 20, // Size of the circular background
                  backgroundColor:
                      Colors.blueAccent, // Background color of the circle
                  child: Icon(Icons.info, color: Colors.white), // White icon
                ),
                title: const Text('About'),
                onTap: () {
                  _navigateToAbout(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  radius: 20, // Size of the circular background
                  backgroundColor:
                      Colors.greenAccent, // Different background color for Help
                  child: Icon(Icons.help, color: Colors.white), // White icon
                ),
                title: const Text('Help'),
                // trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _navigateToHelp(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  radius: 20, // Size of the circular background
                  backgroundColor: Colors
                      .orangeAccent, // Different background color for Language
                  child:
                      Icon(Icons.language, color: Colors.white), // White icon
                ),
                title: const Text('Change Language'),
                // trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.to(() => ChangeLanguagePage());
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Navigation functions for settings options
  void _navigateToAbout(BuildContext context) {
    // Navigate to About page
    Get.toNamed('/about'); // Adjust the route accordingly
  }

  void _navigateToHelp(BuildContext context) {
    // Navigate to Help page
    Get.toNamed('/help'); // Adjust the route accordingly
  }

  void _navigateToChangeLanguage(BuildContext context) {
    // Navigate to Change Language page
    Get.toNamed('/change-language'); // Adjust the route accordingly
  }

  // Logout function
  void _logout(BuildContext context) {
    // Logic for logout (Clear session, etc.)
    Get.snackbar('Logged out', 'You have successfully logged out.',
        snackPosition: SnackPosition.BOTTOM);
    // Navigate to login screen or initial page
    Get.offAllNamed('/login'); // Change the route as per your app structure
  }
}
