import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/registration_service.dart';
import '../providers/registration_providers.dart';

// Controller Layer - Handles business logic and coordinates between UI and Services
class RegistrationController {
  final RegistrationService _registrationService;
  final Ref _ref;
  final StepCompletionNotifier _stepCompletionNotifier;

  RegistrationController({
    required RegistrationService registrationService,
    required Ref ref,
    required StepCompletionNotifier stepCompletionNotifier,
  })  : _registrationService = registrationService,
        _ref = ref,
        _stepCompletionNotifier = stepCompletionNotifier;

  // Getter methods to access notifiers
  RegistrationDataNotifier get _registrationDataNotifier =>
      _ref.read(registrationDataProvider.notifier);
  FormValidationNotifier get _formValidationNotifier =>
      _ref.read(formValidationProvider.notifier);

  // Step 1: Basic Info Controller
  Future<bool> handleBasicInfoStep({
    required String phoneNumber,
    required String email,
    required String? productType,
    // required bool isOnline,
    String? userId,
  }) async {
    try {
      // Clear previous errors
      _formValidationNotifier.clearAllErrors();

      // Validate inputs
      final validationResult =
          _validateBasicInfo(phoneNumber, email, productType);
      if (!validationResult.isValid) {
        return false;
      }

      // Always use the latest customerId from state if userId is not provided
      final currentCustomerId = userId ?? _ref.read(registrationDataProvider).customerId;
      print('[CONTROLLER] Using userId/customerId: $currentCustomerId');

      // Submit to service
      final serviceResult = await _registrationService.submitBasicInfo(
        phoneNumber: phoneNumber,
        email: email,
        productType: productType ?? '',
        // isOnline: isOnline,
        userId: currentCustomerId,
      );

      print('[CONTROLLER] ServiceResult.userId: ${serviceResult.userId}');

      if (serviceResult.isSuccess && serviceResult.userId != null) {
        // Store the userId if it's returned (new user created or updated)
        _ref.read(userIdProvider.notifier).setUserId(serviceResult.userId!);
        // Store the new customer ID in registration data for subsequent steps
        _registrationDataNotifier.updateBasicInfo(
          phone: phoneNumber,
          email: email,
          productType: productType,
          customerId: serviceResult.userId!, // Store the new or updated customer ID
        );
        print("=== Basic Info Step Debug ===");
        print("New customer ID stored: ${serviceResult.userId}");
      }
      // Store the existing user ID (the registering person) if available
      if (serviceResult.hasData) {
        final existingUserId = serviceResult.getData<String>('existingUserId');
        if (existingUserId != null) {
          print('Registering person ID: $existingUserId');
        }
      }

      // Mark step as complete
      _stepCompletionNotifier.markStepComplete(0);

      // Update progress
      _registrationDataNotifier.updateProgress(12.5);

      return serviceResult.isSuccess;
    } catch (e) {
      _formValidationNotifier.setError(
          'submission', 'An unexpected error occurred: $e');
      return false;
    }
  }

  // Step 2: ID Type Controller
  Future<bool> handleIdTypeStep({
    required String? branch,
    required String? documentName,
    required Uint8List? frontImage,
    required Uint8List? backImage,
    
    String? userId,
  }) async {
    try {
      // Clear previous errors
      _formValidationNotifier.clearAllErrors();

      // Validate inputs
      final validationResult =
          _validateIdType(branch, documentName, frontImage, backImage);
      if (!validationResult.isValid) {
        return false;
      }

      // Update registration data
      _registrationDataNotifier.updateIdTypeInfo(
        branch: branch,
        documentName: documentName,
        residenceCard: frontImage,
        residenceCardBack: backImage,
      );

      // Get the user ID to use - prefer provided userId, fallback to customerId from registration data
      final registrationData = _ref.read(registrationDataProvider);
      final userToUse = userId ?? registrationData.customerId;

      // Debug prints
      print("=== ID Type Step Debug ===");
      print("Provided userId: $userId");
      print("Registration data customerId: ${registrationData.customerId}");
      print("Final userToUse: $userToUse");
      // print("Is online: $isOnline");

      // Submit to service
      final serviceResult = await _registrationService.submitIdType(
        branch: branch ?? '',
        documentName: documentName ?? '',
        frontImage: frontImage,
        backImage: backImage,
        // isOnline: isOnline,
        userId: userToUse,
      );

      if (serviceResult.isSuccess) {
        // Mark step as complete
        _stepCompletionNotifier.markStepComplete(1);

        // Update progress
        _registrationDataNotifier.updateProgress(25.0);

        return true;
      } else {
        // Show service error
        _formValidationNotifier.setError(
            'submission', serviceResult.errorMessage!);
        return false;
      }
    } catch (e) {
      _formValidationNotifier.setError(
          'submission', 'An unexpected error occurred: $e');
      return false;
    }
  }

  // Step 3: Signature Controller
  Future<bool> handleSignatureStep({
    required Uint8List? signature,
    required bool isOnline,
    String? userId,
  }) async {
    try {
      _formValidationNotifier.clearAllErrors();

      // Get mother name from registration data
      final registrationData = _ref.read(registrationDataProvider);
      final motherName = registrationData.motherName;

      // Validate mother name
      if (motherName == null || motherName.trim().isEmpty) {
        _formValidationNotifier.setError(
            'motherName', 'Mother name is required');
        return false;
      }

      // Validate signature
      // if (signature == null) {
      //   // _formValidationNotifier.setError('signature', 'Signature is required');
      //   return false;
      // }

      // Update registration data
      _registrationDataNotifier.updateSignature(
        signature: signature,
      );

      // Get the user ID to use - prefer provided userId, fallback to customerId from registration data
      final userToUse = userId ?? registrationData.customerId;

      // Submit to service
      final serviceResult = await _registrationService.submitSignature(
        // signature: signature!,
        signature: signature ?? Uint8List(0),
        motherName: motherName,
        userId: userToUse,
      );

      if (serviceResult.isSuccess) {
        _stepCompletionNotifier.markStepComplete(2);
        _registrationDataNotifier.updateProgress(37.5);
        return true;
      } else {
        // Provide more specific error messages
        String errorMessage = serviceResult.errorMessage!;
        if (errorMessage.contains('Connection reset by peer') ||
            errorMessage.contains('SocketException') ||
            errorMessage.contains('Network connection issue')) {
          errorMessage =
              'Network connection issue. Please check your internet connection and try again.';
        } else if (errorMessage.contains('timed out')) {
          errorMessage =
              'Request timed out. Please check your connection and try again.';
        }

        _formValidationNotifier.setError('submission', errorMessage);
        return false;
      }
    } catch (e) {
      String errorMessage = 'An unexpected error occurred: $e';
      if (e.toString().contains('Connection reset by peer')) {
        errorMessage =
            'Network connection issue. Please check your internet connection and try again.';
      }
      _formValidationNotifier.setError('submission', errorMessage);
      return false;
    }
  }

  // Step 4: Personal Photo Controller
  Future<bool> handlePersonalPhotoStep({
    required Uint8List? photo,
    required bool isOnline,
    String? userId,
  }) async {
    try {
      _formValidationNotifier.clearAllErrors();

      // Update registration data
      _registrationDataNotifier.updatePhoto(photo: photo);

      // Get the user ID to use - prefer provided userId, fallback to customerId from registration data
      final registrationData = _ref.read(registrationDataProvider);
      final userToUse = userId ?? registrationData.customerId;

      // Submit to service
      final serviceResult = await _registrationService.submitPersonalPhoto(
        photo: photo,
        // isOnline: isOnline,
        userId: userToUse,
      );

      if (serviceResult.isSuccess) {
        _stepCompletionNotifier.markStepComplete(3);
        _registrationDataNotifier.updateProgress(50.0);
        return true;
      } else {
        _formValidationNotifier.setError(
            'submission', serviceResult.errorMessage!);
        return false;
      }
    } catch (e) {
      _formValidationNotifier.setError(
          'submission', 'An unexpected error occurred: $e');
      return false;
    }
  }

  // Step 5: Financial Info Controller
  Future<bool> handleFinancialInfoStep({
    required String? occupation,
    required String? monthlyIncome,
    required String? initialDeposit,
    required String? sector,
    required bool isOnline,
    String? userId,
  }) async {
    try {
      _formValidationNotifier.clearAllErrors();

      // Validate inputs
      final validationResult = _validateFinancialInfo(
          occupation, monthlyIncome, initialDeposit, sector);
      if (!validationResult.isValid) {
        return false;
      }

      // Update registration data
      _registrationDataNotifier.updateFinancialInfo(
        occupation: occupation,
        monthlyIncome: monthlyIncome,
        initialDeposit: initialDeposit,
        sector: sector,
      );

      // Get the user ID to use - prefer provided userId, fallback to customerId from registration data
      final registrationData = _ref.read(registrationDataProvider);
      final userToUse = userId ?? registrationData.customerId;

      // Submit to service
      final serviceResult = await _registrationService.submitFinancialInfo(
        occupation: occupation ?? '',
        monthlyIncome: monthlyIncome ?? '',
        initialDeposit: initialDeposit ?? '',
        sector: sector ?? '',
        // isOnline: isOnline,
        userId: userToUse,
      );

      if (serviceResult.isSuccess) {
        _stepCompletionNotifier.markStepComplete(4);
        _registrationDataNotifier.updateProgress(62.5);
        return true;
      } else {
        _formValidationNotifier.setError(
            'submission', serviceResult.errorMessage!);
        return false;
      }
    } catch (e) {
      _formValidationNotifier.setError(
          'submission', 'An unexpected error occurred: $e');
      return false;
    }
  }

  // Step 6: Personal Info Controller
  Future<bool> handlePersonalInfoStep({
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
      _formValidationNotifier.clearAllErrors();

      // Validate personal info inputs only
      final personalValidationResult = _validatePersonalInfo(
          fullName, surname, sex, dateOfBirth, title, maritalStatus);
      if (!personalValidationResult.isValid) {
        return false;
      }

      // Update registration data
      _registrationDataNotifier.updatePersonalInfo(
        fullName: fullName,
        surname: surname,
        motherName: motherName,
        sex: sex,
        dateOfBirth: dateOfBirth,
        title: title,
        maritalStatus: maritalStatus,
      );

      // Get the user ID to use - prefer provided userId, fallback to customerId from registration data
      final registrationData = _ref.read(registrationDataProvider);
      final userToUse = userId ?? registrationData.customerId;

      // Submit personal info to service
      final personalServiceResult =
          await _registrationService.submitPersonalInfo(
        fullName: fullName,
        surname: surname,
        motherName: motherName,
        sex: sex,
        dateOfBirth: dateOfBirth,
        title: title,
        maritalStatus: maritalStatus,
        // isOnline: isOnline,
        userId: userToUse,
      );

      if (personalServiceResult.isSuccess) {
        // Mark step as complete
        _stepCompletionNotifier.markStepComplete(5);
        _registrationDataNotifier.updateProgress(75.0);
        return true;
      } else {
        // Show service error
        _formValidationNotifier.setError(
            'submission', personalServiceResult.errorMessage!);
        return false;
      }
    } catch (e) {
      _formValidationNotifier.setError(
          'submission', 'An unexpected error occurred: $e');
      return false;
    }
  }

  // Step 7: Address Info Controller
  Future<bool> handleAddressInfoStep({
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
      _formValidationNotifier.clearAllErrors();

      // Validate address info inputs
      final addressValidationResult = _validateAddressInfo(
          legalId,
          issueAuthority,
          issueDate,
          expirayDate,
          state,
          zoneSubCity,
          streetAddress);
      if (!addressValidationResult.isValid) {
        return false;
      }

      // Update registration data
      _registrationDataNotifier.updateAddressInfo(
        country: country,
        issueAuthority: issueAuthority,
        issueDate: issueDate,
        expirayDate: expirayDate,
        legalId: legalId,
        stateValue: state,
        zoneSubCity: zoneSubCity,
        streetAddress: streetAddress,
      );

      // Get the user ID to use - prefer provided userId, fallback to customerId from registration data
      final registrationData = _ref.read(registrationDataProvider);
      final userToUse = userId ?? registrationData.customerId;

      // Submit address info to service
      final serviceResult = await _registrationService.submitAddressInfo(
        country: country,
        issueAuthority: issueAuthority,
        issueDate: issueDate,
        expirayDate: expirayDate,
        legalId: legalId,
        state: state,
        zoneSubCity: zoneSubCity,
        streetAddress: streetAddress,
        // isOnline: isOnline,
        userId: userToUse,
      );

      if (serviceResult.isSuccess) {
        // Mark step as complete
        _stepCompletionNotifier.markStepComplete(6);
        _registrationDataNotifier.updateProgress(87.5);
        return true;
      } else {
        // Show service error
        _formValidationNotifier.setError(
            'submission', serviceResult.errorMessage!);
        return false;
      }
    } catch (e) {
      _formValidationNotifier.setError(
          'submission', 'An unexpected error occurred: $e');
      return false;
    }
  }

  // Step 8: Account Type Controller
  Future<bool> handleAccountTypeStep({
    required String? accountType,
    required bool isOnline,
    String? userId,
  }) async {
    try {
      print("=== handleAccountTypeStep called ===");
      print("accountType ID: $accountType");
      print("isOnline: $isOnline");
      print("userId: $userId");

      _formValidationNotifier.clearAllErrors();

      // Validate account type selection
      if (accountType == null || accountType.isEmpty) {
        _formValidationNotifier.setError(
            'accountType', 'Please select an account type');
        return false;
      }

      // Get the user ID to use - prefer provided userId, fallback to customerId from registration data
      final registrationData = _ref.read(registrationDataProvider);
      final userToUse = userId ?? registrationData.customerId;

      // Submit account type using registration service
      print("Calling _registrationService.submitAccountType...");
      final result = await _registrationService.submitAccountType(
        accountType: accountType,
        // isOnline: isOnline,
        userId: userToUse,
      );

      if (result.isSuccess) {
        // Update registration data
        _registrationDataNotifier.updateAccountType(accountType);
        _stepCompletionNotifier.markStepComplete(7);
        _registrationDataNotifier.updateProgress(87.5);
        return true;
      } else {
        _formValidationNotifier.setError('accountType',
            result.errorMessage ?? 'Failed to submit account type');
        return false;
      }
    } catch (e) {
      _formValidationNotifier.setError(
          'submission', 'An unexpected error occurred: $e');
      return false;
    }
  }

  // Step 8: Terms and Conditions Controller
  Future<bool> handleTermsConditionsStep({
    required bool? termsAccepted,
  }) async {
    try {
      _formValidationNotifier.clearAllErrors();

      // Validate terms acceptance
      if (termsAccepted != true) {
        _formValidationNotifier.setError('termsAccepted',
            'You must accept the terms and conditions to continue');
        return false;
      }

      // Mark step as complete
      _stepCompletionNotifier.markStepComplete(8);
      _registrationDataNotifier.updateProgress(100.0);
      return true;
    } catch (e) {
      _formValidationNotifier.setError(
          'submission', 'An unexpected error occurred: $e');
      return false;
    }
  }

  // Validation methods
  ValidationResult _validateBasicInfo(
      String phoneNumber, String email, String? productType) {
    final errors = <String, String>{};

    // Validate product type
    if (productType == null || productType.isEmpty) {
      errors['productType'] = 'Product Type is required';
    }

    // Validate phone number
    if (phoneNumber.trim().isEmpty) {
      errors['phone'] = 'Phone Number is required';
    } else if (phoneNumber.trim().length != 9) {
      errors['phone'] = 'Phone Number must be 9 digits';
    }

    // Validate email (optional but if provided, must be valid)
    if (email.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email.trim())) {
        errors['email'] = 'Please enter a valid email address';
      }
    }

    // Set errors in validation notifier
    errors.forEach((field, error) {
      _formValidationNotifier.setError(field, error);
    });

    return ValidationResult(isValid: errors.isEmpty);
  }

  ValidationResult _validateIdType(String? branch, String? documentName,
      Uint8List? frontImage, Uint8List? backImage) {
    final errors = <String, String>{};

    // Validate branch
    if (branch == null || branch.isEmpty) {
      errors['branch'] = 'Branch is required';
    }

    // Validate document type
    if (documentName == null || documentName.isEmpty) {
      errors['documentType'] = 'Document Type is required';
    }

    // Validate front image
    // if (frontImage == null) {
    //   errors['frontImage'] = 'Front photo is required';
    // }

    // Validate back image
    // if (backImage == null) {
    //   errors['backImage'] = 'Back photo is required';
    // }

    // Set errors in validation notifier
    errors.forEach((field, error) {
      _formValidationNotifier.setError(field, error);
    });

    return ValidationResult(isValid: errors.isEmpty);
  }

  ValidationResult _validatePersonalInfo(
    String? fullName,
    String? surname,
    // String? motherName,
    String? sex,
    String? dateOfBirth,
    String? title,
    String? maritalStatus,
  ) {
    bool isValid = true;

    // Validate full name
    if (fullName == null || fullName.trim().isEmpty) {
      _formValidationNotifier.setError('fullName', 'Full name is required');
      isValid = false;
    } else if (fullName.trim().length < 2) {
      _formValidationNotifier.setError(
          'fullName', 'Full name must be at least 2 characters');
      isValid = false;
    }

    // Validate surname
    if (surname == null || surname.trim().isEmpty) {
      _formValidationNotifier.setError('surname', 'Surname is required');
      isValid = false;
    } else if (surname.trim().length < 2) {
      _formValidationNotifier.setError(
          'surname', 'Surname must be at least 2 characters');
      isValid = false;
    }

    // Validate sex
    if (sex == null || sex.isEmpty) {
      _formValidationNotifier.setError('gender', 'Gender is required');
      isValid = false;
    }

    // Validate date of birth
    if (dateOfBirth == null || dateOfBirth.isEmpty) {
      _formValidationNotifier.setError(
          'dateOfBirth', 'Date of birth is required');
      isValid = false;
    }

    // Validate title
    if (title == null || title.isEmpty) {
      _formValidationNotifier.setError('title', 'Title is required');
      isValid = false;
    }

    // Validate marital status
    if (maritalStatus == null || maritalStatus.isEmpty) {
      _formValidationNotifier.setError(
          'maritalStatus', 'Marital status is required');
      isValid = false;
    }

    return ValidationResult(isValid: isValid);
  }

  ValidationResult _validateAddressInfo(
    String? legalId,
    String? issueAuthority,
    String? issueDate,
    String? expirayDate,
    String? state,
    String? zoneSubCity,
    String? streetAddress,
  ) {
    bool isValid = true;

    // Validate legal ID (required)
    if (legalId == null || legalId.trim().isEmpty) {
      _formValidationNotifier.setError('legalId', 'Legal ID is required');
      isValid = false;
    } else if (legalId.trim().length < 3) {
      _formValidationNotifier.setError(
          'legalId', 'Legal ID must be at least 3 characters');
      isValid = false;
    }

    // Validate state (optional but recommended)
    if (state == null || state.isEmpty) {
      _formValidationNotifier.setError('state', 'Please select a state');
      isValid = false;
    }

    // Validate zone subcity (optional)
    if (zoneSubCity != null &&
        zoneSubCity.trim().isNotEmpty &&
        zoneSubCity.trim().length < 2) {
      _formValidationNotifier.setError(
          'zoneSubCity', 'Zone subcity must be at least 2 characters');
      isValid = false;
    }

    // Validate street address (optional)
    if (streetAddress != null &&
        streetAddress.trim().isNotEmpty &&
        streetAddress.trim().length < 2) {
      _formValidationNotifier.setError(
          'streetAddress', 'Woreda must be at least 2 characters');
      isValid = false;
    }

    // Validate issue authority (optional)
    if (issueAuthority != null &&
        issueAuthority.trim().isNotEmpty &&
        issueAuthority.trim().length < 2) {
      _formValidationNotifier.setError(
          'issueAuthority', 'Issue authority must be at least 2 characters');
      isValid = false;
    }

    // Validate issue date (optional)
    if (issueDate != null && issueDate.isNotEmpty) {
      try {
        DateTime.parse(issueDate);
      } catch (e) {
        _formValidationNotifier.setError(
            'issueDate', 'Please enter a valid issue date');
        isValid = false;
      }
    }

    // Validate expire date (optional)
    if (expirayDate != null && expirayDate.isNotEmpty) {
      try {
        DateTime.parse(expirayDate);
      } catch (e) {
        _formValidationNotifier.setError(
            'expireDate', 'Please enter a valid expire date');
        isValid = false;
      }
    }

    return ValidationResult(isValid: isValid);
  }

  ValidationResult _validateFinancialInfo(String? occupation,
      String? monthlyIncome, String? initialDeposit, String? sector) {
    final errors = <String, String>{};

    // Validate sector (required)
    if (sector == null || sector.isEmpty) {
      errors['sector'] = 'Sector is required';
    }

    // Validate occupation (required)
    if (occupation == null || occupation.trim().isEmpty) {
      errors['occupation'] = 'Occupation is required';
    }

    // Validate initial deposit (required)
    if (initialDeposit == null || initialDeposit.trim().isEmpty) {
      errors['initialDeposit'] = 'Initial Deposit is required';
    }

    // Monthly income is optional as per original code
    // No validation for this field

    // Set errors in validation notifier
    errors.forEach((field, error) {
      _formValidationNotifier.setError(field, error);
    });

    return ValidationResult(isValid: errors.isEmpty);
  }

  // Utility methods
  void resetStep(int stepIndex) {
    _stepCompletionNotifier.markStepIncomplete(stepIndex);
    _formValidationNotifier.clearAllErrors();
  }

  void resetAllSteps() {
    _stepCompletionNotifier.reset();
    _formValidationNotifier.clearAllErrors();
    _registrationDataNotifier.reset();
    _ref.read(userIdProvider.notifier).clear();
  }

  double getProgressPercentage() {
    final completedSteps = _stepCompletionNotifier.completedStepsCount;
    return (completedSteps / 9) * 100; // Assuming 9 total steps
  }

  bool isStepComplete(int stepIndex) {
    return _stepCompletionNotifier.isStepComplete(stepIndex);
  }

  int getCompletedStepsCount() {
    return _stepCompletionNotifier.completedStepsCount;
  }

  // Public getter for validation errors
  Map<String, String?> get validationErrors => _formValidationNotifier.state;

  // Method called by the registration screen
  Future<bool> validateAndSaveStep(int step, WidgetRef ref) async {
    switch (step) {
      case 0: // Basic Info
        final phoneController = ref.read(phoneControllerProvider);
        final emailController = ref.read(emailControllerProvider);
        final data = ref.read(registrationDataProvider);
        return await handleBasicInfoStep(
          phoneNumber: phoneController.text.trim(),
          email: emailController.text.trim(),
          productType: data.productType,
          // isOnline: ref.read(connectivityProvider),
        );
      case 1: // ID Type
        final data = ref.read(registrationDataProvider);
        final userId = ref.read(userIdProvider);
        return await handleIdTypeStep(
          branch: data.branch,
          documentName: data.documentName,
          frontImage: data.residenceCard,
          backImage: data.residenceCardBack,
          // isOnline: ref.read(connectivityProvider),
          userId: userId,
        );
      case 2: // Signature
        final data = ref.read(registrationDataProvider);
        final userId = ref.read(userIdProvider);
        return await handleSignatureStep(
          signature: data.signature,
          isOnline: ref.read(connectivityProvider),
          userId: userId,
        );
      case 3: // Personal Photo
        final data = ref.read(registrationDataProvider);
        final userId = ref.read(userIdProvider);
        return await handlePersonalPhotoStep(
          photo: data.photo,
          isOnline: ref.read(connectivityProvider),
          userId: userId,
        );
      case 4: // Financial Info
        final data = ref.read(registrationDataProvider);
        final userId = ref.read(userIdProvider);
        return await handleFinancialInfoStep(
          occupation: data.occupation,
          monthlyIncome: data.monthlyIncome,
          initialDeposit: data.initialDeposit,
          sector: data.sector,
          isOnline: ref.read(connectivityProvider),
          userId: userId,
        );
      case 5: // Personal Info (step 6)
        final data = ref.read(registrationDataProvider);
        final userId = ref.read(userIdProvider);
        return await handlePersonalInfoStep(
          fullName: data.fullName,
          surname: data.surname,
          motherName: data.motherName,
          sex: data.sex,
          dateOfBirth: data.dateOfBirth,
          title: data.title,
          maritalStatus: data.maritalStatus,
          isOnline: ref.read(connectivityProvider),
          userId: userId,
        );
      case 6: // Payment (step 7) - includes address info
        final data = ref.read(registrationDataProvider);
        final userId = ref.read(userIdProvider);
        return await handleAddressInfoStep(
          country: data.country,
          issueAuthority: data.issueAuthority,
          issueDate: data.issueDate,
          expirayDate: data.expirayDate,
          legalId: data.legalId,
          state: data.state,
          zoneSubCity: data.zoneSubCity,
          streetAddress: data.streetAddress,
          isOnline: ref.read(connectivityProvider),
          userId: userId,
        );
      case 7: // Account Type (step 8)
        final data = ref.read(registrationDataProvider);
        final userId = ref.read(userIdProvider);
        return await handleAccountTypeStep(
          accountType: data.accountType,
          isOnline: ref.read(connectivityProvider),
          userId: userId,
        );
      case 8: // Terms and Conditions (step 9)
        final data = ref.read(registrationDataProvider);
        return await handleTermsConditionsStep(
          termsAccepted: data.termsAccepted,
        );
      default:
        return true; // For other steps, just return true
    }
  }

  // Method to submit the entire registration
  Future<bool> submitRegistration(WidgetRef ref) async {
    try {
      // This would typically submit all the collected data
      // For now, we'll just mark all steps as complete
      for (int i = 0; i < 9; i++) {
        _stepCompletionNotifier.markStepComplete(i);
      }
      _registrationDataNotifier.updateProgress(100.0);
      return true;
    } catch (e) {
      _formValidationNotifier.setError(
          'submission', 'Failed to submit registration: $e');
      return false;
    }
  }
}

// Validation Result Model
class ValidationResult {
  final bool isValid;
  final Map<String, String>? errors;

  ValidationResult({required this.isValid, this.errors});
}
