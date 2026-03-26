class SendOtpResult {
  const SendOtpResult({required this.phoneNumber, required this.message});

  final String phoneNumber;
  final String message;

  static String _pickPhone(Map<String, dynamic> j) {
    for (final key in [
      'phoneNumber',
      'phone',
      'mobile',
      'msisdn',
      'mobileNumber',
    ]) {
      final v = j[key];
      if (v != null && '$v'.trim().isNotEmpty) return '$v'.trim();
    }
    return '';
  }

  factory SendOtpResult.fromJson(Map<String, dynamic> j) {
    var phone = _pickPhone(j);
    if (phone.isEmpty) {
      final data = j['data'];
      if (data is Map) {
        phone = _pickPhone(Map<String, dynamic>.from(data));
      }
    }
    return SendOtpResult(
      phoneNumber: phone,
      message: '${j['message'] ?? j['msg'] ?? ''}',
    );
  }
}

class CustomerInfoResult {
  const CustomerInfoResult({required this.customerDetails});

  final Map<String, dynamic> customerDetails;

  factory CustomerInfoResult.fromJson(Map<String, dynamic> j) {
    final raw = j['customerDetails'];
    if (raw is Map<String, dynamic>) {
      return CustomerInfoResult(customerDetails: raw);
    }
    final data = j['data'];
    if (data is Map) {
      final inner = data['customerDetails'];
      if (inner is Map<String, dynamic>) {
        return CustomerInfoResult(customerDetails: inner);
      }
      if (inner is Map) {
        return CustomerInfoResult(
          customerDetails: Map<String, dynamic>.from(inner),
        );
      }
    }
    return const CustomerInfoResult(customerDetails: {});
  }
}
