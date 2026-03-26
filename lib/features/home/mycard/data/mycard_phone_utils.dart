/// Normalizes phone strings from Soufle for OTP APIs (digits; `09…` → `2519…`).
String normalizeMycardPhone(String raw) {
  final trimmed = raw.trim();
  final d = trimmed.replaceAll(RegExp(r'\D'), '');
  if (d.isEmpty) return trimmed;
  if (d.startsWith('251') && d.length >= 12) return d;
  if (d.startsWith('0') && d.length >= 10) return '251${d.substring(1)}';
  return d;
}
