// import 'package:coopengageplus/features/onboarding/Indivudualaccount/CustomerRegistrationScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:coopengageplus/features/onboarding/corporate/corporateAccount.dart';
// import 'package:coopengageplus/features/onboarding/jointaccount/jointAccount.dart';
// // import 'package:coopengageplus/features/onboarding/Indivudualaccount/CustomerRegistrationScreen.dart';

// class AccountOpeningHomePage extends StatelessWidget {
//   AccountOpeningHomePage({Key? key}) : super(key: key);

//   final Color lightBlue = Color(0xFFE3F2FD);
//   final Color blueAccent = Color(0xFF42A5F5);

//   final Color lightOrange = Color(0xFFFFF3E0);
//   final Color orangeAccent = Color(0xFFFF9800);

//   final Color lightCyan = Color(0xFFE0F7FA);
//   final Color cyanAccent = Color(0xFF00BCD4);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         title: const Text(
//           'Choose Account Type',
//           style: TextStyle(
//               fontSize: 19, fontWeight: FontWeight.bold, color: Colors.blue),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: GridView.count(
//           crossAxisCount: 2,
//           mainAxisSpacing: 12,
//           crossAxisSpacing: 12,
//           childAspectRatio: 1.2, // Adjusted to make the card size smaller
//           children: [
//             _buildAccountCard(
//               title: 'Individual',
//               description: 'For personal use',
//               icon: Icons.person_outline,
//               gradientColors: [
//                 const Color.fromARGB(255, 12, 19, 24),
//                 Colors.blueAccent,
//                 const Color.fromARGB(255, 19, 33, 45)!
//               ],
//               onTap: () {
//                 // Navigator.of(context).pushReplacement(
//                 //   MaterialPageRoute(builder: (context) => RegistrationScreen()),
//                 // );

//                 Navigator.of(context).pushReplacement(
//                   MaterialPageRoute(builder: (context) => RegistrationScreen()),
//                 );
//               },
//             ),
//             _buildAccountCard(
//               title: 'Joint',
//               description: 'Shared account',
//               icon: Icons.group_outlined,
//               gradientColors: [
//                 const Color.fromARGB(255, 16, 19, 19),
//                 const Color.fromARGB(255, 60, 99, 99),
//                 const Color.fromARGB(255, 20, 57, 74)
//               ],
//               onTap: () {
//                 // Navigator.pushAndRemoveUntil(
//                 //   context,
//                 //   MaterialPageRoute(
//                 //       builder: (context) => JointAccountStepperPage()),
//                 //   (route) => false,
//                 // );

//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => JointAccountStepperPage()),
//                   (route) =>
//                       false, // This removes all routes, except the one you're pushing
//                 );
//               },
//             ),
//             _buildAccountCard(
//               title: 'Corporate',
//               description: 'Business accounts',
//               icon: Icons.business_outlined,
//               gradientColors: [
//                 Colors.orange,
//                 Colors.orangeAccent,
//                 Colors.orange[300]!
//               ],
//               onTap: () {
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => CorporateRegistration()),
//                   (route) => false,
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAccountCard({
//     required String title,
//     required String description,
//     required IconData icon,
//     required List<Color> gradientColors,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: gradientColors,
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: gradientColors.last.withOpacity(0.3),
//               blurRadius: 10,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(16), // Adjust padding to make it smaller
//         child: Stack(
//           children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(
//                         height: 5), // Space between title and description
//                     Text(
//                       description,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w400,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             Positioned(
//               bottom: 0,
//               right: 0,
//               child: Icon(
//                 icon,
//                 size: 25, // Larger icon
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
