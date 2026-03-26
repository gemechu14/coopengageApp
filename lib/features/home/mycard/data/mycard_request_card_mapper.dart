import 'package:uuid/uuid.dart';

/// Picks branch code from DB/JWT/GlobalData branch maps (not numeric row [id]).
String branchCodeFromBranch(Map<String, dynamic> branch) {
  final v = branch['branchCode'] ??
      branch['code'] ??
      branch['branch_id'] ??
      branch['branchId'];
  if (v == null) return '';
  return '$v'.trim();
}

/// Builds prepaid card request JSON from API customer payload + picked branch.
Map<String, dynamic> buildRequestNewCardBody({
  required Map<String, dynamic> customerDetails,
  required Map<String, dynamic> branch,
  String? otpPhoneFallback,
  String? accountNumberFallback,
}) {
  final uuid = Uuid();
  var customerId = _pickCustomerId(customerDetails, accountNumberFallback);
  if (customerId.isEmpty) {
    final sub = customerDetails['customer'];
    if (sub is Map) {
      customerId = _pickCustomerId(
        Map<String, dynamic>.from(sub),
        accountNumberFallback,
      );
    }
  }
  final displayName =
      '${customerDetails['displayName'] ?? customerDetails['customerName'] ?? customerDetails['fullName'] ?? ''}'
          .trim();
  final firstName =
      '${customerDetails['firstName'] ?? displayName}'.trim().split(' ').first;
  final lastName = '${customerDetails['lastName'] ?? ''}'.trim();
  final last = lastName.isNotEmpty
      ? lastName
      : (displayName.contains(' ')
          ? displayName.split(' ').skip(1).join(' ')
          : displayName);

  final genderRaw = '${customerDetails['gender'] ?? 'MALE'}'.toUpperCase();
  final gender = genderRaw.startsWith('F') ? 'F' : 'M';

  final marital = '${customerDetails['maritalStatus'] ?? 'M'}';
  final maritalCode = marital.length == 1 ? marital : marital[0];

  final street = '${customerDetails['street'] ?? customerDetails['addressLine1'] ?? ''}'
      .trim();
  final town =
      '${customerDetails['townCountry'] ?? customerDetails['city'] ?? customerDetails['town'] ?? ''}'
          .trim();
  final addr = street.isNotEmpty ? street : town;

  final email =
      '${customerDetails['email'] ?? customerDetails['emailAddress'] ?? 'n/a@example.com'}'
          .trim();
  final phoneRaw = _rawPhone(customerDetails, otpPhoneFallback);

  final dob = _pickDateOfBirth(customerDetails);
  final bCode = branchCodeFromBranch(branch);

  return {
    'MsgUid': uuid.v4(),
    'CustomerCode': customerId,
    'Title': 'Mr',
    'FirstName': firstName.isNotEmpty ? firstName : displayName,
    'LastName': last.isNotEmpty ? last : firstName,
    'IdNumber': customerId,
    'DateOfBirth': dob,
    'MaritalStatus': maritalCode,
    'Gender': gender,
    'AddressLine1': addr.isNotEmpty ? addr : 'NA',
    'City': town.isNotEmpty ? town : 'NA',
    'PostalCode': _postal(customerDetails),
    'Region': town.isNotEmpty ? town : 'NA',
    'Phone1': _formatPhone(phoneRaw),
    'Email': email,
    'District': town.isNotEmpty ? town : 'NA',
    'CurrCode': '${customerDetails['currencyCode'] ?? '840'}',
    'BranchCode': "10104",
    'CardProduct': '${customerDetails['cardProduct'] ?? '402'}',
    'EmbossingName':
        displayName.isNotEmpty ? displayName : '$firstName $last'.trim(),
    'CustomerIdNumber': customerId,
    'ExtendedCustomerIdNumber': customerId,
  };
}

String _pickCustomerId(
  Map<String, dynamic> c,
  String? accountNumberFallback,
) {
  for (final key in [
    'customerId',
    'customerCode',
    'CustomerCode',
    'accountNumber',
    'accountId',
    'AccountNumber',
  ]) {
    final v = c[key];
    if (v != null && '$v'.trim().isNotEmpty) return '$v'.trim();
  }
  final fb = accountNumberFallback?.trim();
  return fb ?? '';
}

String _postal(Map<String, dynamic> c) {
  final raw =
      '${c['postalCode'] ?? c['postCode'] ?? ''}'.trim();
  if (raw.isEmpty) return '12345';
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  return digits.isNotEmpty ? digits : raw;
}

String _pickDateOfBirth(Map<String, dynamic> c) {
  for (final key in ['dateOfBirth', 'birthDate', 'dob', 'DateOfBirth']) {
    final v = c[key];
    if (v == null) continue;
    final s = '$v'.trim();
    if (s.isEmpty) continue;
    if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(s)) return s.substring(0, 10);
  }
  return '1980-01-01';
}

String _rawPhone(Map<String, dynamic> c, String? otpPhone) {
  final fromCustomer =
      '${c['phoneNumber'] ?? c['phone'] ?? c['mobile'] ?? ''}'.replaceAll(RegExp(r'\D'), '');
  if (fromCustomer.isNotEmpty) return fromCustomer;
  if (otpPhone != null && otpPhone.isNotEmpty) {
    return otpPhone.replaceAll(RegExp(r'\D'), '');
  }
  return '';
}

String _formatPhone(String digits) {
  if (digits.isEmpty) return '+251000000000';
  if (digits.startsWith('251')) return '+$digits';
  if (digits.length >= 9) return '+251${digits.substring(digits.length - 9)}';
  return '+$digits';
}
