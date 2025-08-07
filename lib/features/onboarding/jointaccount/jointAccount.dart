// ignore_for_file: unused_local_variable, constant_identifier_names, unused_element, avoid_print, unused_import, unnecessary_import, prefer_typing_uninitialized_variables, file_names, non_constant_identifier_names, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
// import 'package:csc_picker/csc_picker.dart';
import 'package:coopengageplus/common_widgets/AlertDialog/DialogHelper%20.dart';
import 'package:coopengageplus/features/onboarding/jointaccount/RegistrationService.dart';
// import 'package:coopengageplus/features/onboarding/HomePage/homepage.dart';
import 'package:coopengageplus/features/onboarding/pages/ConfirmationPage.dart';
import 'package:coopengageplus/pages/MainPage.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phonenumbers/phonenumbers.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';
// import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:http/http.dart' as http;
import '../../../common_widgets/dropDown/DatePickerField.dart';
import 'dart:ui' as ui;
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/common_widgets/textField/PaymentMethod.dart';
import 'package:coopengageplus/common_widgets/textField/PhoneNumberWidget.dart';
import 'package:coopengageplus/common_widgets/textField/emailWidget.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/main.dart';
import 'package:coopengageplus/service/GlobalData.dart';
import 'package:coopengageplus/widget/ButtonUploadTakePhoto%20.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:coopengageplus/widget/SignatureButtons.dart';
import '../pages/home/HomePage.dart';

import 'package:path_provider/path_provider.dart';

bool isConventionalSelected = true;
List<Map<String, dynamic>> allBranches = [];
String? selectedBranch;
List<List<bool>> isExpandedPersonalList = [];
List<List<bool>> isExpandedAddressInfoList = [];
List<List<bool>> isExpandedDocumentInfoList = [];
List<List<bool>> isExpandedIDInfoList = [];
String? selectedAccountTypeId; // you already have this
String? expandedAccountTypeId; // <<< ADD THIS NEW LINE
// String? selectedAccountTypeId;
bool isFirstPersonExpanded = false;
bool isSecondPersonExpanded = false;
bool isExpandedPersonalInformation = false;
List<bool> isExpandedList = [false, false];
//******************************************************************************

List<GlobalKey<FormState>> formKeys = [];
List<TextEditingController> fullNameControllers = [];
List<TextEditingController> phoneControllers = [];
List<TextEditingController> emailControllers = [];

List<TextEditingController> monthlyIncomeControllers = [];
List<TextEditingController> initialDepositControllers = [];
List<TextEditingController> motherNameControllers = [];
List<TextEditingController> DateofBirthControllers = [];
List<TextEditingController> occupationControllers = [];

List<TextEditingController> issueAuthorityControllers = [];
List<TextEditingController> zoneSubsityControllers = [];
List<TextEditingController> woredaControllers = [];

List<TextEditingController> expireDateControllers = [];
List<TextEditingController> issueDateControllers = [];
List<TextEditingController> legalIDControllers = [];
List<TextEditingController> dateControllers = [];

List<TextEditingController> signatureControllers = [];
List<TextEditingController> photoControllers = [];
List<TextEditingController> dateOfBirthControllers = [];
List<TextEditingController> cityControllers = [];

TextEditingController emailController = TextEditingController();
TextEditingController genderController = TextEditingController();
TextEditingController addressController = TextEditingController();
TextEditingController streetController = TextEditingController();
TextEditingController stateController = TextEditingController();
TextEditingController residenceAddressController = TextEditingController();
TextEditingController nationalityController = TextEditingController();
TextEditingController accountCurrencyController = TextEditingController();

//******************************************************************************
class JointAccountStepperPage extends StatefulWidget {
  const JointAccountStepperPage({super.key});
  @override
  State<JointAccountStepperPage> createState() => _Registration();
}

class _Registration extends State<JointAccountStepperPage> {
  String? userId;
  int? userID;
  bool termsAccepted = false;
  List<String> branches = [];
  List<String> filteredBranches = [];
  String? selectedBranch;
  List<Map<String, dynamic>> branch = [];
  List<Map<String, dynamic>> mainBranches = [];
  int? idOne;
  final Map<String, dynamic> registrationData = {};
  bool registerStatus = true;
  var phoneNumber;
  bool isConventionalSelected = true;
  String? signatureImagePath;
  Uint8List? savedSignature;
  bool isDrawingSelected = false;
  String? selectedBranch1;
  String? selectedBankingType; // Default value
  List<Map<String, dynamic>> mergedBranches = [];
  bool isAccountTypeSelected = false;
  List<Map<String, dynamic>> accountTypes = [];

  late SignatureController _signatureController1,
      _signatureController2,
      _signatureController3;
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _signatureImages = [];
  Uint8List? _combinedSignature;

  Future<void> _initializeGlobalData() async {
    await GlobalData().fetchToken();
    setState(() {});
  }

  @override
  void dispose() {
    _signatureController1.dispose();
    _signatureController2.dispose();
    _signatureController3.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selectedProductType = ListContants.productType.first;
    int membersCount = 2;
    selectedSectors = List.generate(membersCount, (index) => null);
    selectedMaritalStatus = List.generate(membersCount, (index) => null);
    selectedDocumentType = List.generate(membersCount, (index) => null);
    selectedTitle = List.generate(membersCount, (index) => null);
    selectedState = List.generate(membersCount, (index) => null);
    selectedGender = List.generate(membersCount, (index) => null);
    formKeys = List.generate(membersCount, (index) => GlobalKey<FormState>());
    motherNameControllers =
        List.generate(membersCount, (index) => TextEditingController());
    fullNameControllers = List.generate(2, (index) => TextEditingController());
    occupationControllers =
        List.generate(membersCount, (index) => TextEditingController());
    monthlyIncomeControllers =
        List.generate(membersCount, (index) => TextEditingController());
    phoneControllers =
        List.generate(membersCount, (index) => TextEditingController());
    emailControllers =
        List.generate(membersCount, (index) => TextEditingController());

    cityControllers =
        List.generate(membersCount, (index) => TextEditingController());

    woredaControllers =
        List.generate(membersCount, (index) => TextEditingController());

    dateOfBirthControllers =
        List.generate(membersCount, (index) => TextEditingController());

    expireDateControllers =
        List.generate(membersCount, (index) => TextEditingController());
    issueAuthorityControllers =
        List.generate(membersCount, (index) => TextEditingController());
    issueAuthorityControllers =
        List.generate(membersCount, (index) => TextEditingController());
    issueDateControllers =
        List.generate(membersCount, (index) => TextEditingController());
    legalIDControllers =
        List.generate(membersCount, (index) => TextEditingController());

    isExpandedPersonalList = List.generate(membersCount, (index) => [false]);

    isExpandedAddressInfoList = List.generate(membersCount, (index) => [false]);
    isExpandedDocumentInfoList =
        List.generate(membersCount, (index) => [false]);
    isExpandedIDInfoList = List.generate(membersCount, (index) => [false]);
    _initializeGlobalData();
    _initializeGlobal();
    initializeBranches();
    // NumberOfMembers = "2";
    _signatureController1 = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 5,
      exportBackgroundColor: Colors.transparent,
    );
    _signatureController2 = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 5,
      exportBackgroundColor: Colors.transparent,
    );
    _signatureController3 = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 5,
      exportBackgroundColor: Colors.transparent,
    );

    globalData;
    GlobalData().fetchToken();
    // selectedState = ListContants.ethiopianStates.first;
    // selectedMaritalStatus = ListContants.maritalStatuses.first;
    selectedCustomerType = ListContants.customerType.first;
    // selectedSector = ListContants.sectors.first;

    AccountTypeSelection = ListContants.AccountTypeSelection.first;
    NumberOfMembers = ListContants.NumberOfMembers.first;
    issueAuthorityController.text = 'ET';
  }

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
  );

  bool validate = false;
  bool circular = false;
  bool isValid = true;
  // String? selectedTitle;
  // String selectedGender = 'FEMALE';
  String selectedIdType = 'KEBELE_ID';
  String? selectedCustomerType;

  String? selectedAccountType;
  String? AccountTypeSelection;
  String? NumberOfMembers;

  String? selectedProductType;
//**********************************************************/
  // String? selectedSector;
  List<String?> selectedSectors = [];
  List<String?> selectedMaritalStatus = [];
  List<String?> selectedDocumentType = [];
  List<String?> selectedTitle = [];
  List<String?> selectedState = [];
  List<String?> selectedGender = [];
  List<String> profilePaths = List.generate(2, (index) => "");
  List<String> passportPaths = List.generate(2, (index) => "");
  List<String> residentPaths = List.generate(2, (index) => "");
  List<String> residentCardBackPaths = List.generate(2, (index) => "");
  List<Uint8List> combinedSignatures =
      List.generate(2, (index) => Uint8List(0));
  String? accountTypeForJoint;
//**********************************************************/

  String imagePath = "";
  String passportPath = "";
  String formPath = "";
  String residentPath = "";
  String residentCardBackPath = "";
  // String profilePath = "";

  String selectedCountry = 'Ethiopia';
  String? selectedCity;
  bool isLoading = false;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController surNameController = TextEditingController();
  TextEditingController motherNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController residenceAddressController = TextEditingController();
  TextEditingController nationalityController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController accountCurrencyController = TextEditingController();
  TextEditingController occupationController = TextEditingController();
  TextEditingController initialDepositController = TextEditingController();
  TextEditingController monthlyIncomeController = TextEditingController();
  TextEditingController branchController = TextEditingController();
  TextEditingController accountTypeController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController photoController = TextEditingController();
  TextEditingController signatureController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  final TextEditingController controller = TextEditingController();
  TextEditingController legalIDController = TextEditingController();
  TextEditingController issueDateController = TextEditingController();
  TextEditingController expireDateController = TextEditingController();
  TextEditingController issueAuthorityController = TextEditingController();
  TextEditingController zoneSubsityController = TextEditingController();
  TextEditingController woredaController = TextEditingController();

  FocusNode focusNode = FocusNode();
  NetworkHandler networkHandler = NetworkHandler();
  String imagepath2 = "";
  String imagepath3 = "";
  String selectedCurrency = 'ETB';
  final picker = ImagePicker();
  final picker2 = ImagePicker();
  final picker3 = ImagePicker();
  File? imageFile;
  File? passportImageFile;
  File? profileImageFile;
  var selectedDate;
  var selectedTime;
  String initialCountry = 'ET';
  final List<String> genders = ['MALE', 'FEMALE'];
  final List<String> titles = ['MR', 'MS', 'DR'];
  final List<String> maritalStatus = ['Single', 'Married'];
  String? selectedPaymentMethod;
  bool isBankTransferSelected = false;

  List<Map<String, dynamic>> filteredAccountTypes = [];
  List<String> countries = ['Ethiopia'];
  int? selectedAccountId;

  String? selectedAccountName;

  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey1 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey2 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey3 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey4 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey5 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey6 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey7 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey8 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey9 = GlobalKey<FormState>();
  String? accountNumber;
  bool isVerified = false;
  String? amount;
  String? description;
  bool isBankTransferIconClicked = false;

  // List<Map<String, dynamic>>? branches1 = GlobalData()?.branches;
  int? UserID = GlobalData()?.userId;
  final globalData = GlobalData();

  List<Step> stepList() {
    bool isSmallScreen = MediaQuery.of(context).size.width < 1400;
    return [
      Step(
        title: Text(isSmallScreen ? "" : "Basic Information"),
        isActive: _activeStepIndex >= 0,
        // state: _activeStepIndex > 0 ? StepState.complete : StepState.indexed,
        state: isStepComplete(0) ? StepState.complete : StepState.indexed,
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextLabel("Product Type"),
            ReusableDropdown(
              selectedValue: selectedProductType,
              items: ListContants.productType,
              hintText: 'Select Product Type',
              onChanged: (newStatus) {
                setState(() {
                  selectedProductType = newStatus;
                });

                print("Gemechuuu123");
                if (selectedProductType != null) {
                  print("Gemechuuu");

                  setState(() {
                    // _filterAccountTypes(selectedProductType!);
                  });
                }
              },
              prefixIcon: Icons.business,
              errorMessage: 'Please select a product type',
              isRequired: true,
            ),
            TextLabel("Account Type"),
            ReusableDropdown(
              selectedValue: AccountTypeSelection,
              items: ListContants.AccountTypeSelection,
              hintText: 'Select Account Type',
              onChanged: (newStatus) {
                setState(() {
                  AccountTypeSelection = newStatus!;
                });
              },
              prefixIcon: Icons.merge,
              errorMessage: 'Please select a Account Type',
              isRequired: true,
            ),
            const SizedBox(height: 5),
            TextLabel("Select Number of Members"),
            ReusableDropdown(
              selectedValue: NumberOfMembers,
              items: ListContants.NumberOfMembers,
              hintText: 'Select Number of Members',
              onChanged: (newStatus) {
                print("""Roobee""");
                setState(() {
                  NumberOfMembers = newStatus!;
                  isExpandedList = List.generate(
                      int.parse(NumberOfMembers!), (index) => false);
                  int membersCount = int.parse(NumberOfMembers!);
                  print(membersCount);
                  print("gemechuuuu");
                  isExpandedList =
                      List.generate(membersCount, (index) => false);
                  isExpandedPersonalList =
                      List.generate(membersCount, (index) => [false]);
                  isExpandedAddressInfoList =
                      List.generate(membersCount, (index) => [false]);
                  isExpandedPersonalList =
                      List.generate(membersCount, (index) => [false]);
                  isExpandedAddressInfoList =
                      List.generate(membersCount, (index) => [false]);
                  isExpandedDocumentInfoList =
                      List.generate(membersCount, (index) => [false]);

                  isExpandedIDInfoList =
                      List.generate(membersCount, (index) => [false]);
                  isExpandedList =
                      List.generate(membersCount, (index) => false);
                  isExpandedPersonalList =
                      List.generate(membersCount, (index) => [false]);
                  isExpandedAddressInfoList =
                      List.generate(membersCount, (index) => [false]);
                  formKeys = List.generate(
                      membersCount, (index) => GlobalKey<FormState>());
                  fullNameControllers = List.generate(
                      membersCount, (index) => TextEditingController());
                  phoneControllers = List.generate(
                      membersCount, (index) => TextEditingController());
                  emailControllers = List.generate(
                      membersCount, (index) => TextEditingController());

                  motherNameControllers = List.generate(
                      membersCount, (index) => TextEditingController());
                  occupationControllers = List.generate(
                      membersCount, (index) => TextEditingController());
                  monthlyIncomeControllers = List.generate(
                      membersCount, (index) => TextEditingController());

                  selectedState = List.generate(membersCount, (index) => null);
                  selectedGender = List.generate(membersCount, (index) => null);
                  selectedMaritalStatus =
                      List.generate(membersCount, (index) => null);
                  selectedSectors =
                      List.generate(membersCount, (index) => null);
                  selectedDocumentType =
                      List.generate(membersCount, (index) => null);
                  selectedTitle = List.generate(membersCount, (index) => null);

                  issueAuthorityControllers = List.generate(
                      membersCount, (index) => TextEditingController());
                  zoneSubsityControllers = List.generate(
                      membersCount, (index) => TextEditingController());
                  woredaControllers = List.generate(
                      membersCount, (index) => TextEditingController());

                  expireDateControllers = List.generate(
                      membersCount, (index) => TextEditingController());
                  issueDateControllers = List.generate(
                      membersCount, (index) => TextEditingController());
                  legalIDControllers = List.generate(
                      membersCount, (index) => TextEditingController());
                  dateControllers = List.generate(
                      membersCount, (index) => TextEditingController());

                  signatureControllers = List.generate(
                      membersCount, (index) => TextEditingController());
                  photoControllers = List.generate(
                      membersCount, (index) => TextEditingController());
                  dateOfBirthControllers = List.generate(
                      membersCount, (index) => TextEditingController());
                  cityControllers = List.generate(
                      membersCount, (index) => TextEditingController());

                  profilePaths = List.generate(membersCount, (index) => "");
                  passportPaths = List.generate(membersCount, (index) => "");
                  residentPaths = List.generate(membersCount, (index) => "");
                  residentCardBackPaths =
                      List.generate(membersCount, (index) => "");
                  combinedSignatures =
                      List.generate(membersCount, (index) => Uint8List(0));
                });
              },
              prefixIcon: Icons.person_add,
              errorMessage: 'Please select Number of Members',
              isRequired: true,
            ),
            const SizedBox(height: 5),
            TextLabel("FullName (First person)"),
            ReusableTextFormField(
              hintText: "FullName",
              controller: fullNameControllers[0],
              keyboardType: TextInputType.text,
              errorMessage: "FullName cannot be empty",

              leadingIcon: Icons.person,
              // inputFormatters: [
              //   FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+$')),
              // ],

              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                // TextInputFormatter.withFunction(
                //   (oldValue, newValue) {
                //     return newValue.copyWith(text: newValue.text.toUpperCase());
                //   },
                // ),
              ],
              isRequired: true,
            ),
            TextLabel("PhoneNumber"),
            PhoneNumberWidget(phoneNumberController: phoneControllers[0]),
          ],
        ),
      ),
    
    
    
      Step(
        title: Text(isSmallScreen ? "" : "Signature"),
        isActive: _activeStepIndex >= 1,
        state: _activeStepIndex > 1 ? StepState.complete : StepState.indexed,
        content: Form(
          key: globalFormKey2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextLabel("Branch"),
              // branchSelectorWidget(),
              branchSelectorWidget1(),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
      Step(
        title: Text(
          isSmallScreen ? "" : "Personal Information",
        ),
        isActive: _activeStepIndex >= 2,
        state: _activeStepIndex > 2 ? StepState.complete : StepState.indexed,
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < int.parse(NumberOfMembers!); i++)
              Form(
                key: formKeys[i],
                child: _buildExpandableSection(
                  "Person ${i + 1}",
                  isExpandedList[i],
                  () {
                    setState(() {
                      // If clicked section is already expanded, collapse it
                      isExpandedList[i] = !isExpandedList[i];

                      // Close all other sections
                      for (int j = 0; j < isExpandedList.length; j++) {
                        if (i != j) {
                          isExpandedList[j] =
                              false; // Collapse all other sections
                        }
                      }
                    });
                  },
                  [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildExpandablePersonalInformationSection(
                            "Personal Information",
                            isExpandedPersonalList[i][0], () {
                          setState(() {
                            isExpandedPersonalList[i][0] =
                                !isExpandedPersonalList[i][0];

                            if (isExpandedPersonalList[i][0]) {
                              isExpandedAddressInfoList[i][0] = false;
                              isExpandedDocumentInfoList[i][0] = false;
                              isExpandedIDInfoList[i][0] = false;
                            }
                          });
                        }, [
                          TextLabel("Full Name"),
                          ReusableTextFormField(
                            hintText: "Full Name",
                            controller: fullNameControllers[i],
                            isEnabled: i == 0 ? false : true,
                            keyboardType: TextInputType.text,
                            errorMessage: "Full Name cannot be empty",
                            leadingIcon: Icons.person,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp("[a-zA-Z ]")),
                              // TextInputFormatter.withFunction(
                              //   (oldValue, newValue) {
                              //     return newValue.copyWith(
                              //         text: newValue.text.toUpperCase());
                              //   },
                              // ),
                            ],
                            isRequired: true,
                          ),
                          TextLabel("Phone Number"),
                          PhoneNumberWidget(
                            phoneNumberController: phoneControllers[i],
                            isEnabled: i == 0 ? false : true,
                          ),
                          TextLabel("Email"),
                          EmailWidget(emailController: emailControllers[i]),
                          TextLabel("Mother Name"),
                          ReusableTextFormField(
                            hintText: "Mother Name",
                            controller: motherNameControllers[i],
                            keyboardType: TextInputType.text,
                            errorMessage: "Mother Name cannot be empty",
                            leadingIcon: Icons.person,
                            isRequired: false,
                          ),
                          TextLabel("Title"),
                          ReusableDropdown(
                            selectedValue: selectedTitle[
                                i], // Use list index for each person
                            items: ListContants.title,
                            hintText: 'Select Title',
                            onChanged: (newStatus) {
                              setState(() {
                                selectedTitle[i] = newStatus!;
                              });
                            },
                            prefixIcon: Icons.category,
                            errorMessage: 'Please select a Title',
                            isRequired: true,
                          ),
                          TextLabel("Occupation "),
                          ReusableTextFormField(
                            hintText: "Enter Occupation",
                            controller: occupationControllers[i],
                            // keyboardType: TextInputType.number,
                            errorMessage: "Occupation cannot be empty",
                            leadingIcon: Icons.work,
                            // return '';
                            // inputFormatters: [
                            //   FilteringTextInputFormatter.digitsOnly, // Only allow numbers
                            // ],
                            isRequired: true,
                          ),
                          TextLabel("Monthly Income"),
                          ReusableTextFormField(
                            hintText: "Enter Monthly Income",
                            controller: monthlyIncomeControllers[i],
                            keyboardType: TextInputType.number,
                            errorMessage: "monthlyIncome cannot be empty",
                            leadingIcon: Icons.trending_up,
                            // return '';
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly, // Only allow numbers
                            ],
                            isRequired: true,
                          ),
                          TextLabel("Gender"),
                          ReusableDropdown(
                            selectedValue: selectedGender[i],
                            items: ListContants.gender,
                            hintText: 'Select Gender ',
                            onChanged: (newStatus) {
                              setState(() {
                                selectedGender[i] = newStatus!;
                              });
                            },
                            prefixIcon: Icons.person,
                            errorMessage:
                                'Please select Gender', // Pass the custom error message
                            isRequired: false, // Make the field required
                          ),
                          TextLabel("Marital Status"),
                          ReusableDropdown(
                            selectedValue: selectedMaritalStatus[i],
                            items: ListContants.maritalStatuses,
                            hintText: 'Select Marital Status',
                            onChanged: (newStatus) {
                              setState(() {
                                selectedMaritalStatus[i] = newStatus!;
                              });
                            },
                            prefixIcon: Icons.family_restroom,
                            errorMessage:
                                'Please select a marital status', // Pass the custom error message
                            isRequired: false, // Make the field required
                          ),
                          TextLabel("Sector"),
                          ReusableDropdown(
                            selectedValue: selectedSectors[
                                i], // Use list index for each person
                            items: ListContants.sectors,
                            hintText: 'Select Sector',
                            onChanged: (newStatus) {
                              setState(() {
                                selectedSectors[i] = newStatus!;
                              });
                            },
                            prefixIcon: Icons.category,
                            errorMessage: 'Please select a Sector status',
                            isRequired: true,
                          ),
                          TextLabel("Date of Birth"),
                          DatePickerField(
                            controller: dateOfBirthControllers[i],
                            hintText: 'Date of Birth',
                            prefixIcon: Icons.date_range,
                            initialDate: DateTime.now()
                                .add(const Duration(days: -10000)),
                            firstDate: DateTime(1940),
                            lastDate: DateTime.now(),
                            isRequired: true,
                            errorMessage: 'Please select a date of birth',
                          ),
                        ]),
                        _buildExpandablePersonalInformationSection(
                            "Address Information",
                            isExpandedAddressInfoList[i][0],
                            // isExpandedPersonalList[i][0],
                            () {
                          setState(() {
                            isExpandedAddressInfoList[i][0] =
                                !isExpandedAddressInfoList[i][0];
                            // isExpandedPersonalList[i][0] =
                            //     !isExpandedPersonalList[i][0];

                            isExpandedDocumentInfoList[i][0] = false;
                            isExpandedIDInfoList[i][0] = false;
                            isExpandedPersonalList[i][0] = false;
                          });
                        }, [
                          TextLabel("State"),
                          ReusableDropdown(
                            selectedValue: selectedState[i],
                            items: ListContants.ethiopianStates,
                            hintText: 'Select State',
                            onChanged: (newState) {
                              setState(() {
                                selectedState[i] = newState;
                                print(selectedState);
                              });
                            },
                            errorMessage: 'Please select a state',
                            prefixIcon: Icons.map,
                            isRequired: false,
                          ),
                          TextLabel("Zone Subcity"),
                          ReusableTextFormField(
                            hintText: "Zone Subcity",
                            controller: cityControllers[i],
                            // keyboardType: TextInputType.number,
                            errorMessage: "Zone Subcity cannot be empty",
                            leadingIcon: Icons.location_city,
                            isRequired: false,
                          ),
                          TextLabel("Woreda"),
                          ReusableTextFormField(
                            hintText: "Woreda",
                            controller: woredaControllers[i],
                            // keyboardType: TextInputType.number,
                            errorMessage: "Woreda cannot be empty",
                            leadingIcon: Icons.location_city,
                            isRequired: false,
                          ),
                        ]),
                        _buildExpandablePersonalInformationSection(
                            "Document Information",
                            isExpandedDocumentInfoList[i][0],
                            // isExpandedPersonalList[i][0],
                            () {
                          setState(() {
                            isExpandedDocumentInfoList[i][0] =
                                !isExpandedDocumentInfoList[i][0];
                            // isExpandedPersonalList[i][0] =
                            //     !isExpandedPersonalList[i][0];

                            isExpandedAddressInfoList[i][0] = false;
                            isExpandedPersonalList[i][0] = false;
                            isExpandedIDInfoList[i][0] = false;
                          });
                        }, [
                          TextLabel("Personal Photo"),

                          personalPhoto(i),
                          TextLabel("Document Type"),
                          ReusableDropdown(
                            selectedValue: selectedDocumentType[
                                i], // Use list index for each person
                            items: ListContants.documentName,
                            hintText: 'Select Document Type',
                            onChanged: (newStatus) {
                              setState(() {
                                selectedDocumentType[i] = newStatus!;
                              });
                            },
                            prefixIcon: Icons.category,
                            errorMessage: 'Please select a Sector status',
                            isRequired: true,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          idCardPhoto(i),
                          TextLabel("Signature"),
                          // signatureWidget1(context),
                          signatureCard(i),
                          signaturePadSelection(i),
                        ]),
                        _buildExpandablePersonalInformationSection(
                            "ID Information", isExpandedIDInfoList[i][0],
                            // isExpandedPersonalList[i][0],
                            () {
                          setState(() {
                            isExpandedIDInfoList[i][0] =
                                !isExpandedIDInfoList[i][0];
                            // isExpandedPersonalList[i][0] =
                            //     !isExpandedPersonalList[i][0];
                            isExpandedAddressInfoList[i][0] = false;
                            isExpandedDocumentInfoList[i][0] = false;
                            isExpandedPersonalList[i][0] = false;
                          });
                        }, [
                          TextLabel("Legal ID"),
                          ReusableTextFormField(
                            hintText: "Legal ID",
                            controller: legalIDControllers[i],
                            // keyboardType: TextInputType.number,
                            errorMessage: "Legal ID cannot be empty",
                            leadingIcon: Icons.badge,
                            isRequired: true,
                          ),
                          TextLabel("ISSUE AUTHORITY"),
                          ReusableTextFormField(
                            hintText: "ISSUE AUTHORITY",
                            controller: issueAuthorityControllers[i],
                            // keyboardType: TextInputType.number,
                            errorMessage: "ISSUE AUTHORITY cannot be empty",
                            leadingIcon: Icons.verified,
                            isRequired: false,
                          ),
                          TextLabel("ISSUE DATE"),
                          DatePickerField(
                            controller: issueDateControllers[i],
                            hintText: 'Issue Date',
                            prefixIcon: Icons.calendar_today,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(
                                days: 365 * 15)), // 15 years before today
                            lastDate: DateTime.now(),
                            isRequired: false,
                            errorMessage: 'Please select an issue date',
                          ),
                          TextLabel("EXPIRY DATE"),
                          DatePickerField(
                            controller: expireDateControllers[i],
                            hintText: 'Expire Date',
                            prefixIcon: Icons.event_busy,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(), // First date is today
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365 * 12)),
                            isRequired: false,
                            errorMessage: 'Please select an expire date',
                          ),
                        ]),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                    // idCardPhoto(),
                  ],
                ),
              ),
          ],
        ),
      ),
      Step(
        title: Text(isSmallScreen ? "" : "Financial Information"),
        isActive: _activeStepIndex >= 3,
        state: _activeStepIndex > 3 ? StepState.complete : StepState.indexed,
        content: Form(
          key: globalFormKey3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextLabel("InitialDeposit"),
              ReusableTextFormField(
                hintText: "InitialDeposit",
                controller: initialDepositController,
                keyboardType: TextInputType.number,
                errorMessage: "InitialDeposit cannot be empty",
                leadingIcon: Icons.account_balance_wallet,
                // return '';
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Only allow numbers
                ],
                isRequired: true,
              ),
              // TextLabel("Payment Method"),
              // PaymentMethodWidget(
              //   initialDepositController: initialDepositController,
              //   phoneNumberController: phoneNumberController,
              // ),
            ],
          ),
        ),
      ),
      Step(
        title: Text(isSmallScreen ? "" : "Financial Information"),
        isActive: _activeStepIndex >= 4,
        state: _activeStepIndex > 4 ? StepState.complete : StepState.indexed,
        content: Form(
          key: globalFormKey5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TextLabel("Gemechu Bulti "),

              const Text(
                ' Select Account Type',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.end,
              ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 15, right: 15),
              //   child: filteredAccountTypes.isNotEmpty
              //       ? Column(
              //           mainAxisAlignment: MainAxisAlignment.start,
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children:
              //               filteredAccountTypes.map<Widget>((accountType) {
              //             bool isSelected =
              //                 selectedAccountTypeId == accountType['name'];

              //             return GestureDetector(
              //               onTap: () {
              //                 setState(() {
              //                   selectedAccountTypeId = accountType[
              //                       'name']; // Update selected account type
              //                   print(
              //                       'Selected Account Type ID: $selectedAccountTypeId');
              //                 });
              //               },
              //               child: Container(
              //                 width: MediaQuery.of(context).size.width,
              //                 child: Card(
              //                   margin: const EdgeInsets.all(10),
              //                   color: isSelected
              //                       ? Colors.blue
              //                       : Colors.grey, // Change color if selected
              //                   shape: RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(10),
              //                   ),
              //                   child: Padding(
              //                     padding: const EdgeInsets.symmetric(
              //                         vertical: 1, horizontal: 2),
              //                     child: ListTile(
              //                       title: Text(
              //                         accountType['name'] as String,
              //                         style: TextStyle(
              //                           color: isSelected
              //                               ? Colors.white
              //                               : Colors
              //                                   .black, // Text color changes when selected
              //                           fontWeight: FontWeight.bold,
              //                         ),
              //                       ),
              //                       subtitle: Text("                     "),
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             );
              //           }).toList(),
              //         )
              //       : Center(
              //           child: Padding(
              //             padding: const EdgeInsets.all(20.0),
              //             child: Text(
              //               "Sorry, no accounts were found for selection. Please ensure that the initial deposit and date of birth are correctly entered.",
              //               style: TextStyle(
              //                 fontSize: 16,
              //                 fontWeight: FontWeight.bold,
              //                 color: Colors.red,
              //               ),
              //             ),
              //           ),
              //         ),
              // ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: filteredAccountTypes.isNotEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            filteredAccountTypes.map<Widget>((accountType) {
                          bool isSelected =
                              selectedAccountTypeId == accountType['name'];
                          bool isExpanded =
                              selectedAccountTypeId == accountType['name'] &&
                                  expandedAccountTypeId == accountType['name'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (selectedAccountTypeId ==
                                    accountType['name']) {
                                  expandedAccountTypeId =
                                      expandedAccountTypeId ==
                                              accountType['name']
                                          ? null
                                          : accountType['name'];
                                } else {
                                  selectedAccountTypeId = accountType['name'];
                                  expandedAccountTypeId = accountType['name'];
                                }
                                print(
                                    'Selected Account Type: $selectedAccountTypeId');
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Card(
                                margin: const EdgeInsets.all(10),
                                color: isSelected ? Colors.blue : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title
                                      Text(
                                        accountType['name'] ?? '',
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Description
                                      Text(
                                        accountType['description'] ?? '',
                                        maxLines: isExpanded ? null : 1,
                                        overflow: isExpanded
                                            ? TextOverflow.visible
                                            : TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white70
                                              : Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // More / Less Button
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          isExpanded
                                              ? "Show Less"
                                              : "Show More",
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            "Sorry, no accounts were found for selection. Please ensure that the initial deposit and date of birth are correctly entered.",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    ];
  }

  void _showSignaturePadDialog(BuildContext context, int i) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Draw Signatures',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // First Signature
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Signature(
                          controller: _signatureController1,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text("Signature 1"),
                          TextButton(
                            onPressed: () => clearSignature(1),
                            child: const Text("Clear"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Second Signature
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Signature(
                          controller: _signatureController2,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Signature 2"),
                          TextButton(
                            onPressed: () => clearSignature(2),
                            child: const Text("Clear"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Third Signature
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Signature(
                          controller: _signatureController3,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Signature 3"),
                          TextButton(
                            onPressed: () => clearSignature(3),
                            child: const Text("Clear"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (areAllSignaturesCompleted()) {
                            _saveCombinedSignature(i);
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please complete all signatures'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Padding signaturePadSelection(int i) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _showSignaturePadDialog(context, i),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
            ),
            child: const Text("      Sign     "),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              showImagePicker(context, i, "signature");
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
            ),
            child: const Text("Upload"),
          ),
        ],
      ),
    );
  }

  Center signatureCard(int i) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
        child: Container(
            height: 200,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 7,
                ),
              ],
            ),
            child: combinedSignatures[i].isNotEmpty
                ? Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.memory(
                        combinedSignatures[i]!,
                        fit: BoxFit.fill,
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.asset(
                      'assets/signature.png',
                      height: 10.0,
                      width: MediaQuery.of(context).size.width * 0.1,
                      fit: BoxFit.contain,
                    ),
                  )),
      ),
    );
  }

  Column personalPhoto(int i) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              const SizedBox(height: 10.0),
              Container(
                height: 200.0,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: profilePaths[i].isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(
                              'assets/photo1.png',
                              height: 170.0,
                              width: MediaQuery.of(context).size.width * 0.6,
                              fit: BoxFit.fill,
                            ),
                          )
                        ],
                      )
                    : GestureDetector(
                        onTap: () =>
                            _showFullScreenImage(context, profilePaths[i]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.file(
                            File(profilePaths[i]),
                            height: 200,
                            width: MediaQuery.of(context).size.width * 0.8,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 40.0),
              ButtonUploadTakePhoto(
                onUploadPressed: () => _imgFromGallery(i, 'profilePath'),
                onCapturePressed: () => _imgFromCamera(i, 'profilePath'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Column idCardPhoto(int i) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7, left: 10, right: 3),
          child: Text(
            'Front Photo of ${selectedDocumentType[i] ?? "ID"}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              Container(
                height: 150.0,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: residentPaths[i].isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(
                              'assets/id_front.png',
                              height: 150.0,
                              width: MediaQuery.of(context).size.width * 0.7,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      )
                    : GestureDetector(
                        onTap: () =>
                            _showFullScreenImage(context, residentPaths[i]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.file(
                            File(residentPaths[i]),
                            height: 200,
                            width: MediaQuery.of(context).size.width * 0.8,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20.0),
              ButtonUploadTakePhoto(
                onUploadPressed: () => _imgFromGallery(i, "resident"),
                onCapturePressed: () => _imgFromCamera(i, "resident"),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 7, left: 10, right: 3),
          child: Text(
            'Back Photo of ${selectedDocumentType[i] ?? "ID"}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              Container(
                height: 150.0,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: residentCardBackPaths[i].isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(
                              'assets/backpage.png',
                              height: 150.0,
                              width: MediaQuery.of(context).size.width * 0.7,
                              fit: BoxFit.fill,
                            ),
                          )
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.file(
                          File(residentCardBackPaths[i]),
                          height: 180.0,
                          width: MediaQuery.of(context).size.width * 0.7,
                          fit: BoxFit.fill,
                        ),
                      ),
              ),
              const SizedBox(height: 20.0),
              ButtonUploadTakePhoto(
                onUploadPressed: () => _imgFromGallery(i, "residentCardBack"),
                onCapturePressed: () => _imgFromCamera(i, "residentCardBack"),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        )
      ],
    );
  }

  Widget branchSelectorWidget1() {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: selectedBranch,
            hint: const Text('Choose a branch'),
            onChanged: (String? newValue) {
              setState(() {
                selectedBranch = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Branch is required';
              }
              return null;
            },
            items: allBranches.map<DropdownMenuItem<String>>((branch) {
              return DropdownMenuItem<String>(
                value: branch['companyName'] ?? '',
                child: Text(branch['companyName'] ?? ''),
              );
            }).toList(),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.blue),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.red),
              ),
              prefixIcon: Icon(Icons.location_city),
            ),
          ),
        ],
      ),
    );
  }

  void initializeBranches() async {
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      var decodedToken = JwtDecoder.decode(token);

      // Get regular branches
      List<Map<String, dynamic>> regularBranches =
          decodedToken.containsKey("branch")
              ? List<Map<String, dynamic>>.from(decodedToken["branch"])
              : [];

      setState(() {
        allBranches = [];

        // Add main branch first if it exists
        if (decodedToken.containsKey("mainBranch")) {
          allBranches.add(decodedToken["mainBranch"]);
          // Set main branch as default selected branch
          selectedBranch = decodedToken["mainBranch"]["companyName"];
        }

        // Add regular branches
        allBranches.addAll(regularBranches);
      });
    }
  }

  int _activeStepIndex = 0;

  @override
  Widget build(BuildContext context) {
    final SignatureController _signatureController = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.black,
    );
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: AppBar(
              title: const Text(
                "Joint Account Opening",
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),

              leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage()),
                      (route) => false,
                    );
                  }),
              // actions: [
              //   IconButton(
              //       icon: const Icon(Icons.sync_outlined), onPressed: () {}),
              // ],
              // centerTitle: true,
              backgroundColor: Colors.white,
            ),
          ),
          body: Container(
            child: Center(
              child: Container(
                width: width < 600 ? double.infinity : width * 0.5,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              width: max(constraints.maxWidth, 380),
                              child: Form(
                                key: globalFormKey,
                                child: Theme(
                                  data: ThemeData(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors.blue,
                                      secondary: Colors.blue,
                                    ),
                                  ),
                                  child: Stepper(
                                    type: StepperType.horizontal,
                                    steps: stepList(),
                                    currentStep: _activeStepIndex,
                                    margin: EdgeInsets.zero,
                                    controlsBuilder: (BuildContext context,
                                        ControlsDetails details) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20, left: 20, right: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            if (_activeStepIndex > 0)
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: TextButton(
                                                  onPressed: onStepCancel,
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.blue,
                                                  ),
                                                  child: const Text(
                                                    '     Back     ',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            const Spacer(),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                onPressed: onStepContinue,
                                                style: TextButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                ),
                                                child: isLoading
                                                    ? const SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    : Text(
                                                        _activeStepIndex == 4
                                                            ? 'Submit'
                                                            : 'Continue',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  void showImagePicker(BuildContext context, int i, String imageTypes) {
    print("iamgellanlaoofofoofo");
    print(imageTypes);
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Card(
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 5.2,
                margin: const EdgeInsets.only(top: 8.0),
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: InkWell(
                      child: const Column(
                        children: [
                          Icon(
                            Icons.image,
                            size: 60.0,
                          ),
                          SizedBox(height: 12.0),
                          Text(
                            "Gallery",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          )
                        ],
                      ),
                      onTap: () {
                        _imgFromGallery(i, imageTypes);
                        Navigator.pop(context);
                      },
                    )),
                    Expanded(
                        child: InkWell(
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 60.0,
                            ),
                            SizedBox(height: 12.0),
                            Text(
                              "Camera",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        // _imgFromCamera(i, imageTypes);
                        _imgFromCamera(i, 'signature');
                        Navigator.pop(context);
                      },
                    ))
                  ],
                )),
          );
        });
  }

  Future<void> _imgFromGallery(int i, String imageTypes) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File originalFile = File(pickedFile.path);

      // Step 1: Check if the original file exists
      bool originalExists = await originalFile.exists();
      print("Original file exists: $originalExists");

      if (!originalExists) {
        print("Error: Selected file does not exist.");
        return;
      }

      // Step 2: Get the application's document directory
      Directory appDir = await getApplicationDocumentsDirectory();
      String newPath =
          '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      try {
        // Step 3: Copy the file to the permanent directory
        File newImage = await originalFile.copy(newPath);

        // Step 4: Verify the new file exists
        bool newFileExists = await newImage.exists();
        print("New saved path: $newPath");
        print("New file exists: $newFileExists");

        if (newFileExists) {
          setState(() {
            if (imageTypes == 'profilePath') {
              profilePaths[i] = newPath;
            } else if (imageTypes == 'resident') {
              residentPaths[i] = newPath;
            } else if (imageTypes == 'residentCardBack') {
              residentCardBackPaths[i] = newPath;
            } else if (imageTypes == 'signature') {
              // signatureImagePath = croppedFile.path;
              // savedSignature = null;
              // _signatureController.clear();

              // Clear drawn signature
              _signatureController1.clear();
              _signatureController2.clear();
              _signatureController3.clear();
              savedSignature = null;
              combinedSignatures[i] = File(newPath).readAsBytesSync();
            }
          });
        } else {
          print("Error: File was not copied successfully.");
        }
      } catch (e) {
        print("Error copying file: $e");
      }
    }
  }

  bool _isDialogShowing = false;
  Future<void> _imgFromCamera(int i, String imageTypes) async {
    try {
      FocusScope.of(context).unfocus();

      final permissionStatus = await Permission.camera.request();
      if (!permissionStatus.isGranted) {
        if (permissionStatus.isPermanentlyDenied) {
          await openAppSettings();
        }
        return;
      }

      if (mounted && !_isDialogShowing) {
        _isDialogShowing = true;
        // Await dialog to avoid racing issues
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }

      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );
      debugPrint('Picked file path: ${pickedFile?.path}');

      if (!mounted || pickedFile == null) {
        _closeDialogIfNeeded();
        return;
      }

      final originalFile = File(pickedFile.path);
      if (!await originalFile.exists()) {
        debugPrint('Original file does not exist');
        _closeDialogIfNeeded();
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final newPath =
          '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      File newImage;
      try {
        newImage = await originalFile.copy(newPath);
      } catch (e) {
        debugPrint('Error copying file: $e');
        _closeDialogIfNeeded();
        return;
      }

      if (!await newImage.exists()) {
        debugPrint('Copied file does not exist');
        _closeDialogIfNeeded();
        return;
      }

      Uint8List bytes;
      try {
        bytes = await newImage.readAsBytes();
      } catch (e) {
        debugPrint('Error reading bytes from copied file: $e');
        _closeDialogIfNeeded();
        return;
      }

      if (!mounted) {
        _closeDialogIfNeeded();
        return;
      }

      void ensureIndex<T>(List<T> list, T defaultValue) {
        if (i >= list.length) {
          list.addAll(List.generate(i - list.length + 1, (_) => defaultValue));
        }
      }

      if (mounted) {
        setState(() {
          switch (imageTypes) {
            case 'profilePath':
              ensureIndex<String>(profilePaths, '');
              profilePaths[i] = newPath;
              break;
            case 'resident':
              ensureIndex<String>(residentPaths, '');
              residentPaths[i] = newPath;
              break;
            case 'residentCardBack':
              ensureIndex<String>(residentCardBackPaths, '');
              residentCardBackPaths[i] = newPath;
              break;
            case 'signature':
              _signatureController1.clear();
              _signatureController2.clear();
              _signatureController3.clear();
              savedSignature = null;
              ensureIndex<Uint8List>(combinedSignatures, Uint8List(0));
              combinedSignatures[i] = bytes;
              break;
          }
        });
      }

      // Small delay to ensure UI settled before closing dialog
      await Future.delayed(const Duration(milliseconds: 300));
      _closeDialogIfNeeded();
    } catch (e, stack) {
      debugPrint("Exception in _imgFromCamera: $e\n$stack");
      _closeDialogIfNeeded();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to capture image. Step not lost.")),
        );
      }
    }
  }

  void _closeDialogIfNeeded() {
    if (_isDialogShowing && mounted) {
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (e) {
        debugPrint('Error closing dialog: $e');
      }
      _isDialogShowing = false;
    }
  }

// Future<void> _imgFromCamera(int i, String imageTypes) async {
//   bool _isDialogShowing = false;

//   Future<void> safeCloseDialog() async {
//     if (_isDialogShowing && mounted && Navigator.canPop(context)) {
//       Navigator.of(context, rootNavigator: true).pop();
//       _isDialogShowing = false;
//     }
//   }

//   try {
//     FocusScope.of(context).unfocus();

//     // Request camera permission
//     final permissionStatus = await Permission.camera.request();
//     if (!permissionStatus.isGranted) {
//       if (permissionStatus.isPermanentlyDenied) {
//         await openAppSettings();
//       }
//       return;
//     }

//     // Show loading indicator
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) {
//         _isDialogShowing = true;
//         return const Center(child: CircularProgressIndicator());
//       },
//     );

//     final XFile? pickedFile = await ImagePicker().pickImage(
//       source: ImageSource.camera,
//       imageQuality: 50,
//     );

//     if (pickedFile == null) {
//       await safeCloseDialog();
//       return;
//     }

//     final File originalFile = File(pickedFile.path);
//     if (!await originalFile.exists()) {
//       await safeCloseDialog();
//       return;
//     }

//     final appDir = await getApplicationDocumentsDirectory();
//     final newPath = '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final File newImage = await originalFile.copy(newPath);

//     if (!await newImage.exists()) {
//       await safeCloseDialog();
//       return;
//     }

//     final Uint8List bytes = await newImage.readAsBytes();

//     if (!mounted) {
//       await safeCloseDialog();
//       return;
//     }

//     // Ensure list has room at index i
//     void ensureIndex<T>(List<T> list, T defaultValue) {
//       if (i >= list.length) {
//         list.addAll(List.generate(i - list.length + 1, (_) => defaultValue));
//       }
//     }

//     // Safely update state
//     if (mounted) {
//       setState(() {
//         switch (imageTypes) {
//           case 'profilePath':
//             ensureIndex<String>(profilePaths, '');
//             profilePaths[i] = newPath;
//             break;
//           case 'resident':
//             ensureIndex<String>(residentPaths, '');
//             residentPaths[i] = newPath;
//             break;
//           case 'residentCardBack':
//             ensureIndex<String>(residentCardBackPaths, '');
//             residentCardBackPaths[i] = newPath;
//             break;
//           case 'signature':
//             _signatureController1.clear();
//             _signatureController2.clear();
//             _signatureController3.clear();
//             savedSignature = null;
//             ensureIndex<Uint8List>(combinedSignatures, Uint8List(0));
//             combinedSignatures[i] = bytes;
//             break;
//         }
//       });
//     }

//     await safeCloseDialog();
//   } catch (e, stack) {
//     debugPrint("Exception in _imgFromCamera: $e\n$stack");
//     await safeCloseDialog();

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to capture image. Step not lost.")),
//       );
//     }
//   }
// }

  // Future<void> _imgFromCamera(int i, String imageTypes) async {
  //   try {
  //     FocusScope.of(context).unfocus();

  //     final permissionStatus = await Permission.camera.request();
  //     if (!permissionStatus.isGranted) {
  //       debugPrint("Camera permission denied");
  //       return;
  //     }

  //     // Show loader
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (_) => const Center(child: CircularProgressIndicator()),
  //     );

  //     final pickedFile = await ImagePicker().pickImage(
  //       source: ImageSource.camera,
  //       imageQuality: 50,
  //     );

  //     if (pickedFile != null) {
  //       final originalFile = File(pickedFile.path);

  //       bool originalExists = await originalFile.exists();
  //       debugPrint("Original file exists: $originalExists");

  //       if (!originalExists) {
  //         debugPrint("Error: Captured file does not exist.");
  //         Navigator.of(context, rootNavigator: true).pop();
  //         return;
  //       }

  //       final appDir = await getApplicationDocumentsDirectory();
  //       final newPath =
  //           '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

  //       try {
  //         final newImage = await originalFile.copy(newPath);
  //         final newFileExists = await newImage.exists();
  //         debugPrint("New saved path: $newPath");
  //         debugPrint("New file exists: $newFileExists");

  //         if (newFileExists) {
  //           if (!mounted) return;
  //           setState(() {
  //             switch (imageTypes) {
  //               case 'profilePath':
  //                 profilePaths[i] = newPath;
  //                 break;
  //               case 'resident':
  //                 residentPaths[i] = newPath;
  //                 break;
  //               case 'residentCardBack':
  //                 residentCardBackPaths[i] = newPath;
  //                 break;
  //               case 'signature':
  //                 _signatureController1.clear();
  //                 _signatureController2.clear();
  //                 _signatureController3.clear();
  //                 savedSignature = null;
  //                 combinedSignatures[i] = File(newPath).readAsBytesSync();
  //                 break;
  //             }
  //           });
  //         } else {
  //           debugPrint("Error: File was not copied successfully.");
  //         }
  //       } catch (e) {
  //         debugPrint("Error copying file: $e");
  //       }
  //     }

  //     // Dismiss loader
  //     Navigator.of(context, rootNavigator: true).pop();
  //   } catch (e, stack) {
  //     debugPrint("Error in _imgFromCamera: $e\n$stack");
  //     // Dismiss loader if still open
  //     Navigator.of(context, rootNavigator: true).pop();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //           content: Text("Failed to capture image. Please try again.")),
  //     );
  //   }
  // }

  // Future<void> _imgFromCamera(int i, String imageTypes) async {
  //   final pickedFile =
  //       await ImagePicker().pickImage(source: ImageSource.camera);
  //   if (pickedFile != null) {
  //     File originalFile = File(pickedFile.path);

  //     bool originalExists = await originalFile.exists();
  //     print("Original file exists: $originalExists");

  //     if (!originalExists) {
  //       print("Error: Captured file does not exist.");
  //       return;
  //     }

  //     Directory appDir = await getApplicationDocumentsDirectory();
  //     String newPath =
  //         '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

  //     try {
  //       File newImage = await originalFile.copy(newPath);
  //       bool newFileExists = await newImage.exists();
  //       print("New saved path: $newPath");
  //       print("New file exists: $newFileExists");

  //       if (newFileExists) {
  //         setState(() {
  //           if (imageTypes == 'profilePath') {
  //             profilePaths[i] = newPath;
  //           } else if (imageTypes == 'resident') {
  //             residentPaths[i] = newPath;
  //           } else if (imageTypes == 'residentCardBack') {
  //             residentCardBackPaths[i] = newPath;
  //           } else if (imageTypes == 'signature') {
  //             print("dkdnandjhahdadjsdfh");
  //             // signatureImagePath = croppedFile.path;
  //             // savedSignature = null;
  //             // _signatureController.clear();

  //             // Clear drawn signature
  //             _signatureController1.clear();
  //             _signatureController2.clear();
  //             _signatureController3.clear();
  //             savedSignature = null;

  //             combinedSignatures[i] = File(newPath).readAsBytesSync();
  //           }
  //         });
  //       } else {
  //         print("Error: File was not copied successfully.");
  //       }
  //     } catch (e) {
  //       print("Error copying file: $e");
  //     }
  //   }
  // }

  Future<Uint8List?> _getImageBytes(String imagePath) async {
    try {
      final File imageFile = File(imagePath);

      // Check if file exists
      bool fileExists = await imageFile.exists();
      print('File exists at $imagePath: $fileExists');

      if (fileExists) {
        // Try reading the file as bytes
        final bytes = await imageFile.readAsBytes();
        print('File successfully read');
        return bytes;
      } else {
        print('File does not exist at path: $imagePath');
        return null;
      }
    } catch (e) {
      print("Error reading image: $e");

      // If file doesn't exist, check the file path and directory
      final directory =
          Directory(imagePath.substring(0, imagePath.lastIndexOf('/')));
      bool dirExists = await directory.exists();
      print("Directory exists at ${directory.path}: $dirExists");

      if (!dirExists) {
        print("Directory does not exist. Attempting to create it...");
        await directory.create(
            recursive: true); // Create the directory if it doesn't exist
      }

      return null;
    }
  }

  void clearSignature(int index) {
    setState(() {
      switch (index) {
        case 1:
          _signatureController1.clear();
          break;
        case 2:
          _signatureController2.clear();
          break;
        case 3:
          _signatureController3.clear();
          break;
      }
    });
  }

  Future<Uint8List?> _combineSignatures() async {
    // Get individual signature bytes
    final signature1 = await _signatureController1.toPngBytes();
    final signature2 = await _signatureController2.toPngBytes();
    final signature3 = await _signatureController3.toPngBytes();

    if (signature1 == null || signature2 == null || signature3 == null) {
      print("One or more signatures are empty!");
      return null;
    }

    // Decode the individual images
    final ui.Image image1 = await decodeImageFromList(signature1);
    final ui.Image image2 = await decodeImageFromList(signature2);
    final ui.Image image3 = await decodeImageFromList(signature3);

    // Calculate the total width and height (maximum height of all signatures)
    final int totalWidth =
        image1.width + image2.width + image3.width + 20; // Add spacing
    final int maxHeight = [image1.height, image2.height, image3.height]
        .reduce((a, b) => a > b ? a : b);

    // Draw the images onto a single canvas
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromLTWH(0, 0, totalWidth.toDouble(), maxHeight.toDouble()));

    double currentX = 0;

    // Draw signature 1
    canvas.drawImage(image1, Offset(currentX, 0), Paint());
    currentX += image1.width.toDouble() + 10; // Add spacing

    // Draw signature 2
    canvas.drawImage(image2, Offset(currentX, 0), Paint());
    currentX += image2.width.toDouble() + 10;

    // Draw signature 3
    canvas.drawImage(image3, Offset(currentX, 0), Paint());

    // End the recording
    final picture = recorder.endRecording();
    final combinedImage = await picture.toImage(totalWidth, maxHeight);

    // Convert the combined image to bytes
    final byteData =
        await combinedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  void _clearSignature() {
    _signatureController.clear();
  }

  void _saveSignature() {}
  bool isStepComplete(int stepIndex) {
    print(_activeStepIndex);
    print("_activeStepIndex");
    switch (stepIndex) {
      case 0:
        return phoneNumberController.text.isNotEmpty &&
            phoneNumberController.text.length == 9;
      case 2:
      case 1:
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
      default:
        return false;
    }
  }

  void _previousStep() {
    if (_activeStepIndex > 0) {
      setState(() {
        _activeStepIndex -= 1;
      });
    }
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;

    isValid = EmailValidator.validate(emailController.text);
    if (form != null && form.validate()) {
      form.save();
      return true;
    }

    return false;
  }

  Future<void> onStepContinue() async {
    registerStatus = true;
    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
    });
    final formIsValid = validateData();

    print("formIsValid");
    print(formIsValid);

    if (formIsValid) {
      final isLastStep = _activeStepIndex == stepList().length - 1;
      print("isLastStep1");
      print(isLastStep);
      print(_activeStepIndex);

      if (_activeStepIndex == 0) {
        registerStatus = true;
        // await handleFirstStep();
      } else if (_activeStepIndex == 1) {
        registerStatus = true;
        // validateAllForms();
        // handleSecondStep();
      } else if (_activeStepIndex == 2) {
        registerStatus = true;
        // await handleThirdStep();
      } else if (_activeStepIndex == 3) {
        registerStatus = true;
        _filterAccountTypes(selectedProductType!);
        // await handleStepFour();
      } else if (_activeStepIndex == 4) {
        _filterAccountTypes(selectedProductType!);
        // await handleStepFive();
      } else if (_activeStepIndex == 5) {
        // await basicInformation();
      } else if (_activeStepIndex == 6) {
        // await addressInfo();
      } else if (_activeStepIndex == 7) {
        // await handleStepSeven();
      }

      if (isLastStep) {
        registerStatus = true;
        if (selectedAccountTypeId == null) {
          registerStatus = false;
          isLoading = false;

          DialogHelper.showErrorDialog(context, "Please select account type");

          return;
        } else {
          // registerAllUsers();
          setState(() {
            isLoading = true; // Start loading before registration
          });
          await registerAllUsers();
          setState(() {
            isLoading = false; // Stop loading after registration
          });
        }
      } else {
        if (!registerStatus) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to register try later.')),
          );
        } else {
          setState(() {
            _activeStepIndex += 1;

            print("_activeStepIndex");
            print(_activeStepIndex);
          });
        }
      }
    } else {}

    setState(() {
      isLoading = false;
    });
  }

  bool validateAllForms() {
    bool allValid = true;

    if (formKeys.isEmpty) {
      print("No forms available for validation.");
      return false;
    }

    setState(() {
      for (int i = 0; i < formKeys.length; i++) {
        bool isMainValid = formKeys[i].currentState?.validate() ?? false;

        if (!isMainValid) {
          allValid = false;
          isExpandedList[i] = true; // Expand the main section if invalid
        }

        // Check if personal information section has errors
        bool isPersonalValid = true;
        if (fullNameControllers[i].text.trim().isEmpty ||
            phoneControllers[i].text.trim().isEmpty ||
            emailControllers[i].text.trim().isEmpty) {
          isPersonalValid = false;
        }

        if (!isPersonalValid) {
          allValid = false;
          isExpandedPersonalList[i][0] =
              true; // Expand Personal Information section
        }
      }
    });

    if (allValid) {
      print("All forms are valid. Proceeding to submission...");
      return true;
    } else {
      showSnackBar(context, "Please fill in all required fields.");
      return false;
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 14),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(
            horizontal: 20, vertical: 10), // Smaller margins
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded edges
        ),
        duration: Duration(seconds: 2), // Shorter display time
      ),
    );
  }

  bool validateData() {
    // bool data = validateAllForms();

    // print("dhjddddjdjdjdjjdjdj");
    // print(data);
    switch (_activeStepIndex) {
      case 0:
        isValid = true;
        print("check emial status");
        print(emailController.text);
        if (emailController.text.isNotEmpty) {
          isValid = EmailValidator.validate(emailController.text);
        }

        return (globalFormKey.currentState?.validate() ?? false) && isValid;
      case 1:
        return true;
      case 2:
        return true;
      case 3:
        return true;
      case 4:
        return true;
      case 5:
        return globalFormKey5.currentState?.validate() ?? false;
      case 6:
        return globalFormKey6.currentState?.validate() ?? false;
      case 7:
        return globalFormKey7.currentState?.validate() ?? false;
      case 8:
        return globalFormKey8.currentState?.validate() ?? false;

      default:
        return false;
    }
  }

  void onStepCancel() {
    if (_activeStepIndex > 0) {
      setState(() {
        _activeStepIndex -= 1;
      });
    }
  }

  _setDateHandler(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(seconds: 1)),
      firstDate: DateTime(1940),
      lastDate: DateTime(2024, 12, 31),
    );
    if (picked != null) {
      {
        dateController.text = picked.toString().split(" ")[0];
      }
    }
  }

  Padding TextLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 10, right: 3),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Column signatureWidget1(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
            child: Container(
              height: 180,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                  ),
                ],
              ),
              child: savedSignature != null
                  ? Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.memory(
                          savedSignature!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : (signatureImagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.file(
                            File(signatureImagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.asset(
                            'assets/signature.png',
                            height: 10.0,
                            width: MediaQuery.of(context).size.width * 0.1,
                            fit: BoxFit.contain,
                          ),
                        )),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: [
                    // SignatureButtons(
                    //   onDrawSignature: () => _showDrawSignatureDialog(context),
                    //   onUploadOrTake: () =>
                    //       showImagePicker(context, "signature"),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> fetchToken() async {
    String? token =
        await storage.read(key: "token"); // Get token from secure storage
    if (token != null && token.isNotEmpty) {
      // Decode the token using the JwtDecoder
      var decodedToken = JwtDecoder.decode(token);
      branch = decodedToken.containsKey("branch")
          ? List<Map<String, dynamic>>.from(decodedToken["branch"])
          : [];

      if (decodedToken.containsKey("mainBranch")) {
        branches.insert(0, decodedToken["mainBranch"]);
      }

      setState(() {
        mergedBranches = branch;
        selectedBranch1 = mergedBranches.isNotEmpty
            ? mergedBranches[0]['id'].toString()
            : null;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDrawSignatureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Draw Signature'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: Signature(
              controller: _signatureController,
              backgroundColor: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Clear'),
              onPressed: () {
                _signatureController.clear();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (_signatureController.isNotEmpty) {
                  // Capture the signature as an image
                  final signatureImage = await _signatureController.toImage();
                  final byteData = await signatureImage!
                      .toByteData(format: ImageByteFormat.png);

                  setState(() {
                    savedSignature = byteData!.buffer.asUint8List();
                    signatureImagePath = null;

                    // isSignatureDrawn = true;
                  });

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> submitStepData() async {
    // var connectivityResult = await Conne().checkConnectivity();
    if (isOnline) {
      var response;
      print("userId V");
      print(userId);
      if (userId == null) {
        try {
          print("registrationData1");
          print("object");
          print(userId);
          response = await networkHandler
              .post1('/api/v1/accounts', registrationData)
              .timeout(const Duration(seconds: 20));

          var responseData = json.decode(response.body);
          print("response.statusCode");
          print(response.statusCode);

          if (response.statusCode == 200 || response.statusCode == 201) {
            setState(() {
              validate = true;
              circular = false;
              userId = responseData['id'].toString();
              registerStatus = true;
            });
          } else {
            String errorText;
            print("response.body");
            var errorResponse = jsonDecode(response.body);
            errorText = errorResponse['message'] ??
                "Unable to register, please try later";
            print("object");
            registerStatus = false;

            FormHelper.showSimpleAlertDialog(
              context,
              "Coop Engage +",
              errorText,
              "OK",
              () {
                Navigator.of(context).pop();
              },
            );
            // const SnackBar(
            //   content: Text(errorText),
            // );
          }
        } on TimeoutException catch (_) {
          registerStatus = false;
          print("The request timed out. Please try again.");
        } catch (e) {
          registerStatus = false;
          // Handle other exceptions
          print("An error occurred: $e");
        }
      } else if (userId != null) {
        print("registrationData");

        print("userI1d");
        print(userId);
        await updateUser();
      } else {
        registerStatus = false;
        // Handle API error
        Map<String, dynamic> responseBody = json.decode(response.body);
        String errorMessage = responseBody['message'] ?? 'An error occurred';
        setState(() {
          validate = false;
          circular = false;
        });
        // Show error feedback
        FormHelper.showSimpleAlertDialog(
          context,
          "Error",
          errorMessage,
          "OK",
          () {
            Navigator.of(context).pop();
          },
        );
      }
    } else {
// If offline, store only email and phoneNumber locally
      print("Offline: Saving email and phoneNumber locally");

      try {
        if (GlobalData().role != 'ACCOUNT-CREATOR' &&
            GlobalData().role != 'AGENT') {
          print(GlobalData().role);
          registerStatus = false;
          FormHelper.showSimpleAlertDialog(
            context,
            "Coop Engage +",
            "You dont have permission to create Account",
            "OK",
            () {
              Navigator.of(context).pop();
            },
          );
        } else {
          DatabaseHelper dbHelper = DatabaseHelper();
          await dbHelper.database; // Ensure the database is initialized
          print(UserID);
          // Insert customer data
          var data = await dbHelper.insertCustomer({
            'phone': registrationData['phone'],
            'email': registrationData['email'],
            'status': 'INITIAL',
            "userId": UserID
          });

          print("data");
          print(data);

          setState(() {
            registerStatus = true;
            validate = true;
            circular = false;
            userID = data;
          });
          print(data);
          print("Customer data inserted successfully.");
        }
      } catch (e) {
        registerStatus = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error inserting customer data')),
        );
        print("Error inserting customer data: $e");
      }
    }
  }

  // Step 6:
  Future<void> basicInformation() async {
    final Map<String, String> titleGenderMap = {
      'MR': 'MALE',
      'MRS': 'FEMALE',
      'MS': 'FEMALE',
      'MISS': 'FEMALE',
      'DR': 'Both',
    };

    bool isValidTitle = false;

    if (selectedTitle == 'DR') {
      isValidTitle = true;
    } else if (titleGenderMap[selectedTitle] == selectedGender) {
      isValidTitle = true; // Title aligns with gender
    }

    if (!isValidTitle) {
      registerStatus = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid Title: "$selectedTitle" is not valid for gender "$selectedGender".',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop execution if invalid
    }

    registrationData['fullName'] = fullNameController.text;
    registrationData['surname'] = surNameController.text;
    registrationData['motherName'] = motherNameController.text;
    registrationData['sex'] = selectedGender;
    registrationData['dateOfBirth'] = dateOfBirthController.text;
    registrationData["title"] = selectedTitle;
    // registrationData["maritalStatus"] = selectedMaritalStatus;
    registrationData["percentageCompleted"] = 75;
    isOnline
        ? registrationData['formCompleted'] = "false"
        : registrationData['formCompleted'] = 0;
    print(registrationData);
    // registerStatus = true;
    await updateUser();
  }

  // Step 1:
  Future<void> handleFirstStep() async {
    registrationData['customerType'] = selectedCustomerType;
    registrationData['phone'] = '+251${phoneNumberController.text}';
    registrationData['email'] = emailController.text;
    registrationData["percentageCompleted"] = 12.5;
    registrationData['status'] = "INITIAL";
    isOnline
        ? registrationData['formCompleted'] = "false"
        : registrationData['formCompleted'] = 0;
    print(registrationData);

    await submitStepData();
  }

  //STEP 2:
  Future<void> handleSecondStep() async {
    Uint8List? residentBytes;
    Uint8List? residentCardBackBytes;
    if (residentPath.isNotEmpty) {
      residentBytes = await _getImageBytes(residentPath);
    }
    if (residentCardBackPath.isNotEmpty) {
      residentCardBackBytes = await _getImageBytes(residentCardBackPath);
    }

    registrationData["branch"] = selectedBranch;
    registrationData["documentName"] = selectedDocumentType;
    registrationData['residenceCard'] = residentBytes;
    registrationData['residenceCardBack'] = residentCardBackBytes;
    registrationData["percentageCompleted"] = 25;
    registrationData['status'] = "INITIAL";
    isOnline
        ? registrationData['formCompleted'] = false
        : registrationData['formCompleted'] = 0;

    print(registrationData);

    await updateUser();
  }

// STEP 3:
  Future<void> handleThirdStep() async {
    registrationData['signature'] = _combinedSignature;
    registrationData['motherName'] = motherNameController.text;
    // registrationData['branch'] = selectedBranch;
    registrationData["percentageCompleted"] = 37.5;
    registrationData['status'] = "INITIAL";
    isOnline
        ? registrationData['formCompleted'] = "false"
        : registrationData['formCompleted'] = 0;

    print(registrationData);
    await updateUser();
  }

//STEP: 4
  Future<void> handleStepFour() async {}

  Future<void> addressInfo() async {
    registrationData['country'] = selectedCountry;
    registrationData['issueAuthority'] = issueAuthorityController.text;
    registrationData['issueDate'] = issueDateController.text;
    registrationData['expirayDate'] = expireDateController.text;
    registrationData['legalId'] = legalIDController.text;
    registrationData['state'] = selectedState;
    registrationData['zoneSubCity'] = cityController.text;
    registrationData['streetAddress'] = woredaController.text;
    registrationData["percentageCompleted"] = 87.5;
    registrationData['status'] = "INITIAL";

    isOnline
        ? registrationData['formCompleted'] = false
        : registrationData['formCompleted'] = 0;
    print(registrationData);
    await updateUser();
  }

  Future<void> handleStepThree() async {
    registrationData['occupation'] = occupationController.text;
    registrationData['monthlyIncome'] = monthlyIncomeController.text;
    registrationData['branch'] = selectedBranch;
    registrationData['currency'] = selectedCurrency;
    registrationData['status'] = "INITIAL";
    isOnline
        ? registrationData['formCompleted'] = false
        : registrationData['formCompleted'] = 0;

    print(registrationData);
    await updateUser();
  }

  Future<void> handleStepFive() async {
    //  registrationData['sector'] = selectedSector;
    registrationData['occupation'] = occupationController.text;
    registrationData['monthlyIncome'] = monthlyIncomeController.text;
    registrationData['initialDeposit'] = initialDepositController.text;
    registrationData["percentageCompleted"] = 62.5;
    registrationData['status'] = "INITIAL";

    isOnline
        ? registrationData['formCompleted'] = "false"
        : registrationData['formCompleted'] = 0;

    print(registrationData['occupation']);
    print(registrationData['monthlyIncome']);
    await updateUser();
  }

  Future<void> handleStepSeven() async {
    print(selectedAccountId);
    print("daaaaa");

    var id;
    if (selectedAccountTypeId != null) {
      var accountTypeDetails = getAccountTypeDetails(selectedAccountTypeId!);
// // Check if accountTypeDetails is not null and then get the id
      id = accountTypeDetails != null ? accountTypeDetails['id'] : null;
    }

    if (id == null) {
      registerStatus = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select account type',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop execution if invalid
    }

    registrationData['accountType'] = id;
    registrationData["percentageCompleted"] = 90;
    // registrationData['status'] = "UNSETTLED";
    registrationData['status'] = "INITIAL";
    // registrationData['accountType'] = id;
    isOnline
        ? registrationData['formCompleted'] = "false"
        : registrationData['formCompleted'] = 0;
    // registerStatus = true;
    await updateUser();
  }

  Future<void> submitFormData1() async {
    print("objectqwww");
    if (!termsAccepted) {
      registerStatus = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please accept terms and Conditions',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop execution if invalid
    }

    registrationData["percentageCompleted"] = 100;
    registrationData['status'] = "UNSETTLED";
    isOnline
        ? registrationData['formCompleted'] = "true"
        : registrationData['formCompleted'] = 1;
    // registerStatus = true;
    await updateUser();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationPage(
          registrationData: registrationData,
          userId: userId,
          className: "create",
        ),
      ),
    );

    if (result != null) {
      setState(() async {
        isLoading = false;
        await Future.delayed(const Duration(milliseconds: 100));
        FocusScope.of(context).unfocus();
        userId = result;
        isLoading = false;
      });
    }
  }

  Future<void> updateUser() async {
    if (isOnline) {
      try {
        var response = await networkHandler
            .put1('/api/v1/accounts/$userId', registrationData)
            .timeout(const Duration(seconds: 15));

        print("response.statusCode");
        print(response.statusCode);

        print("response");

        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() {
            validate = true;
            circular = false;
            registerStatus = true;
          });
        } else {
          registerStatus = false;
        }
      } on TimeoutException catch (_) {
        registerStatus = false;
        print("The request timed out. Please try again.");
      } catch (e) {
        registerStatus = false;
        // Handle other exceptions
        print("An error occurred: $e");
      }
    } else if (isOnline == false) {
      try {
        final DatabaseHelper dbHelper = DatabaseHelper();
        registrationData['id'] = userID;

        // Apply timeout to the updateCustomer call
        int rowsAffected = await dbHelper
            .updateCustomer(userID!, registrationData)
            .timeout(const Duration(seconds: 10));

        if (rowsAffected > 0) {
          registerStatus = true;
          print("User updated successfully in the local database.");
        } else {
          registerStatus = false;
          print("Failed to update user in the local database.");
        }
      } on TimeoutException catch (_) {
        registerStatus = false;
        print("The update operation timed out.");
      } catch (e) {
        registerStatus = false;
        print("An error occurred: $e");
      }
    }
  }

  Future<void> _initializeGlobal() async {
    List<Map<String, dynamic>> fetchedAccountTypes =
        await networkHandler.fetchAccountTypesFromDatabase();

    setState(() {
      accountTypes =
          fetchedAccountTypes; // Update the state with the fetched account types
    });
  }

  // void _filterAccountTypes(String bankingType) {
  //   print("Filtering account types...");
  //   setState(() {
  //     // Parse initial deposit
  //     double initialDeposit =
  //         double.tryParse(initialDepositController.text) ?? 0;

  //     filteredAccountTypes = accountTypes.where((accountType) {
  //       // Check banking type
  //       if (accountType['bankingType'] != bankingType) {
  //         print(
  //             "BankingType mismatch: ${accountType['bankingType']} != $bankingType");
  //         return false;
  //       }

  //       if (accountType['sex'] == 'FEMALE') {
  //         print("Account type has 'female' gender, excluded.");
  //         return false;
  //       }
  //       // Exclude account types with minAge == 0
  //       int minAge = int.tryParse(accountType['minAge']?.trim() ?? '0') ?? 0;
  //       if (minAge < 18) {
  //         print("Account type has minAge == 0, excluded.");
  //         return false;
  //       }

  //       // Validate minimum amount
  //       double minAmount =
  //           double.tryParse(accountType['minAmount']?.toString() ?? '0') ?? 0;
  //       if (initialDeposit < minAmount) {
  //         print(
  //             "Initial deposit $initialDeposit less than required $minAmount");
  //         return false;
  //       }

  //       print("Account type matches!");
  //       return true;
  //     }).toList();

  //     // Show feedback if no account types match
  //     if (filteredAccountTypes.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             'No account types available for your deposit ($initialDeposit).',
  //             style: const TextStyle(color: Colors.white),
  //           ),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   });
  // }

  void _filterAccountTypes(String bankingType) {
    print("Filtering account types...");
    setState(() {
      // Parse initial deposit safely from text
      double initialDeposit =
          double.tryParse(initialDepositController.text.trim()) ?? 0;

      filteredAccountTypes = accountTypes.where((accountType) {
        // Check banking type (normalize both sides to uppercase)
        String accountBankingType =
            (accountType['bankingType'] ?? '').toString().toUpperCase();
        if (accountBankingType != bankingType.toUpperCase()) {
          print(
              "BankingType mismatch: ${accountType['bankingType']} != $bankingType");
          return false;
        }

        // Exclude account types with 'FEMALE' sex
        String accountTypeSex =
            (accountType['sex'] ?? '').toString().toUpperCase();
        if (accountTypeSex == 'FEMALE') {
          print("Account type has 'female' gender, excluded.");
          return false;
        }

        // Exclude account types with minAge less than 18
        int minAge =
            int.tryParse(accountType['minAge']?.toString()?.trim() ?? '0') ?? 0;
        if (minAge < 18) {
          print("Account type has minAge < 18, excluded.");
          return false;
        }

        // Validate minimum amount
        double minAmount = double.tryParse(
                accountType['minAmount']?.toString()?.trim() ?? '0') ??
            0;
        if (initialDeposit < minAmount) {
          print(
              "Initial deposit $initialDeposit less than required $minAmount");
          return false;
        }

        print("Account type matches!");
        return true;
      }).toList();

      // Show feedback if no account types match
      if (filteredAccountTypes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No account types available for your deposit ($initialDeposit).',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  String escapeSpecialChars(String input) {
    return input.replaceAll("'", "\\'");
  }

  Map<String, dynamic>? getAccountTypeDetails(String selectedAccountType) {
    if (selectedAccountType != null && filteredAccountTypes.isNotEmpty) {
      try {
        var selectedAccountTypeDetails = filteredAccountTypes.firstWhere(
          (accountType) => accountType['name'] == selectedAccountType,
        );

        return {
          "id": selectedAccountTypeDetails['id'],
          "name": selectedAccountTypeDetails['name'],
          "type": selectedAccountTypeDetails['type'],
          "minAge": selectedAccountTypeDetails["minAge"] ?? "",
          "maxAge": selectedAccountTypeDetails["maxAge"] ?? "",
          "minAmount": selectedAccountTypeDetails["minAmount"] ?? "",
          "sex": selectedAccountTypeDetails["sex"] ?? "",
          "bankingType": selectedAccountTypeDetails["bankingType"]
        };
      } catch (e) {
        print('Error finding account type: $e');
        return null; // Return null if an error occurs or no match is found
      }
    }
    return null; // Return null if the account type list is empty or the selected account is null
  }

  Future<void> _pickSignatureImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _signatureImages!.add(pickedFile);
      });
    }
  }

  void _saveCombinedSignature(int i) async {
    final Uint8List? combinedImage = await _combineSignatures();

    // Check if all signature pads are signed
    if (!areAllSignaturesCompleted()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please complete all signature pads before saving."),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop execution if not all pads are signed
    }
    if (combinedImage != null) {
      setState(() {
        combinedSignatures[i] = combinedImage;
      });
      // Example: Save to a file
      final file = File('${Directory.systemTemp.path}/combined_signature.png');
      await file.writeAsBytes(combinedImage);
      print("Saved combined image at: ${file.path}");
    } else {
      print("Failed to generate combined signature image.");
    }
  }

  bool areAllSignaturesCompleted() {
    return _signatureController1.isNotEmpty &&
        _signatureController2.isNotEmpty &&
        _signatureController3.isNotEmpty;
  }

  Widget _buildExpandableSection(
    String title,
    bool isExpanded,
    VoidCallback onTap,
    List<Widget> children,
  ) {
    return Card(
      color: Colors.grey[50],
      // color: Colors.blue,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              // color: const Color.fromARGB(255, 61, 68, 72),
              color: Colors.grey.shade200, // Different title background color
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: ListTile(
              title: Text(
                title,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              trailing: Icon(
                isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: isExpanded ? Colors.blue : Colors.black,
                size: 35,
              ),
              onTap: onTap,
            ),
          ),
          Visibility(
            visible: true,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: isExpanded ? null : 0,
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandablePersonalInformationSection(
    String title,
    bool isExpanded,
    VoidCallback onTap,
    List<Widget> children,
  ) {
    return Card(
      color: Colors.white,
      shadowColor: Colors.red,
      surfaceTintColor: Colors.grey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade100, // Change title background color
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: ListTile(
              title: Text(
                title,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              trailing: Icon(
                isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: isExpanded ? Colors.blue : Colors.black,
                size: 35,
              ),
              onTap: onTap,
            ),
          ),
          Visibility(
            visible: true, // ✅ Always keep in tree, just control visibility
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: isExpanded ? null : 0, // Collapses smoothly
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        insetPadding: EdgeInsets.zero, // Fullscreen effect
        child: Stack(
          children: [
            Center(
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  registerAllUsers() async {
    List<Map<String, dynamic>> customers = [];

    for (int i = 0; i < int.parse(NumberOfMembers!); i++) {
      Uint8List? residentBytes;
      Uint8List? residentCardBackBytes;
      Uint8List? personalPhotoBytes;

      // Check and handle image paths (make sure they're not null)
      if (residentPaths[i].isNotEmpty) {
        residentBytes = await _getImageBytes(residentPaths[i]);
      }
      if (residentCardBackPaths[i].isNotEmpty) {
        residentCardBackBytes = await _getImageBytes(residentCardBackPaths[i]);
      }
      if (profilePaths[i].isNotEmpty) {
        personalPhotoBytes = await _getImageBytes(profilePaths[i]);
      }

      // Create the customer object with null handling
      Map<String, dynamic> customer = {
        "fullName": fullNameControllers[i].text.isNotEmpty
            ? fullNameControllers[i].text
            : "", // Default value for empty fields
        "surname": "", // Add surname if available
        "motherName": motherNameControllers[i].text.isNotEmpty
            ? motherNameControllers[i].text
            : "", // Default value for empty fields
        "emailVerified": true,
        "phone":
            phoneControllers[i].text.isNotEmpty ? phoneControllers[i].text : "",
        "percentageCompleted": 0
      };

      customers.add(customer);
    }

    // Construct the final payload
    Map<String, dynamic> requestData = {
      "customers": customers,
      "primaryPhone": phoneControllers[0].text.isNotEmpty
          ? phoneControllers[0].text
          : "Unknown", // Default value for primary phone
      "branch": selectedBranch ?? "Unknown", // Default branch if null
      "currency": accountCurrencyController.text.isNotEmpty
          ? accountCurrencyController.text
          : "Unknown", // Default value for empty fields
      "accountType": "1",
      "initialDeposit": initialDepositController.text.toString(),
      "percentageCompleted": 0,
    };

    print("Final JSON payload:");
    print(requestData);

    // Send request
    RegistrationService registrationService = RegistrationService();
    var response = await registrationService.registerCustomers(requestData);

    if (response["statusCode"] == 200) {
      print("✅ Success: ${response["message"]}");
      DialogHelper.showSuccessDialog(context, response["message"]);
    } else {
      DialogHelper.showErrorDialog(context, response["message"]);

      print("❌ Error1 (${response["statusCode"]}): ${response["message"]}");
      print("Error Details: ${response["error"]}");
    }
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Rounded corners
          ),
          backgroundColor: Colors.red[50], // Light red background
          title: Text(
            "Error",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.red[800], // Darker red for title
            ),
          ),
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[800], // Error icon color
                size: 32.0,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.red[800], // Button background color
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
