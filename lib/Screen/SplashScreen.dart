// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, use_super_parameters

// import 'dart:async';

// import 'package:flutter/material.dart';

// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:coopengageplus/Screen/LoginScreen.dart';
// import 'package:coopengageplus/crm/CRMMainScreen.dart';
// import 'package:coopengageplus/pages/MainPage.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   static const storage = FlutterSecureStorage();

//   bool isLoading = false;
//   @override
//   void initState() {
//     super.initState();

//     print("datae is called");
//     Timer(const Duration(seconds: 1), () async {
//       const storage = FlutterSecureStorage();
//       String? token = await storage.read(key: "token");

//       if (token != null) {
//         print("maindata");
//         Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
//         List<dynamic> roles = decodedToken['role'] ?? [];

//         if (roles!.contains("CRM")) {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => const MainPage()),
//           );
//         } else {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => const CRMMainScreen()),
//           );
//         }
//       } else {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const Loginscreen()),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: Colors.white,
//       body: Center(
//         child: Image.asset('assets/logo.png', width: 100, height: 100),
//       ),
//     );
//   }
// }
//   Future<void> _fetchToken() async {
//     String? token = await storage.read(key: "token");
//     if (token != null && token.isNotEmpty) {
//       var decodedToken = JwtDecoder.decode(token);
//       setState(() {
//         String role = decodedToken["role"][0];
//         isLoading = false;
//       });
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:coopengageplus/Screen/LoginScreen.dart';
// import 'package:coopengageplus/crm/CRMMainScreen.dart';
// import 'package:coopengageplus/pages/MainPage.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   static const storage = FlutterSecureStorage();
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _navigateBasedOnToken();
//   }

//   Future<void> _navigateBasedOnToken() async {
//     String? token = await storage.read(key: "token");

//     if (token != null && token.isNotEmpty) {
//           try {
//         Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
//         String? role = decodedToken['role'];
//         print(decodedToken);

//         if (role == 'CRM') {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => const CRMMainScreen()),
//           );
//         } else {
//           // Navigate to MainPage for other roles
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => const MainPage()),
//           );
//         }
//       } catch (e) {
//         // Handle token decode failure or invalid token
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const Loginscreen()),
//         );
//       }
//     } else {
//       // Navigate to LoginScreen if no token is found
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => const Loginscreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Image.asset('assets/engage+.png', width: 100, height: 100),
//       ),
//     );
//   }
// }

/////

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:coopengageplus/Screen/LoginScreen.dart';
// import 'package:coopengageplus/crm/CRMMainScreen.dart';
// import 'package:coopengageplus/pages/MainPage.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   static const storage = FlutterSecureStorage();
//   bool _isNavigating = false;

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Future.delayed(const Duration(milliseconds: 500), () {
//         _navigateBasedOnRole();
//       });
//     });
//     print("date12");
//     // _navigateBasedOnRole();
//   }

//   Future<void> _navigateBasedOnRole() async {
//     if (_isNavigating) return;
//     _isNavigating = true;

//     try {
//       String? token = await storage.read(key: "token");

//       print("Token check started");

//       if (token != null) {
//         print("Token received: $token");

//         // Decode the token to extract roles
//         Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
//         List<dynamic>? roles;

//         setState(() {
//           roles = decodedToken['role'] ?? [];
//         });

//         print("Roles extracted: $roles");
//         print("Is CRM: ${roles?.contains("CRM")}");

//         // Navigate based on the role
//         if (roles!.contains("CRM")) {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => const CRMMainScreen()),
//           );
//         } else {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => const MainPage()),
//           );
//         }
//       } else {
//         print("No token found, redirecting to Login");
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const Loginscreen()),
//         );
//       }
//     } catch (e) {
//       // Log and handle errors
//       debugPrint("Error navigating based on role: $e");
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => const Loginscreen()),
//       );
//     } finally {
//       _isNavigating = false; // Reset the flag after navigation
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Image.asset('assets/logo.png', width: 100, height: 100),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:coopengageplus/Screen/LoginScreen.dart';
import 'package:coopengageplus/features/crm/CRMMainScreen.dart';
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
        }
      } else {
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
