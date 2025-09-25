import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/customerOnboarding/_IndividualAccount/providers/registration_providers.dart';
import 'package:coopengageplus/features/onboarding/pages/home/HomePage.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
// import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/main.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/service_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationService {
  final NetworkHandler _networkHandler;
  // final RegistrationDatabase _database;
  final DatabaseHelper _database;

  RegistrationService(this._networkHandler, this._database);

  Future<ServiceResult> submitBasicInfo({
    required String phoneNumber,
    required String email,
    required String productType,
    String? userId,
  }) async {
    try {
      if (isOnline) {
        return await submitBasicInfoOnline(
          phoneNumber: phoneNumber,
          email: email,
          productType: productType,
          userId: userId,
        );
      } else {
        return await _submitBasicInfoOffline(
          phoneNumber: phoneNumber,
          email: email,
          // productType: productType,
          userId: userId,
        );
      }
    } catch (e) {
      return ServiceResult.error('Failed to submit basic info: $e');
    }
  }

  Future<ServiceResult> submitIdType({
    required String branch,
    required String documentName,
    required dynamic? frontImage,
    required dynamic? backImage,
    // required bool isOnline,
    String? userId,
  }) async {
    print("fdhfdhfdhfdfhdjfdjjfhdfddjjdf");
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
    required dynamic signature,
    // required bool isOnline,
    required String motherName,
    String? userId,
  }) async {
    try {
      if (isOnline) {
        return await _submitSignatureOnline(signature, motherName, userId);
      } else {
        return await _submitSignatureOffline(signature, motherName, userId);
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
    // required bool isOnline,
    String? userId,
  }) async {
    try {
      if (isOnline) {
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
    // required bool isOnline,
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
    // required bool isOnline,
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
    required dynamic? photo,
    // required bool isOnline,
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
    // required bool isOnline,
    String? userId,
  }) async {
    try {
      print("isondj");
      print(isOnline);
      if (isOnline) {
        return await _submitAccountTypeOnline(accountType, userId);
      } else {
        return await _submitAccountTypeOffline(accountType, userId);
      }
    } catch (e) {
      return ServiceResult.error('Failed to submit account type: $e');
    }
  }

  Future<ServiceResult> submitBasicInfoOnline({
    required String phoneNumber,
    required String email,
    required String productType,
    String? userId,
  }) async {
    try {
      print("isondj");
      print(isOnline);
      print("dkfjdfndfdjdfjddjjfdjfjddffd");
      print(userId);
      if (userId != null) {
        // UPDATE existing user
        final response = await _networkHandler.put1(
          '/api/v1/accounts/individual/$userId',
          {
            'customerInfo.phone': '0$phoneNumber',
            'customerInfo.email': email,
            'customerInfo.percentageCompleted': 12.5,
            'customerInfo.status': 'INITIAL',
            'customerInfo.formCompleted': 0,
          },
        );
        print('Update status code: \\${response.statusCode}');
        print('Update response body: \\${response.body}');
        if (response.statusCode == 200 || response.statusCode == 201) {
          return ServiceResult.success(userId: userId);
        } else {
          return ServiceResult.error('Failed to update user');
        }
      } else {
        // (Optional) If you never want to create, you can return an error here:
        return ServiceResult.error('No userId provided for update');
      }
    } catch (e) {
      return ServiceResult.error('Error in registration: $e');
    }
  }

  Future<ServiceResult> _submitIdTypeOnline(
    String branch,
    String documentName,
    dynamic? frontImage,
    dynamic? backImage,
    String? userId,
  ) async {
    try {
      print('Branch: $branch');
      print('Front Image: $frontImage');
      print('Back Image: $backImage');

      if (userId == null) {
        return ServiceResult.error(
          'User ID not found. Please complete step 1 first.',
        );
      }

      // Build request map dynamically
      final Map<String, dynamic> requestData = {
        'branch': branch,
        'customerInfo.documentName': documentName,
        'accountType': '1',
        'percentageCompleted': 25,
        'status': 'INITIAL',
        'formCompleted': false,
      };

      // Only include images if they are Uint8List (not String paths)
      if (frontImage != null && frontImage is Uint8List) {
        requestData['customerInfo.residenceCard'] = frontImage;
      }

      if (backImage != null && backImage is Uint8List) {
        requestData['customerInfo.residenceCardBack'] = backImage;
      }

      final response = await _networkHandler
          .put1('/api/v1/accounts/individual/$userId', requestData)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServiceResult.success();
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage =
            errorResponse['message'] ?? 'Failed to update user data';
        return ServiceResult.error(errorMessage);
      }
    } on TimeoutException {
      return ServiceResult.error('Request timed out. Please try again.');
    } catch (e) {
      print(e);
      return ServiceResult.error('An error occurred: $e');
    }
  }

  // Future<ServiceResult> _submitIdTypeOnline(String branch, String documentName,
  //     dynamic? frontImage, Uint8List? backImage, String? userId) async {
  //   try {
  //     print(branch);
  //     print(frontImage);
  //     if (userId == null) {
  //       return ServiceResult.error(
  //           'User ID not found. Please complete step 1 first.');
  //     }

  //     final requestData = {
  //       'branch': branch,
  //       'residenceCard': frontImage,
  //       'customerInfo.documentName': documentName,
  //       // 'customerInfo.residenceCard': frontImage,
  //       // 'customerInfo.residenceCardBack': backImage,
  //       'accountType': '1',
  //       'percentageCompleted': 25,
  //       'status': 'INITIAL',
  //       'formCompleted': false,
  //     };

  //     final response = await _networkHandler
  //         .put1('/api/v1/accounts/individual/$userId', requestData)
  //         .timeout(const Duration(seconds: 15));

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return ServiceResult.success();
  //     } else {
  //       final errorResponse = jsonDecode(response.body);
  //       final errorMessage =
  //           errorResponse['message'] ?? 'Failed to update user data';
  //       return ServiceResult.error(errorMessage);
  //     }
  //   } on TimeoutException {
  //     return ServiceResult.error('Request timed out. Please try again.');
  //   } catch (e) {
  //     print(e);
  //     return ServiceResult.error('An error occurred: $e');
  //   }
  // }

  Future<ServiceResult> _submitSignatureOnline(
      dynamic signature, String? motherName, String? userId) async {
    try {
      if (userId == null) {
        return ServiceResult.error(
            'User ID not found. Please complete previous steps first.');
      }
      print("dfdfhdjjfhdjfhdhjfjdhdfhdfjd");
      // Validate userId format
      if (userId.isEmpty || !RegExp(r'^\d+$').hasMatch(userId)) {
        return ServiceResult.error(
            'Invalid user ID format. Please complete previous steps first.');
      }

      // final requestData = {
      //   'customerInfo.signature': signature,
      //   'customerInfo.motherName': motherName,
      //   'percentageCompleted': 37.5,
      //   'status': 'INITIAL',
      // };
      print("kfdkfkjdjffjkdkjfkjdkjkfjkjdjkkjfkjdkfjdjkfjkdjkf");
      final requestData = {
        if (signature != null && signature is Uint8List)
          'customerInfo.signature': signature,
        if (motherName != null && motherName.isNotEmpty)
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
              .put1('/api/v1/accounts/individualdd/$userId', requestData)
              .timeout(const Duration(seconds: 30)); // Increased timeout

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

  Future<ServiceResult> _submitBasicInfoOffline({
    required String phoneNumber,
    required String email,
    String? userId,
  }) async {
    try {
      print("object32323232322dfdfdddfd");
      if (!await _checkPermissions()) {
        return ServiceResult.error(
            'You don\'t have permission to create Account');
      }

      print("[BASIC INFO OFFLINE] userId param: $userId");
      // Get the current user ID from token (the registering person)
      final existingUserId = await _getCurrentUserId();

      print("phonenumberndfbdhfbdhf ");
      print(phoneNumber);
      if (userId != null) {
        // UPDATE existing customer
        final updateData = {
          'phone': '0$phoneNumber',
          'email': email,
          'status': 'INITIAL',
          'userId': existingUserId,
        };
        print('[BASIC INFO OFFLINE] Updating customer with ID: $userId');
        print('[BASIC INFO OFFLINE] Update data: $updateData');
        final rowsAffected =
            await _database.updateCustomer(int.parse(userId), updateData);
        print('[BASIC INFO OFFLINE] rowsAffected: $rowsAffected');
        if (rowsAffected > 0) {
          print(
              '[BASIC INFO OFFLINE] Update success, returning userId: $userId');
          return ServiceResult.success(
              userId: userId, data: {'existingUserId': existingUserId});
        } else {
          print('[BASIC INFO OFFLINE] Update failed');
          return ServiceResult.error('Failed to update customer');
        }
      } else {
        // INSERT new customer
        final customerData = {
          'phone': '0$phoneNumber',
          'email': email,
          'status': 'INITIAL',
          'userId': existingUserId,
        };
        print('[BASIC INFO OFFLINE] Inserting new customer');
        print('[BASIC INFO OFFLINE] Insert data: $customerData');
        final insertedId = await _database.insertCustomer(customerData);
        print('[BASIC INFO OFFLINE] Inserted ID: $insertedId');
        final result = ServiceResult.success(
          userId: insertedId.toString(),
          data: {'existingUserId': existingUserId},
        );
        print(
            '[BASIC INFO OFFLINE] Returning ServiceResult with userId: ${result.userId}');
        return result;
      }
    } catch (e) {
      print('[BASIC INFO OFFLINE] Exception: $e');
      return ServiceResult.error('Error inserting/updating customer data: $e');
    }
  }

  Future<ServiceResult> _submitIdTypeOffline(String branch, String documentName,
      Uint8List? frontImage, Uint8List? backImage, String? userId) async {
    try {
      print("=== _submitIdTypeOffline Debug ===");
      print("Received userId: $userId");
      print("Branch: $branch");
      print("Document name: $documentName");

      // print(data);
      if (userId == null) {
        print("❌ User ID is null - returning error");
        return ServiceResult.error(
            'User ID not found. Please complete step 1 first.');
      }

      print("✅ User ID is valid: $userId");

      final updateData = {
        'branch': branch,
        'documentName': documentName,
        'residenceCard': frontImage,
        'residenceCardBack': backImage,
        'accountType': '1',
        'percentageCompleted': 25,
        'status': 'INITIAL',
        'formCompleted': 0,
        // 'id': currentUserId,
      };
      print(updateData);
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
      Uint8List signature, String motherName, String? userId) async {
    try {
      if (userId == null) {
        return ServiceResult.error(
            'User ID not found. Please complete previous steps first.');
      }

      // var currentUserId = await _getCurrentUserId();
      final updateData = {
        "motherName": motherName,
        'signature': signature,
        'percentageCompleted': 37.5,
        'status': 'INITIAL',
        // 'id': userId,
      };

      print("dshfhjdhfdhfhdjfjdjmotherName");
      print(motherName);

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
      dynamic? photo, String? userId) async {
    try {
      print("djfdjfdfdkfhdfdkfdkjjfhdhfdjjjjjjjjjj");

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
        if (photo != null && photo is Uint8List)
          'customerInfo.signature': photo,
        // 'customerInfo.photo':
        //     photo, // Photo will be handled separately if needed

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
      var currentUserId = await _getCurrentUserId();
      final updateData = {
        'photo': photo,
        'percentageCompleted': 50,
        'status': 'INITIAL',
        // 'id': userId,
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
      print("gememchh");
      if (userId == null) {
        return ServiceResult.error(
            'User ID not found. Please complete previous steps first.');
      }
      var currentUserId = await _getCurrentUserId();
      final updateData = {
        'occupation': occupation,
        'monthlyIncome': monthlyIncome,
        'initialDeposit': initialDeposit,
        // 'sector': sector,
        'percentageCompleted': 50,
        'status': 'INITIAL',
        // 'id': userId,
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
        return ServiceResult.success(userId: userId);
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

      print("personal information ");
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
        'customerInfo.country': "ETHIOPIA",
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
      // final existingUserId = await _getExistingUserId(phoneNumber);
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
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      var decodedToken = JwtDecoder.decode(token);

      print("gememememem");
      print(decodedToken['userId']);
      username = decodedToken['sub'] ?? "User";
      firstLetter = username!.isNotEmpty ? username![0].toUpperCase() : '';

      final userId = decodedToken['userId'];
      if (userId != null) {
        return userId.toString();
      } else {
        throw Exception('User ID not found in token');
      }
    } else {
      throw Exception('No valid token found. Please log in again.');
    }
  }

  Future<String> _getCurrentUserRole() async {
    return 'ACCOUNT-CREATOR';
  }
}
