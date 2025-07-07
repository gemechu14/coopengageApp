import 'package:flutter/material.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import '../models/registration_data.dart';

class RegistrationSummaryDialog extends StatelessWidget {
  final RegistrationData registrationData;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const RegistrationSummaryDialog({
    super.key,
    required this.registrationData,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cyanblueColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.summarize,
                    color: Colors.white,
                    size: 28,
                  ),
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
                    onPressed: onCancel,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Basic Information',
                      Icons.person,
                      [
                        _buildSummaryItem('Phone Number',  registrationData.phone ?? 'Not provided'),
                        _buildSummaryItem('Email', registrationData.email ?? 'Not provided'),
                        _buildSummaryItem('Product Type', registrationData.productType ?? 'Not provided'),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildSection(
                      'Personal Information',
                      Icons.contact_page,
                      [
                        _buildSummaryItem('Full Name', registrationData.fullName ?? 'Not provided'),
                        _buildSummaryItem('Surname', registrationData.surname ?? 'Not provided'),
                        _buildSummaryItem('Mother Name', registrationData.motherName ?? 'Not provided'),
                        _buildSummaryItem('Title', registrationData.title ?? 'Not provided'),
                        _buildSummaryItem('Sex', registrationData.sex ?? 'Not provided'),
                        _buildSummaryItem('Date of Birth', registrationData.dateOfBirth ?? 'Not provided'),
                        _buildSummaryItem('Marital Status', registrationData.maritalStatus ?? 'Not provided'),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildSection(
                      'Document Information',
                      Icons.description,
                      [
                        _buildSummaryItem('Branch', registrationData.branch ?? 'Not provided'),
                        _buildSummaryItem('Document Name', registrationData.documentName ?? 'Not provided'),
                        _buildSummaryItem('Residence Card', registrationData.residenceCard != null ? 'Uploaded' : 'Not uploaded'),
                        _buildSummaryItem('Residence Card Back', registrationData.residenceCardBack != null ? 'Uploaded' : 'Not uploaded'),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildSection(
                      'Financial Information',
                      Icons.account_balance_wallet,
                      [
                        _buildSummaryItem('Occupation', registrationData.occupation ?? 'Not provided'),
                        _buildSummaryItem('Monthly Income', registrationData.monthlyIncome ?? 'Not provided'),
                        _buildSummaryItem('Initial Deposit', registrationData.initialDeposit ?? 'Not provided'),
                        _buildSummaryItem('Sector', registrationData.sector ?? 'Not provided'),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildSection(
                      'Address Information',
                      Icons.location_on,
                      [
                        _buildSummaryItem('Country', registrationData.country ?? 'Not provided'),
                        _buildSummaryItem('State', registrationData.state ?? 'Not provided'),
                        _buildSummaryItem('Zone/Sub City', registrationData.zoneSubCity ?? 'Not provided'),
                        _buildSummaryItem('Street Address', registrationData.streetAddress ?? 'Not provided'),
                        _buildSummaryItem('Legal ID', registrationData.legalId ?? 'Not provided'),
                        _buildSummaryItem('Issue Authority', registrationData.issueAuthority ?? 'Not provided'),
                        _buildSummaryItem('Issue Date', registrationData.issueDate ?? 'Not provided'),
                        _buildSummaryItem('Expiry Date', registrationData.expirayDate ?? 'Not provided'),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildSection(
                      'Account Information',
                      Icons.account_balance,
                      [
                        _buildSummaryItem('Account Type', registrationData.accountType ?? 'Not selected'),
                        _buildSummaryItem('Currency', registrationData.currency ?? 'Not provided'),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildSection(
                      'Additional Information',
                      Icons.photo_camera,
                      [
                        _buildSummaryItem('Signature', registrationData.signature != null ? 'Uploaded' : 'Not uploaded'),
                        _buildSummaryItem('Personal Photo', registrationData.photo != null ? 'Uploaded' : 'Not uploaded'),
                        _buildSummaryItem('Terms Accepted', registrationData.termsAccepted == true ? 'Yes' : 'No'),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Progress Information
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: cyanblueColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Registration Progress',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: cyanblueColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Progress: ${registrationData.percentageCompleted.toInt()}%',
                            style: TextStyle(
                              fontSize: 14,
                              color: cyanblueColor,
                            ),
                          ),
                          // Text(
                          //   'Status: ${registrationData.status}',
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //     color: Colors.green.shade600,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onCancel,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
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
            Icon(
              icon,
              color: cyanblueColor,
              size: 20,
            ),
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
          child: Column(
            children: children,
          ),
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
                color: value == 'Not provided' || value == 'Not uploaded' || value == 'Not selected'
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