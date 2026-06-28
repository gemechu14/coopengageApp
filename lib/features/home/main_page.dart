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
  bool isInitializing = true;
  String role = '';
  final List<Widget?> _cachedTabWidgets = List<Widget?>.filled(4, null);
  int _agentPageGeneration = 0;

  static const int _agentTabIndex = 2;

  bool get _showsAgentTab => role != 'AGENT';

  void _openAgentTabFresh() {
    _agentPageGeneration++;
    _cachedTabWidgets[_agentTabIndex] =
        AgentPage(key: ValueKey('agent-$_agentPageGeneration'));
  }

  void _navigateToTab(int pageIndex) {
    setState(() {
      if (pageIndex == _agentTabIndex && _showsAgentTab) {
        _openAgentTabFresh();
      } else {
        _cachedTabWidgets[pageIndex] ??= _getCurrentWidget(pageIndex);
      }
      currentState = pageIndex;
    });
  }

  /// Maps GNav's sequential tap index to our internal page index.
  /// Rebuilt whenever role changes.
  List<int> _tabIndexMap = [0, 1, 2, 3];

  @override
  void initState() {
    super.initState();

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

    _tabIndexMap = role != 'AGENT'
        ? [0, 1, 2, 3]   // Home, Customer, Agent, Profile
        : [0, 1, 3];     // Home, Customer, Profile (no Agent tab)

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
        return Dashboard(onSettingsTap: () => _navigateToTab(_agentTabIndex));
      case 1:

        return AccountOnboardingScreen();
      case 2:
        if (_showsAgentTab) {
          return AgentPage(key: ValueKey('agent-$_agentPageGeneration'));
        } else {
          return const ProfileScreen();
        }

      case 3:
        return const ProfileScreen();
      default:
        return Dashboard(onSettingsTap: () => _navigateToTab(_agentTabIndex));
    }
  }

  /// Converts our internal page index to GNav's sequential index.
  int _pageIndexToGNavIndex(int pageIndex) {
    final gnavIdx = _tabIndexMap.indexOf(pageIndex);
    return gnavIdx == -1 ? 0 : gnavIdx;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      bottomNavigationBar: (isLoading || isInitializing)
          ? null
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
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, bottomPadding > 0 ? 4 : 10),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double screenWidth = constraints.maxWidth;
                      final isSmall = screenWidth < 360;
                      final isMedium = screenWidth < 400;

                      return GNav(
                        rippleColor: Colors.grey[300]!,
                        hoverColor: Colors.grey[100]!,
                        gap: isSmall ? 2 : 3,
                        activeColor: Color(0xFF2196F3),
                        iconSize: isSmall ? 22 : (isMedium ? 26 : 29),
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmall ? 6 : (isMedium ? 9 : 18),
                          vertical: isSmall ? 6 : (isMedium ? 8 : 12),
                        ),
                        duration: const Duration(milliseconds: 400),
                        tabBackgroundColor: Color(0xffD4F1F4),
                        color: Colors.black,
                        selectedIndex: _pageIndexToGNavIndex(currentState),
                        onTabChange: (gnavIndex) {
                          _navigateToTab(_tabIndexMap[gnavIndex]);
                        },
                        tabs: [
                          GButton(icon: Icons.home, text: translation(context).home),
                          GButton(icon: Icons.assignment, text: translation(context).customer),
                          if (role != 'AGENT')
                            GButton(icon: Icons.group, text: 'Agent'),
                          GButton(icon: Icons.person_2, text: 'Profile'),
                        ],
                      );
                    },
                  ),
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
                  _cachedTabWidgets[currentState] ??=
                      _getCurrentWidget(currentState);
                  return IndexedStack(
                    index: currentState,
                    sizing: StackFit.expand,
                    children: List<Widget>.generate(
                      4,
                      (i) =>
                          _cachedTabWidgets[i] ?? const SizedBox.shrink(),
                    ),
                  );
                },
              ),
      ),
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
