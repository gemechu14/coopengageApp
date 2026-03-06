/// Link Generator Page
/// Main UI for generating and sharing invitation links

import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/shared/widgets/text/custom_nav_heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/link_generator_models.dart';
import 'providers/link_generator_provider.dart';
import 'widgets/form_card.dart';
import 'widgets/link_result_card.dart';
import 'widgets/email_success_card.dart';
import 'helpers/contact_picker_helper.dart';
import 'helpers/snackbar_helper.dart';
import 'utils/phone_formatter.dart';

class LinkGeneratorPage extends ConsumerStatefulWidget {
  const LinkGeneratorPage({super.key});

  @override
  ConsumerState<LinkGeneratorPage> createState() => _LinkGeneratorPageState();
}

class _LinkGeneratorPageState extends ConsumerState<LinkGeneratorPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final ContactPickerHelper _contactPickerHelper = ContactPickerHelper();

  AccountType _selectedAccountType = AccountType.individual;
  SharePlatform _selectedPlatform = SharePlatform.whatsapp;

  // Track if link has been generated to lock fields
  bool _isLinkGenerated = false;
  bool _isEmailSent = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Handle contact picker
  Future<void> _handlePickContact() async {
    final result = await _contactPickerHelper.pickPhoneFromContacts(
      context,
      _formKey,
    );

    if (result != null) {
      if (result['phone']!.isNotEmpty) {
        _phoneController.text = result['phone']!;
      }

      // Optionally populate recipient name if empty
      if (_nameController.text.trim().isEmpty &&
          result['name'] != null &&
          result['name']!.isNotEmpty) {
        _nameController.text = result['name']!;
      }
    }
  }

  /// Handle form submission
  Future<void> _onSubmit() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPlatform == SharePlatform.email) {
      await _handleEmailInvitation();
    } else {
      await _handleLinkGeneration();
    }
  }

  /// Handle email invitation
  Future<void> _handleEmailInvitation() async {
    final emailRequest = EmailInvitationRequest(
      recipientEmail: _emailController.text.trim(),
      recipientName: _nameController.text.trim(),
      accountType: _selectedAccountType,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    // Call provider to send email
    await ref
        .read(linkGeneratorProvider.notifier)
        .sendEmailInvitation(emailRequest);

    // Check result and show appropriate message
    final state = ref.read(linkGeneratorProvider);
    if (mounted) {
      if (!state.hasError && !state.isLoading) {
        // Lock fields after successful email send
        setState(() {
          _isEmailSent = true;
          _isLinkGenerated = true;
        });

        SnackbarHelper.showSuccess(
          context,
          'Email invitation sent successfully!',
        );
      } else if (state.hasError) {
        SnackbarHelper.showError(
          context,
          state.errorMessage ?? 'Failed to send email invitation',
        );
      }
    }
  }

  /// Handle link generation (WhatsApp/Telegram)
  Future<void> _handleLinkGeneration() async {
    // Format phone number for API
    final formattedPhone = PhoneFormatter.formatForApi(_phoneController.text.trim());

    // Create request
    final request = LinkGenerationRequest(
      accountType: _selectedAccountType,
      platform: _selectedPlatform,
      recipientName: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      recipientPhone: formattedPhone,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
    );

    // Call provider to generate link
    await ref.read(linkGeneratorProvider.notifier).generateLink(request);

    // Check result and show appropriate message
    final state = ref.read(linkGeneratorProvider);
    if (mounted) {
      if (state.hasResult && !state.hasError) {
        // Lock fields after successful generation
        setState(() {
          _isLinkGenerated = true;
        });

        SnackbarHelper.showSuccess(
          context,
          'Social media shareable link generated successfully.',
        );
      } else if (state.hasError) {
        SnackbarHelper.showError(
          context,
          'Failed to generate or link already generated',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(linkGeneratorProvider);

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          backgroundColor: whiteColor,
          elevation: 0,
          title:  CustomNavHeading(
            text: 'Generate Link',
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: cyanblueColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Form Card
                FormCard(
                  formKey: _formKey,
                  selectedAccountType: _selectedAccountType,
                  selectedPlatform: _selectedPlatform,
                  nameController: _nameController,
                  phoneController: _phoneController,
                  emailController: _emailController,
                  notesController: _notesController,
                  onAccountTypeChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedAccountType = value);
                    }
                  },
                  onPlatformChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPlatform = value);
                    }
                  },
                  onPickContact: _handlePickContact,
                  onSubmit: _onSubmit,
                  state: state,
                  isLinkGenerated: _isLinkGenerated,
                  isEmailSent: _isEmailSent,
                ),
                const SizedBox(height: 16),

                // Result Card (only for WhatsApp/Telegram, not Email)
                if (_isLinkGenerated && !_isEmailSent)
                  if (state.hasResult)
                    LinkResultCard(
                      result: state.result!,
                      platform: _selectedPlatform,
                    ),

                // Email Success Card
                if (_isEmailSent)
                  EmailSuccessCard(
                    recipientName: _nameController.text.trim(),
                    recipientEmail: _emailController.text.trim(),
                    accountType: _selectedAccountType,
                    notes: _notesController.text.trim().isEmpty
                        ? null
                        : _notesController.text.trim(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
