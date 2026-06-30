import 'package:coopengageplus/features/home/widgets/mycard_registration/mycard_registration_step_panel.dart';
import 'package:coopengageplus/features/merchant/widgets/merchant_mycard_form_fields.dart';
import 'package:flutter/material.dart';
import '../constants/form_styles.dart';
import '../models/link_generator_models.dart';
import 'account_type_dropdown.dart';
import 'email_field.dart';
import 'notes_field.dart';
import 'phone_number_field.dart';
import 'platform_dropdown.dart';
import 'recipient_name_field.dart';
import 'submit_button.dart';

/// Main form card widget
class FormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final AccountType selectedAccountType;
  final SharePlatform selectedPlatform;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController notesController;
  final ValueChanged<AccountType?>? onAccountTypeChanged;
  final ValueChanged<SharePlatform?>? onPlatformChanged;
  final VoidCallback? onPickContact;
  final VoidCallback? onSubmit;
  final LinkGeneratorState state;

  const FormCard({
    super.key,
    required this.formKey,
    required this.selectedAccountType,
    required this.selectedPlatform,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.notesController,
    this.onAccountTypeChanged,
    this.onPlatformChanged,
    this.onPickContact,
    this.onSubmit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final fieldsEnabled = !state.isLoading;

    return MycardFlowCard(
      accentColor: FormStyles.coopCyan,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.link_rounded, color: FormStyles.coopCyan, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Link generation',
                  style: FormStyles.sectionTitleStyle,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Send an onboarding invitation via WhatsApp, Telegram, or email',
              style: FormStyles.sectionSubtitleStyle,
            ),
            const SizedBox(height: 14),
            // MerchantFlowSubheading(
            //   accentColor: FormStyles.coopCyan,
            //   mutedColor: FormStyles.muted,
            //   title: 'Account & platform',
            //   subtitle: 'Choose account type and delivery channel',
            //   icon: Icons.tune_outlined,
            // ),
            // const SizedBox(height: 10),
            AccountTypeDropdown(
              value: selectedAccountType,
              onChanged: onAccountTypeChanged,
              enabled: fieldsEnabled,
            ),
            const SizedBox(height: 12),
            PlatformDropdown(
              value: selectedPlatform,
              onChanged: onPlatformChanged,
              enabled: fieldsEnabled,
              onPlatformChanged: () {
                phoneController.clear();
                emailController.clear();
                notesController.clear();
                formKey.currentState?.validate();
              },
            ),
            const SizedBox(height: 16),
            // MerchantFlowSubheading(
            //   accentColor: FormStyles.coopCyan,
            //   mutedColor: FormStyles.muted,
            //   title: 'Recipient',
            //   subtitle: selectedPlatform == SharePlatform.email
            //       ? 'Name and email are required for email invitations'
            //       : 'Phone number is required; name is optional',
            //   icon: Icons.person_outline_rounded,
            // ),
            // const SizedBox(height: 12),
            RecipientNameField(
              controller: nameController,
              platform: selectedPlatform,
              enabled: fieldsEnabled,
              formKey: formKey,
            ),
            const SizedBox(height: 12),
            if (selectedPlatform == SharePlatform.whatsapp ||
                selectedPlatform == SharePlatform.telegram)
              PhoneNumberField(
                controller: phoneController,
                platform: selectedPlatform,
                enabled: fieldsEnabled,
                onPickContact: onPickContact,
              ),
            if (selectedPlatform == SharePlatform.email) ...[
              EmailField(
                controller: emailController,
                enabled: fieldsEnabled,
              ),
              const SizedBox(height: 12),
              NotesField(
                controller: notesController,
                enabled: fieldsEnabled,
              ),
            ],
            const SizedBox(height: 16),
            SubmitButton(
              isLoading: state.isLoading,
              platform: selectedPlatform,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
