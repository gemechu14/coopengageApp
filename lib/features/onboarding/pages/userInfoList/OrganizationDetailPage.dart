// ignore_for_file: use_build_context_synchronously

import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:flutter/material.dart';
import 'package:coopengageplus/features/onboarding/pages/userInfoList/registration_service.dart';
import 'package:coopengageplus/shared/widgets/AlertDialog/dialog_helper.dart';

class OrganizationDetailPage extends StatelessWidget {
  final Map org;
  final BuildContext parentContext;
  const OrganizationDetailPage(
      {Key? key, required this.org, required this.parentContext})
      : super(key: key);

  void sendEmailToAuthorizedSigners(BuildContext context) async {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final accountId = org['id']?.toString() ?? '';
    String message;
    try {
      final result =
          await RegistrationService().sendRegistrationLink(accountId, 48);
      final success = result['success'] == true;
      var message = result['message'] ?? '';

      if (success) {
        Navigator.of(parentContext, rootNavigator: true).pop();
        DialogHelper.show(
          context,
          title: "Coopengageplus",
          message: message,
        );
      } else {
        Navigator.of(parentContext, rootNavigator: true).pop();
        DialogHelper.show(
          context,
          title: "Coopengageplus",
          message: message,
        );
      }
    } catch (e) {
      Navigator.of(parentContext, rootNavigator: true).pop();
      message = 'An error occurred: $e';
      DialogHelper.show(
        context,
        title: "Coopengageplus",
        message: message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List personalInfo = (org['customersInfo'] != null &&
            (org['customersInfo'] as List).isNotEmpty)
        ? org['customersInfo']
        : (org['personalInfo'] ?? []);
    final String companyName = org['companyName'] ?? 'Organization';
    final String status = org['status'] ?? '';
    final String initials = companyName
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F6FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.93,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        builder: (context, scrollController) => Column(
          children: [
            _buildSheetHeader(companyName, initials, status),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildSection(
                      'Company Information',
                      Icons.business_outlined,
                      [
                        _InfoItem('Company Name', org['companyName']),
                        _InfoItem('TIN Number', org['tinNumber']),
                        _InfoItem('Date of Establishment',
                            org['dateOfEstablishment']),
                        _InfoItem('Target', org['target']),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSection(
                      'Location',
                      Icons.location_on_outlined,
                      [
                        _InfoItem('Residence', org['residence']),
                        _InfoItem('State', org['state']),
                        _InfoItem('Zone', org['zone']),
                        _InfoItem('Sub City', org['subCity']),
                        _InfoItem('Woreda', org['woreda']),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSection(
                      'Account Details',
                      Icons.account_balance_outlined,
                      [
                        _InfoItem('Branch', org['branch']),
                        _InfoItem('Currency', org['currency']),
                        _InfoItem(
                            'Account Type', org['accountType']?.toString()),
                        _InfoItem('Initial Deposit',
                            org['initialDeposit']?.toString()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSignersSection(personalInfo),
                    const SizedBox(height: 20),
                    _buildSendEmailButton(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetHeader(
      String companyName, String initials, String status) {
    return Container(
      decoration: BoxDecoration(
        color: cyanblueColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.3), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (status.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status[0] + status.substring(1).toLowerCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<_InfoItem> items) {
    final validItems =
        items.where((i) => i.value != null && i.value!.toString().isNotEmpty).toList();
    if (validItems.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: cyanblueColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: cyanblueColor),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cyanblueColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              children: validItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.value.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignersSection(List personalInfo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: cyanblueColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.people_outline, size: 16, color: cyanblueColor),
                ),
                const SizedBox(width: 10),
                Text(
                  'Authorized Signers',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cyanblueColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cyanblueColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${personalInfo.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: cyanblueColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          if (personalInfo.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No authorized signers found',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            )
          else
            ...personalInfo.asMap().entries.map((entry) {
              return _buildSignerCard(entry.value, entry.key + 1);
            }).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSignerCard(Map person, int number) {
    final String name = person['fullName'] ?? 'Unknown';
    final String initials = name
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    final items = <_InfoItem>[
      _InfoItem('Full Name', person['fullName']),
      _InfoItem('Surname', person['surname']),
      _InfoItem('Mother\'s Name', person['motherName']),
      _InfoItem('Email', person['email']),
      _InfoItem('Phone', person['phone']),
      _InfoItem('Date of Birth', person['dateOfBirth']),
      _InfoItem('Gender', person['sex']),
      _InfoItem('Country', person['country']),
      _InfoItem('State', person['state']),
      _InfoItem('City', person['city']),
      _InfoItem('Zone / Sub City', person['zoneSubCity']),
      _InfoItem('House No', person['houseNo']),
      _InfoItem('Zip Code', person['zipCode']),
      _InfoItem('Occupation', person['occupation']),
      _InfoItem('Title', person['title']),
      _InfoItem('Marital Status', person['maritalStatus']),
      _InfoItem('Document Name', person['documentName']),
      _InfoItem('Issue Authority', person['issueAuthority']),
      _InfoItem('Issue Date', person['issueDate']),
      _InfoItem('Expiry Date', person['expiryDate']),
      _InfoItem('Legal ID', person['legalId']),
      _InfoItem('Sector', person['sector']),
      _InfoItem('Industry', person['industry']),
      _InfoItem('Employer', person['employerName']),
      _InfoItem('Salary', person['salary']?.toString()),
      _InfoItem('Monthly Income', person['monthlyIncome']?.toString()),
    ];

    final validItems =
        items.where((i) => i.value != null && i.value!.toString().isNotEmpty).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cyanblueColor, cyanblueColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          subtitle: Text(
            person['email'] ?? person['phone'] ?? '',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                children: validItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.value.toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendEmailButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => sendEmailToAuthorizedSigners(context),
        icon: const Icon(Icons.email_outlined, size: 20),
        label: const Text(
          'Send Email to Signers',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: cyanblueColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

}

class _InfoItem {
  final String label;
  final dynamic value;
  _InfoItem(this.label, this.value);
}
