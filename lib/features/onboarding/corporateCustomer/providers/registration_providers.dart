import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';

class RegistrationState {
  // Basic Info
  String? selectedProductType;
  TextEditingController companyNameController;
  TextEditingController phoneNumberController;
  TextEditingController emailController;
  TextEditingController tinNumberController;
  TextEditingController dateOfEstabilishmentController;

  // Signature/Branch
  String? selectedBranch;
  String? selectedState;
  TextEditingController cityController;
  TextEditingController woredaController;
  TextEditingController residenceControllers;
  String? numberOfMembers;

  // Dynamic Members
  int membersCount;
  List<TextEditingController> fullNameControllers;
  List<TextEditingController> phoneControllers;
  List<TextEditingController> emailControllers;
  List<String?> selectedGender;
  List<String?> selectedTitle;
  List<TextEditingController> motherNameControllers;
  List<TextEditingController> dateOfBirthControllers;
  List<TextEditingController> occupationControllers;
  List<TextEditingController> monthlyIncomeControllers;
  List<TextEditingController> cityControllers;
  List<TextEditingController> stateControllers;
  List<TextEditingController> woredaControllers;
  List<String?> selectedDocumentType;
  List<TextEditingController> legalIDControllers;
  List<TextEditingController> issueAuthorityControllers;
  List<TextEditingController> issueDateControllers;
  List<TextEditingController> expireDateControllers;
  List<SignatureController> signatureControllers;
  List<Uint8List?> signatureImages;

  // Financial Info
  TextEditingController initialDepositController;

  // Document Uploads
  String? licenseFilePath;
  String? articleFilePath;
  String? letterOfRequestFilePath;
  String? tinNumberPhoto;
  String? tradeName;
  List<String> otherDocumentPaths;

  // Account Type
  String? selectedAccountTypeId;

  RegistrationState({
    this.selectedProductType,
    TextEditingController? companyNameController,
    TextEditingController? phoneNumberController,
    TextEditingController? emailController,
    TextEditingController? tinNumberController,
    TextEditingController? dateOfEstabilishmentController,
    this.selectedBranch,
    this.selectedState,
    TextEditingController? cityController,
    TextEditingController? woredaController,
    TextEditingController? residenceControllers,
    this.numberOfMembers,
    this.licenseFilePath,
    this.articleFilePath,
    this.letterOfRequestFilePath,
    this.tinNumberPhoto,
    this.tradeName,
    this.selectedAccountTypeId,
    this.membersCount = 1,
    List<TextEditingController>? fullNameControllers,
    List<TextEditingController>? phoneControllers,
    List<TextEditingController>? emailControllers,
    List<String?>? selectedGender,
    List<String?>? selectedTitle,
    List<TextEditingController>? motherNameControllers,
    List<TextEditingController>? dateOfBirthControllers,
    List<TextEditingController>? occupationControllers,
    List<TextEditingController>? monthlyIncomeControllers,
    List<TextEditingController>? cityControllers,
    List<TextEditingController>? stateControllers,
    List<TextEditingController>? woredaControllers,
    List<String?>? selectedDocumentType,
    List<TextEditingController>? legalIDControllers,
    List<TextEditingController>? issueAuthorityControllers,
    List<TextEditingController>? issueDateControllers,
    List<TextEditingController>? expireDateControllers,
    List<SignatureController>? signatureControllers,
    List<Uint8List?>? signatureImages,
    List<String>? otherDocumentPaths,
    TextEditingController? initialDepositController,
  })  : companyNameController = companyNameController ?? TextEditingController(),
        phoneNumberController = phoneNumberController ?? TextEditingController(),
        emailController = emailController ?? TextEditingController(),
        tinNumberController = tinNumberController ?? TextEditingController(),
        dateOfEstabilishmentController = dateOfEstabilishmentController ?? TextEditingController(),
        cityController = cityController ?? TextEditingController(),
        woredaController = woredaController ?? TextEditingController(),
        residenceControllers = residenceControllers ?? TextEditingController(),
        fullNameControllers = fullNameControllers ?? [TextEditingController()],
        phoneControllers = phoneControllers ?? [TextEditingController()],
        emailControllers = emailControllers ?? [TextEditingController()],
        selectedGender = selectedGender ?? [null],
        selectedTitle = selectedTitle ?? [null],
        motherNameControllers = motherNameControllers ?? [TextEditingController()],
        dateOfBirthControllers = dateOfBirthControllers ?? [TextEditingController()],
        occupationControllers = occupationControllers ?? [TextEditingController()],
        monthlyIncomeControllers = monthlyIncomeControllers ?? [TextEditingController()],
        cityControllers = cityControllers ?? [TextEditingController()],
        stateControllers = stateControllers ?? [TextEditingController()],
        woredaControllers = woredaControllers ?? [TextEditingController()],
        selectedDocumentType = selectedDocumentType ?? [null],
        legalIDControllers = legalIDControllers ?? [TextEditingController()],
        issueAuthorityControllers = issueAuthorityControllers ?? [TextEditingController()],
        issueDateControllers = issueDateControllers ?? [TextEditingController()],
        expireDateControllers = expireDateControllers ?? [TextEditingController()],
        signatureControllers = signatureControllers ?? [SignatureController(penColor: Colors.black, penStrokeWidth: 5, exportBackgroundColor: Colors.transparent)],
        signatureImages = signatureImages ?? [null],
        otherDocumentPaths = otherDocumentPaths ?? [],
        initialDepositController = initialDepositController ?? TextEditingController();

  static RegistrationState from(RegistrationState other) {
    return RegistrationState(
      selectedProductType: other.selectedProductType,
      companyNameController: other.companyNameController,
      phoneNumberController: other.phoneNumberController,
      emailController: other.emailController,
      tinNumberController: other.tinNumberController,
      dateOfEstabilishmentController: other.dateOfEstabilishmentController,
      selectedBranch: other.selectedBranch,
      selectedState: other.selectedState,
      cityController: other.cityController,
      woredaController: other.woredaController,
      residenceControllers: other.residenceControllers,
      numberOfMembers: other.numberOfMembers,
      membersCount: other.membersCount,
      fullNameControllers: List.from(other.fullNameControllers),
      phoneControllers: List.from(other.phoneControllers),
      emailControllers: List.from(other.emailControllers),
      selectedGender: List.from(other.selectedGender),
      selectedTitle: List.from(other.selectedTitle),
      motherNameControllers: List.from(other.motherNameControllers),
      dateOfBirthControllers: List.from(other.dateOfBirthControllers),
      occupationControllers: List.from(other.occupationControllers),
      monthlyIncomeControllers: List.from(other.monthlyIncomeControllers),
      cityControllers: List.from(other.cityControllers),
      stateControllers: List.from(other.stateControllers),
      woredaControllers: List.from(other.woredaControllers),
      selectedDocumentType: List.from(other.selectedDocumentType),
      legalIDControllers: List.from(other.legalIDControllers),
      issueAuthorityControllers: List.from(other.issueAuthorityControllers),
      issueDateControllers: List.from(other.issueDateControllers),
      expireDateControllers: List.from(other.expireDateControllers),
      signatureControllers: List.from(other.signatureControllers),
      signatureImages: List.from(other.signatureImages),
      initialDepositController: other.initialDepositController,
      licenseFilePath: other.licenseFilePath,
      articleFilePath: other.articleFilePath,
      letterOfRequestFilePath: other.letterOfRequestFilePath,
      tinNumberPhoto: other.tinNumberPhoto,
      tradeName: other.tradeName,
      otherDocumentPaths: List.from(other.otherDocumentPaths),
      selectedAccountTypeId: other.selectedAccountTypeId,
    );
  }
}

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  RegistrationNotifier() : super(RegistrationState());

  void setSelectedProductType(String? value) {
    state.selectedProductType = value;
    state = RegistrationState.from(state);
  }
  void setSelectedState(String? value) {
    state.selectedState = value;
    state = RegistrationState.from(state);
  }
  void setNumberOfMembers(String? value) {
    state.numberOfMembers = value;
    int count = int.tryParse(value ?? '1') ?? 1;
    state.membersCount = count;
    // Optionally, resize member lists here
    state = RegistrationState.from(state);
  }
  // ... Add similar setters for all fields ...
}

final registrationProvider = StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  return RegistrationNotifier();
}); 