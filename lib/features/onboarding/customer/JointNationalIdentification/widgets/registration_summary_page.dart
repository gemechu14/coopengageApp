import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/model/account_type.dart';
import 'package:flutter/material.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import '../model/registration_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/account_type_provider.dart';
// import 'package:coopengageplus/features/onboarding/IndividualNationalIdentification/model/account_type.dart';

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
    // Get the list of account types from the provider
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
                    // 1. Show each member in their own section with all fields
                    if (registrationData.members != null &&
                        registrationData.members!.isNotEmpty)
                      ...registrationData.members!.asMap().entries.map((entry) {
                        final i = entry.key;
                        final member = entry.value;
                        return _buildSection(
                          'Member ${i + 1}',
                          Icons.person,
                          [
                            _buildSummaryItem(
                                'Full Name', member.fullName ?? 'Not provided'),
                            // _buildSummaryItem(
                            //     'Surname',
                            //     _getStringValue(
                            //             member.verifiedData?['surname']) ??
                            //         'Not provided'),
                            _buildSummaryItem('Mother Name',
                                member.motherName ?? 'Not provided'),
                            _buildSummaryItem(
                                'Title', member.title ?? 'Not provided'),
                            _buildSummaryItem(
                                'Sex', member.sex ?? 'Not provided'),
                            _buildSummaryItem('Date of Birth',
                                member.dateOfBirth ?? 'Not provided'),
                            _buildSummaryItem('Marital Status',
                                member.maritalStatus ?? 'Not provided'),
                            _buildSummaryItem(
                                'Phone',
                                _getStringValue(
                                        member.verifiedData?['phone']) ??
                                    'Not provided'),
                            _buildSummaryItem(
                                'Email',
                                _getStringValue(
                                        member.verifiedData?['email']) ??
                                    'Not provided'),
                            _buildSummaryItem(
                                'Country',
                                _getStringValue(
                                        member.verifiedData?['country']) ??
                                    'Not provided'),
                            _buildSummaryItem(
                                'Region',
                                _getStringValue(
                                        member.verifiedData?['region']) ??
                                    'Not provided'),
                            _buildSummaryItem(
                                'Zone',
                                _getStringValue(member.verifiedData?['zone']) ??
                                    'Not provided'),
                            _buildSummaryItem(
                                'Woreda',
                                _getStringValue(
                                        member.verifiedData?['woreda']) ??
                                    'Not provided'),
                            _buildSummaryItem(
                                'State',
                                _getStringValue(
                                        member.verifiedData?['state']) ??
                                    'Not provided'),
                            _buildSummaryItem(
                                'City',
                                _getStringValue(member.verifiedData?['city']) ??
                                    'Not provided'),
                            _buildSummaryItem(
                                'Zone/Sub City',
                                _getStringValue(
                                        member.verifiedData?['zoneSubCity']) ??
                                    'Not provided'),
                            _buildSummaryItem(
                                'Street Address',
                                _getStringValue(member
                                        .verifiedData?['streetAddress']) ??
                                    'Not provided'),
                            _buildSummaryItem(
                                'House No',
                                _getStringValue(
                                        member.verifiedData?['houseNo']) ??
                                    'Not provided'),
                            _buildSummaryItem(
                                'Zip Code',
                                _getStringValue(
                                        member.verifiedData?['zipCode']) ??
                                    'Not provided'),
                            _buildSummaryItem(
                                'Occupation',
                                _getStringValue(
                                        member.verifiedData?['occupation']) ??
                                    'Not provided'),
                            _buildSummaryItem(
                                'Monthly Income',
                                _getStringValue(member
                                        .verifiedData?['monthlyIncome']) ??
                                    'Not provided'),
                            _buildSummaryItem(
                                'Sector',
                                _getStringValue(
                                        member.verifiedData?['sector']) ??
                                    'Not provided'),
                            _buildSummaryItem(
                                'Employer Name',
                                _getStringValue(
                                        member.verifiedData?['employerName']) ??
                                    'Not provided'),
                            _buildSummaryItem('Document Name', 'NATIONALID'),
                            _buildSummaryItem('Legal ID', member.legalId ?? ''),
                            _buildSummaryItem(
                                'Issue Authority', member.issueAuthority ?? ''),
                            _buildSummaryItem(
                                'Issue Date', member.issueDate ?? ''),
                            _buildSummaryItem(
                                'Expiry Date', member.expireDate ?? ''),
                            _buildSummaryItem(
                                'Verified', member.isVerified ? 'Yes' : 'No'),
                          ],
                        );
                      }),

                    // 2. Joint Account Info Section (once, at the end)
                    _buildSection(
                      'Joint Account Information',
                      Icons.account_balance,
                      [
                        _buildSummaryItem('Branch',
                            registrationData.branch ?? 'Not provided'),
                        _buildSummaryItem(
                            'Account Type',
                            getAccountTypeNameById(
                                    registrationData.accountType) ??
                                'Not selected'),
                        _buildSummaryItem('Initial Deposit',
                            registrationData.initialDeposit ?? 'Not provided'),
                        _buildSummaryItem(
                            'Bank Share',
                            registrationData.bankShare != null
                                ? '${registrationData.bankShare}%'
                                : 'Not provided'),
                        _buildSummaryItem(
                            'Customer Share',
                            registrationData.customerShare != null
                                ? '${registrationData.customerShare}%'
                                : 'Not provided'),
                        _buildSummaryItem(
                            'Signature',
                            registrationData.signature != null
                                ? 'Uploaded'
                                : 'Not uploaded'),
                        _buildSummaryItem(
                            'Terms Accepted',
                            registrationData.termsAccepted == true
                                ? 'Yes'
                                : 'No'),
                        // Add more joint account fields as needed
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

  String? _getStringValue(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value.trim().isEmpty ? null : value.trim();
    }
    if (value is Map<String, dynamic>) {
      // If it's an address object, try to extract meaningful string representation
      if (value.containsKey('country')) {
        return value['country']?.toString()?.trim();
      }
      if (value.containsKey('region')) {
        return value['region']?.toString()?.trim();
      }
      if (value.containsKey('zone')) {
        return value['zone']?.toString()?.trim();
      }
      if (value.containsKey('woreda')) {
        return value['woreda']?.toString()?.trim();
      }
      if (value.containsKey('state')) {
        return value['state']?.toString()?.trim();
      }
      if (value.containsKey('city')) {
        return value['city']?.toString()?.trim();
      }
      // If it's a complex object, try to get a reasonable string representation
      return value.toString();
    }
    String stringValue = value.toString().trim();
    return stringValue.isEmpty ? null : stringValue;
  }
}
