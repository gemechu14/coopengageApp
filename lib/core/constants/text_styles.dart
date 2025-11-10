import 'package:coopengageplus/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';

TextStyle get subHeadingStyle {
  return GoogleFonts.lato(
      textStyle:
          const TextStyle(fontSize: Sizes.p18, fontWeight: FontWeight.bold));
}

TextStyle get headingStyle {
  return GoogleFonts.lato(
      textStyle:
          const TextStyle(fontSize: Sizes.p30, fontWeight: FontWeight.bold));
}

TextStyle get subSubheadingStyle {
  return GoogleFonts.lato(
      textStyle:
          const TextStyle(fontSize: Sizes.p14, fontWeight: FontWeight.w500));
}

TextStyle get titleStyle {
  return GoogleFonts.lato(
      textStyle: const TextStyle(
          fontSize: Sizes.p14, fontWeight: FontWeight.w400, color: blackColor));
}

TextStyle get subtitleStyle {
  return GoogleFonts.lato(
      textStyle: const TextStyle(
          fontSize: Sizes.p12,
          fontWeight: FontWeight.w400,
          color: Colors.grey));
}

TextStyle get nameStyle {
  return GoogleFonts.lato(
      textStyle: const TextStyle(
          fontSize: Sizes.p14, fontWeight: FontWeight.w400, color: blackColor));
}

TextStyle get linkStyle {
  return GoogleFonts.lato(
      textStyle: const TextStyle(
          fontSize: Sizes.p12,
          fontWeight: FontWeight.w600,
          color: primaryBlue));
}

TextStyle get sectionTitleStyle {
  return const TextStyle(
    fontSize: Sizes.p18,
    fontWeight: FontWeight.w600,
    fontFamily: "Gilroy Medium",
    color: Color.fromARGB(150, 0, 0, 0),
  );
}
