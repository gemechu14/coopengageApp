// lib/routes/routes.dart

import 'package:coopengageplus/features/crm/CRMMainScreen.dart';
import 'package:coopengageplus/features/crm/ListOfCustomers.dart';
import 'package:coopengageplus/features/crm/presentation/client_details/client_details.dart';
import 'package:coopengageplus/features/crm/presentation/dashboard/CRMDashboard.dart';
import 'package:coopengageplus/features/crm/presentation/notes/TextNote.dart';
import 'package:coopengageplus/features/crm/presentation/notes/VoiceNote.dart';
import 'package:coopengageplus/features/crm/presentation/notes/noteScreen.dart';
import 'package:coopengageplus/features/crm/presentation/profile/profileScreen.dart';
import 'package:coopengageplus/features/crm/presentation/schedule/Schedule.dart';
import 'package:coopengageplus/features/crm/presentation/schedule/meetingSchedule.dart';
import 'package:coopengageplus/features/crm/presentation/schedule/taskSchedule.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const String home = '/home';
  static const String initial = '/';
  static const String schedule = '/schedule';
  static const String notes = '/notes';

  static const String profile = '/profile';
  static const String addTask = '/addTask';

  static const String addSchedule = '/addSchedule';

  static const String textNote = '/textNote';

  static const String voiceNote = '/voiceNote';
  static const String cleintDetail = '/cleintDetail';
  static const String listOfCustomers = '/listOfCustomers';
  static const String meetingDetail = '/meetingDetail';
}

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => CRMDashboard(),
    ),
    GetPage(
      name: AppRoutes.initial,
      page: () => CRMMainScreen(),
    ),
    GetPage(
      name: AppRoutes.schedule,
      page: () => Schedule(),
    ),
    GetPage(
      name: AppRoutes.notes,
      page: () => Notescreen(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.addTask,
      page: () => Taskschedule(),
    ),
    GetPage(
      name: AppRoutes.addSchedule,
      page: () => MeetingSchedule(),
    ),
    GetPage(
      name: AppRoutes.textNote,
      page: () => TextNote(),
    ),
    GetPage(
      name: AppRoutes.voiceNote,
      page: () => VoiceNote(),
    ),
    GetPage(
      name: AppRoutes.cleintDetail,
      page: () => ClientDetails(),
    ),
    GetPage(
      name: AppRoutes.listOfCustomers,
      page: () => Listofcustomers(),
    ),
    // GetPage(
    //   name: AppRoutes.meetingDetail,
    //   page: () => ScheduleDetails(),
    // ),
  ];
}
