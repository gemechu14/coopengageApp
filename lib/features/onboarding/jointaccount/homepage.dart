// // ignore_for_file: deprecated_member_use, use_key_in_widget_constructors

// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:coopengageplus/features/onboarding/corporate/corporateAccount.dart';
import 'package:coopengageplus/features/onboarding/jointaccount/jointAccount.dart';
import 'package:coopengageplus/features/onboarding/Indivudualaccount/CustomerRegistrationScreen.dart';

class AccountOpeningHomePage extends StatelessWidget {
  AccountOpeningHomePage({Key? key}) : super(key: key);
  final Color cyanBlue = Color(0xFF00B8D4); // Example cyan blue
  final Color deepCyan = Color(0xFF008394); // A deeper cyan for gradient
  final Color brightOrange = Color(0xFFFF6F00); // Vivid orange
  final Color deepOrange = Color(0xFFE65100); // Deep orange for gradient

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Choose Account Type',
          style: TextStyle(
              fontSize: 19, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        // centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1.3,
          children: [
            _buildAccountCard(
              title: 'Individual',
              icon: Icons.person_outline,
              gradientColors: [Colors.blue.shade400, Colors.blue.shade700],
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => RegistrationScreen()),
                );
              },
            ),
            _buildAccountCard(
              title: 'Joint',
              icon: Icons.group_outlined,
              gradientColors: [deepCyan, Colors.blue],
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => JointAccountStepperPage()),
                  (route) => false,
                );
              },
            ),
            _buildAccountCard(
              title: 'Corporate',
              icon: Icons.business_outlined,
              gradientColors: [Colors.orange.shade400, Colors.deepOrange],
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CorporateRegistration()),
                  (route) => false,
                );
              },
            ),
            // Add another card if needed to make it a perfect 2x2 grid
            Container(), // Placeholder to keep 2x2 layout if only 3 cards
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
