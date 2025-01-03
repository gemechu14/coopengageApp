// import 'package:flutter/material.dart';
// import 'package:coopengageplus/common_widgets/text/CustomText.dart';
// import 'package:coopengageplus/constants/app_sizes.dart';
// import 'package:coopengageplus/constants/kconstant.dart';
// import 'package:coopengageplus/features/crm/presentation/dashboard/widgets/categories_row.dart';

// class ScheduleCard extends StatelessWidget {
//   final String eventType; // "Task" or "Meeting"
//   final String time; // Time of the event
//   final String targetPerson; // Person the meeting is planned with
//   final String? reason;
//   const ScheduleCard({
//     Key? key,
//     required this.eventType,
//     required this.time,
//     required this.targetPerson,
//     this.reason,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Define gradient colors
//     final gradientColors = eventType.toLowerCase() == 'meeting'
//         ? [Colors.blue, Colors.cyan]
//         : [Colors.pink, Colors.orange];

//     return Container(
//       margin: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: gradientColors,
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: gradientColors.last.withOpacity(0.5),
//             offset: const Offset(4, 4),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Event Type
//             Text(
//               eventType.toUpperCase(),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             // Time
//             Row(
//               children: [
//                 const Icon(
//                   Icons.access_time,
//                   color: Colors.white70,
//                   size: 18,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   time,
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             // Target Person
//             Row(
//               children: [
//                 const Icon(
//                   Icons.person,
//                   color: Colors.white70,
//                   size: 18,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     targetPerson,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             Container(
//                 margin: EdgeInsets.only(left: Sizes.p16),
//                 child: CustomText(
//                   text: reason != null ? reason.toString().capitalize() : "",
//                   fontColor: whiteColor,
//                   fontSize: Sizes.p14,
//                 ))
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:coopengageplus/common_widgets/text/CustomText.dart';
import 'package:coopengageplus/constants/app_sizes.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/features/crm/presentation/dashboard/widgets/categories_row.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

class ScheduleCard extends StatelessWidget {
  final String eventType; // "Task" or "Meeting"
  final String time; // Time of the event
  final String targetPerson; // Person the meeting is planned with
  final String? reason;
  const ScheduleCard({
    Key? key,
    required this.eventType,
    required this.time,
    required this.targetPerson,
    this.reason,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define gradient colors
    final gradientColors = eventType.toLowerCase() == 'meeting'
        ? [Colors.blue, Colors.cyan]
        : eventType.toLowerCase() == 'task'
            ? [Colors.pink, Colors.orange]
            : [Colors.grey, Colors.black]; // Default gradient

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.5),
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Type
            Text(
              eventType.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Time
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Target Person
            Row(
              children: [
                const Icon(
                  Icons.person,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    targetPerson,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Reason (optional)
            if (reason != null && reason!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: Sizes.p16),
                child: CustomText(
                  text: reason.toString(),
                  fontColor: whiteColor,
                  fontSize: Sizes.p14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
