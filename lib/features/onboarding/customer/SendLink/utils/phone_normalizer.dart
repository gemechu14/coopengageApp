/// Phone number normalization utilities
class PhoneNormalizer {
  /// Normalize phone number to local format (09xxxxxxxx or 07xxxxxxxx)
  static String normalizeToLocalPhone(String? raw) {
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
}

