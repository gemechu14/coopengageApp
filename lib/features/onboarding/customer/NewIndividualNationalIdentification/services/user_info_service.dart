import '../model/user_information.dart';
import '../providers/stepper_provider.dart';

/// Service to handle user information operations
class UserInfoService {
  
  /// Extracts user information from stepper state
  static UserInformation extractUserInfo(StepperState stepperState) {
    return UserInformation(
      authId: stepperState.authId,
      fullName: stepperState.fullName,
      email: stepperState.email,
      emailVerified: stepperState.emailVerified,
      phone: stepperState.authPhone,
      state: stepperState.state,
      country: stepperState.country,
      sex: stepperState.sex,
      status: stepperState.status,
      dateOfBirth: stepperState.dateOfBirth,
      customerType: stepperState.customerType,
      legalId: stepperState.legalId,
      percentageComplete: stepperState.percentageComplete,
      createdAt: stepperState.createdAt,
      updatedAt: stepperState.updatedAt,
      accountId: stepperState.accountId,
    );
  }

  /// Formats date string for display
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Not provided';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  /// Formats boolean for display
  static String formatBoolean(bool? value) {
    if (value == null) return 'Not provided';
    return value ? 'Yes' : 'No';
  }

  /// Formats percentage for display
  static String formatPercentage(double? percentage) {
    if (percentage == null) return 'Not available';
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Checks if user info is complete enough for display
  static bool hasMinimumInfo(UserInformation userInfo) {
    return userInfo.fullName != null || 
           userInfo.email != null || 
           userInfo.authId != null;
  }

  /// Gets user info summary for quick display
  static String getUserSummary(UserInformation userInfo) {
    final parts = <String>[];
    
    if (userInfo.fullName != null) {
      parts.add(userInfo.fullName!);
    }
    
    if (userInfo.email != null) {
      parts.add(userInfo.email!);
    }
    
    if (userInfo.state != null) {
      parts.add(userInfo.state!);
    }
    
    return parts.isEmpty ? 'User Information' : parts.join(' • ');
  }
} 