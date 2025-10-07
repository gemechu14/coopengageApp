// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use, use_super_parameters
import 'package:coopengageplus/HomePage/Dashboard/Dashboard.dart';
import 'package:coopengageplus/HomePage/AccountOpeningHomePage.dart';
// import 'package:coopengageplus/features/onboarding/_IndividualAccount/screens/registration_screen.dart';
import 'package:coopengageplus/customerOnboarding/agent/AgentPage.dart';
// import 'package:coopengageplus/features/onboarding/HomePage/homepage.dart';
import 'package:coopengageplus/features/onboarding/screens/profileScreen.dart';
import 'package:coopengageplus/pages/LoginPage.dart';
import 'package:coopengageplus/utils/language_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/services/token_service.dart';

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
  String role = '';
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchToken();
    // Initialize token monitoring
    _initializeTokenService();
  }

  Future<void> _initializeTokenService() async {
    // Initialize token service for automatic logout on expiration
    await TokenService.initialize();
  }

  Future<void> _fetchToken() async {
    String? token = await storage.read(key: "token");


    print("MainPage: Token found: ${token != null ? 'Yes' : 'No'}");

    print(token);
    
    if (token != null && token.isNotEmpty) {
      try {
        var decodedToken = JwtDecoder.decode(token);
        print("MainPage: JWT decoded successfully, role: ${decodedToken['role']}");
        setState(() {
          role = decodedToken['role'][0];
          isLoading = false;
        });
      } catch (e) {
        print("MainPage: JWT decoding failed: $e");
        // If JWT decoding fails, try to get user data from local database
        final dbHelper = DatabaseHelper();
        final user = await dbHelper.getUserByToken(token);
        print("MainPage: User found by token: ${user != null ? 'Yes' : 'No'}");
        
        if (user != null && user['role'] != null) {
          print("MainPage: Role from database: ${user['role']}");
          setState(() {
            role = user['role'];
            isLoading = false;
          });
        } else {
          // If no user found by token, try to get the first user from database
          final users = await dbHelper.getUsers();
          print("MainPage: Total users in database: ${users.length}");
          
          if (users.isNotEmpty && users.first['role'] != null) {
            print("MainPage: Role from first user: ${users.first['role']}");
            setState(() {
              role = users.first['role'];
              isLoading = false;
            });
          } else {
            print("MainPage: No role found in database");
            setState(() {
              isLoading = false;
            });
            // No valid token or role found, redirect to login
            _redirectToLogin();
          }
        }
      }
    } else {
      print("MainPage: No token found, checking database for any user");
      // If no token, try to get any user from database
      final dbHelper = DatabaseHelper();
      final users = await dbHelper.getUsers();
      if (users.isNotEmpty && users.first['role'] != null) {
        print("MainPage: Using role from first user in database: ${users.first['role']}");
        setState(() {
          role = users.first['role'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // No users found in database, redirect to login
        _redirectToLogin();
      }
    }
    
    print("MainPage: Final role set to: $role");
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
        // return AccountOpeningHomePage();
        // return RegistrationScreen();

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

  void _redirectToLogin() async {
    // Stop token monitoring
    TokenService.stopTokenMonitoring();
    
    // Navigate to login page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void logout() async {
    // Use TokenService for complete logout
    await TokenService.forceLogoutWithContext(context);
  }
}
