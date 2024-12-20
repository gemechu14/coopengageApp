import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:coopengageplus/crm12/meetingSchedule.dart';

import 'package:coopengageplus/crm12/taskSchedule.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  bool _isDialOpen = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Schedule",
          style: TextStyle(
              fontSize: 21, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.blue,
        icon: Icons.add,
        activeIcon: Icons.close,
        foregroundColor: Colors.white,
        // iconColor: Colors.white, // Set the color of the plus sign to white
        // activeIconColor: Colors.white,
        children: [
          SpeedDialChild(
            shape: StadiumBorder(),
            backgroundColor: const Color.fromARGB(255, 49, 114, 167),
            child: Icon(Icons.task, color: Colors.white),
            label: "New Task",
            onTap: () {
              // Handle New Task actionx
              print("New Task tapped");
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Taskschedule(),
                  ),
                  (route) => false);
            },
          ),
          SpeedDialChild(
            backgroundColor: Color.fromARGB(255, 75, 17, 137),
            shape: const StadiumBorder(),
            child: const Icon(Icons.people, color: Colors.white),
            label: "Schedule Meeting",
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MeetingSchedule(),
                  ),
                  (route) => false);
            },
          ),
        ],
      ),
      // floatingActionButton: SpeedDial(
      //   backgroundColor: Colors.blue,
      //   animatedIcon: AnimatedIcons.add_event,
      //   children: [
      //     SpeedDialChild(
      //         backgroundColor: Colors.blue,
      //         child: const Icon(
      //           Icons.people,
      //           color: Colors.white,
      //         ),
      //         label: "Schedule Meeting"),
      //     SpeedDialChild(
      //         backgroundColor: Colors.blue,
      //         child: const Icon(
      //           Icons.people,
      //           color: Colors.white,
      //         ),
      //         label: "New Task")
      //   ],
      // ),
    );
  }
}
