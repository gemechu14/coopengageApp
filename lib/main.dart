// ignore_for_file: avoid_print

import 'package:coopengageplus/Screen/LoginScreen.dart';
import 'package:coopengageplus/Screen/SplashScreen.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/pages/MainPage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
// import 'package:coopengageplus/Screen/LoginScreen.dart';
// import 'package:coopengageplus/Screen/SplashScreen.dart';
// import 'package:coopengageplus/features/hpc/hpcmainpage.dart';
// import 'package:coopengageplus/features/onboarding/marchent/DownloadAndPrintPage.dart';
// import 'package:coopengageplus/features/onboarding/marchent/marchentRegistration.dart';
// import 'package:coopengageplus/features/onboarding/marchent/presentation/MarchentRegistration.dart';
// import 'package:coopengageplus/features/onboarding/marchent/presentation/otpPage.dart';
// import 'package:coopengageplus/features/onboarding/screens/signatureScreen.dart';
// import 'package:coopengageplus/helper/databaseHelper.dart';
// import 'package:coopengageplus/pages/LoginPage.dart';
// import 'package:coopengageplus/pages/MainPage.dart';

import 'package:flutter/material.dart';
// import 'package:coopengageplus/service/newDta1.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

bool isOnline = true;

int? TOTALPENDING;
int? TOTALAPPROVED;
int? TOTALUNSETTLED;
int? TOTALINITIAL;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper dbHelper = DatabaseHelper();

  try {
    await dbHelper.database;
    await dbHelper.printTables();
  } catch (e) {
    print("Error initializing the database: $e");
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Customer Engage +',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      //   useMaterial3: true,
      // ),
      // home: SignatureScreen(),
      home: const SplashScreen(),
      // home: DownloadAndPrintPage(
      //   title: "Gemechu",
      // ),
      routes: {
        // "/crm": (context) => const CRMMainScreen(),
        '/home': (context) => const MainPage(),
        '/login': (context) => const Loginscreen(),
      },
      // localizationsDelegates: [
      //   AppLocalizations.delegate,
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: [
      //   Locale('en', ''),
      //   Locale('am', ''),
      // ],

      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''), // English
        Locale('am', ''), // Amharic
      ],
      locale: Locale('en', ''),
    );
  }
}
