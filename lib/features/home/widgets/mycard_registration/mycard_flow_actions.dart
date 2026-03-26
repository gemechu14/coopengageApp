/// Client-side MyCard flow actions. Replace with real HTTP calls when endpoints exist.
class MycardFlowActions {
  MycardFlowActions._();

  /// Simulates requesting an OTP for [accountNumber] (13 digits).
  static Future<void> sendOtp(String accountNumber) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    // TODO: POST …/mycard/send-otp { accountNumber }
  }

  /// Simulates OTP verification. Returns true when [otp] is a valid 6-digit code.
  static Future<bool> verifyOtp({
    required String accountNumber,
    required String otp,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final digits = otp.replaceAll(RegExp(r'\D'), '');
    return digits.length == 6;
  }
}
