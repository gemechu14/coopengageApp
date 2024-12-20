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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AchievementBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const AchievementBarChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find the maximum achievement and target value
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

    // Calculate the maximum of both achievement and target, and add padding
    double adjustedMaxY =
        (maxAchievement > maxTarget ? maxAchievement : maxTarget) * 1.1;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            adjustedMaxY, // Use dynamically calculated maxY for both achievement and target
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  String title = data[value.toInt()]['name'];

                  // Assign colors based on the title (name)
                  Color titleColor;
                  switch (title) {
                    case "New Accounts":
                      titleColor = Colors.blue;
                      break;
                    case "Inactive Accounts":
                      titleColor = Colors.red;
                      break;
                    case "Agents":
                      titleColor = Colors.green;
                      break;
                    default:
                      titleColor = Colors.black;
                      break;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: titleColor, // Set the color dynamically
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 50, // Increase space for the titles
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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

          // Assign bar colors based on the title (name)
          Color barColor;
          switch (item['name']) {
            case "New Accounts":
              barColor = Colors.blue;
              break;
            case "Inactive Accounts":
              barColor = Colors.red;
              break;
            case "Agents":
              barColor = Colors.green;
              break;
            default:
              barColor = Colors.grey;
              break;
          }

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item['achievements']?.toDouble() ?? 0,
                color: barColor, // Set color for the achievement bar
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: item['target']?.toDouble() ?? 0,
                color:
                    barColor.withOpacity(0.3), // Set color for the target bar
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
