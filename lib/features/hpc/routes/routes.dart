import 'package:coopengageplus/features/crm/presentation/schedule/meetingSchedule.dart';
import 'package:coopengageplus/features/hpc/Dashboard/dashboard.dart';
import 'package:coopengageplus/features/hpc/presentation/crmChangeRequest/crmChangeRequest.dart';
import 'package:coopengageplus/features/hpc/presentation/feedback/feedback.dart';
import 'package:coopengageplus/features/hpc/presentation/language/changeLanguage.dart';
import 'package:coopengageplus/features/hpc/presentation/profile/hpcProfile.dart';
import 'package:get/get.dart';


class AppRoutes {
  static const String hpcmeetingschedule = '/hpcmeetingschedule';
  static const String hpcfeedback = '/hpcfeedback';
  static const String hpcDashboard = '/hpcdashboard';
  static const String hpcCRMChangeRequest = '/hpcCRMChangeRequest';
  static const String highClientProfilePage = '/highClientProfilePage';
  static const String changeLanguage = '/changeLanguage';
}

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.hpcmeetingschedule,
      page: () => MeetingSchedule(),
    ),
    GetPage(
      name: AppRoutes.hpcfeedback,
      page: () => HPCFeedback(),
    ),
    GetPage(
      name: AppRoutes.hpcDashboard,
      page: () => HPCDashBoard(),
    ),
    GetPage(
      name: AppRoutes.hpcCRMChangeRequest,
      page: () => HPCCRMChangeRequest(),
    ),
    GetPage(
      name: AppRoutes.highClientProfilePage,
      page: () => HighClientProfilePage(),
    ),
    GetPage(
      name: AppRoutes.changeLanguage,
      page: () => ChangeLanguagePage(),
    ),
    // GetPage(
    //   name: AppRoutes.addSchedule,
    //   page: () => MeetingSchedule(),
    // ),
    // GetPage(
    //   name: AppRoutes.textNote,
    //   page: () => TextNote(),
    // ),
    // GetPage(
    //   name: AppRoutes.voiceNote,
    //   page: () => VoiceNote(),
    // ),
    // GetPage(
    //   name: AppRoutes.cleintDetail,
    //   page: () => ClientDetails(),
    // ),
    // GetPage(
    //   name: AppRoutes.listOfCustomers,
    //   page: () => Listofcustomers(),
    // ),
  ];
}
