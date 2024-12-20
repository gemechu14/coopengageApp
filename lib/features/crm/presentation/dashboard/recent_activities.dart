import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:coopengageplus/common_widgets/text/CustomText.dart';
import 'package:coopengageplus/constants/app_sizes.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/constants/text_styles.dart';
import 'package:coopengageplus/features/crm/presentation/dashboard/widgets/upcoming.dart';
import 'package:coopengageplus/features/crm/providers/meeting/meeting_provider.dart';
import 'package:coopengageplus/features/crm/providers/task/task.dart';

import 'widgets/passed.dart';

class RecentActivites extends ConsumerStatefulWidget {
  const RecentActivites({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RecentActivitesState();
}

class _RecentActivitesState extends ConsumerState<RecentActivites> {
  bool showFutureActivities = true;
  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);
    final meetings = ref.watch(meetingProvider);

    List<Map<String, dynamic>> transformedTasks = tasks.when(
        data: (data) => data.map((task) {
              return {
                'type': 'task',
                'highProfileCustomerName': task.highProfileCustomerName,
                'date': task.taskDate,
                'time': task.taskTime,
                'title': task.title,
                'description': task.description
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
                'reason': meeting.reason
              };
            }).toList(),
        error: (err, stk) => [],
        loading: () => []);
    // Combine both lists
    List<Map<String, dynamic>> combinedList = [
      ...transformedTasks,
      ...transformedMeetings
    ];
    DateTime now = DateTime.now();
    String today = DateFormat('yyyy-MM-dd').format(now);
    List<Map<String, dynamic>> previousDatesList = combinedList.where((item) {
      DateTime itemDate = DateFormat('yyyy-MM-dd').parse(item['date']);
      return itemDate.isBefore(DateTime.parse(today));
    }).toList();
    List<Map<String, dynamic>> upcomingDatesList = combinedList.where((item) {
      DateTime itemDate = DateFormat('yyyy-MM-dd').parse(item['date']);
      return itemDate.isAfter(DateTime.parse(today));
    }).toList();

    return Container(
      // height: 550.h,
      padding: EdgeInsets.all(Sizes.p12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Latest Schedules",
            style: sectionTitleStyle,
          ),
          gapH10,
          Container(
              margin: EdgeInsets.only(left: Sizes.p12),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // RecentTabItem(
                  //   showFutureActivities: showFutureActivities,
                  //   title: "Upcoming",
                  // ),
                  // gapW20,
                  // RecentTabItem(
                  //     showFutureActivities: showFutureActivities, title: "Passed")
                  GestureDetector(
                    child: Column(
                      children: [
                        CustomText(
                          // text: translation(context).upcoming,
                          text: "Upcoming",
                          fontSize: Sizes.p16,
                          fontWeight: FontWeight.w600,
                          fontColor: showFutureActivities
                              ? Colors.grey[600]
                              : textColor,
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: showFutureActivities
                                  ? blackColor
                                  : backgroundColor),
                        )
                      ],
                    ),
                    onTap: () {
                      // setState(() {
                      //   showFutureActivities = true;
                      // });
                    },
                  ),
                  SizedBox(
                    width: Sizes.p22,
                  ),
                  GestureDetector(
                    child: Column(
                      children: [
                        CustomText(
                          // text: translation(context).passed,
                          text: "Passed",
                          fontSize: Sizes.p16,
                          fontWeight: FontWeight.w600,
                          fontColor: showFutureActivities
                              ? textColor
                              : Colors.grey[600],
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: showFutureActivities
                                  ? backgroundColor
                                  : blackColor),
                        )
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        showFutureActivities = false;
                      });
                    },
                  )
                ],
              )),
          // if (showFutureActivities == true) DonationsHome() else NeedsHome()
          gapH12,
          showFutureActivities
              ? Upcoming(data: upcomingDatesList)
              : Passed(data: previousDatesList)
        ],
      ),
    );
  }
}
