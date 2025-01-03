// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class AchievementBarChart extends StatelessWidget {
//   final List<Map<String, dynamic>> data;

//   const AchievementBarChart({Key? key, required this.data}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         maxY: 100, // Adjust this based on your maximum target value
//         titlesData: FlTitlesData(
//           show: true,
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 if (value.toInt() >= 0 && value.toInt() < data.length) {
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       data[value.toInt()]['name'],
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   );
//                 }
//                 return const Text('');
//               },
//             ),
//           ),
//           leftTitles: const AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 40,
//             ),
//           ),
//           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         ),
//         borderData: FlBorderData(show: false),
//         gridData: const FlGridData(
//           show: true,
//           drawVerticalLine: false,
//           horizontalInterval: 20,
//         ),
//         barGroups: data.asMap().entries.map((entry) {
//           final index = entry.key;
//           final item = entry.value;
//           return BarChartGroupData(
//             x: index,
//             barRods: [
//               BarChartRodData(
//                 toY: item['achievements']?.toDouble() ?? 0,
//                 color: Colors.blue,
//                 width: 20,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               BarChartRodData(
//                 toY: item['target']?.toDouble() ?? 0,
//                 color: Colors.green.withOpacity(0.3),
//                 width: 20,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class AchievementBarChart extends StatelessWidget {
//   final List<Map<String, dynamic>> data;

//   const AchievementBarChart({Key? key, required this.data}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         maxY: 100, // Adjust this based on your maximum target value
//         titlesData: FlTitlesData(
//           show: true,
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 if (value.toInt() >= 0 && value.toInt() < data.length) {
//                   String title = data[value.toInt()]['name'];

//                   // Assign colors based on the title (name)
//                   Color titleColor;
//                   switch (title) {
//                     case "New Accounts":
//                       titleColor = Colors.blue;
//                       break;
//                     case "Inactive Accounts":
//                       titleColor = Colors.red;
//                       break;
//                     case "Agents":
//                       titleColor = Colors.green;
//                       break;
//                     default:
//                       titleColor = Colors.black;
//                       break;
//                   }

//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     child: Text(
//                       title,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: titleColor, // Set the color dynamically
//                       ),
//                     ),
//                   );
//                 }
//                 return const Text('');
//               },
//               reservedSize: 50, // Increase space for the titles
//             ),
//           ),
//           leftTitles: const AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 40,
//             ),
//           ),
//           topTitles:
//               const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           rightTitles:
//               const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         ),
//         borderData: FlBorderData(show: false),
//         gridData: const FlGridData(
//           show: true,
//           drawVerticalLine: false,
//           horizontalInterval: 20,
//         ),
//         barGroups: data.asMap().entries.map((entry) {
//           final index = entry.key;
//           final item = entry.value;

//           // Assign bar colors based on the title (name)
//           Color barColor;
//           switch (item['name']) {
//             case "New Accounts":
//               barColor = Colors.blue;
//               break;
//             case "Inactive Accounts":
//               barColor = Colors.red;
//               break;
//             case "Agents":
//               barColor = Colors.green;
//               break;
//             default:
//               barColor = Colors.grey;
//               break;
//           }

//           return BarChartGroupData(
//             x: index,
//             barRods: [
//               BarChartRodData(
//                 toY: item['achievements']?.toDouble() ?? 0,
//                 color: barColor, // Set color for the achievement bar
//                 width: 20,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               BarChartRodData(
//                 toY: item['target']?.toDouble() ?? 0,
//                 color:
//                     barColor.withOpacity(0.3), // Set color for the target bar
//                 width: 20,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class AchievementBarChart extends StatelessWidget {
//   final List<Map<String, dynamic>> data;

//   const AchievementBarChart({Key? key, required this.data}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Find the maximum target value
//     double maxTarget = 0;
//     for (var item in data) {
//       double target = item['target']?.toDouble() ?? 0;
//       if (target > maxTarget) {
//         maxTarget = target;
//       }
//     }

//     // Add some padding to the max value to ensure the bars don't get cut off
//     double adjustedMaxY = maxTarget * 1.1; // 10% padding

//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         maxY: adjustedMaxY, // Use dynamically calculated maxY
//         titlesData: FlTitlesData(
//           show: true,
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 if (value.toInt() >= 0 && value.toInt() < data.length) {
//                   String title = data[value.toInt()]['name'];

//                   // Assign colors based on the title (name)
//                   Color titleColor;
//                   switch (title) {
//                     case "New Accounts":
//                       titleColor = Colors.blue;
//                       break;
//                     case "Inactive Accounts":
//                       titleColor = Colors.red;
//                       break;
//                     case "Agents":
//                       titleColor = Colors.green;
//                       break;
//                     default:
//                       titleColor = Colors.black;
//                       break;
//                   }

//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     child: Text(
//                       title,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: titleColor, // Set the color dynamically
//                       ),
//                     ),
//                   );
//                 }
//                 return const Text('');
//               },
//               reservedSize: 50, // Increase space for the titles
//             ),
//           ),
//           leftTitles: const AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 40,
//             ),
//           ),
//           topTitles:
//               const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           rightTitles:
//               const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         ),
//         borderData: FlBorderData(show: false),
//         gridData: const FlGridData(
//           show: true,
//           drawVerticalLine: false,
//           horizontalInterval: 20,
//         ),
//         barGroups: data.asMap().entries.map((entry) {
//           final index = entry.key;
//           final item = entry.value;

//           // Assign bar colors based on the title (name)
//           Color barColor;
//           switch (item['name']) {
//             case "New Accounts":
//               barColor = Colors.blue;
//               break;
//             case "Inactive Accounts":
//               barColor = Colors.red;
//               break;
//             case "Agents":
//               barColor = Colors.green;
//               break;
//             default:
//               barColor = Colors.grey;
//               break;
//           }

//           return BarChartGroupData(
//             x: index,
//             barRods: [
//               BarChartRodData(
//                 toY: item['achievements']?.toDouble() ?? 0,
//                 color: barColor, // Set color for the achievement bar
//                 width: 20,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               BarChartRodData(
//                 toY: item['target']?.toDouble() ?? 0,
//                 color:
//                     barColor.withOpacity(0.3), // Set color for the target bar
//                 width: 20,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class AchievementBarChart extends StatelessWidget {
//   final List<Map<String, dynamic>> data;

//   const AchievementBarChart({Key? key, required this.data}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Find the maximum achievement and target value
//     double maxAchievement = 0;
//     double maxTarget = 0;

//     for (var item in data) {
//       double achievement = item['achievements']?.toDouble() ?? 0;
//       double target = item['target']?.toDouble() ?? 0;

//       if (achievement > maxAchievement) {
//         maxAchievement = achievement;
//       }
//       if (target > maxTarget) {
//         maxTarget = target;
//       }
//     }
//     print("dataaa");

//     print(data);
//     // Calculate the maximum of both achievement and target, and add padding
//     double adjustedMaxY =
//         (maxAchievement > maxTarget ? maxAchievement : maxTarget) * 1.1;

//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         maxY:
//             adjustedMaxY, // Use dynamically calculated maxY for both achievement and target
//         titlesData: FlTitlesData(
//           show: true,
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 if (value.toInt() >= 0 && value.toInt() < data.length) {
//                   String title = data[value.toInt()]['name'];

//                   // Assign colors based on the title (name)
//                   Color titleColor;
//                   switch (title) {
//                     case "New Accounts":
//                       titleColor = Colors.blue;
//                       break;
//                     case "Inactive Accounts":
//                       titleColor = Colors.red;
//                       break;
//                     case "Agents":
//                       titleColor = Colors.green;
//                       break;
//                     default:
//                       titleColor = Colors.black;
//                       break;
//                   }

//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     child: Text(
//                       title,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: titleColor, // Set the color dynamically
//                       ),
//                     ),
//                   );
//                 }
//                 return const Text('');
//               },
//               reservedSize: 50, // Increase space for the titles
//             ),
//           ),
//           leftTitles: const AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 40,
//             ),
//           ),
//           topTitles:
//               const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           rightTitles:
//               const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         ),
//         borderData: FlBorderData(show: false),
//         gridData: const FlGridData(
//           show: true,
//           drawVerticalLine: false,
//           horizontalInterval: 20,
//         ),
//         barGroups: data.asMap().entries.map((entry) {
//           final index = entry.key;
//           final item = entry.value;

//           // Assign bar colors based on the title (name)
//           Color barColor;
//           switch (item['name']) {
//             case "New Accounts":
//               barColor = Colors.blue;
//               break;
//             case "Inactive Accounts":
//               barColor = Colors.red;
//               break;
//             case "Agents":
//               barColor = Colors.green;
//               break;
//             default:
//               barColor = Colors.grey;
//               break;
//           }

//           return BarChartGroupData(
//             x: index,
//             barRods: [
//               BarChartRodData(
//                 toY: item['achievements']?.toDouble() ?? 0,
//                 color: barColor, // Set color for the achievement bar
//                 width: 20,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               BarChartRodData(
//                 toY: item['target']?.toDouble() ?? 0,
//                 color:
//                     barColor.withOpacity(0.3), // Set color for the target bar
//                 width: 20,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class AchievementBarChart extends StatelessWidget {
//   final List<Map<String, dynamic>> data;

//   const AchievementBarChart({Key? key, required this.data}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Calculate max values for achievement and target in one loop
//     double maxAchievement = 0;
//     double maxTarget = 0;

//     for (var item in data) {
//       double achievement = item['achievements']?.toDouble() ?? 0;
//       double target = item['target']?.toDouble() ?? 0;

//       if (achievement > maxAchievement) {
//         maxAchievement = achievement;
//       }
//       if (target > maxTarget) {
//         maxTarget = target;
//       }
//     }

//     // Adjust max Y axis dynamically, adding padding
//     double adjustedMaxY =
//         (maxAchievement > maxTarget ? maxAchievement : maxTarget) * 1.1;

//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment
//             .spaceBetween, // Adjust alignment to prevent bars from overflowing
//         maxY: adjustedMaxY,
//         titlesData: FlTitlesData(
//           show: true,
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 if (value.toInt() >= 0 && value.toInt() < data.length) {
//                   String title = data[value.toInt()]['name'];

//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     child: Text(
//                       title,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: _getBarColor(title),
//                       ),
//                     ),
//                   );
//                 }
//                 return const Text('');
//               },
//               reservedSize: 50,
//             ),
//           ),
//           leftTitles: const AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 40,
//             ),
//           ),
//           topTitles:
//               const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           rightTitles:
//               const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         ),
//         borderData: FlBorderData(show: false),
//         gridData: const FlGridData(
//           show: true,
//           drawVerticalLine: false,
//           horizontalInterval: 20,
//         ),
//         barGroups: data.asMap().entries.map((entry) {
//           final index = entry.key;
//           final item = entry.value;

//           return BarChartGroupData(
//             x: index,
//             barRods: [
//               BarChartRodData(
//                 toY: item['achievements']?.toDouble() ?? 0,
//                 color: _getBarColor(item['name']),
//                 width: 15, // Reduced width to ensure bars fit inside the area
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               BarChartRodData(
//                 toY: item['target']?.toDouble() ?? 0,
//                 color: _getBarColor(item['name']).withOpacity(0.3),
//                 width: 15, // Reduced width to ensure bars fit inside the area
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }

//   // Function to assign colors based on title
//   Color _getBarColor(String title) {
//     switch (title) {
//       case "New Accounts":
//         return Colors.blue;
//       case "Inactive Accounts":
//         return Colors.red;
//       case "Agents":
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }
// }

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AchievementBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const AchievementBarChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate max values for achievement and target in one loop
    double maxAchievement = 0;
    double maxTarget = 0;

    for (var item in data) {
      double achievement = item['achievements']?.toDouble() ?? 0;
      double target = item['target']?.toDouble() ?? 0;

      if (achievement > maxAchievement) {
        maxAchievement = achievement;
      }
      if (target > maxTarget) {
        maxTarget = target;
      }
    }

    // Adjust max Y axis dynamically, adding padding
    double adjustedMaxY =
        (maxAchievement > maxTarget ? maxAchievement : maxTarget) * 1.1;

    return Column(
      children: [
        const Text(
          'Monthly Reports',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.start,
        ),
        // Bar chart
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Container(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                maxY: adjustedMaxY,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          String title = data[value.toInt()]['name'];

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 25,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                ),
                barGroups: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      // Achievement Bar: Blue
                      // BarChartRodData(
                      //   toY: item['achievements']?.toDouble() ?? 0,
                      //   color: Colors.blue, // Achievement bar color
                      //   width: 15,
                      //   borderRadius: BorderRadius.circular(4),
                      // ),
                      // Target Bar: Green
                      BarChartRodData(
                        toY: item['target']?.toDouble() ?? 0,
                        color: Colors.blue, // Target bar color
                        width: 15,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: item['achievements']?.toDouble() ?? 0,
                        color: Colors.orange, // Achievement bar color
                        width: 15,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        // Legend outside the chart
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Legend for Achievement

              // Legend for Target
              Container(
                width: 20,
                height: 10,
                color: Colors.blue,
              ),
              const SizedBox(width: 5),
              const Text("Target", style: TextStyle(fontSize: 16)),
              const SizedBox(width: 20),
              Container(
                width: 20,
                height: 10,
                color: Colors.orange,
              ),

              const Text("Achievement", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
