import 'package:coopengageplus/features/onboarding/IndividualNationalIdentification/model/account_type.dart';
import 'package:coopengageplus/features/onboarding/IndividualNationalIdentification/providers/account_type_provider.dart';
import 'package:flutter/material.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/registration_data.dart';

class RegistrationSummaryScreen extends ConsumerWidget {
  final RegistrationData registrationData;
  final VoidCallback onConfirm;

  const RegistrationSummaryScreen({
    super.key,
    required this.registrationData,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountTypes =
        ref.watch(accountTypeStepProvider).availableAccountTypes;
    String? getAccountTypeNameById(String? id) {
      if (id == null) return null;
      final found = accountTypes.firstWhere(
        (type) => type.id.toString() == id,
        orElse: () => AccountType(
            id: 0,
            name: '',
            minAge: 0,
            maxAge: 0,
            minAmount: 0,
            sex: '',
            bankingType: '',
            type: '',
            category: ''),
      );
      return found.name.isNotEmpty ? found.name : null;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cyanblueColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(1),
                  topRight: Radius.circular(1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.summarize, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Registration Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Basic Information',
                      Icons.person,
                      [
                        _buildSummaryItem('Phone Number',
                            registrationData.phone ?? 'Not provided'),
                        _buildSummaryItem(
                            'Email', registrationData.email ?? 'Not provided'),
                        _buildSummaryItem('Product Type',
                            registrationData.productType ?? 'Not provided'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      'Personal Information',
                      Icons.contact_page,
                      [
                        _buildSummaryItem('Full Name',
                            registrationData.fullName ?? 'Not provided'),
                        _buildSummaryItem('Surname',
                            registrationData.surname ?? 'Not provided'),
                        _buildSummaryItem('Mother Name',
                            registrationData.motherName ?? 'Not provided'),
                        _buildSummaryItem(
                            'Title', registrationData.title ?? 'Not provided'),
                        _buildSummaryItem(
                            'Sex', registrationData.sex ?? 'Not provided'),
                        _buildSummaryItem('Date of Birth',
                            registrationData.dateOfBirth ?? 'Not provided'),
                        _buildSummaryItem('Marital Status',
                            registrationData.maritalStatus ?? 'Not provided'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      'Document Information',
                      Icons.description,
                      [
                        _buildSummaryItem('Branch',
                            registrationData.branch ?? 'Not provided'),
                        _buildSummaryItem('Document Name',
                            registrationData.documentName ?? 'Not provided'),
                        _buildSummaryItem(
                            'Residence Card',
                            registrationData.residenceCard != null
                                ? 'Uploaded'
                                : 'Not uploaded'),
                        _buildSummaryItem(
                            'Residence Card Back',
                            registrationData.residenceCardBack != null
                                ? 'Uploaded'
                                : 'Not uploaded'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      'Financial Information',
                      Icons.account_balance_wallet,
                      [
                        _buildSummaryItem('Occupation',
                            registrationData.occupation ?? 'Not provided'),
                        _buildSummaryItem('Monthly Income',
                            registrationData.monthlyIncome ?? 'Not provided'),
                        _buildSummaryItem('Initial Deposit',
                            registrationData.initialDeposit ?? 'Not provided'),
                        _buildSummaryItem('Sector',
                            registrationData.sector ?? 'Not provided'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      'Address Information',
                      Icons.location_on,
                      [
                        _buildSummaryItem('Country',
                            registrationData.country ?? 'Not provided'),
                        _buildSummaryItem(
                            'State', registrationData.state ?? 'Not provided'),
                        _buildSummaryItem('Zone/Sub City',
                            registrationData.zoneSubCity ?? 'Not provided'),
                        _buildSummaryItem('Street Address',
                            registrationData.streetAddress ?? 'Not provided'),
                        _buildSummaryItem('Legal ID',
                            registrationData.legalId ?? 'Not provided'),
                        _buildSummaryItem('Issue Authority',
                            registrationData.issueAuthority ?? 'Not provided'),
                        _buildSummaryItem('Issue Date',
                            registrationData.issueDate ?? 'Not provided'),
                        _buildSummaryItem('Expiry Date',
                            registrationData.expirayDate ?? 'Not provided'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      'Account Information',
                      Icons.account_balance,
                      [
                        _buildSummaryItem(
                            'Account Type',
                            getAccountTypeNameById(
                                    registrationData.accountType) ??
                                'Not selected'),
                        // _buildSummaryItem('Account Type',
                        //   registrationData.accountType ?? 'Not selected'),
                        _buildSummaryItem(
                          'Bank Share',
                          registrationData.bankShare != null
                              ? '${registrationData.bankShare}%'
                              : 'Not provided',
                        ),
                        _buildSummaryItem(
                          'Customer Share',
                          registrationData.customerShare != null
                              ? '${registrationData.customerShare}%'
                              : 'Not provided',
                        ),
                        _buildSummaryItem('Currency',
                            registrationData.currency ?? 'Not provided'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      'Additional Information',
                      Icons.photo_camera,
                      [
                        _buildSummaryItem(
                            'Signature',
                            registrationData.signature != null
                                ? 'Uploaded'
                                : 'Not uploaded'),
                        _buildSummaryItem(
                            'Personal Photo',
                            registrationData.photo != null
                                ? 'Uploaded'
                                : 'Not uploaded'),
                        _buildSummaryItem(
                            'Terms Accepted',
                            registrationData.termsAccepted == true
                                ? 'Yes'
                                : 'No'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cyanblueColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Complete',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: cyanblueColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: value == 'Not provided' ||
                        value == 'Not uploaded' ||
                        value == 'Not selected'
                    ? Colors.grey.shade600
                    : Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
