import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/features/onboarding/corporate/corporateAccount.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import '../models/registration_data.dart';
import '../models/service_result.dart';
import '../database/registration_database.dart';

class RegistrationService {
  final NetworkHandler _networkHandler;
  final RegistrationDatabase _database;

  RegistrationService(this._networkHandler, this._database);

  Future<ServiceResult> submitBasicInfo({
    required String phoneNumber,
    required String email,
    required String productType,
    required bool isOnline,
  }) async {
    try {
      if (isOnline) {
        return await _submitBasicInfoOnline(phoneNumber, email, productType);
      } else {
        return await _submitBasicInfoOffline(phoneNumber, email, productType);
      }
    } catch (e) {
      return ServiceResult.error('Failed to submit basic info: $e');
    }
  }

  Future<ServiceResult> submitIdType({
    required String branch,
    required String documentName,
    required Uint8List? frontImage,
    required Uint8List? backImage,
    required bool isOnline,
    String? userId,
  }) async {
    try {
      if (isOnline) {
        return await _submitIdTypeOnline(
            branch, documentName, frontImage, backImage, userId);
      } else {
        return await _submitIdTypeOffline(
            branch, documentName, frontImage, backImage, userId);
      }
    } catch (e) {
      return ServiceResult.error('Failed to submit ID type: $e');
    }
  }

  Future<ServiceResult> submitSignature({
    required Uint8List signature,
    required bool isOnline,
    required String motherName,
    String? userId,
  }) async {
    try {
      if (isOnline) {
        return await _submitSignatureOnline(signature, motherName, userId);
      } else {
        return await _submitSignatureOffline(signature, userId);
      }
    } catch (e) {
      return ServiceResult.error('Failed to submit signature: $e');
    }
  }

  Future<ServiceResult> submitFinancialInfo({
    required String occupation,
    required String monthlyIncome,
    required String initialDeposit,
    required String sector,
    required bool isOnline,
    String? userId,
  }) async {
    try {
      if (isOnline) {
        print("466666666666666666666666666666666666665");
        return await _submitFinancialInfoOnline(
            occupation, monthlyIncome, initialDeposit, sector, userId);
      } else {
        return await _submitFinancialInfoOffline(
            occupation, monthlyIncome, initialDeposit, sector, userId);
      }
    } catch (e) {
      return ServiceResult.error('Failed to submit financial info: $e');
    }
  }

  Future<ServiceResult> submitPersonalInfo({
    required String? fullName,
    required String? surname,
    required String? motherName,
    required String? sex,
    required String? dateOfBirth,
    required String? title,
    required String? maritalStatus,
    required bool isOnline,
    String? userId,
  }) async {
    try {
      if (isOnline) {
        return await _submitPersonalInfoOnline(fullName, surname, motherName,
            sex, dateOfBirth, title, maritalStatus, userId);
      } else {
        return await _submitPersonalInfoOffline(fullName, surname, motherName,
            sex, dateOfBirth, title, maritalStatus, userId);
      }
    } catch (e) {
      return ServiceResult.error('Failed to submit personal info: $e');
    }
  }

  Future<ServiceResult> submitAddressInfo({
    required String? country,
    required String? issueAuthority,
    required String? issueDate,
    required String? expirayDate,
    required String? legalId,
    required String? state,
    required String? zoneSubCity,
    required String? streetAddress,
    required bool isOnline,
    String? userId,
  }) async {
    try {
      if (isOnline) {
        return await _submitAddressInfoOnline(
            country,
            issueAuthority,
            issueDate,
            expirayDate,
            legalId,
            state,
            zoneSubCity,
            streetAddress,
            userId);
      } else {
        return await _submitAddressInfoOffline(
            country,
            issueAuthority,
            issueDate,
            expirayDate,
            legalId,
            state,
            zoneSubCity,
            streetAddress,
            userId);
      }
    } catch (e) {
      return ServiceResult.error('Failed to submit address info: $e');
    }
  }

  Future<ServiceResult> submitPersonalPhoto({
    required Uint8List? photo,
    required bool isOnline,
    String? userId,
  }) async {
    try {
      if (isOnline) {
        return await _submitPersonalPhotoOnline(photo, userId);
      } else {
        return await _submitPersonalPhotoOffline(photo, userId);
      }
    } catch (e) {
      return ServiceResult.error('Failed to submit personal photo: $e');
    }
  }

  Future<ServiceResult> submitAccountType({
    required String accountType,
    required bool isOnline,
    String? userId,
  }) async {
    try {
      if (isOnline) {
        return await _submitAccountTypeOnline(accountType, userId);
      } else {
        return await _submitAccountTypeOffline(accountType, userId);
      }
    } catch (e) {
      return ServiceResult.error('Failed to submit account type: $e');
    }
  }

  Future<ServiceResult> _submitBasicInfoOnline(
      String phoneNumber, String email, String productType) async {
    try {
      final requestData = {
        'customerInfo.phone': '0$phoneNumber',
        'customerInfo.email': email,
        'customerInfo.percentageCompleted': 12.5,
        'customerInfo.status': 'INITIAL',
        'customerInfo.formCompleted': 0,
      };

      // Check if we have an existing userId (user coming back to update)
      final existingUserId = await _getExistingUserId(phoneNumber);

      if (existingUserId != null) {
        // Update existing user
        final response = await _networkHandler
            .put1('/api/v1/accounts/individual/$existingUserId', requestData)
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200 || response.statusCode == 201) {
          return ServiceResult.success(userId: existingUserId);
        } else {
          final errorResponse = jsonDecode(response.body);
          final errorMessage = errorResponse['message'] ??
              'Unable to update user, please try later';
          return ServiceResult.error(errorMessage);
        }
      } else {
        // Create new user
        final response = await _networkHandler
            .post1('/api/v1/accounts/individual', requestData)
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = json.decode(response.body);
          final userId = responseData['id'].toString();
          return ServiceResult.success(userId: userId);
        } else {
          final errorResponse = jsonDecode(response.body);
          final errorMessage = errorResponse['message'] ??
              'Unable to register, please try later';
          return ServiceResult.error(errorMessage);
        }
      }
    } on TimeoutException {
      return ServiceResult.error('Request timed out. Please try again.');
    } catch (e) {
      return ServiceResult.error('An error occurred: $e');
    }
  }

  Future<ServiceResult> _submitIdTypeOnline(String branch, String documentName,
      Uint8List? frontImage, Uint8List? backImage, String? userId) async {
    try {
      print("ttttttttttttttttttttttttttt");

      print(branch);
      print(frontImage);
      if (userId == null) {
        return ServiceResult.error(
            'User ID not found. Please complete step 1 first.');
      }

      final requestData = {
        'branch': branch,
        'residenceCard': frontImage,
        'customerInfo.documentName': documentName,
        // 'customerInfo.residenceCard': frontImage,
        // 'customerInfo.residenceCardBack': backImage,
        'accountType': '1',
        'percentageCompleted': 25,
        'status': 'INITIAL',
        'formCompleted': false,
      };

      final response = await _networkHandler
          .put1('/api/v1/accounts/individual/$userId', requestData)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServiceResult.success();
      } else {
        print(("333333333333333333333333333333333333333333"));
        final errorResponse = jsonDecode(response.body);
        final errorMessage =
            errorResponse['message'] ?? 'Failed to update user data';
        return ServiceResult.error(errorMessage);
      }
    } on TimeoutException {
      return ServiceResult.error('Request timed out. Please try again.');
    } catch (e) {
      print("1111111111111111111111111111111111111111111111111111111");
      print(e);
      return ServiceResult.error('An error occurred: $e');
    }
  }

  Future<ServiceResult> _submitSignatureOnline(
      Uint8List signature, String? motherName, String? userId) async {
    try {
      if (userId == null) {
        return ServiceResult.error(
            'User ID not found. Please complete previous steps first.');
      }

      // Validate userId format
      if (userId.isEmpty || !RegExp(r'^\d+$').hasMatch(userId)) {
        return ServiceResult.error(
            'Invalid user ID format. Please complete previous steps first.');
      }

      final requestData = {
        // 'customerInfo.signature': signature,
        'customerInfo.motherName': motherName,
        'percentageCompleted': 37.5,
        'status': 'INITIAL',
      };

      // Add retry logic for network issues
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          final response = await _networkHandler
              .put1('/api/v1/accounts/individual/$userId', requestData)
              .timeout(const Duration(seconds: 20)); // Increased timeout

          if (response.statusCode == 200 || response.statusCode == 201) {
            return ServiceResult.success();
          } else {
            final errorResponse = jsonDecode(response.body);
            final errorMessage =
                errorResponse['message'] ?? 'Failed to update signature';
            return ServiceResult.error(errorMessage);
          }
        } on TimeoutException {
          retryCount++;
          if (retryCount >= maxRetries) {
            return ServiceResult.error(
                'Request timed out after $maxRetries attempts. Please check your connection and try again.');
          }
          // Wait before retrying
          await Future.delayed(Duration(seconds: retryCount * 2));
        } catch (e) {
          if (e.toString().contains('Connection reset by peer') ||
              e.toString().contains('SocketException')) {
            retryCount++;
            if (retryCount >= maxRetries) {
              return ServiceResult.error(
                  'Network connection issue. Please check your internet connection and try again.');
            }
            // Wait before retrying
            await Future.delayed(Duration(seconds: retryCount * 2));
          } else {
            return ServiceResult.error('An error occurred: $e');
          }
        }
      }

      return ServiceResult.error(
          'Failed to update signature after $maxRetries attempts.');
    } catch (e) {
      return ServiceResult.error('An error occurred: $e');
    }
  }

  Future<ServiceResult> _submitFinancialInfoOnline(
      String occupation,
      String monthlyIncome,
      String initialDeposit,
      String sector,
      String? userId) async {
    try {
      print("jfkdfkdfdfkdjfdkkkkkkkkkkkkkkkkk");
      if (userId == null) {
        return ServiceResult.error(
            'User ID not found. Please complete previous steps first.');
      }

      final requestData = {
        'customerInfo.occupation': occupation,
        'customerInfo.monthlyIncome': monthlyIncome,
        'initialDeposit': initialDeposit,
        'customerInfo.sector': sector,
        'percentageCompleted': 50,
        'status': 'INITIAL',
      };

      print("jfkdfkdfdfkdjfdkkkkkkkkkkkkkkkkk");
      print(requestData);
      final response = await _networkHandler
          .put1('/api/v1/accounts/individual/$userId', requestData)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServiceResult.success();
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage =
            errorResponse['message'] ?? 'Failed to update financial info';
        return ServiceResult.error(errorMessage);
      }
    } on TimeoutException {
      return ServiceResult.error('Request timed out. Please try again.');
    } catch (e) {
      return ServiceResult.error('An error occurred: $e');
    }
  }

  Future<ServiceResult> _submitBasicInfoOffline(
      String phoneNumber, String email, String productType) async {
    try {
      if (!await _checkPermissions()) {
        return ServiceResult.error(
            'You don\'t have permission to create Account');
      }

      final customerData = {
        'phone': '0$phoneNumber',
        'email': email,
        'status': 'INITIAL',
        'userId': await _getCurrentUserId(),
      };

      final insertedId = await _database.insertCustomer(customerData);
      return ServiceResult.success(userId: insertedId.toString());
    } catch (e) {
      return ServiceResult.error('Error inserting customer data: $e');
    }
  }

  Future<ServiceResult> _submitIdTypeOffline(String branch, String documentName,
      Uint8List? frontImage, Uint8List? backImage, String? userId) async {
    try {
      if (userId == null) {
        return ServiceResult.error(
            'User ID not found. Please complete step 1 first.');
      }

      final updateData = {
        'branch': branch,
        'documentName': documentName,
        'residenceCard': frontImage,
        'residenceCardBack': backImage,
        'accountType': '1',
        'percentageCompleted': 25,
        'status': 'INITIAL',
        'formCompleted': 0,
        'id': userId,
      };

      final rowsAffected = await _database
          .updateCustomer(int.parse(userId), updateData)
          .timeout(const Duration(seconds: 10));

      if (rowsAffected > 0) {
        return ServiceResult.success();
      } else {
        return ServiceResult.error('Failed to update customer data');
      }
    } on TimeoutException {
      return ServiceResult.error('Update operation timed out.');
    } catch (e) {
      return ServiceResult.error('An error occurred: $e');
    }
  }

  Future<ServiceResult> _submitSignatureOffline(
      Uint8List signature, String? userId) async {
    try {
      if (userId == null) {
        return ServiceResult.error(
            'User ID not found. Please complete previous steps first.');
      }

      final updateData = {
        'signature': signature,
        'percentageCompleted': 37.5,
        'status': 'INITIAL',
        'id': userId,
      };

      final rowsAffected = await _database
          .updateCustomer(int.parse(userId), updateData)
          .timeout(const Duration(seconds: 10));

      if (rowsAffected > 0) {
        return ServiceResult.success();
      } else {
        return ServiceResult.error('Failed to update signature');
      }
    } on TimeoutException {
      return ServiceResult.error('Update operation timed out.');
    } catch (e) {
      return ServiceResult.error('An error occurred: $e');
    }
  }

  Future<ServiceResult> _submitPersonalPhotoOnline(
      Uint8List? photo, String? userId) async {
    try {
      print("djfdjfdfdkfhdfdkfdkjjjjjjjjjjj");

      print(photo);
      if (userId == null) {
        return ServiceResult.error(
            'User ID not found. Please complete previous steps first.');
      }

      // Validate userId format
      if (userId.isEmpty || !RegExp(r'^\d+$').hasMatch(userId)) {
        return ServiceResult.error(
            'Invalid user ID format. Please complete previous steps first.');
      }

      final requestData = {
        // 'customerInfo.photo': photo, // Photo will be handled separately if needed
        'percentageCompleted': 50,
        'status': 'INITIAL',
      };

      // Add retry logic for network issues
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          final response = await _networkHandler
              .put1('/api/v1/accounts/individual/$userId', requestData)
              .timeout(const Duration(seconds: 20));

          if (response.statusCode == 200 || response.statusCode == 201) {
            return ServiceResult.success();
          } else {
            final errorResponse = jsonDecode(response.body);
            final errorMessage =
                errorResponse['message'] ?? 'Failed to update personal photo';
            return ServiceResult.error(errorMessage);
          }
        } on TimeoutException {
          retryCount++;
          if (retryCount >= maxRetries) {
            return ServiceResult.error(
                'Request timed out after $maxRetries attempts. Please check your connection and try again.');
          }
          // Wait before retrying
          await Future.delayed(Duration(seconds: retryCount * 2));
        } catch (e) {
          if (e.toString().contains('Connection reset by peer') ||
              e.toString().contains('SocketException')) {
            retryCount++;
            if (retryCount >= maxRetries) {
              return ServiceResult.error(
                  'Network connection issue. Please check your internet connection and try again.');
            }
            // Wait before retrying
            await Future.delayed(Duration(seconds: retryCount * 2));
          } else {
            return ServiceResult.error('An error occurred: $e');
          }
        }
      }

      return ServiceResult.error(
          'Failed to update personal photo after $maxRetries attempts.');
    } catch (e) {
      return ServiceResult.error('An error occurred: $e');
    }
  }

  Future<ServiceResult> _submitPersonalPhotoOffline(
      Uint8List? photo, String? userId) async {
    try {
      if (userId == null) {
        return ServiceResult.error(
            'User ID not found. Please complete previous steps first.');
      }

      final updateData = {
        'photo': photo,
        'percentageCompleted': 50,
        'status': 'INITIAL',
        'id': userId,
      };

      final rowsAffected = await _database
          .updateCustomer(int.parse(userId), updateData)
          .timeout(const Duration(seconds: 10));

      if (rowsAffected > 0) {
        return ServiceResult.success();
      } else {
        return ServiceResult.error('Failed to update personal photo data');
      }
    } on TimeoutException {
      return ServiceResult.error('Update operation timed out.');
    } catch (e) {
      return ServiceResult.error('An error occurred: $e');
    }
  }

  Future<ServiceResult> _submitFinancialInfoOffline(
      String occupation,
      String monthlyIncome,
      String initialDeposit,
      String sector,
      String? userId) async {
    try {
      if (userId == null) {
        return ServiceResult.error(
            'User ID not found. Please complete previous steps first.');
      }

      final updateData = {
        'occupation': occupation,
        'monthlyIncome': monthlyIncome,
        'initialDeposit': initialDeposit,
        'sector': sector,
        'percentageCompleted': 50,
        'status': 'INITIAL',
        'id': userId,
      };

      final rowsAffected = await _database
          .updateCustomer(int.parse(userId), updateData)
          .timeout(const Duration(seconds: 10));

      if (rowsAffected > 0) {
        return ServiceResult.success();
      } else {
        return ServiceResult.error('Failed to update financial info');
      }
    } on TimeoutException {
      return ServiceResult.error('Update operation timed out.');
    } catch (e) {
      return ServiceResult.error('An error occurred: $e');
    }
  }

  Future<ServiceResult> _submitPersonalInfoOnline(
      String? fullName,
      String? surname,
      String? motherName,
      String? sex,
      String? dateOfBirth,
      String? title,
      String? maritalStatus,
      String? userId) async {
    try {
      print('kdfndfdkfkdnfdkssssfdfndnfd');
      if (userId == null) {
        return ServiceResult.error(
            'User ID not found. Please complete previous steps first.');
      }

      final requestData = {
        'customerInfo.fullName': fullName,
        'customerInfo.surname': surname,
        'customerInfo.motherName': motherName,
        'customerInfo.sex': sex,
        'customerInfo.dateOfBirth': dateOfBirth,
        'customerInfo.title': title,
        'customerInfo.maritalStatus': maritalStatus?.toUpperCase(),
        'percentageCompleted': 75,
        'status': 'INITIAL',
      };

      final response = await _networkHandler
          .put1('/api/v1/accounts/individual/$userId', requestData)
          .timeout(const Duration(seconds: 15));
      print('kdfndfdkfkdnfdkfdfndnfd');
      print(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServiceResult.success();
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage =
            errorResponse['message'] ?? 'Failed to update personal info';
        return ServiceResult.error(errorMessage);
      }
    } on TimeoutException {
      return ServiceResult.error('Request timed out. Please try again.');
    } catch (e) {
      return ServiceResult.error('An error occurred: $e');
    }
  }

  Future<ServiceResult> _submitPersonalInfoOffline(
      String? fullName,
      String? surname,
      String? motherName,
      String? sex,
      String? dateOfBirth,
      String? title,
      String? maritalStatus,
      String? userId) async {
    try {
      if (userId == null) {
        return ServiceResult.error(
            'User ID not found. Please complete previous steps first.');
      }

      final updateData = {
        'fullName': fullName,
        'surname': surname,
        'motherName': motherName,
        'sex': sex,
        'dateOfBirth': dateOfBirth,
        'title': title,
        'maritalStatus': maritalStatus,
        'percentageCompleted': 75,
        'status': 'INITIAL',
        'id': userId,
      };

      final rowsAffected = await _database
          .updateCustomer(int.parse(userId), updateData)
          .timeout(const Duration(seconds: 10));

      if (rowsAffected > 0) {
        return ServiceResult.success();
      } else {
        return ServiceResult.error('Failed to update personal info');
      }
    } on TimeoutException {
      return ServiceResult.error('Update operation timed out.');
    } catch (e) {
      return ServiceResult.error('An error occurred: $e');
    }
  }

  Future<ServiceResult> _submitAddressInfoOnline(
      String? country,
      String? issueAuthority,
      String? issueDate,
      String? expirayDate,
      String? legalId,
      String? state,
      String? zoneSubCity,
      String? streetAddress,
      String? userId) async {
    try {
      if (userId == null) {
        return ServiceResult.error(
            'User ID not found. Please complete previous steps first.');
      }

      final requestData = {
        'customerInfo.country': country,
        'customerInfo.issueAuthority': issueAuthority,
        'customerInfo.issueDate': issueDate,
        'customerInfo.expiryDate': expirayDate,
        'customerInfo.legalId': legalId,
        'customerInfo.state': state,
        'customerInfo.zoneSubCity': zoneSubCity,
        'customerInfo.streetAddress': streetAddress,
        'percentageCompleted': 87.5,
        'status': 'INITIAL',
      };

      final response = await _networkHandler
          .put1('/api/v1/accounts/individual/$userId', requestData)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServiceResult.success();
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage =
            errorResponse['message'] ?? 'Failed to update address info';
        return ServiceResult.error(errorMessage);
      }
    } on TimeoutException {
      return ServiceResult.error('Request timed out. Please try again.');
    } catch (e) {
      return ServiceResult.error('An error occurred: $e');
    }
  }

  Future<ServiceResult> _submitAddressInfoOffline(
      String? country,
      String? issueAuthority,
      String? issueDate,
      String? expirayDate,
      String? legalId,
      String? state,
      String? zoneSubCity,
      String? streetAddress,
      String? userId) async {
    try {
      if (userId == null) {
        return ServiceResult.error(
            'User ID not found. Please complete previous steps first.');
      }

      final updateData = {
        'country': country,
        'issueAuthority': issueAuthority,
        'issueDate': issueDate,
        'expirayDate': expirayDate,
        'legalId': legalId,
        'state': state,
        'zoneSubCity': zoneSubCity,
        'streetAddress': streetAddress,
        'percentageCompleted': 87.5,
        'status': 'INITIAL',
        'id': userId,
      };

      final rowsAffected = await _database
          .updateCustomer(int.parse(userId), updateData)
          .timeout(const Duration(seconds: 10));

      if (rowsAffected > 0) {
        return ServiceResult.success();
      } else {
        return ServiceResult.error('Failed to update address info');
      }
    } on TimeoutException {
      return ServiceResult.error('Update operation timed out.');
    } catch (e) {
      return ServiceResult.error('An error occurred: $e');
    }
  }

  Future<ServiceResult> _submitAccountTypeOnline(
      String accountType, String? userId) async {
    try {
      print("dfksnfkdndnfdndnnddnfndf");
      print(accountType);
      if (userId == null) {
        return ServiceResult.error(
            'User ID not found. Please complete previous steps first.');
      }

      final requestData = {
        'accountType': accountType,
        'percentageCompleted': 87.5,
        'status': 'INITIAL',
      };

      final response = await _networkHandler
          .put1('/api/v1/accounts/individual/$userId', requestData)
          .timeout(const Duration(seconds: 15));
      print("ytytytyytyt");
      print(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("ytytytyytyt");
        return ServiceResult.success();
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage =
            errorResponse['message'] ?? 'Failed to update account type';
        return ServiceResult.error(errorMessage);
      }
    } on TimeoutException {
      return ServiceResult.error('Request timed out. Please try again.');
    } catch (e) {
      return ServiceResult.error('An error occurred: $e');
    }
  }

  Future<ServiceResult> _submitAccountTypeOffline(
      String accountType, String? userId) async {
    try {
      if (userId == null) {
        return ServiceResult.error(
            'User ID not found. Please complete previous steps first.');
      }

      final updateData = {
        'accountType': accountType,
        'percentageCompleted': 87.5,
        'status': 'INITIAL',
        'id': userId,
      };

      final rowsAffected = await _database
          .updateCustomer(int.parse(userId), updateData)
          .timeout(const Duration(seconds: 10));

      if (rowsAffected > 0) {
        return ServiceResult.success();
      } else {
        return ServiceResult.error('Failed to update account type');
      }
    } on TimeoutException {
      return ServiceResult.error('Update operation timed out.');
    } catch (e) {
      return ServiceResult.error('An error occurred: $e');
    }
  }

  Future<bool> _checkPermissions() async {
    final role = await _getCurrentUserRole();
    return role == 'ACCOUNT-CREATOR' || role == 'AGENT';
  }

  Future<String> _getCurrentUserId() async {
    return 'current_user_id';
  }

  Future<String> _getCurrentUserRole() async {
    return 'ACCOUNT-CREATOR';
  }

  Future<String?> _getExistingUserId(String phoneNumber) async {
    try {
      // Check database for existing user with this phone number
      final existingUser = await _database.getCustomerByPhone('0$phoneNumber');
      if (existingUser != null) {
        return existingUser['id'].toString();
      }
      return null;
    } catch (e) {
      // If there's an error checking, assume no existing user
      return null;
    }
  }
}
