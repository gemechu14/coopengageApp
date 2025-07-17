import 'package:flutter/material.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:coopengageplus/common_widgets/dropDown/DatePickerField.dart';

class IDInfoSection extends StatelessWidget {
  final TextEditingController legalIDController;
  final TextEditingController issueAuthorityController;
  final TextEditingController issueDateController;
  final TextEditingController expireDateController;

  const IDInfoSection({
    Key? key,
    required this.legalIDController,
    required this.issueAuthorityController,
    required this.issueDateController,
    required this.expireDateController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Legal ID'),
        ReusableTextFormField(
          hintText: "Legal ID",
          controller: legalIDController,
          errorMessage: "Legal ID cannot be empty",
          leadingIcon: Icons.badge,
          isRequired: true,
        ),
        Text('ISSUE AUTHORITY'),
        ReusableTextFormField(
          hintText: "ISSUE AUTHORITY",
          controller: issueAuthorityController,
          errorMessage: "ISSUE AUTHORITY cannot be empty",
          leadingIcon: Icons.verified,
          isRequired: false,
        ),
        Text('ISSUE DATE'),
        DatePickerField(
          controller: issueDateController,
          hintText: 'Issue Date',
          prefixIcon: Icons.calendar_today,
          initialDate: DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365 * 15)),
          lastDate: DateTime.now(),
          isRequired: false,
          errorMessage: 'Please select an issue date',
        ),
        Text('EXPIRY DATE'),
        DatePickerField(
          controller: expireDateController,
          hintText: 'Expire Date',
          prefixIcon: Icons.event_busy,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 12)),
          isRequired: false,
          errorMessage: 'Please select an expire date',
        ),
      ],
    );
  }
} 