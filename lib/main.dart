
import 'dart:io';

import 'package:coopengageplus/core/network/http_overrides.dart';
import 'package:coopengageplus/core/l10n/app_localizations.dart';
import 'package:coopengageplus/features/screens/LoginScreen.dart';
import 'package:coopengageplus/features/screens/SplashScreen.dart';
// import 'package:coopengageplus/core/database/database_helper.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/features/home/main_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:device_preview/device_preview.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

bool isOnline = true;

int? TOTALPENDING;
int? TOTALAPPROVED;
int? TOTALUNSETTLED;
int? TOTALINITIAL;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // DatabaseHelper dbHelper = DatabaseHelper();

  HttpOverrides.global = MyHttpOverrides();
  String initialLanguage = 'en';
  // try {
  //   await dbHelper.database;
  //   await dbHelper.printTables();
  //   initialLanguage = await dbHelper.getSelectedLanguage();
  // } catch (e) {
  //   print("Error initializing the database: $e");
  // }
  SystemChrome.setSystemUIOverlayStyle(systemUiForLightBackground);
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
      useInheritedMediaQuery: true, 
      locale: DevicePreview.locale(context), 
      builder: DevicePreview.appBuilder, 
      navigatorKey: navigatorKey,

      home: const SplashScreen(),
//
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
