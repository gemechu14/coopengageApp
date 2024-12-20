// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// ignore: unused_import
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/features/crm/presentation/dashboard/CRMDashboard.dart';
import 'package:coopengageplus/features/crm/presentation/notes/noteScreen.dart';
import 'package:coopengageplus/features/crm/presentation/schedule/Schedule.dart';
import 'package:coopengageplus/features/onboarding/Dashboard/Dashboard.dart';

import 'package:coopengageplus/features/onboarding/screens/profileScreen.dart';
import 'package:coopengageplus/pages/LoginPage.dart';

class CRMMainScreen extends StatefulWidget {
  const CRMMainScreen({Key? key}) : super(key: key);

  @override
  _CRMMainScreenState createState() => _CRMMainScreenState();
}

class _CRMMainScreenState extends State<CRMMainScreen> {
  int currentState = 0;
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        // backgroundColor: Colors.white10,
        height: MediaQuery.of(context).size.height * 0.08,
        destinations: [
          _buildBottomNavItem(Icons.home, 'Home', 0),
          _buildBottomNavItem(Icons.schedule, 'Schedule', 1),
          _buildBottomNavItem(Icons.notes, 'Notes', 2),
          _buildBottomNavItem(Icons.person_2, 'Profile', 3),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: _getCurrentWidget(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Method to get the current widget based on the currentState
  Widget _getCurrentWidget() {
    switch (currentState) {
      case 0:
        return CRMDashboard();

      case 1:
        return const Schedule();
      case 2:
        return const Notescreen();
      case 3:
        return const ProfileScreen();
      default:
        return Dashboard(onSettingsTap: () {
          setState(() {
            currentState = 2; // Switch to ProfileScreen
          });
        }); // Fallback
    }
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: Icon(icon),
          color: currentState == index ? Colors.blue : Colors.black,
          onPressed: () {
            setState(() {
              currentState = index;
            });
          },
          // iconSize: 25,
        ),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: currentState == index ? Colors.blue : Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  void logout() async {
    await storage.delete(key: "token");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }
}
