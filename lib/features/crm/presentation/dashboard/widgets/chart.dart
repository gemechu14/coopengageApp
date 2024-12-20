import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/features/crm/presentation/widgets/pie_chart.dart';
import 'package:coopengageplus/features/crm/providers/high_profile_clients.dart';

class SegementationChart extends ConsumerStatefulWidget {
  const SegementationChart({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SegementationChartState();
}

class _SegementationChartState extends ConsumerState<SegementationChart> {
  @override
  Widget build(BuildContext context) {
    final highProfileClients = ref.watch(highProfileClientsProvider);
    int length = highProfileClients.when(
      data: (clients) => clients.length, // Access the length of the data
      loading: () => 0, // Handle loading state
      error: (err, stack) => 0, // Handle error state
    );
    return Expanded(
      flex: 4,
      child: LayoutBuilder(
        builder: (context, constraint) {
          double circleSize =
              constraint.maxWidth * 0.6; // Circle size relative to width
          double innerCircleSize = circleSize *
              0.5; // Inner circle size relative to outer circle size

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  spreadRadius: -10,
                  blurRadius: 17,
                  offset: Offset(-5, -5),
                  color: Color.fromRGBO(193, 214, 233, 1),
                ),
                BoxShadow(
                  spreadRadius: -2,
                  blurRadius: 10,
                  offset: Offset(7, 7),
                  color: Color.fromRGBO(146, 182, 216, 1),
                )
              ],
            ),
            child: Stack(
              alignment: Alignment
                  .center, // Align the children in the center of the container
              children: [
                SizedBox(
                  width: circleSize,
                  height:
                      circleSize, // Make sure the width and height are the same for a circle
                  child: CustomPaint(
                    child: Center(),
                    foregroundPainter: PieChart(
                      width: circleSize *
                          0.25, // Pie chart size relative to circle size
                      categories: kCategories,
                    ),
                  ),
                ),
                // Inner circle with the number '31'
                Container(
                  height: innerCircleSize,
                  width: innerCircleSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      const BoxShadow(
                        blurRadius: 1,
                        offset: Offset(-1, -1),
                        color: Color.fromRGBO(193, 214, 233, 1),
                      ),
                      BoxShadow(
                        spreadRadius: -2,
                        blurRadius: 10,
                        offset: const Offset(5, 5),
                        color: Colors.black.withOpacity(0.5),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      length.toString(), // This can be dynamic as needed
                      style: TextStyle(
                        fontSize: innerCircleSize *
                            0.3, // Adjust text size based on inner circle size
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// class _SegementationChartState extends ConsumerState<SegementationChart> {
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//         flex: 4,
//         child: Expanded(
//           flex: 4,
//           child: LayoutBuilder(
//             builder: (context, constraint) {
//               double circleSize =
//                   constraint.maxWidth * 0.6; // Circle size relative to width
//               double innerCircleSize = circleSize *
//                   0.5; // Inner circle size relative to outer circle size

//               return Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       spreadRadius: -10,
//                       blurRadius: 17,
//                       offset: Offset(-5, -5),
//                       color: Color.fromRGBO(193, 214, 233, 1),
//                     ),
//                     BoxShadow(
//                       spreadRadius: -2,
//                       blurRadius: 10,
//                       offset: Offset(7, 7),
//                       color: Color.fromRGBO(146, 182, 216, 1),
//                     )
//                   ],
//                 ),
//                 child: Stack(
//                   alignment: Alignment
//                       .center, // Align the children in the center of the container
//                   children: [
//                     SizedBox(
//                       width: circleSize,
//                       height:
//                           circleSize, // Make sure the width and height are the same for a circle
//                       child: CustomPaint(
//                         child: Center(),
//                         foregroundPainter: PieChart(
//                           width: circleSize *
//                               0.5, // Pie chart size relative to circle size
//                           categories: kCategories,
//                         ),
//                       ),
//                     ),
//                     // Inner circle with the number '31'
//                     Container(
//                       height: innerCircleSize,
//                       width: innerCircleSize,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             blurRadius: 1,
//                             offset: Offset(-1, -1),
//                             color: Color.fromRGBO(193, 214, 233, 1),
//                           ),
//                           BoxShadow(
//                             spreadRadius: -2,
//                             blurRadius: 10,
//                             offset: Offset(5, 5),
//                             color: Colors.black.withOpacity(0.5),
//                           )
//                         ],
//                       ),
//                       child: Center(
//                         child: Text(
//                           '31', // This can be dynamic as needed
//                           style: TextStyle(
//                               fontSize: innerCircleSize *
//                                   0.3), // Adjust text size based on inner circle size
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ));
//   }
// }

// Container(
//                   decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           spreadRadius: -10,
//                           blurRadius: 17,
//                           offset: Offset(
//                             -5,
//                             -5,
//                           ),
//                           color: Color.fromRGBO(193, 214, 233, 1),
//                         ),
//                         BoxShadow(
//                             spreadRadius: -2,
//                             blurRadius: 10,
//                             offset: Offset(
//                               7,
//                               7,
//                             ),
//                             color: Color.fromRGBO(146, 182, 216, 1))
//                       ]),
//                 )
