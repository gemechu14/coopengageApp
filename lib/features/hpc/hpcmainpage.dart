import 'package:coopengageplus/features/hpc/Dashboard/dashboard.dart';
import 'package:coopengageplus/features/hpc/presentation/profile/hpcProfile.dart';
import 'package:coopengageplus/pages/LoginPage.dart';
import 'package:coopengageplus/utils/language_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:google_nav_bar/google_nav_bar.dart';

class HPCMainPage extends StatefulWidget {
  const HPCMainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<HPCMainPage> {
  int currentState = 0;
  final storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding),
  );

  bool isLoading = true;
  String role = '';
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchToken();
  }

  Future<void> _fetchToken() async {
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      var decodedToken = JwtDecoder.decode(token);
      setState(() {
        role = decodedToken['role'][0];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _getCurrentWidget(int index) {
    switch (index) {
      case 0:
        return HPCDashBoard();

      case 1:
        return const HighClientProfilePage();
      default:
        return HPCDashBoard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: isLoading
          ? null // Hide bottom navigation bar while loading
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withOpacity(.1),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: GNav(
                  rippleColor: Colors.grey[300]!,
                  hoverColor: Colors.grey[100]!,
                  gap: 3,
                  activeColor: Color(0xFF2196F3),
                  iconSize: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor: Color(0xffD4F1F4),
                  color: Colors.black,
                  selectedIndex: currentState,
                  onTabChange: (index) {
                    setState(() {
                      currentState = index;
                    });
                    _pageController
                        .jumpToPage(index); // Move to the corresponding page
                  },
                  tabs: [
                    _buildGNavItem(Icons.home, translation(context).home, 0),
                    _buildGNavItem(
                        Icons.person_2, translation(context).profile, 0),
                  ],
                ),
              ),
            ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  return PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentState = index;
                      });
                    },
                    children: [
                      _getCurrentWidget(0),
                      _getCurrentWidget(1),
                    ],
                  );
                },
              ),
      ),
    );
  }

  GButton _buildGNavItem(IconData icon, String label, int index) {
    return GButton(
      icon: icon,
      text: label,
      onPressed: () {
        setState(() {
          currentState = index;
        });
        _pageController.jumpToPage(index); // Move to the corresponding page
      },
    );
  }

  // Logout method
  void logout() async {
    await storage.delete(key: "token");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }
}
