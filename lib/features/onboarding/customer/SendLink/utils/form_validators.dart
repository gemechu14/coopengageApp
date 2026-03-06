import '../models/link_generator_models.dart';

/// Form validation utilities
class FormValidators {
  /// Validate phone number based on platform
  static String? validatePhone(String? value, SharePlatform platform) {
    if (platform == SharePlatform.whatsapp || platform == SharePlatform.telegram) {
      if (value == null || value.trim().isEmpty) {
        return 'Phone number is required for ${platform.displayName}';
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
  static String? validateEmail(String? value, SharePlatform platform) {
    if (platform == SharePlatform.email) {
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
  static String? validateNameForEmail(String? value, SharePlatform platform) {
    if (platform == SharePlatform.email) {
      if (value == null || value.trim().isEmpty) {
        return 'Recipient name is required for EMAIL';
      }
    }
    return null;
  }
}

