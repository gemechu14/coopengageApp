// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use, use_super_parameters
import 'package:coopengageplus/features/home/Dashboard/Dashboard.dart';
import 'package:coopengageplus/features/home/AccountOpeningHomePage.dart';
import 'package:coopengageplus/features/onboarding/customer/agent/AgentPage.dart';
import 'package:coopengageplus/features/onboarding/screens/profile/profileScreen.dart';
import 'package:coopengageplus/features/screens/LoginScreen.dart';
import 'package:coopengageplus/shared/services/session_manager.dart';
import 'package:coopengageplus/shared/widgets/BeautifulLoadingScreen.dart';
import 'package:coopengageplus/core/utils/language_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentState = 0;
  final storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );

  bool isLoading = true;
  bool isInitializing = true; // New state for preventing immediate component loading
  String role = '';
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    if (!SessionManager.instance.isActive) {
      SessionManager.instance.startSession();
    }

    _fetchToken();
  }

  Future<void> _fetchToken() async {
    String? token = await storage.read(key: "token");

    if (token != null && token.isNotEmpty) {
      try {
        var decodedToken = JwtDecoder.decode(token);
        role = decodedToken['role']?[0] ?? '';
      } catch (e) {
        print("MainPage: JWT decode error: $e");
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        isInitializing = false;
      });
    }
  }

  Widget _getCurrentWidget(int index) {
    switch (index) {
      case 0:
        return Dashboard(onSettingsTap: () {
          setState(() {
            currentState = 2;
            _pageController.jumpToPage(2);
          });
        });
      case 1:

        return AccountOnboardingScreen();
      case 2:
        if (role != 'AGENT') {
          return const AgentPage();
        } else {
          return const ProfileScreen();
        }

      case 3:
        return const ProfileScreen();
      default:
        return Dashboard(onSettingsTap: () {
          setState(() {
            currentState = 2;
            _pageController.jumpToPage(2); // Navigate to Agent Page
          });
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: (isLoading || isInitializing)
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
                padding: const EdgeInsets.all(10.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;

                    return GNav(
                      rippleColor: Colors.grey[300]!,
                      hoverColor: Colors.grey[100]!,
                      gap: 3,
                      activeColor: Color(0xFF2196F3),
                      iconSize: screenWidth < 400 ? 26 : 29, // Adjust icon size
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth < 400 ? 9 : 18,
                        vertical: screenWidth < 400 ? 8 : 12,
                      ),
                      duration: const Duration(milliseconds: 400),
                      tabBackgroundColor: Color(0xffD4F1F4),
                      color: Colors.black,
                      selectedIndex: currentState,
                      onTabChange: (index) {
                        setState(() {
                          currentState = index;
                        });
                        _pageController.jumpToPage(
                            index); // Move to the corresponding page
                      },
                      tabs: [
                        _buildGNavItem(
                            Icons.home, translation(context).home, 0),
                        _buildGNavItem(
                            Icons.assignment, translation(context).customer, 1),
                        // _buildGNavItem(
                        //     Icons.store, translation(context).merchant, 2),
                        if (role != 'AGENT')
                          _buildGNavItem(Icons.group, 'Agent', 2),
                        _buildGNavItem(Icons.person_2, 'Profile', 3),
                      ],
                    );
                  },
                ),
              ),
            ),
      body: SafeArea(
        child: (isLoading || isInitializing)
            ? const BeautifulLoadingScreenV2(
                message: 'Loading dashboard...',
                primaryColor: Color(0xFF2196F3),
                secondaryColor: Color(0xFF1976D2),
                size: 20.0,
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentState = index;
                      });
                    },
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _getCurrentWidget(0),
                      _getCurrentWidget(1),
                      _getCurrentWidget(2),
                      _getCurrentWidget(3),
                      // _getCurrentWidget(4),
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
        _pageController.jumpToPage(index);
      },
    );
  }

  void logout() async {
    await SessionManager.instance.endSession();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Loginscreen()),
        (route) => false,
      );
    }
  }
}
