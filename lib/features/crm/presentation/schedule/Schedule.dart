import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:coopengageplus/shared/widgets/text/custom_nav_heading.dart';
import 'package:coopengageplus/core/constants/app_sizes.dart';
import 'package:coopengageplus/features/crm/presentation/schedule/meetingSchedule.dart';
import 'package:coopengageplus/features/crm/presentation/schedule/schedule_details.dart';
import 'package:coopengageplus/features/crm/presentation/widgets/schedule_card.dart';
import 'package:coopengageplus/features/crm/providers/task/task.dart';
import 'package:coopengageplus/core/utils/language_store.dart';
import '../../../hpc/providers/meeting/meeting_provider.dart';
import 'taskSchedule.dart';

class Schedule extends ConsumerStatefulWidget {
  const Schedule({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScheduleState();
}

class _ScheduleState extends ConsumerState<Schedule> {
  List<DateTime> dates = [];
  final int loadBatchSize = 7;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);
    final meetings = ref.watch(meetingProvider);

// Transform TaskModel data
    List<Map<String, dynamic>> transformedTasks = tasks.when(
        data: (data) => data.map((task) {
              return {
                'type': 'task',
                'highProfileCustomerName': task.highProfileCustomerName,
                'date': task.taskDate,
                'time': task.taskTime,
                'title': task.title,
                'description': task.description,
                'status': task.status,
                'address': task.address,
                'id': task.taskId
              };
            }).toList(),
        error: (err, stk) => [],
        loading: () => []);
    // // Transform MeetingModel data
    List<Map<String, dynamic>> transformedMeetings = meetings.when(
        data: (data) => data.map((meeting) {
              return {
                'type': 'meeting',
                'highProfileCustomerName': meeting.highProfileCustomerName,
                'date': meeting.meetingDate,
                'time': meeting.meetingTime,
                'reason': meeting.reason,
                'status': meeting.status,
                'address': meeting.address ?? "",
                'feeling': meeting.feeling,
                'id': meeting.meetingId,
                "notes": meeting.notes
              };
            }).toList(),
        error: (err, stk) => [],
        loading: () => []);
    // Combine both lists
    List<Map<String, dynamic>> combinedList = [
      ...transformedTasks,
      ...transformedMeetings
    ];
    final filteredData = combinedList.where((item) {
      final itemDate = DateTime.parse(item['date']);
      return itemDate.year == selectedDate.year &&
          itemDate.month == selectedDate.month &&
          itemDate.day == selectedDate.day;
    }).toList();
    print({filteredData});
    return Scaffold(
      // backgroundColor: lightBG,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: EdgeInsets.all(Sizes.p8),
          child: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: CustomNavHeading(
              text: translation(context).schedule,
            ),
            actions: const [Icon(Icons.notifications)],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(Sizes.p10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EasyDateTimeLinePicker(
                focusedDate: selectedDate,
                firstDate: DateTime(2024, 1, 1),
                lastDate: DateTime(2030, 3, 18),
                onDateChange: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
              Column(
                children: filteredData.map((event) {
                  final eventType = event['type']!;
                  final time = event['time']!;
                  final date = event['date']!;
                  final address = event['address']!;
                  final id = event['id']!;
                  final targetPerson = event['highProfileCustomerName']!;
                  final reason = eventType == "task"
                      ? event['description']!
                      : event["reason"];
                  final status = event['status'];
                  final feeling =
                      eventType == "meeting" ? event['feeling'] : null;
                  final notes = eventType == "meeting" ? event['notes'] : null;
                  return GestureDetector(
                      onTap: () {
                        Get.to(() => ScheduleDetails(
                              meetingDetails: {
                                "id": id,
                                "highProfileCustomerName": targetPerson,
                                "meetingDate": date,
                                "meetingTime": time,
                                "reason": reason ?? "",
                                "feeling": feeling,
                                "emotionalAttachment": null,
                                "notes": notes,
                                "address": address ?? "",
                                "category": null,
                                "status": status,
                              },
                              eventType: eventType,
                            ));
                      },
                      
                      child: ScheduleCard(
                        eventType: eventType,
                        time: time,
                        targetPerson: targetPerson,
                        reason: reason ?? "",
                      ));
                }).toList(),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: SpeedDial(
        backgroundColor: Colors.blue,
        icon: Icons.add,
        activeIcon: Icons.close,
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            shape: StadiumBorder(),
            backgroundColor: const Color.fromARGB(255, 49, 114, 167),
            child: const Icon(Icons.task, color: Colors.white),
            label: translation(context).newTask,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Taskschedule()),
              );
            },
          ),
          SpeedDialChild(
            backgroundColor: Color.fromARGB(255, 75, 17, 137),
            shape: StadiumBorder(),
            child: const Icon(Icons.people, color: Colors.white),
            label: "Schedule Meeting",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MeetingSchedule()),
              );
            },
          ),
        ],
      ),
      // bottomNavigationBar: GoogleButtomNavBar(
      //   showBottomNavBar: true,
      // ),
    );
  }

  // Update month and year incrementally when the next or prev button is clicked

  String _getMonthName(int month) {
    return [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ][month - 1];
  }
}
