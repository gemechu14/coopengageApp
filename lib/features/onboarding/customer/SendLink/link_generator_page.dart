/// Link Generator Page
/// Main UI for generating and sharing invitation links

import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/shared/widgets/text/custom_nav_heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/link_generator_models.dart';
import 'providers/link_generator_provider.dart';

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
  final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();

  AccountType _selectedAccountType = AccountType.individual;
  SharePlatform _selectedPlatform = SharePlatform.whatsapp;

  // Compact form styling to match smaller button sizing
  static const double _fieldFontSize = 13;
  static const EdgeInsets _fieldContentPadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  static const TextStyle _fieldLabelStyle = TextStyle(fontSize: _fieldFontSize);
  static const TextStyle _fieldHintStyle = TextStyle(fontSize: _fieldFontSize);

  String _normalizeToLocalPhone(String? raw) {
    if (raw == null) return '';
    // Keep digits only
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');

    // Convert +251 / 251 to local 0XXXXXXXXX
    if (digits.startsWith('251') && digits.length >= 12) {
      digits = '0${digits.substring(3)}';
    }

    // Ensure local prefix
    if (digits.startsWith('9') && digits.length == 9) {
      digits = '0$digits';
    }
    if (digits.startsWith('7') && digits.length == 9) {
      digits = '0$digits';
    }

    return digits;
  }

  Future<void> _pickPhoneFromContacts() async {
    try {
      // Ask permission (Android). iOS also needs Info.plist usage string.
      var status = await Permission.contacts.status;

      if (!status.isGranted) {
        // First time / not yet decided → show system permission dialog
        status = await Permission.contacts.request();
      }

      if (!status.isGranted) {
        if (mounted) {
          final message = status.isPermanentlyDenied
              ? 'Please enable Contacts permission in Settings to pick a phone number.'
              : 'Contacts permission is required to pick a phone number.';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
              action: status.isPermanentlyDenied
                  ? SnackBarAction(
                      label: 'OPEN SETTINGS',
                      onPressed: () {
                        openAppSettings();
                      },
                    )
                  : null,
            ),
          );
        }
        return;
      }

      final contact = await _contactPicker.selectPhoneNumber();
      if (contact == null) return;

      final picked = contact.selectedPhoneNumber ??
          (contact.phoneNumbers != null && contact.phoneNumbers!.isNotEmpty
              ? contact.phoneNumbers!.first
              : null);

      final normalized = _normalizeToLocalPhone(picked);
      if (normalized.isNotEmpty) {
        _phoneController.text = normalized;
      }

      // Optionally populate recipient name if empty
      final name = contact.fullName?.trim();
      if ((_nameController.text.trim().isEmpty) &&
          name != null &&
          name.isNotEmpty) {
        _nameController.text = name;
      }

      // Revalidate after autofill
      _formKey.currentState?.validate();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick contact: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Track if link has been generated to lock fields
  bool _isLinkGenerated = false;
  bool _isEmailSent = false; // Track if email was sent

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Validate phone number based on platform
  String? _validatePhone(String? value) {
    if (_selectedPlatform == SharePlatform.whatsapp ||
        _selectedPlatform == SharePlatform.telegram) {
      if (value == null || value.trim().isEmpty) {
        return 'Phone number is required for ${_selectedPlatform.displayName}';
      }
      final trimmed = value.trim();
      
      // During typing: only validate prefix, allow incomplete input
      if (trimmed.isNotEmpty && trimmed.length < 10) {
        // Check if first character is valid
        if (trimmed.length == 1 && trimmed != '0') {
          return 'Must start with 09 or 07';
        }
        // Check if first two characters are valid
        if (trimmed.length >= 2) {
          final prefix = trimmed.substring(0, 2);
          if (prefix != '09' && prefix != '07') {
            return 'Must start with 09 or 07';
          }
        }
        // If prefix is valid but not complete, allow it (will validate on submit)
        return null;
      }
      
      // Full validation for complete input (10 digits)
      if (trimmed.length == 10) {
        final regex = RegExp(r'^(09|07)\d{8}$');
        if (!regex.hasMatch(trimmed)) {
          return 'Must start with 09 or 07 and be exactly 10 digits';
        }
      } else if (trimmed.length > 10) {
        return 'Phone number must be exactly 10 digits';
      }
    }
    return null;
  }

  /// Validate email based on platform
  String? _validateEmail(String? value) {
    if (_selectedPlatform == SharePlatform.email) {
      if (value == null || value.trim().isEmpty) {
        return 'Email is required for EMAIL platform';
      }
      final trimmed = value.trim();
      final regex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      if (!regex.hasMatch(trimmed)) {
        return 'Enter a valid email address';
      }
    }
    return null;
  }

  /// Validate recipient name for email
  String? _validateNameForEmail(String? value) {
    if (_selectedPlatform == SharePlatform.email) {
      if (value == null || value.trim().isEmpty) {
        return 'Recipient name is required for EMAIL';
      }
    }
    return null;
  }

  /// Handle form submission
  Future<void> _onSubmit() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPlatform == SharePlatform.email) {
      // Handle email invitation (different API)
      await _handleEmailInvitation();
    } else {
      // Handle WhatsApp/Telegram (existing logic)
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
          _isLinkGenerated = true; // Also set this to lock fields
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email invitation sent successfully!'),
            backgroundColor: cyanblueColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(state.errorMessage ?? 'Failed to send email invitation'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Handle link generation (WhatsApp/Telegram)
  Future<void> _handleLinkGeneration() async {
    // Format phone number: remove first 0 and add +251
    String? formattedPhone;
    if (_phoneController.text.trim().isNotEmpty) {
      final phone = _phoneController.text.trim();
      // Remove first 0 if present and add +251
      if (phone.startsWith('0')) {
        formattedPhone = '+251${phone.substring(1)}';
      } else {
        formattedPhone = '+251$phone';
      }
    }

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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Social media shareable link generated successfully.'),
            backgroundColor: cyanblueColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // content: Text(state.errorMessage ?? 'Failed to generate link'),
            content: Text('Failed to generate or link already generated'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Copy link to clipboard
  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Share via platform-specific URL
  Future<void> _shareViaPlatform(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the app. Please try again.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening app: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(linkGeneratorProvider);

    return PopScope(
      canPop: true, // allows normal back navigation
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
                _buildFormCard(state),
                const SizedBox(height: 16),

                // Result Card (only for WhatsApp/Telegram, not Email)
                if (_isLinkGenerated && !_isEmailSent)
                  if (state.hasResult) _buildResultCard(state.result!),

                // Email Success Card
                if (_isEmailSent) _buildEmailSuccessCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build form card
  Widget _buildFormCard(LinkGeneratorState state) {
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
          key: _formKey,
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
              DropdownButtonFormField<AccountType>(
                value: _selectedAccountType,
                decoration: InputDecoration(
                  labelText: 'Account Type',
                  isDense: true,
                  contentPadding: _fieldContentPadding,
                  labelStyle: _fieldLabelStyle,
                  prefixIcon: const Icon(Icons.account_circle_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: false,
                ),
                items: AccountType.values.map((type) {
                  final displayName = type == AccountType.organization
                      ? 'CORPORATE'
                      : type.displayName;
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      displayName,
                      style: const TextStyle(fontSize: _fieldFontSize),
                    ),
                  );
                }).toList(),
                onChanged: (state.isLoading || _isLinkGenerated)
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedAccountType = value);
                        }
                      },
              ),
              const SizedBox(height: 16),

              // Platform Dropdown
              DropdownButtonFormField<SharePlatform>(
                value: _selectedPlatform,
                decoration: InputDecoration(
                  labelText: 'Platform',
                  isDense: true,
                  contentPadding: _fieldContentPadding,
                  labelStyle: _fieldLabelStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: false,
                ),
                items: SharePlatform.values.map((platform) {
                  return DropdownMenuItem(
                    value: platform,
                    child: Row(
                      children: [
                        Icon(platform.iconData,
                            color: platform.color, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          platform.displayName,
                          style: const TextStyle(fontSize: _fieldFontSize),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (state.isLoading || _isLinkGenerated)
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPlatform = value;
                            // Clear fields when platform changes
                            _phoneController.clear();
                            _emailController.clear();
                            _notesController.clear();
                          });
                          // Revalidate form
                          _formKey.currentState?.validate();
                        }
                      },
              ),
              const SizedBox(height: 16),

              // Recipient Name Field
              TextFormField(
                controller: _nameController,
                enabled: !state.isLoading && !_isLinkGenerated,
                decoration: InputDecoration(
                  labelText: _selectedPlatform == SharePlatform.email
                      ? 'Recipient Name *'
                      : 'Recipient Name (Optional)',
                  hintText: 'Enter recipient name',
                  isDense: true,
                  contentPadding: _fieldContentPadding,
                  labelStyle: _fieldLabelStyle,
                  hintStyle: _fieldHintStyle,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: false,
                ),
                textCapitalization: TextCapitalization.words,
                validator: _validateNameForEmail,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),

              // Phone Number Field
              if (_selectedPlatform == SharePlatform.whatsapp ||
                  _selectedPlatform == SharePlatform.telegram)
                TextFormField(
                  controller: _phoneController,
                  enabled: !state.isLoading && !_isLinkGenerated,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Phone Number*',
                    hintText: '09xxxxxxxx or 07xxxxxxxx',
                    isDense: true,
                    contentPadding: _fieldContentPadding,
                    labelStyle: _fieldLabelStyle,
                    hintStyle: _fieldHintStyle,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    suffixIcon: IconButton(
                      tooltip: 'Pick from contacts',
                      onPressed: (state.isLoading || _isLinkGenerated)
                          ? null
                          : _pickPhoneFromContacts,
                      icon: const Icon(
                        Icons.contacts_rounded,
                        color: cyanblueColor,
                        size: 20,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: false,
                  ),
                  validator: _validatePhone,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),

              // Email Field
              if (_selectedPlatform == SharePlatform.email) ...[
                TextFormField(
                  controller: _emailController,
                  enabled: !state.isLoading && !_isLinkGenerated,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address *',
                    hintText: 'example@email.com',
                    isDense: true,
                    contentPadding: _fieldContentPadding,
                    labelStyle: _fieldLabelStyle,
                    hintStyle: _fieldHintStyle,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: false,
                  ),
                  validator: _validateEmail,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),

                // Notes Field (Optional - for Email only)
                TextFormField(
                  controller: _notesController,
                  enabled: !state.isLoading && !_isLinkGenerated,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'e.g., High potential customer',
                    isDense: true,
                    contentPadding: _fieldContentPadding,
                    labelStyle: _fieldLabelStyle,
                    hintStyle: _fieldHintStyle,
                    // prefixIcon: const Icon(Icons.note_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: false,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Submit Button
              FilledButton.icon(
                onPressed:
                    (state.isLoading || _isLinkGenerated) ? null : _onSubmit,
                icon: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(_isLinkGenerated ? Icons.check_circle : Icons.link),
                label: Text(
                  state.isLoading
                      ? (_selectedPlatform == SharePlatform.email
                          ? 'Sending Email...'
                          : 'Generating...')
                      : _isLinkGenerated
                          ? (_isEmailSent ? 'Email Sent' : 'Link Generated')
                          : (_selectedPlatform == SharePlatform.email
                              ? 'Send Invitation'
                              : 'Generate Link'),
                  style: const TextStyle(fontSize: 13),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      _isLinkGenerated ? Colors.grey : cyanblueColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build result card
  Widget _buildResultCard(LinkGenerationResponse result) {
    final canShare = (_selectedPlatform == SharePlatform.whatsapp ||
            _selectedPlatform == SharePlatform.telegram) &&
        result.platformSpecificUrl != null &&
        result.platformSpecificUrl!.isNotEmpty;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Header
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: cyanblueColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Link Generated Successfully',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cyanblueColor,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Shareable Link Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shareable Link:',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    result.shareableLink,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // Copy Link Button
                FilledButton.icon(
                  onPressed: () => _copyToClipboard(result.shareableLink),
                  icon: const Icon(Icons.copy_all_outlined),
                  label: const Text('Copy Link'),
                  style: FilledButton.styleFrom(
                    backgroundColor: cyanblueColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // Share Button (conditional)
                if (canShare)
                  OutlinedButton.icon(
                    onPressed: () =>
                        _shareViaPlatform(result.platformSpecificUrl!),
                    icon: Icon(
                      _selectedPlatform.iconData,
                      color: _selectedPlatform.color,
                    ),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),

            // QR Code Section
            if (result.qrCodeUrl != null && result.qrCodeUrl!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'QR Code:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    result.qrCodeUrl!,
                    fit: BoxFit.contain,
                    height: 220,
                    width: 220,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 220,
                        width: 220,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Failed to load QR code'),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 220,
                        width: 220,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            // Message Section (if provided)
            // if (result.message != null && result.message!.isNotEmpty) ...[
            //   const SizedBox(height: 16),
            //   Container(
            //     padding: const EdgeInsets.all(12),
            //     decoration: BoxDecoration(
            //       color: Theme.of(context).colorScheme.primaryContainer,
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: Row(
            //       children: [
            //         Icon(
            //           Icons.info_outline,
            //           color: Theme.of(context).colorScheme.primary,
            //         ),
            //         const SizedBox(width: 12),
            //         Expanded(
            //           child: Text(
            //             result.message!,
            //             style: TextStyle(
            //               color:
            //                   Theme.of(context).colorScheme.onPrimaryContainer,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }

  /// Build email success card
  Widget _buildEmailSuccessCard() {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Header
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: cyanblueColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Email Sent Successfully',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cyanblueColor,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Success Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: cyanblueColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Invitation Email Sent',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'An invitation email has been sent to ${_emailController.text.trim()}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The recipient will receive the invitation link directly in their inbox.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),

            // Recipient Details
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Recipient:', _nameController.text.trim()),
                  const SizedBox(height: 8),
                  _buildDetailRow('Email:', _emailController.text.trim()),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                      'Account Type:', _selectedAccountType.displayName),
                  if (_notesController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow('Notes:', _notesController.text.trim()),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build detail row for email success card
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
