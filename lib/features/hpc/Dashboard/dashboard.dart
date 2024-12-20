import 'package:coopengageplus/features/hpc/presentation/crmChangeRequest/crmChangeRequest.dart';
import 'package:coopengageplus/features/hpc/presentation/feedback/feedback.dart';
import 'package:coopengageplus/features/hpc/presentation/schedule/meetingSchedule.dart';
import 'package:coopengageplus/utils/language_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widgets/text/custom_nav_heading.dart';


class HPCDashBoard extends StatefulWidget {
  const HPCDashBoard({super.key});

  @override
  _HPCDashBoardState createState() => _HPCDashBoardState();
}

class _HPCDashBoardState extends State<HPCDashBoard> {
  final List<Map<String, dynamic>> tasks = [
    {
      "title": "Review portfolio performance and analyze current investments",
      "time": DateTime.now().add(Duration(days: 1)), // Upcoming task
    },
    {
      "title": "Conduct due diligence on new investment opportunities",
      "time": DateTime.now().add(Duration(hours: 2)), // Far-off task
    },
    {
      "title":
          "Prepare for upcoming investor meeting to discuss ROI and market trends",
      "time": DateTime.now().add(Duration(days: 3)), // Latest task
    },
    {
      "title":
          "Evaluate quarterly financial reports and adjust investment strategy",
      "time": DateTime.now().subtract(Duration(days: 4)), // Past task
    },
    {
      "title":
          "Schedule follow-up with financial advisor to discuss tax planning",
      "time": DateTime.now().add(Duration(days: 5)), // Near future task
    },
  ];

  Color getIconColorBasedOnTime(DateTime taskTime) {
    final currentTime = DateTime.now();
    final diff = taskTime.difference(currentTime).inHours;

    if (diff <= 0) {
      return Colors.orange; // Past task (Overdue)
    } else if (diff <= 24) {
      return Colors.green; // Latest/Upcoming task
    } else if (diff <= 72) {
      return Colors.blue; // Near future task
    } else {
      return Colors.red; // Far-off task
    }
  }

  // final List<Map<String, dynamic>> tasks = [
  //   {
  //     "title": "Review portfolio performance and analyze current investments",
  //     "icon": Icons.check_circle,
  //   },
  //   {
  //     "title":
  //         "Conduct due diligence on new investment opportunities in emerging markets",
  //     "icon": Icons.access_time,
  //   },
  //   {
  //     "title":
  //         "Prepare for upcoming investor meeting to discuss ROI and market trends",
  //     "icon": Icons.warning,
  //   },
  //   {
  //     "title":
  //         "Evaluate quarterly financial reports and adjust investment strategy",
  //     "icon": Icons.error,
  //   },
  //   {
  //     "title":
  //         "Schedule follow-up with financial advisor to discuss tax planning and asset allocation",
  //     "icon": Icons.event,
  //   },
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: ,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          title: CustomNavHeading(
            text: translation(context).home,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 150,
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildInteractiveCard(
                          title: translation(context).schedule,
                          icon: Icons.schedule,
                          color: Colors.blue,
                          onTap: () => Get.to(() => MeetingSchedule())),
                      const SizedBox(width: 16),
                      buildInteractiveCard(
                        title: translation(context).feedback,
                        icon: Icons.lightbulb,
                        color: Colors.green,
                        onTap: () => Get.to(() => HPCFeedback()),
                      ),
                      const SizedBox(width: 16),
                      buildInteractiveCard(
                        title: translation(context).crmchangerequest,
                        icon: Icons.change_circle,
                        color: Colors.orange,
                        onTap: () => Get.to(() => HPCCRMChangeRequest()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                textAlign: TextAlign.start,
                "Latest Meeting",
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

              // Task list
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final taskIconColor = getIconColorBasedOnTime(task['time']);
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            taskIconColor, // Set the color based on task timing
                        child: const Icon(
                          Icons.event, // The same icon for all tasks
                          color: Colors.white, // Icon color is white
                        ),
                      ),
                      title: Text(
                        task["title"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2, // Limit to 2 lines
                        overflow:
                            TextOverflow.ellipsis, // Handle overflow gracefully
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInteractiveCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100, // Compact height
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
            ),
            Positioned(
              bottom: 10, // Position text at the bottom
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 1, right: 1),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12, // Reduced font size
                    fontWeight: FontWeight.bold,
                    color: color.darken(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension ColorShade on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
