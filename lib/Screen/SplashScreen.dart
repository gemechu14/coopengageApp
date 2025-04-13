import 'dart:async';
import 'package:coopengageplus/Screen/LoginScreen.dart';
import 'package:coopengageplus/features/crm/CRMMainScreen.dart';
import 'package:coopengageplus/features/onboarding/jointaccount/homepage.dart';
import 'package:coopengageplus/pages/MainPage.dart';
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
      const storage = FlutterSecureStorage();
      String? token = await storage.read(key: "token");

      if (token != null) {
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
          // Navigator.of(context).pushReplacement(
          //   MaterialPageRoute(builder: (context) => AccountOpeningHomePage()),
          // );
        }
      } else {
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (context) => MainPage()),
        // );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Loginscreen()),
        );
      }
    } catch (e) {
      print("Error during navigation: $e");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Loginscreen()),
      );
    }
  }

//   }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/coop_engage.png', width: 100, height: 100),
      ),
    );
  }
}
