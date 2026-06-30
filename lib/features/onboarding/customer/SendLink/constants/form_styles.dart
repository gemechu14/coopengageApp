import 'package:flutter/material.dart';

/// Form styling constants aligned with merchant registration flow.
class FormStyles {
  static const Color coopCyan = Color(0xFF00AEEF);
  static const Color muted = Color(0xFF64748B);

  static const double fieldFontSize = 13;
  static const EdgeInsets fieldContentPadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  static const TextStyle fieldLabelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Color(0xFF334155),
  );
  static const TextStyle fieldHintStyle = TextStyle(fontSize: fieldFontSize);

  static TextStyle sectionTitleStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: Colors.blueGrey.shade900,
  );

  static TextStyle sectionSubtitleStyle = const TextStyle(
    fontSize: 11.5,
    color: muted,
    height: 1.3,
  );
}
