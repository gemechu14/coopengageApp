// import 'package:flutter/material.dart';

// class MerchantDetailsBuilder extends StatelessWidget {
//   final Map<String, String> registrationData;

//   const MerchantDetailsBuilder({Key? key, required this.registrationData})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           header(),
//           for (var entry in registrationData.entries)
//             buildDetailRow(entry.key, entry.value),
//         ],
//       ),
//     );
//   }

//   Widget header() => const Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Icon(
//           //   Icons.person,
//           //   color: Colors.indigo,
//           //   size: 35.0,
//           // ),
//           SizedBox(width: 10),
//           Text(
//             "Merchant Details",
//             style: TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold),
//           ),
//           // buildDetailRow()
//         ],
//       );

// //   Widget buildDetailRow(String title, String value) => Center(
// //     child: Row(
// //           crossAxisAlignment: CrossAxisAlignment.center,
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Expanded(
// //               flex: 2,
// //               child: Text(
// //                 title,
// //                 style: const TextStyle(
// //                   fontSize: 16.0,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.black,
// //                 ),
// //               ),
// //             ),
// //             Expanded(
// //               flex: 3,
// //               child: Text(
// //                 value,
// //                 style: const TextStyle(
// //                   fontSize: 16.0,
// //                   color: Colors.black,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //   );

//   Widget buildDetailRow(String title, String value) => Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: 120.0, // Fixed width for the title column
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16.0,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 16.0,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );

//   // Widget buildDetailRow(String title, String value) => Padding(
//   //       padding: const EdgeInsets.symmetric(vertical: 8.0),
//   //       child: Row(
//   //         mainAxisAlignment:
//   //             MainAxisAlignment.center, // Center-align all content
//   //         children: [
//   //           Text(
//   //             "$title: ", // Add a colon for better readability
//   //             style: const TextStyle(
//   //               fontSize: 16.0,
//   //               fontWeight: FontWeight.bold,
//   //               color: Colors.black,
//   //             ),
//   //           ),
//   //           Text(
//   //             value,
//   //             style: const TextStyle(
//   //               fontSize: 16.0,
//   //               color: Colors.black,
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     );
// }

import 'package:flutter/material.dart';

class MerchantDetailsBuilder extends StatelessWidget {
  final Map<String, String> registrationData;

  const MerchantDetailsBuilder({Key? key, required this.registrationData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center the entire table horizontally
      child: Column(
        children: [
          header(),
          const SizedBox(height: 16.0), // Space between header and rows
          // Wrap the table rows with a Center widget to make the table centered
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment:
                  MainAxisAlignment.center, // Align row items to the left
              children: [
                for (var entry in registrationData.entries)
                  buildDetailRow(entry.key, entry.value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget header() => const Center(
        // Center the header text
        child: Column(
          children: [
            // Text(
            //   "Merchant Details",
            //   style: TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold),
            // ),
          ],
        ),
      );

  Widget buildDetailRow(String title, String value) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120.0, // Fixed width for the title column
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
