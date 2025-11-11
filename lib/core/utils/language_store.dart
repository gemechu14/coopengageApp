import 'dart:ui';
import 'package:coopengageplus/core/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';


const String English = 'en';
const String Amharic = 'am';
const String Oromifa = 'om';



Locale _locale(String lang) {
  Locale _temp;
  switch (lang) {
    case English:
      return Locale(English, 'US');
    // _temp = Locale(lang, 'US');
    // break;
    case Amharic:
      return Locale(Amharic, "ET");
    case Oromifa:
      return Locale(Oromifa, "ET");
    // _temp = Locale(lang, 'IN');
    // break;
    default:
      _temp = Locale(English, 'US');
  }

  return _temp;
}

AppLocalizations translation(BuildContext context) {
  return AppLocalizations.of(context)!;
}
  // static void getLanguagePref(String langPref) async {
  //   return box.read('langPref') == null ? 'en' : box.read('langPref');
  // }