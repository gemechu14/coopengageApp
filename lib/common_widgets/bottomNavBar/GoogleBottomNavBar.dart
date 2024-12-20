
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_nav_bar/google_nav_bar.dart';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:google_nav_bar/google_nav_bar.dart';
// // import 'package:sebez_app/src/constants/kconstant.dart';
// // import 'package:line_icons/line_icons.dart';
// // import 'package:sebez_app/src/routing/app_route.dart';
// // import 'package:sebez_app/src/routing/app_routes.dart';

// class GoogleButtomNavBar extends ConsumerStatefulWidget {
//   final bool showBottomNavBar;
//   const GoogleButtomNavBar({super.key, required this.showBottomNavBar});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _GoogleButtomNavBarState();
// }

// class _GoogleButtomNavBarState extends ConsumerState<GoogleButtomNavBar> {
//   static int _selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     void onTabTapped(int index) {
//       setState(() {
//         _selectedIndex = index;
//         print({_selectedIndex});
//       });
//       switch (_selectedIndex) {
//         case 0:
//           // Get.to(() => CRMDashboard());
//           Get.off(() => CRMDashboard());
//           break;
//         case 1:
//           Get.to(() => Schedule());
//           break;
//         case 2:
//           Get.to(() => Notescreen());
//           break;
//         case 3:
//           Get.to(() => ProfileScreen());

//           break;
//       }
//     }

//     return widget.showBottomNavBar
//         ? Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   blurRadius: 20,
//                   color: Colors.black.withOpacity(.1),
//                 )
//               ],
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(6.0),
//               child: GNav(
//                   rippleColor: Colors.grey[300]!,
//                   hoverColor: Colors.grey[100]!,
//                   gap: 8,
//                   activeColor: primaryBlue,
//                   iconSize: 24,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   duration: const Duration(milliseconds: 400),
//                   tabBackgroundColor: lightBlueColor,
//                   color: Colors.black,
//                   tabs: [
//                     GButton(
//                       icon: Icons.home,
//                       text: translation(context).home,
//                     ),
//                     GButton(
//                       icon: Icons.schedule,
//                       text: translation(context).schedule,
//                     ),
//                     GButton(
//                       icon: Icons.notes,
//                       text: translation(context).notes,
//                     ),
//                     GButton(
//                       icon: Icons.person_2,
//                       text: translation(context).profile,
//                     )
//                   ],
//                   selectedIndex: _selectedIndex,
//                   onTabChange: onTabTapped),
//             ),
//           )
//         : const SizedBox();
//   }
// }
