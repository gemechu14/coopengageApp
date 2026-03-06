import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/phone_normalizer.dart';
import 'snackbar_helper.dart';

/// Contact picker helper
class ContactPickerHelper {
  final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();

  /// Pick phone number from contacts
  /// Returns a map with 'phone' and 'name' keys, or null if cancelled/error
  Future<Map<String, String>?> pickPhoneFromContacts(
    BuildContext context,
    GlobalKey<FormState>? formKey,
  ) async {
    try {
      // Always request permission directly on every click - this will show Allow/Deny dialog
      // whenever Android allows it (not permanently denied)
      // If already granted, request() returns granted immediately without showing dialog
      var status = await Permission.contacts.request();
      
      // If not granted, check if permanently denied
      if (!status.isGranted) {
        // Check if permanently denied (Android won't show dialog after 2 denials)
        final isPermanentlyDenied = await Permission.contacts.isPermanentlyDenied;
        
        if (isPermanentlyDenied) {
          // Permanently denied - show option to open Settings
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Contacts permission is required. Please enable it in Settings.',
                ),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'OPEN SETTINGS',
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              ),
            );
          }
        }
        // If not permanently denied, return null silently
        // User can click again and the dialog will appear again
        return null;
      }
      
      // Permission is granted at this point, proceed to contact picker
      final contact = await _contactPicker.selectPhoneNumber();
      if (contact == null) return null;

      final picked = contact.selectedPhoneNumber ??
          (contact.phoneNumbers != null && contact.phoneNumbers!.isNotEmpty
              ? contact.phoneNumbers!.first
              : null);

      final normalized = PhoneNormalizer.normalizeToLocalPhone(picked);
      final name = contact.fullName?.trim() ?? '';

      // Revalidate form after picking
      if (formKey?.currentState != null) {
        formKey!.currentState?.validate();
      }

      return {
        'phone': normalized,
        'name': name,
      };
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(
          context,
          'Failed to pick contact: ${e.toString()}',
        );
      }
      return null;
    }
  }
}

