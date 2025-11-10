import 'package:flutter/material.dart';
import 'package:coopengageplus/shared/widgets/ReusableTextFormField.dart';
import 'package:coopengageplus/shared/widgets/dropDown/DatePickerField.dart';

class IDInfoSection extends StatelessWidget {
  final TextEditingController legalIDController;
  final TextEditingController issueAuthorityController;
  final TextEditingController issueDateController;
  final TextEditingController expireDateController;
  final ValueChanged<String>? onLegalIdChanged;
  final ValueChanged<String>? onIssueAuthorityChanged;
  final ValueChanged<String>? onIssueDateChanged;
  final ValueChanged<String>? onExpireDateChanged;

  const IDInfoSection({
    Key? key,
    required this.legalIDController,
    required this.issueAuthorityController,
    required this.issueDateController,
    required this.expireDateController,
    this.onLegalIdChanged,
    this.onIssueAuthorityChanged,
    this.onIssueDateChanged,
    this.onExpireDateChanged,
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
          onChanged: onLegalIdChanged,
        ),
        Text('ISSUE AUTHORITY'),
        ReusableTextFormField(
          hintText: "ISSUE AUTHORITY",
          controller: issueAuthorityController,
          errorMessage: "ISSUE AUTHORITY cannot be empty",
          leadingIcon: Icons.verified,
          isRequired: false,
          onChanged: onIssueAuthorityChanged,
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
          // DatePickerField does not support onChanged, so add a listener in parent if needed
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
          // DatePickerField does not support onChanged, so add a listener in parent if needed
        ),
      ],
    );
  }
} 