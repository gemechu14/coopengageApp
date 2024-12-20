import 'package:intl/intl.dart';

String convertTo24HourFormat(String time) {
  final parsedTime =
      DateFormat('h:mm a').parse(time); // Parse input like "3:50 PM"
  return DateFormat('HH:mm').format(parsedTime); // Format to "15:50"
}
