// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unrelated_type_equality_checks

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coopengageplus/features/screens/LoginScreen.dart';
import 'package:coopengageplus/features/crm/CRMMainScreen.dart';
import 'package:coopengageplus/features/home/main_page.dart';
import 'package:coopengageplus/shared/services/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateBasedOnRole();
  }

  Future<void> _navigateBasedOnRole() async {
    try {
      const storage = FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
          storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
        ),
      );
      String? token = await storage.read(key: "token");
      var connectivityResult = await Connectivity().checkConnectivity();
      bool isOnline = connectivityResult != ConnectivityResult.none;

      if (token != null && token.isNotEmpty) {
        if (isOnline && JwtDecoder.isExpired(token)) {
          await SessionManager.instance.endSession();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Loginscreen()),
          );
          return;
        }

        SessionManager.instance.startSession();

        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        List<dynamic> roles = decodedToken['role'] ?? [];

        if (roles.contains("CRM")) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const CRMMainScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        }
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Loginscreen()),
        );
      }
    } catch (e) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Loginscreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/coop_engage.png', width: 100, height: 100),
      ),
    );
  }
}
