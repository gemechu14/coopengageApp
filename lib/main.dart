// // ignore_for_file: avoid_print, non_constant_identifier_names

// import 'dart:io';

// import 'package:coopengageplus/HttpOverrides.dart';
// import 'package:coopengageplus/Screen/LoginScreen.dart';
// import 'package:coopengageplus/Screen/SplashScreen.dart';
// import 'package:coopengageplus/helper/databaseHelper.dart';
// import 'package:coopengageplus/pages/MainPage.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:get/get.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// bool isOnline = true;

// int? TOTALPENDING;
// int? TOTALAPPROVED;
// int? TOTALUNSETTLED;
// int? TOTALINITIAL;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DatabaseHelper dbHelper = DatabaseHelper();

//   HttpOverrides.global = MyHttpOverrides();
//   String initialLanguage = 'en';
//   try {
//     await dbHelper.database;
//     await dbHelper.printTables();
//     initialLanguage = await dbHelper.getSelectedLanguage();
//   } catch (e) {
//     print("Error initializing the database: $e");
//   }
//   runApp(ProviderScope(child: MyApp(initialLanguage: initialLanguage)));
// }

// class MyApp extends StatelessWidget {
//   final String initialLanguage;

//   const MyApp({Key? key, required this.initialLanguage}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Customer Engage +',
//       debugShowCheckedModeBanner: false,

//       home: const SplashScreen(),

//       routes: {
//         '/home': (context) => const MainPage(),
//         '/login': (context) => const Loginscreen(),
//       },

//       localizationsDelegates: [
//         AppLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: [
//         Locale('en', ''), // English
//         Locale('am', ''), // Amharic
//         Locale('or', ''), // Amharic
//       ],
//       locale: Locale(initialLanguage),
//       // locale: Locale('en'),
//     );
//   }
// }

// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:io';

import 'package:coopengageplus/HttpOverrides.dart';
import 'package:coopengageplus/Screen/LoginScreen.dart';
import 'package:coopengageplus/Screen/SplashScreen.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/pages/MainPage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:device_preview/device_preview.dart'; // <-- Added

bool isOnline = true;

int? TOTALPENDING;
int? TOTALAPPROVED;
int? TOTALUNSETTLED;
int? TOTALINITIAL;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper dbHelper = DatabaseHelper();

  HttpOverrides.global = MyHttpOverrides();
  String initialLanguage = 'en';
  try {
    await dbHelper.database;
    await dbHelper.printTables();
    initialLanguage = await dbHelper.getSelectedLanguage();
  } catch (e) {
    print("Error initializing the database: $e");
  }
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Global transparent status bar
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(
    ProviderScope(
      child: MyApp(initialLanguage: initialLanguage),
    ),

    // runApp(
    //   DevicePreview(
    //     enabled: true, // set false in production
    //     builder: (context) => ProviderScope(
    //       child: MyApp(initialLanguage: initialLanguage),
    //     ),
    //   ),
  );
}

class MyApp extends StatelessWidget {
  final String initialLanguage;

  const MyApp({Key? key, required this.initialLanguage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Customer Engage +',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true, // <-- Important for Device Preview
      locale: DevicePreview.locale(context), // <-- Use preview locale
      builder: DevicePreview.appBuilder, // <-- Wraps the app

      home: const SplashScreen(),

      routes: {
        '/home': (context) => const MainPage(),
        '/login': (context) => const Loginscreen(),
      },

      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''), // English
        Locale('am', ''), // Amharic
        Locale('or', ''), // Oromo
      ],
    );
  }
}
