// import 'package:crm/src/constants/config/config.dart';

import 'package:coopengageplus/constants/config/config.dart';

class ApiPaths {
  static String baseUrl = AppConstants.baseUrl;

  static const auth = "auth";

  static const generateOtp = '$auth/generateOtp';
  static const verifyOtp = '$auth/verifyOtp';
  static const signup = '$auth/signup';
  static const signin = '$auth/signin';
}
