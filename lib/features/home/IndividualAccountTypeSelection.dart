import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/views/individual_account_by_national_id.dart';
// import 'package:coopengageplus/features/onboarding/IndividualAccountByNationalId/IndividualAccountByNationalId.dart';
// import 'package:coopengageplus/features/onboarding/IndividualNationalIdentification/views/individual_account_by_national_id.dart';
// import 'package:coopengageplus/features/onboarding/IndividualAccountByNationalId/IndividualAccountNational.dart';
// import 'package:coopengageplus/features/onboarding/IndividualNationalIdentification/IndividualAccountByNationalId.dart';
import 'package:flutter/material.dart';
import 'package:coopengageplus/features/onboarding/customer/_IndividualAccount/screens/registration_screen.dart';

class IndividualAccountTypeSelection extends StatelessWidget {
  const IndividualAccountTypeSelection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: cyanblueColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Individual Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: cyanblueColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              const Text(
                'Choose your identification method',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),

              // Selection cards
              SizedBox(
                height: 300,
                child: Column(
                  children: [
                    _buildSelectionCard(
                      title: 'National ID',
                      description:
                          'Register using your Ethiopian National ID card',
                      icon: Icons.credit_card,
                      gradientColors: [
                        cyanblueColor,
                        const Color.fromARGB(
                            255, 37, 113, 175), // darker cyanblue
                      ],
                      onTap: () {
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) =>
                        //           // const IndividualAccountNational()
                        //           // const IndividualAccountByNationalId(),

                        //           const NationalIdentification()),
                        // );

                        // Navigator.pushAndRemoveUntil(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => NationalIdentification()),
                        //   (route) => false,
                        // );

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NationalIdentificationWebSocket()),
                          (route) => false,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSelectionCard(
                      title: 'Other ID Cards',
                      description:
                          'Register using passport, driving license, or other valid ID',
                      icon: Icons.badge,
                      gradientColors: [
                        const Color(0xFFFF9800), // orange
                        const Color.fromARGB(
                            255, 196, 101, 12), // darker orange
                      ],
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrationScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String description,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
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
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white,
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
