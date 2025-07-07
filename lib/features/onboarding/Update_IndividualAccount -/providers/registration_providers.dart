import 'dart:typed_data';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/registration_data.dart';
import '../services/registration_service.dart';
import '../controllers/registration_controller.dart';
import '../../../../NetworkHandler.dart';
import '../../../../main.dart';

// Database and Network Providers
final networkHandlerProvider = Provider<NetworkHandler>((ref) => NetworkHandler());
final databaseProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper());
final connectivityProvider = Provider<bool>((ref) => isOnline);

// Service Providerr
final registrationServiceProvider = Provider<RegistrationService>((ref) {
  return RegistrationService(
    ref.read(networkHandlerProvider),
    ref.read(databaseProvider),
  );
});

// Controller Provider
final registrationControllerProvider = Provider<RegistrationController>((ref) {
  return RegistrationController(
    registrationService: ref.read(registrationServiceProvider),
    ref: ref,
    stepCompletionNotifier: ref.read(stepCompletionProvider.notifier),
  );
});

// Registration Data Provider
final registrationDataProvider =
    StateNotifierProvider<RegistrationDataNotifier, RegistrationData>(
  (ref) => RegistrationDataNotifier(),
);

// Registration Step Provider
final registrationStepProvider =
    StateNotifierProvider<RegistrationStepNotifier, int>(
  (ref) => RegistrationStepNotifier(),
);

// Step Completion Provider
final stepCompletionProvider =
    StateNotifierProvider<StepCompletionNotifier, List<bool>>(
  (ref) => StepCompletionNotifier(),
);

// Form Validation Provider
final formValidationProvider =
    StateNotifierProvider<FormValidationNotifier, Map<String, String?>>(
  (ref) => FormValidationNotifier(),
);

// Registration Status Provider
final registrationStatusProvider =
    StateNotifierProvider<RegistrationStatusNotifier, RegistrationStatus>(
  (ref) => RegistrationStatusNotifier(),
);

// User ID Provider
final userIdProvider = StateNotifierProvider<UserIdNotifier, String?>(
  (ref) => UserIdNotifier(),
);

// Step Submission Provider
final stepSubmissionProvider =
    StateNotifierProvider<StepSubmissionNotifier, StepSubmissionState>(
  (ref) => StepSubmissionNotifier(ref.read(registrationControllerProvider), ref.read(connectivityProvider)),
);

// Text Controllers Provider
final phoneControllerProvider = StateProvider<TextEditingController>((ref) {
  final controller = TextEditingController();
  final phone = ref.read(registrationDataProvider).phone;
  if (phone != null && phone.isNotEmpty) {
    controller.text = phone;
  }
  return controller;
});
final emailControllerProvider =
    Provider<TextEditingController>((ref) => TextEditingController());

// State Notifiers
class RegistrationDataNotifier extends StateNotifier<RegistrationData> {
  RegistrationDataNotifier() : super(RegistrationData());

  void updateBasicInfo({
    String? phone,
    String? email,
    String? productType,
    String? customerId,
  }) {
    state = state.copyWith(
      phone: phone,
      email: email,
      productType: productType,
      customerId: customerId,
    );
  }

  void updatePersonalInfo({
    String? fullName,
    String? surname,
    String? motherName,
    String? sex,
    String? dateOfBirth,
    String? title,
    String? maritalStatus,
  }) {
    state = state.copyWith(
      fullName: fullName,
      surname: surname,
      motherName: motherName,
      sex: sex,
      dateOfBirth: dateOfBirth,
      title: title,
      maritalStatus: maritalStatus,
    );
  }

  void updateIdTypeInfo({
    String? branch,
    String? documentName,
    Uint8List? residenceCard,
    Uint8List? residenceCardBack,
  }) {
    state = state.copyWith(
      branch: branch,
      documentName: documentName,
      residenceCard: residenceCard,
      residenceCardBack: residenceCardBack,
    );
  }

  void updateSignature({Uint8List? signature}) {
    state = state.copyWith(signature: signature);
  }

  void updatePhoto({Uint8List? photo}) {
    state = state.copyWith(photo: photo);
  }

  void updateFinancialInfo({
    String? occupation,
    String? monthlyIncome,
    String? initialDeposit,
    String? sector,
  }) {
    state = state.copyWith(
      occupation: occupation,
      monthlyIncome: monthlyIncome,
      initialDeposit: initialDeposit,
      sector: sector,
    );
  }

  void updateAddressInfo({
    String? country,
    String? issueAuthority,
    String? issueDate,
    String? expirayDate,
    String? legalId,
    String? stateValue,
    String? zoneSubCity,
    String? streetAddress,
  }) {
    state = state.copyWith(
      country: country,
      issueAuthority: issueAuthority,
      issueDate: issueDate,
      expirayDate: expirayDate,
      legalId: legalId,
      state: stateValue,
      zoneSubCity: zoneSubCity,
      streetAddress: streetAddress,
    );
  }

  void updateAccountInfo({
    String? accountType,
    String? currency,
  }) {
    state = state.copyWith(
      accountType: accountType,
      currency: currency,
    );
  }

  void updateAccountType(String? accountType) {
    state = state.copyWith(
      accountType: accountType,
    );
  }

  void updateTermsAccepted(bool? termsAccepted) {
    state = state.copyWith(
      termsAccepted: termsAccepted,
    );
  }

  void updateProgress(double percentage) {
    state = state.copyWith(percentageCompleted: percentage);
  }

  void updateStatus(String status) {
    state = state.copyWith(status: status);
  }

  void reset() {
    state = RegistrationData();
  }
}

class RegistrationStepNotifier extends StateNotifier<int> {
  RegistrationStepNotifier() : super(0);

  void nextStep() {
    if (state < 8) state++;
  }

  void previousStep() {
    if (state > 0) state--;
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 8) state = step;
  }

  void reset() {
    state = 0;
  }
}

class StepCompletionNotifier extends StateNotifier<List<bool>> {
  StepCompletionNotifier() : super(List.generate(9, (_) => false));

  void markStepComplete(int stepIndex) {
    if (stepIndex >= 0 && stepIndex < state.length) {
      final newState = List<bool>.from(state);
      newState[stepIndex] = true;
      state = newState;
    }
  }

  void markStepIncomplete(int stepIndex) {
    if (stepIndex >= 0 && stepIndex < state.length) {
      final newState = List<bool>.from(state);
      newState[stepIndex] = false;
      state = newState;
    }
  }

  void reset() {
    state = List.generate(9, (_) => false);
  }

  bool isStepComplete(int stepIndex) {
    return stepIndex >= 0 && stepIndex < state.length
        ? state[stepIndex]
        : false;
  }

  int get completedStepsCount => state.where((completed) => completed).length;
}

class FormValidationNotifier extends StateNotifier<Map<String, String?>> {
  FormValidationNotifier() : super({});

  void setError(String field, String? error) {
    state = {...state, field: error};
  }

  void clearError(String field) {
    final newState = Map<String, String?>.from(state);
    newState.remove(field);
    state = newState;
  }

  void clearAllErrors() {
    state = {};
  }

  bool get hasErrors => state.values.any((error) => error != null);
  String? getError(String field) => state[field];
}

class RegistrationStatusNotifier extends StateNotifier<RegistrationStatus> {
  RegistrationStatusNotifier() : super(RegistrationStatus());

  void setLoading() {
    state = state.copyWith(isCircular: true, isValid: false);
  }

  void setSuccess() {
    state = state.copyWith(
      isValid: true,
      isCircular: false,
      registerStatus: true,
      errorMessage: null,
    );
  }

  void setError(String errorMessage) {
    state = state.copyWith(
      isValid: false,
      isCircular: false,
      registerStatus: false,
      errorMessage: errorMessage,
    );
  }

  void reset() {
    state = RegistrationStatus();
  }
}

class UserIdNotifier extends StateNotifier<String?> {
  UserIdNotifier() : super(null);

  void setUserId(String userId) {
    state = userId;
  }

  void clear() {
    state = null;
  }
}

class StepSubmissionNotifier extends StateNotifier<StepSubmissionState> {
  final RegistrationController _controller;
  final bool _isOnline;

  StepSubmissionNotifier(this._controller, this._isOnline) : super(StepSubmissionState());

  // Submit first step (Basic Info)
  Future<bool> submitFirstStep(RegistrationData data, String phoneNumber, String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _controller.handleBasicInfoStep(
        phoneNumber: phoneNumber,
        email: email,
        productType: data.productType,
        // isOnline: _isOnline,
      );

      if (success) {
        // Store the customer ID in StepSubmissionState as well
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          userId: data.customerId, // Use the data parameter that's already passed
        );
        return true;
      } else {
        // Get error from validation notifier
        final validationErrors = _controller.validationErrors;
        final errorMessage = validationErrors.values.firstWhere(
          (error) => error != null,
          orElse: () => 'Validation failed',
        );
        
        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to submit step: $e',
      );
      return false;
    }
  }

  // Submit second step (ID Type)
  Future<bool> submitSecondStep(RegistrationData data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Use the customerId from registration data for offline mode
      final userIdToUse = data.customerId ?? state.userId;
      
      print("=== submitSecondStep Debug ===");
      print("Registration data customerId: ${data.customerId}");
      print("StepSubmissionState userId: ${state.userId}");
      print("Final userIdToUse: $userIdToUse");
      
      final success = await _controller.handleIdTypeStep(
        branch: data.branch,
        documentName: data.documentName,
        frontImage: data.residenceCard,
        backImage: data.residenceCardBack,
        userId: userIdToUse,
      );

      if (success) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      } else {
        // Get error from validation notifier
        final validationErrors = _controller.validationErrors;
        final errorMessage = validationErrors.values.firstWhere(
          (error) => error != null,
          orElse: () => 'Validation failed',
        );
        
        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to submit step: $e',
      );
      return false;
    }
  }

  void reset() {
    state = StepSubmissionState();
    _controller.resetAllSteps();
  }
}

// Models
class RegistrationStatus {
  final bool isValid;
  final bool isCircular;
  final bool registerStatus;
  final String? errorMessage;

  RegistrationStatus({
    this.isValid = false,
    this.isCircular = false,
    this.registerStatus = false,
    this.errorMessage,
  });

  RegistrationStatus copyWith({
    bool? isValid,
    bool? isCircular,
    bool? registerStatus,
    String? errorMessage,
  }) {
    return RegistrationStatus(
      isValid: isValid ?? this.isValid,
      isCircular: isCircular ?? this.isCircular,
      registerStatus: registerStatus ?? this.registerStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class StepSubmissionState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final String? userId;

  StepSubmissionState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.userId,
  });

  StepSubmissionState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    String? userId,
  }) {
    return StepSubmissionState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
    );
  }
} 