import 'package:flutter/material.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import '../models/link_generator_models.dart';
import '../providers/link_generator_provider.dart';
import 'account_type_dropdown.dart';
import 'platform_dropdown.dart';
import 'recipient_name_field.dart';
import 'phone_number_field.dart';
import 'email_field.dart';
import 'notes_field.dart';
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
  final bool isLinkGenerated;
  final bool isEmailSent;

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
    required this.isLinkGenerated, required this.isEmailSent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title (styled similar to profile cards)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cyanblueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.link_rounded,
                      color: cyanblueColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Link Generation Details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Account Type Dropdown
              AccountTypeDropdown(
                value: selectedAccountType,
                onChanged: onAccountTypeChanged,
                enabled: !state.isLoading && !isLinkGenerated,
              ),
              const SizedBox(height: 16),

              // Platform Dropdown
              PlatformDropdown(
                value: selectedPlatform,
                onChanged: onPlatformChanged,
                enabled: !state.isLoading && !isLinkGenerated,
                onPlatformChanged: () {
                  // Clear fields when platform changes
                  phoneController.clear();
                  emailController.clear();
                  notesController.clear();
                  formKey.currentState?.validate();
                },
              ),
              const SizedBox(height: 16),

              // Recipient Name Field
              RecipientNameField(
                controller: nameController,
                platform: selectedPlatform,
                enabled: !state.isLoading && !isLinkGenerated,
                formKey: formKey,
              ),
              const SizedBox(height: 16),

              // Phone Number Field (only for WhatsApp/Telegram)
              if (selectedPlatform == SharePlatform.whatsapp ||
                  selectedPlatform == SharePlatform.telegram)
                PhoneNumberField(
                  controller: phoneController,
                  platform: selectedPlatform,
                  enabled: !state.isLoading && !isLinkGenerated,
                  onPickContact: onPickContact,
                ),

              // Email Field (only for Email platform)
              if (selectedPlatform == SharePlatform.email) ...[
                EmailField(
                  controller: emailController,
                  enabled: !state.isLoading && !isLinkGenerated,
                ),
                const SizedBox(height: 16),

                // Notes Field (Optional - for Email only)
                NotesField(
                  controller: notesController,
                  enabled: !state.isLoading && !isLinkGenerated,
                ),
              ],
              const SizedBox(height: 24),

              // Submit Button
              SubmitButton(
                isLoading: state.isLoading,
                isLinkGenerated: isLinkGenerated,
                isEmailSent: isEmailSent,
                platform: selectedPlatform,
                onPressed: onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

