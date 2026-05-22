class QrPurposeOption {
  const QrPurposeOption({required this.value, required this.label});

  final String value;
  final String label;
}

/// EMV tag 62.08 — static list from MERCHANT_REGISTRATION_MOBILE.md
const List<QrPurposeOption> merchantQrPurposeOptions = [
  QrPurposeOption(value: 'ONLPUR', label: 'Online Purchase'),
  QrPurposeOption(value: 'SALA', label: 'Salary Payments'),
  QrPurposeOption(value: 'GOVTP', label: 'Government Payments'),
  QrPurposeOption(value: 'AIRTK', label: 'Airline Tickets'),
  QrPurposeOption(value: 'BCLUB', label: 'Bars and Clubs'),
  QrPurposeOption(value: 'BUSTP', label: 'Bus Ticket Purchase'),
  QrPurposeOption(value: 'EDUPT', label: 'Education'),
  QrPurposeOption(value: 'ENTMT', label: 'Entertainment and Recreation'),
  QrPurposeOption(value: 'FOREX', label: 'Forex Payments'),
  QrPurposeOption(value: 'GAMBL', label: 'Gambling'),
  QrPurposeOption(value: 'GIFTS', label: 'Gift Shops'),
  QrPurposeOption(value: 'GROCS', label: 'Grocery Stores'),
  QrPurposeOption(value: 'HLTHS', label: 'Health and Beauty Spas'),
  QrPurposeOption(value: 'HOSPT', label: 'Hospital'),
  QrPurposeOption(value: 'LOANP', label: 'Loan Payments'),
  QrPurposeOption(value: 'PETSP', label: 'Pet Shops'),
  QrPurposeOption(value: 'PHARM', label: 'Pharmacy'),
  QrPurposeOption(value: 'RETNTP', label: 'Restaurants and Cafes'),
  QrPurposeOption(value: 'RIDES', label: 'Ride Sharing'),
  QrPurposeOption(value: 'STOFS', label: 'Office Supplies'),
  QrPurposeOption(value: 'TRNST', label: 'Transport Tickets'),
  QrPurposeOption(value: 'UTSBP', label: 'Utilities Bill Payments'),
];

const String defaultQrPurposeCode = 'ENTMT';

List<QrPurposeOption> searchQrPurposeOptions(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return merchantQrPurposeOptions;
  return merchantQrPurposeOptions.where((o) {
    return o.value.toLowerCase().contains(q) ||
        o.label.toLowerCase().contains(q);
  }).toList();
}

bool isValidQrPurposeCode(String code) {
  return merchantQrPurposeOptions.any((o) => o.value == code);
}

QrPurposeOption? qrPurposeByValue(String? code) {
  if (code == null || code.isEmpty) return null;
  for (final o in merchantQrPurposeOptions) {
    if (o.value == code) return o;
  }
  return null;
}
