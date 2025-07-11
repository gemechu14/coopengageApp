// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import '../../providers/registration_providers.dart';

class StepTermsConditions extends ConsumerStatefulWidget {
  const StepTermsConditions({super.key});

  @override
  ConsumerState<StepTermsConditions> createState() => _StepTermsConditionsState();
}

class _StepTermsConditionsState extends ConsumerState<StepTermsConditions> {
  bool isAccepted = false;
  bool hasReadTerms = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final registrationData = ref.read(registrationDataProvider);
    if (registrationData.termsAccepted == true) {
      setState(() {
        isAccepted = true;
        hasReadTerms = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final validationErrors = ref.watch(formValidationProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cyanblueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cyanblueColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: cyanblueColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please read and accept the terms and conditions to complete your registration.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Terms and Conditions Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.gavel,
                        color: cyanblueColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Terms and Conditions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTermsSection(
                            '1. Account Opening',
                            'By opening an account with our bank, you agree to provide accurate and complete information. You are responsible for maintaining the confidentiality of your account credentials.',
                          ),
                          const SizedBox(height: 16),
                          _buildTermsSection(
                            '2. Account Usage',
                            'Your account is for personal use only. You agree not to use the account for any illegal activities or unauthorized transactions.',
                          ),
                          const SizedBox(height: 16),
                          _buildTermsSection(
                            '3. Privacy Policy',
                            'We are committed to protecting your privacy. Your personal information will be handled in accordance with our privacy policy and applicable laws.',
                          ),
                          const SizedBox(height: 16),
                          _buildTermsSection(
                            '4. Fees and Charges',
                            'You agree to pay all applicable fees and charges associated with your account as outlined in our fee schedule.',
                          ),
                          const SizedBox(height: 16),
                          _buildTermsSection(
                            '5. Liability',
                            'The bank reserves the right to modify these terms at any time. Continued use of the account constitutes acceptance of any changes.',
                          ),
                          const SizedBox(height: 16),
                          _buildTermsSection(
                            '6. Termination',
                            'Either party may terminate the account relationship with written notice as per our account closure policy.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Acceptance Checkboxes
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Acceptance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // I have read the terms checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: hasReadTerms,
                        onChanged: (value) {
                          setState(() {
                            hasReadTerms = value ?? false;
                          });
                          if (hasReadTerms) {
                            ref.read(formValidationProvider.notifier).clearError('termsRead');
                          }
                        },
                        activeColor: cyanblueColor,
                      ),
                      const Expanded(
                        child: Text(
                          'I have read and understood the terms and conditions',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // I accept the terms checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: isAccepted,
                        onChanged: (value) {
                          setState(() {
                            isAccepted = value ?? false;
                          });
                          if (isAccepted) {
                            ref.read(registrationDataProvider.notifier).updateTermsAccepted(true);
                            ref.read(formValidationProvider.notifier).clearError('termsAccepted');
                          }
                        },
                        activeColor: cyanblueColor,
                      ),
                      const Expanded(
                        child: Text(
                          'I accept the terms and conditions',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Validation Error
            if (validationErrors['termsAccepted'] != null && validationErrors['termsAccepted']!.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        validationErrors['termsAccepted']!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
