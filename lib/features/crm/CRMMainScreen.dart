import 'package:coopengageplus/features/crm/presentation/dashboard/CRMDashboard.dart';
import 'package:coopengageplus/features/crm/presentation/notes/noteScreen.dart';
import 'package:coopengageplus/features/crm/presentation/profile/profileScreen.dart';
import 'package:coopengageplus/features/crm/presentation/schedule/Schedule.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../constants/kconstant.dart';
import '../../utils/language_store.dart';

// ignore: unused_import
// import 'package:coopengageplus/NetworkHandler.dart';
// import 'package:coopengageplus/Screen/AgentPage.dart';
// import 'package:coopengageplus/Screen/Dashboard.dart';
// import 'package:coopengageplus/Screen/Schedule.dart';
// import 'package:coopengageplus/Screen/noteScreen.dart';
// import 'package:coopengageplus/Screen/profileScreen.dart';
// import 'package:coopengageplus/pages/LoginPage.dart';

class CRMMainScreen extends StatefulWidget {
  final int initialIndex;

  const CRMMainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _CRMMainScreenState createState() => _CRMMainScreenState();
}

class _CRMMainScreenState extends State<CRMMainScreen> {
  late int _selectedIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  final List<Widget> _pages = [
    CRMDashboard(),
    Schedule(),
    Notescreen(),
    ProfileScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          children: _pages,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
      bottomNavigationBar: Container(
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
            gap: 8,
            activeColor: primaryBlue,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: lightBlueColor,
            color: Colors.black,
            tabs: [
              GButton(
                icon: Icons.home,
                text: translation(context).home,
              ),
              GButton(
                icon: Icons.schedule,
                text: translation(context).schedule,
              ),
              GButton(
                icon: Icons.notes,
                text: translation(context).notes,
              ),
              GButton(
                icon: Icons.person_2,
                text: translation(context).profile,
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: onTabTapped,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
