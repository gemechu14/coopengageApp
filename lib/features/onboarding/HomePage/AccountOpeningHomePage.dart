import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/features/onboarding/_corporate/screens/registration_screen.dart';
import 'package:coopengageplus/features/onboarding/corporate/corporateAccount.dart';

import 'package:coopengageplus/features/onboarding/corporateCustomer/corporateAccount.dart';
import 'package:flutter/material.dart';
import 'package:coopengageplus/features/onboarding/jointaccount/jointAccount.dart';
import 'package:coopengageplus/features/onboarding/HomePage/IndividualAccountTypeSelection.dart';
// import 'package:coopengageplus/features/onboarding/Indivudualaccount/CustomerRegistrationScreen.dart';

class AccountOnboardingScreen extends StatelessWidget {
  AccountOnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light gray background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Choose Account Type',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: cyanblueColor,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              const Text(
                'Select the type of account you would like to open',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),

              // Account type cards
              SizedBox(
                height: 400, // Fixed height for GridView
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  shrinkWrap: true, // Add this to prevent unbounded height
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                  children: [
                    _buildAccountCard(
                      title: 'Individual',
                      description: 'Personal account for single user',
                      icon: Icons.person_outline,
                      gradientColors: [
                        const Color(0xFF3B82F6),
                        // const Color(0xFF1E40AF),
                        cyanblueColor
                      ],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  const IndividualAccountTypeSelection()),
                        );
                      },
                    ),
                    _buildAccountCard(
                      title: 'Joint',
                      description: 'Shared account for multiple users',
                      icon: Icons.group_outlined,
                      gradientColors: [
                        const Color(0xFF10B981),
                        const Color(0xFF059669),
                      ],
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JointAccountStepperPage(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                    _buildAccountCard(
                      title: 'Corporate',
                      description: 'Business and organizational accounts',
                      icon: Icons.business_outlined,
                      gradientColors: [
                        const Color(0xFFF59E0B),
                        const Color(0xFFD97706),
                      ],
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CorporateCustomerRegistration(),
                                // CorporateRegistrationScreen()
                                // CorporateRegistration()
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40), // Bottom padding for scroll
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard({
    required String title,
    required String description,
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  // Main content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Description
                      Expanded(
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Arrow indicator (positioned absolutely)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
