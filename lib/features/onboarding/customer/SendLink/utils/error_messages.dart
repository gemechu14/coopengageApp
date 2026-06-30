/// Maps API / technical errors to formal user-facing messages.
class LinkFlowErrorMessages {
  LinkFlowErrorMessages._();

  static String forLinkGeneration(String? rawError) {
    if (_isDuplicate(rawError)) {
      return 'An invitation link has already been generated using this phone number. '
          'Please use a different number or contact your branch for assistance.';
    }
    if (_isNetwork(rawError)) {
      return 'We could not reach the server. Please check your internet connection and try again.';
    }
    if (_isAuth(rawError)) {
      return 'Your session has expired. Please sign in again and try once more.';
    }
    if (_isPermission(rawError)) {
      return 'You do not have permission to perform this action. Please contact your branch administrator.';
    }
    return 'We were unable to generate the invitation link. Please verify the recipient details and try again.';
  }

  static String forEmailInvitation(String? rawError) {
    if (_isDuplicate(rawError)) {
      return 'An invitation has already been sent to this email address. '
          'Please use a different email or contact your branch for assistance.';
    }
    if (_isNetwork(rawError)) {
      return 'We could not reach the server. Please check your internet connection and try again.';
    }
    if (_isAuth(rawError)) {
      return 'Your session has expired. Please sign in again and try once more.';
    }
    if (_isPermission(rawError)) {
      return 'You do not have permission to perform this action. Please contact your branch administrator.';
    }
    return 'We were unable to send the email invitation. Please verify the recipient details and try again.';
  }

  static bool _isDuplicate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return false;
    final lower = raw.toLowerCase();
    return lower.contains('already') ||
        lower.contains('exist') ||
        lower.contains('duplicate') ||
        lower.contains('generated');
  }

  static bool _isNetwork(String? raw) {
    if (raw == null) return false;
    final lower = raw.toLowerCase();
    return lower.contains('internet') ||
        lower.contains('connection') ||
        lower.contains('network') ||
        lower.contains('timeout') ||
        lower.contains('reach the server');
  }

  static bool _isAuth(String? raw) {
    if (raw == null) return false;
    final lower = raw.toLowerCase();
    return lower.contains('unauthorized') ||
        lower.contains('login') ||
        lower.contains('session') ||
        lower.contains('401');
  }

  static bool _isPermission(String? raw) {
    if (raw == null) return false;
    final lower = raw.toLowerCase();
    return lower.contains('permission') || lower.contains('403');
  }
}
