import 'package:flutter/material.dart';

class PersonalInfoCardRiverpod extends StatelessWidget {
  final Map person;
  const PersonalInfoCardRiverpod({Key? key, required this.person}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(person['fullName'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
          ],
        ),
      ),
    );
  }
} 