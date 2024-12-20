import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AppointmentTimeCard extends StatelessWidget {
  final DateTime selectedDate; // Receive selectedDate

  const AppointmentTimeCard({Key? key, required this.selectedDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current date and time
    DateTime currentDateTime = DateTime.now();

    // Check if selectedDate is today
    bool isToday = selectedDate.year == currentDateTime.year &&
        selectedDate.month == currentDateTime.month &&
        selectedDate.day == currentDateTime.day;

    // If the selected date is today, start from the current time
    DateTime startTime = isToday
        ? DateTime(currentDateTime.year, currentDateTime.month,
            currentDateTime.day, currentDateTime.hour)
        : DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0);

    // Create a list of hours for the next 24 hours starting from the startTime
    List<DateTime> hourlyTimes = List.generate(
      24,
      (index) => startTime.add(Duration(hours: index)),
    );

    return SfCalendar();
    // SingleChildScrollView(
    //   child: Column(
    //     children: hourlyTimes.map((time) {
    //       // Format the time to show hours and AM/PM
    //       String hourText = _getFormattedTime(time);

    //       return Padding(
    //         padding: const EdgeInsets.symmetric(vertical: 8.0),
    //         child: Column(
    //           children: [
    //             Text(hourText,
    //                 style:
    //                     TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    //             Container(
    //               margin: const EdgeInsets.symmetric(vertical: 8.0),
    //               height: 1,
    //               width: 50, // Line length (adjustable)
    //               color: Colors.black,
    //             ),
    //           ],
    //         ),
    //       );
    //     }).toList(),
    //   ),
    // );
  }

  // Method to format the time to show hours in AM/PM format
  String _getFormattedTime(DateTime time) {
    int hour = time.hour;
    String period = hour < 12 ? 'AM' : 'PM';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour; // Adjust for 12:00 PM to 12:00 AM
    return '$hour $period';
  }
}
