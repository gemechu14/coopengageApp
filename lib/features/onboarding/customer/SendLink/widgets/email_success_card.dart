import 'package:coopengageplus/features/home/widgets/mycard_registration/mycard_registration_step_panel.dart';
import 'package:coopengageplus/features/merchant/widgets/merchant_mycard_form_fields.dart';
import 'package:flutter/material.dart';
import '../constants/form_styles.dart';
import '../models/link_generator_models.dart';

/// Email success content (used inside success modal)
class EmailSuccessContent extends StatelessWidget {
  final String recipientName;
  final String recipientEmail;
  final AccountType accountType;
  final String? notes;

  const EmailSuccessContent({
    super.key,
    required this.recipientName,
    required this.recipientEmail,
    required this.accountType,
    this.notes,
  });

  String get _accountTypeLabel {
    return accountType == AccountType.organization
        ? 'CORPORATE'
        : accountType.displayName;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'An invitation email has been sent to $recipientEmail',
          style: const TextStyle(
            fontSize: 13,
            color: FormStyles.muted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        MerchantFlowSubheading(
          accentColor: FormStyles.coopCyan,
          mutedColor: FormStyles.muted,
          title: 'Invitation summary',
          icon: Icons.summarize_outlined,
        ),
        const SizedBox(height: 8),
        MerchantFlowSummaryTile(
          accentColor: FormStyles.coopCyan,
          mutedColor: FormStyles.muted,
          label: 'Recipient',
          value: recipientName,
        ),
        MerchantFlowSummaryTile(
          accentColor: FormStyles.coopCyan,
          mutedColor: FormStyles.muted,
          label: 'Email',
          value: recipientEmail,
        ),
        MerchantFlowSummaryTile(
          accentColor: FormStyles.coopCyan,
          mutedColor: FormStyles.muted,
          label: 'Account type',
          value: _accountTypeLabel,
        ),
        if (notes != null && notes!.isNotEmpty)
          MerchantFlowSummaryTile(
            accentColor: FormStyles.coopCyan,
            mutedColor: FormStyles.muted,
            label: 'Notes',
            value: notes!,
          ),
      ],
    );
  }
}

/// @deprecated Use [EmailSuccessContent] inside [LinkFlowModal.showEmailSuccess].
class EmailSuccessCard extends StatelessWidget {
  final String recipientName;
  final String recipientEmail;
  final AccountType accountType;
  final String? notes;

  const EmailSuccessCard({
    super.key,
    required this.recipientName,
    required this.recipientEmail,
    required this.accountType,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return MycardFlowCard(
      accentColor: FormStyles.coopCyan,
      child: EmailSuccessContent(
        recipientName: recipientName,
        recipientEmail: recipientEmail,
        accountType: accountType,
        notes: notes,
      ),
    );
  }
}
