import 'package:email_validator/email_validator.dart';

class ValidationUtils {
  static bool isValidEmail(String email) {
    return EmailValidator.validate(email);
  }

  static bool isValidPhoneNumber(String phone) {
    // Ethiopian phone number format: 9 digits starting with 9
    final phoneRegex = RegExp(r'^9\d{8}$');
    return phoneRegex.hasMatch(phone);
  }

  static bool isValidAge(String dateOfBirth) {
    try {
      final birthDate = DateTime.parse(dateOfBirth);
      var age = DateTime.now().year - birthDate.year;
      if (DateTime.now().month < birthDate.month ||
          (DateTime.now().month == birthDate.month &&
              DateTime.now().day < birthDate.day)) {
        age--;
      }
      return age >= 18 && age <= 100;
    } catch (e) {
      return false;
    }
  }

  static bool isValidInitialDeposit(String amount) {
    try {
      final deposit = double.parse(amount);
      return deposit >= 100; // Minimum deposit amount
    } catch (e) {
      return false;
    }
  }

  static bool isValidDocumentNumber(String documentNumber) {
    // Add specific validation rules for different document types
    return documentNumber.length >= 5;
  }

  static bool isValidIssueDate(String issueDate) {
    try {
      final date = DateTime.parse(issueDate);
      return date.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  static bool isValidExpiryDate(String expiryDate, String issueDate) {
    try {
      final expiry = DateTime.parse(expiryDate);
      final issue = DateTime.parse(issueDate);
      return expiry.isAfter(issue) && expiry.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateTitleGender(String title, String gender) {
    final Map<String, String> titleGenderMap = {
      'MR': 'MALE',
      'MRS': 'FEMALE',
      'MS': 'FEMALE',
      'MISS': 'FEMALE',
      'DR': 'BOTH',
    };

    if (title == 'DR') {
      return null;
    }

    if (titleGenderMap[title] != gender && titleGenderMap[title] != 'BOTH') {
      return 'Invalid title for selected gender';
    }

    return null;
  }
}
