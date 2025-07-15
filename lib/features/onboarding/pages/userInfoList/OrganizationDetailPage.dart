// ignore_for_file: use_build_context_synchronously

import 'package:coopengageplus/constants/kconstant.dart';
import 'package:flutter/material.dart';
import 'package:coopengageplus/features/onboarding/pages/userInfoList/registration_service.dart';
import 'package:coopengageplus/common_widgets/AlertDialog/dialog_helper.dart';

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

    final accountId = org['id']?.toString() ?? org['id']?.toString() ?? '';
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
        Navigator.of(parentContext, rootNavigator: true)
            .pop(); // Remove loading
        DialogHelper.show(
          context,
          title: "Coopengageplus",
          message: message,
        );
      }
    } catch (e) {
      Navigator.of(parentContext, rootNavigator: true).pop(); // Remove loading
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
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.98,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                org['companyName'] ??
                    org['companyName'] ??
                    'Organization Details',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              const SizedBox(height: 16),
              _infoRow('Company Name', org['companyName']),
              _infoRow('TIN Number', org['tinNumber']),
              _infoRow('Date of Establishment', org['dateOfEstablishment']),
              _infoRow('Target', org['target']),
              _infoRow('Residence', org['residence']),
              _infoRow('State', org['state']),
              _infoRow('Zone', org['zone']),
              _infoRow('Sub City', org['subCity']),
              _infoRow('Woreda', org['woreda']),
              _infoRow('Branch', org['branch']),
              _infoRow('Currency', org['currency']),
              _infoRow('Account Type', org['accountType']?.toString()),
              _infoRow('Initial Deposit', org['initialDeposit']?.toString()),
              // _infoRow('Percentage Completed',
              //     org['percentageCompleted']?.toString()),
              // _infoRow('Letter of Request', org['letterOfRequest']),
              // _infoRow('Trade License', org['tradeLicense']),
              // _infoRow('Articles of Association', org['articlesOfAssociation']),
              const SizedBox(height: 24),
              Text('Authorized Signers( ${personalInfo.length})',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue)),
              const SizedBox(height: 8),
              if (personalInfo.isEmpty)
                Text('No authorized signers found')
              else
                ...personalInfo
                    .map<Widget>((person) => _personalInfoCard(person))
                    .toList(),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.email,
                    color: whiteColor,
                  ),
                  label: Text('Send Email'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => sendEmailToAuthorizedSigners(context),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value.toString())),
        ],
      ),
    );
  }

  Widget _personalInfoCard(Map person) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(person['fullName'] ?? '',
            //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

            _infoRow("Name:", person['fullName']),
            _infoRow('Surname', person['surname']),
            _infoRow('Mother Name', person['motherName']),
            _infoRow('Email', person['email']),
            _infoRow('Phone', person['phone']),
            _infoRow('Date of Birth', person['dateOfBirth']),
            _infoRow('Country', person['country']),
            _infoRow('State', person['state']),
            _infoRow('City', person['city']),
            _infoRow('Street Address', person['streetAddress']),
            _infoRow('Zip Code', person['zipCode']),
            _infoRow('Occupation', person['occupation']),
            _infoRow('Title', person['title']),
            _infoRow('Marital Status', person['maritalStatus']),
            _infoRow('Post Code', person['postCode']),
            _infoRow('Zone/SubCity', person['zoneSubCity']),
            _infoRow('House No', person['houseNo']),
            _infoRow('Document Name', person['documentName']),
            _infoRow('Issue Authority', person['issueAuthority']),
            _infoRow('Issue Date', person['issueDate']),
            _infoRow('Expiry Date', person['expiryDate']),
            _infoRow('Employee Status', person['employeeStatus']),
            _infoRow('Legal ID', person['legalId']),
            _infoRow('Salary', person['salary']),
            _infoRow('Sector', person['sector']),
            _infoRow('Industry', person['industry']),
            _infoRow('Employer Name', person['employerName']),
            _infoRow('Monthly Income', person['monthlyIncome']),
            _infoRow('Sex', person['sex']),
            // You can add more fields as needed
          ],
        ),
      ),
    );
  }
}
