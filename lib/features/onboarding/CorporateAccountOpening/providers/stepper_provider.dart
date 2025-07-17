import 'package:coopengageplus/features/onboarding/CorporateAccountOpening/model/registration_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
// import 'package:coopengageplus/features/onboarding/JointNationalIdentification/model/registration_data.dart';

// State class for stepper
class StepperState {
  final int activeStep;
  final String phoneNumber;
  final String fanNumber;
  final String otpCode;
  final String? selectedProductType;
  final String? selectedTitle;
  final String? selectedMaritalStatus;
  final String? selectedBranch;
  final String? motherName;
  final Uint8List? signature;
  final String? selectedAccountType;
  final String? jointAccountType;
  final int customerAge;
  final String customerGender;
  final double? initialDeposit;
  final String bankingType;
  final int? bankShare;
  final int? customerShare;
  final int numberOfMembers;
  final List<JointMemberInfo> members;
  final String? licenseFile;
  final String? articleFile;
  final String? letterOfRequestFile;
  final String? tinNumberPhoto;
  final String? tradeName;
  final List<String> otherFiles;
  final String? companyName;
  final String? companyPhoneNumber;
  final String? companyDateOfEstablishment;
  final String? companyTinNumber;
  final String? companyEmail;
  final String? companyState;
  final String? companyZoneSubCity;
  final String? companyWoreda;

  // National ID Authentication Data
  final int? authId;
  final String? fullName;
  final String? email;
  final bool? emailVerified;
  final String? authPhone;
  final String? state;
  final String? country;
  final String? sex;
  final String? status;
  final String? dateOfBirth;
  final String? customerType;
  final String? legalId;
  final double? percentageComplete;
  final String? createdAt;
  final String? updatedAt;
  final int? accountId;

  const StepperState({
    this.activeStep = 0,
    this.phoneNumber = '',
    this.fanNumber = '',
    this.otpCode = '',
    this.selectedProductType,
    this.selectedTitle,
    this.selectedMaritalStatus,
    this.selectedBranch,
    this.motherName,
    this.signature,
    this.selectedAccountType,
    this.jointAccountType,
    this.customerAge = 25,
    this.customerGender = 'MALE',
    this.initialDeposit,
    this.bankingType = 'DIGITAL',
    this.bankShare,
    this.customerShare,
    this.numberOfMembers = 2,
    this.members = const [],
    this.licenseFile,
    this.articleFile,
    this.letterOfRequestFile,
    this.tinNumberPhoto,
    this.tradeName,
    this.otherFiles = const [],
    this.companyName,
    this.companyPhoneNumber,
    this.companyDateOfEstablishment,
    this.companyTinNumber,
    this.companyEmail,
    this.companyState,
    this.companyZoneSubCity,
    this.companyWoreda,
    this.authId,
    this.fullName,
    this.email,
    this.emailVerified,
    this.authPhone,
    this.state,
    this.country,
    this.sex,
    this.status,
    this.dateOfBirth,
    this.customerType,
    this.legalId,
    this.percentageComplete,
    this.createdAt,
    this.updatedAt,
    this.accountId,
  });

  StepperState copyWith({
    int? activeStep,
    String? phoneNumber,
    String? fanNumber,
    String? otpCode,
    String? selectedProductType,
    String? selectedTitle,
    String? selectedMaritalStatus,
    String? jointAccountType,
    String? selectedBranch,
    String? motherName,
    Uint8List? signature,
    String? selectedAccountType,
    int? customerAge,
    String? customerGender,
    double? initialDeposit,
    String? bankingType,
    int? bankShare,
    int? customerShare,
    int? numberOfMembers,
    List<JointMemberInfo>? members,
    String? licenseFile,
    String? articleFile,
    String? letterOfRequestFile,
    String? tinNumberPhoto,
    String? tradeName,
    List<String>? otherFiles,
    String? companyName,
    String? companyPhoneNumber,
    String? companyDateOfEstablishment,
    String? companyTinNumber,
    String? companyEmail,
    String? companyState,
    String? companyZoneSubCity,
    String? companyWoreda,
    int? authId,
    String? fullName,
    String? email,
    bool? emailVerified,
    String? authPhone,
    String? state,
    String? country,
    String? sex,
    String? status,
    String? dateOfBirth,
    String? customerType,
    String? legalId,
    double? percentageComplete,
    String? createdAt,
    String? updatedAt,
    int? accountId,
  }) {
    return StepperState(
      activeStep: activeStep ?? this.activeStep,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fanNumber: fanNumber ?? this.fanNumber,
      otpCode: otpCode ?? this.otpCode,
      selectedProductType: selectedProductType ?? this.selectedProductType,
      selectedMaritalStatus:
          selectedMaritalStatus ?? this.selectedMaritalStatus,
      jointAccountType: jointAccountType ?? this.jointAccountType,
      selectedTitle: selectedTitle ?? this.selectedTitle,
      selectedBranch: selectedBranch ?? this.selectedBranch,
      motherName: motherName ?? this.motherName,
      signature: signature ?? this.signature,
      selectedAccountType: selectedAccountType ?? this.selectedAccountType,
      customerAge: customerAge ?? this.customerAge,
      customerGender: customerGender ?? this.customerGender,
      initialDeposit: initialDeposit ?? this.initialDeposit,
      bankingType: bankingType ?? this.bankingType,
      bankShare: bankShare ?? this.bankShare,
      customerShare: customerShare ?? this.customerShare,
      numberOfMembers: numberOfMembers ?? this.numberOfMembers,
      members: members ?? this.members,
      licenseFile: licenseFile ?? this.licenseFile,
      articleFile: articleFile ?? this.articleFile,
      letterOfRequestFile: letterOfRequestFile ?? this.letterOfRequestFile,
      tinNumberPhoto: tinNumberPhoto ?? this.tinNumberPhoto,
      tradeName: tradeName ?? this.tradeName,
      otherFiles: otherFiles ?? this.otherFiles,
      companyName: companyName ?? this.companyName,
      companyPhoneNumber: companyPhoneNumber ?? this.companyPhoneNumber,
      companyDateOfEstablishment: companyDateOfEstablishment ?? this.companyDateOfEstablishment,
      companyTinNumber: companyTinNumber ?? this.companyTinNumber,
      companyEmail: companyEmail ?? this.companyEmail,
      companyState: companyState ?? this.companyState,
      companyZoneSubCity: companyZoneSubCity ?? this.companyZoneSubCity,
      companyWoreda: companyWoreda ?? this.companyWoreda,
      authId: authId ?? this.authId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      authPhone: authPhone ?? this.authPhone,
      state: state ?? this.state,
      country: country ?? this.country,
      sex: sex ?? this.sex,
      status: status ?? this.status,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      customerType: customerType ?? this.customerType,
      legalId: legalId ?? this.legalId,
      percentageComplete: percentageComplete ?? this.percentageComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accountId: accountId ?? this.accountId,
    );
  }
}

// Provider for stepper state
class StepperNotifier extends StateNotifier<StepperState> {
  bool _disposed = false;
  final int maxStep;
  StepperNotifier({required this.maxStep}) : super(const StepperState());

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Navigate to next step with safety checks
  void nextStep() {
    if (state.activeStep < maxStep) {
      print(
          'Stepper: Moving from step ${state.activeStep} to step ${state.activeStep + 1}');
      state = state.copyWith(activeStep: state.activeStep + 1);
      print('Stepper: Successfully moved to step ${state.activeStep}');
    }
  }

  // Navigate to previous step with safety checks
  void previousStep() {
    if (state.activeStep > 0) {
      print(
          'Stepper: Moving from step ${state.activeStep} to step ${state.activeStep - 1}');
      state = state.copyWith(activeStep: state.activeStep - 1);
      print('Stepper: Successfully moved to step ${state.activeStep}');
    }
  }

  // Navigate to specific step with safety checks
  void goToStep(int step) {
    if (step >= 0 && step <= maxStep) {
      print('Stepper: Moving to specific step $step');
      state = state.copyWith(activeStep: step);
      print('Stepper: Successfully moved to step ${state.activeStep}');
    }
  }

  // Update phone number
  void updatePhoneNumber(String phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
  }

  // Update FAN number
  void updateFanNumber(String fanNumber) {
    state = state.copyWith(fanNumber: fanNumber);
  }

  // Update OTP code
  void updateOtpCode(String otpCode) {
    state = state.copyWith(otpCode: otpCode);
  }

  // Update product type
  void updateProductType(String? productType) {
    state = state.copyWith(selectedProductType: productType);
  }

  void updateMaritalStatus(String? maritalStatus) {
    state = state.copyWith(selectedMaritalStatus: maritalStatus);
  }

  void updateJointAccountType(String? jointAccountType) {
    state = state.copyWith(jointAccountType: jointAccountType);
  }

  void updateTitle(String? title) {
    state = state.copyWith(selectedTitle: title);
  }

  // Update branch
  void updateBranch(String? branch) {
    state = state.copyWith(selectedBranch: branch);
  }

  // Update mother name
  void updateMotherName(String motherName) {
    state = state.copyWith(motherName: motherName);
  }

  // Update signature
  void updateSignature(Uint8List signature) {
    state = state.copyWith(signature: signature);
  }

  // Update account type
  void updateAccountType(String? accountType) {
    state = state.copyWith(selectedAccountType: accountType);
  }

  // Update customer age
  void updateCustomerAge(int age) {
    state = state.copyWith(customerAge: age);
  }

  // Update customer gender
  void updateCustomerGender(String gender) {
    state = state.copyWith(customerGender: gender);
  }

  // Update initial deposit
  void updateInitialDeposit(double? deposit) {
    state = state.copyWith(initialDeposit: deposit);
  }

  // Update banking type
  void updateBankingType(String bankingType) {
    state = state.copyWith(bankingType: bankingType);
  }

  void updateBankShare(int? value) {
    state = state.copyWith(bankShare: value);
  }

  void updateCustomerShare(int? value) {
    state = state.copyWith(customerShare: value);
  }

  void updateNumberOfMembers(int number) {
    state = state.copyWith(numberOfMembers: number);
    // Optionally reset members list
    if (state.members.length != number) {
      final newMembers = List<JointMemberInfo>.generate(
        number,
        (i) => JointMemberInfo(),
      );
      state = state.copyWith(members: newMembers);
    }
  }

  void updateMember(int index, JointMemberInfo member) {
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      updatedMembers[index] = member;
      state = state.copyWith(members: updatedMembers);
    }
  }

  void updateMemberSignature(int index, Uint8List signature) {
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      final updatedMember =
          updatedMembers[index].copyWith(signature: signature);
      updatedMembers[index] = updatedMember;
      state = state.copyWith(members: updatedMembers);
    }
  }

  void updateMemberFullName(int index, String fullName) {
    print("dfdfdkfkdkfkdkdfkkdfk");

    print(fullName);
    print(index);
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      updatedMembers[index] =
          updatedMembers[index].copyWith(fullName: fullName);
      state = state.copyWith(members: updatedMembers);
    }
  }

  void updateLicenseFile(String? path) {
    state = state.copyWith(licenseFile: path);
  }
  void updateArticleFile(String? path) {
    state = state.copyWith(articleFile: path);
  }
  void updateLetterOfRequestFile(String? path) {
    state = state.copyWith(letterOfRequestFile: path);
  }
  void updateTinNumberPhoto(String? path) {
    state = state.copyWith(tinNumberPhoto: path);
  }
  void updateTradeName(String? path) {
    state = state.copyWith(tradeName: path);
  }
  void updateOtherFiles(List<String> files) {
    state = state.copyWith(otherFiles: files);
  }

  // Add company info update methods
  void updateCompanyName(String? name) {
    state = state.copyWith(companyName: name);
  }
  void updateCompanyPhoneNumber(String? phone) {
    state = state.copyWith(companyPhoneNumber: phone);
  }
  void updateCompanyDateOfEstablishment(String? date) {
    state = state.copyWith(companyDateOfEstablishment: date);
  }
  void updateCompanyTinNumber(String? tin) {
    state = state.copyWith(companyTinNumber: tin);
  }
  void updateCompanyEmail(String? email) {
    state = state.copyWith(companyEmail: email);
  }
  void updateCompanyState(String? value) {
    state = state.copyWith(companyState: value);
  }
  void updateCompanyZoneSubCity(String? value) {
    state = state.copyWith(companyZoneSubCity: value);
  }
  void updateCompanyWoreda(String? value) {
    state = state.copyWith(companyWoreda: value);
  }

  void updateMemberZoneSubCity(int index, String? zoneSubCity) {
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      updatedMembers[index] = updatedMembers[index].copyWith(zoneSubCity: zoneSubCity);
      state = state.copyWith(members: updatedMembers);
    }
  }
  void updateMemberWoreda(int index, String? woreda) {
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      updatedMembers[index] = updatedMembers[index].copyWith(woreda: woreda);
      state = state.copyWith(members: updatedMembers);
    }
  }
  void updateMemberState(int index, String? stateValue) {
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      updatedMembers[index] = updatedMembers[index].copyWith(state: stateValue);
      state = state.copyWith(members: updatedMembers);
    }
  }
  void updateMemberPhone(int index, String? phone) {
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      updatedMembers[index] = updatedMembers[index].copyWith(phone: phone);
      state = state.copyWith(members: updatedMembers);
    }
  }
  void updateMemberEmail(int index, String? email) {
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      updatedMembers[index] = updatedMembers[index].copyWith(email: email);
      state = state.copyWith(members: updatedMembers);
    }
  }
  void updateMemberSex(int index, String? sex) {
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      updatedMembers[index] = updatedMembers[index].copyWith(sex: sex);
      state = state.copyWith(members: updatedMembers);
    }
  }
  void updateMemberTitle(int index, String? title) {
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      updatedMembers[index] = updatedMembers[index].copyWith(title: title);
      state = state.copyWith(members: updatedMembers);
    }
  }
  void updateMemberIssueDate(int index, String? issueDate) {
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      updatedMembers[index] = updatedMembers[index].copyWith(issueDate: issueDate);
      state = state.copyWith(members: updatedMembers);
    }
  }
  void updateMemberExpirayDate(int index, String? expirayDate) {
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      updatedMembers[index] = updatedMembers[index].copyWith(expirayDate: expirayDate);
      state = state.copyWith(members: updatedMembers);
    }
  }
  void updateMemberDocumentType(int index, String? documentType) {
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      updatedMembers[index] = updatedMembers[index].copyWith(documentType: documentType);
      state = state.copyWith(members: updatedMembers);
    }
  }
  void updateMemberResidentPath(int index, String? residentPath) {
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      updatedMembers[index] = updatedMembers[index].copyWith(residentPath: residentPath);
      state = state.copyWith(members: updatedMembers);
    }
  }
  void updateMemberResidentCardBackPath(int index, String? residentCardBackPath) {
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      updatedMembers[index] = updatedMembers[index].copyWith(residentCardBackPath: residentCardBackPath);
      state = state.copyWith(members: updatedMembers);
    }
  }
  void updateMemberProfilePath(int index, String? profilePath) {
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      updatedMembers[index] = updatedMembers[index].copyWith(profilePath: profilePath);
      state = state.copyWith(members: updatedMembers);
    }
  }
  void updateMemberLegalId(int index, String? legalId) {
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      updatedMembers[index] = updatedMembers[index].copyWith(legalId: legalId);
      state = state.copyWith(members: updatedMembers);
    }
  }
  void updateMemberIssueAuthority(int index, String? issueAuthority) {
    final updatedMembers = List<JointMemberInfo>.from(state.members);
    if (index >= 0 && index < updatedMembers.length) {
      updatedMembers[index] = updatedMembers[index].copyWith(issueAuthority: issueAuthority);
      state = state.copyWith(members: updatedMembers);
    }
  }

  // Helper method to calculate age from date of birth
  int _calculateAgeFromDateOfBirth(String? dateOfBirth) {
    if (dateOfBirth == null) return 25; // Default age

    try {
      final birthDate = DateTime.parse(dateOfBirth);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 25; // Default age if parsing fails
    }
  }

  // Save authentication data from step 1
  void saveAuthenticationData(Map<String, dynamic> authResult) {
    print('StepperProvider: saveAuthenticationData called');
    print('StepperProvider: Auth result: $authResult');

    final dateOfBirth = authResult['dateOfBirth']?.toString();
    final calculatedAge = _calculateAgeFromDateOfBirth(dateOfBirth);
    final sexString = authResult['sex']?.toString();
    final sex = sexString != null ? sexString.toUpperCase() : 'MALE';

    final newState = state.copyWith(
      authId: authResult['id'] != null
          ? int.tryParse(authResult['id'].toString())
          : null,
      fullName: authResult['fullName']?.toString(),
      email: authResult['email']?.toString(),
      emailVerified: authResult['emailVerified'] as bool?,
      authPhone: authResult['phone']?.toString(),
      state: authResult['state']?.toString(),
      country: authResult['country']?.toString(),
      sex: sex,
      status: authResult['status']?.toString(),
      dateOfBirth: dateOfBirth,
      customerType: authResult['customerType']?.toString(),
      legalId: authResult['legalId']?.toString(),
      percentageComplete: authResult['percentageComplete'] != null
          ? double.tryParse(authResult['percentageComplete'].toString())
          : null,
      createdAt: authResult['createdAt']?.toString(),
      updatedAt: authResult['updatedAt']?.toString(),
      accountId: authResult['accountId'] != null
          ? int.tryParse(authResult['accountId'].toString())
          : null,
      // Always preserve existing non-nullable values if null
      customerAge: calculatedAge != null ? calculatedAge : state.customerAge,
      customerGender: sex.isNotEmpty ? sex : state.customerGender,

      // initialDeposit and bankingType are omitted so they are preserved
    );

    state = newState;

    print('StepperProvider: Authentication data saved successfully');
    print('StepperProvider: Auth ID: ${state.authId}');
    print('StepperProvider: Full Name: ${state.fullName}');
    print('StepperProvider: Email: ${state.email}');
    print('StepperProvider: State: ${state.state}');
  }

  // Update individual authentication fields
  void updateAuthId(int? authId) {
    state = state.copyWith(authId: authId);
  }

  void updateFullName(String? fullName) {
    state = state.copyWith(fullName: fullName);
  }

  void updateEmail(String? email) {
    state = state.copyWith(email: email);
  }

  void updateEmailVerified(bool? emailVerified) {
    state = state.copyWith(emailVerified: emailVerified);
  }

  void updateAuthPhone(String? authPhone) {
    state = state.copyWith(authPhone: authPhone);
  }

  void updateState(String? stateValue) {
    state = state.copyWith(state: stateValue);
  }

  void updateCountry(String? country) {
    state = state.copyWith(country: country);
  }

  void updateSex(String? sex) {
    state = state.copyWith(sex: sex);
  }

  void updateStatus(String? status) {
    state = state.copyWith(status: status);
  }

  void updateDateOfBirth(String? dateOfBirth) {
    state = state.copyWith(dateOfBirth: dateOfBirth);
  }

  void updateCustomerType(String? customerType) {
    state = state.copyWith(customerType: customerType);
  }

  void updateLegalId(String? legalId) {
    state = state.copyWith(legalId: legalId);
  }

  void updatePercentageComplete(double? percentageComplete) {
    state = state.copyWith(percentageComplete: percentageComplete);
  }

  void updateCreatedAt(String? createdAt) {
    state = state.copyWith(createdAt: createdAt);
  }

  void updateUpdatedAt(String? updatedAt) {
    state = state.copyWith(updatedAt: updatedAt);
  }

  void updateAccountId(int? accountId) {
    state = state.copyWith(accountId: accountId);
  }

  // Reset stepper
  void reset() {
    state = const StepperState();
  }
}

// Provider
final stepperProvider =
    StateNotifierProvider<StepperNotifier, StepperState>((ref) {
  // Set maxStep to 3 for 4 steps (0-based)
  return StepperNotifier(maxStep: 5);
});
