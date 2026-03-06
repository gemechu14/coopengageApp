/// Phone number formatting utilities for API
class PhoneFormatter {
  /// Format phone number for API: remove first 0 and add +251
  static String? formatForApi(String? phone) {
    if (phone == null || phone.trim().isEmpty) return null;
    
    final trimmed = phone.trim();
    // Remove first 0 if present and add +251
    if (trimmed.startsWith('0')) {
      return '+251${trimmed.substring(1)}';
    } else {
      return '+251$trimmed';
    }
  }
}

