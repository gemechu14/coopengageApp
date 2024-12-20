// ignore_for_file: unused_local_variable, constant_identifier_names, unused_element, avoid_print, unused_import, unnecessary_import, prefer_typing_uninitialized_variables, file_names, non_constant_identifier_names, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
// import 'package:csc_picker/csc_picker.dart';
import 'package:coopengageplus/features/onboarding/pages/ConfirmationPage.dart';
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

///////////////////////////////////////////

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
// import 'package:csc_picker/csc_picker.dart';
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
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

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

import '../pages/old/HomePage.dart';

bool isConventionalSelected = true;

List<Map<String, dynamic>> allBranches = [];
String? selectedBranch;

String? selectedAccountTypeId;

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _Registration();
}

class _Registration extends State<RegistrationScreen> {
  // final storage = FlutterSecureStorage();
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
  bool _isSigning = false; // To toggle between sign and upload
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
    _initializeGlobalData();
    _initializeGlobal();
    initializeBranches();

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
    selectedState = ListContants.ethiopianStates.first;
    selectedMaritalStatus = ListContants.maritalStatuses.first;
    selectedCustomerType = ListContants.customerType.first;
    selectedDocumentType = ListContants.documentName.first;
    selectedTitle = ListContants.title.first;
    selectedSector = ListContants.sectors.first;
    issueAuthorityController.text = 'ET';
  }

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
  );
  bool isApiCallProcess = false;
  bool validate = false;
  bool circular = false;
  bool isValid = true;
  String? selectedTitle;
  String selectedGender = 'FEMALE';
  String selectedIdType = 'KEBELE_ID';
  String? selectedMaritalStatus;
  String? selectedCustomerType;
  String? selectedDocumentType;
  String? selectedSector;
  String imagePath = "";
  String passportPath = "";
  String formPath = "";
  String residentPath = "";
  String residentCardBackPath = "";
  String profilePath = "";
  String selectedCountry = 'Ethiopia';
  String? selectedState;
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
            TextLabel("Customer Type"),
            ReusableDropdown(
              selectedValue: selectedCustomerType,

              items: ListContants.customerType,
              hintText: 'Select Customer Type',
              onChanged: (newStatus) {
                setState(() {
                  selectedCustomerType = newStatus!;
                });
              },
              prefixIcon: selectedCustomerType == 'INDIVIDUAL' ||
                      selectedCustomerType == 'DIASPORA'
                  ? Icons.person
                  : Icons.business,
              errorMessage:
                  'Please select a marital status', // Pass the custom error message
              isRequired: false, // Make the field required
            ),
            TextLabel("PhoneNumber"),
            PhoneNumberWidget(phoneNumberController: phoneNumberController),
            TextLabel("Email"),
            EmailWidget(emailController: emailController),
            // emailWidget(),
          ],
        ),
      ),
      Step(
        title: Text(
          isSmallScreen ? "" : "ID TYPE",
        ),
        isActive: _activeStepIndex >= 1,
        state: _activeStepIndex > 1 ? StepState.complete : StepState.indexed,
        content: Form(
          key: globalFormKey1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextLabel("Branch"),
              // branchSelectorWidget(),
              branchSelectorWidget1(),
              TextLabel("Document Type"),
              ReusableDropdown(
                selectedValue: selectedDocumentType,

                items: ListContants.documentName,
                hintText: 'Select Customer Type',
                onChanged: (newStatus) {
                  setState(() {
                    selectedDocumentType = newStatus!;
                  });
                },
                prefixIcon: Icons.document_scanner,
                errorMessage:
                    'Please select a Document  type', // Pass the custom error message
                isRequired: false, // Make the field required
              ),
              const SizedBox(
                height: 5,
              ),
              idCardPhoto(),
            ],
          ),
        ),
      ),
      Step(
        title: Text(isSmallScreen ? "" : "Signature"),
        isActive: _activeStepIndex >= 2,
        state: _activeStepIndex > 2 ? StepState.complete : StepState.indexed,
        content: Form(
          key: globalFormKey2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextLabel("Mother Name"),
              ReusableTextFormField(
                hintText: "Mother Name",
                controller: motherNameController,
                keyboardType: TextInputType.text,
                errorMessage: "Mother Name cannot be empty",
                leadingIcon: Icons.person,
                isRequired: false,
              ),
              TextLabel("Signature"),
              // signatureWidget1(context),
              signatureCard(),
              signaturePadSelection(),
            ],
          ),
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
              TextLabel("Personal Photo"),
              personalPhoto(),
            ],
          ),
        ),
      ),
      Step(
        title: Text(isSmallScreen ? "" : "Personal photo"),
        isActive: _activeStepIndex >= 4,
        state: _activeStepIndex > 4 ? StepState.complete : StepState.indexed,
        content: Form(
          key: globalFormKey4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextLabel("Sector"),
              ReusableDropdown(
                selectedValue: selectedSector,
                items: ListContants.sectors,
                hintText: 'Select Sector',
                onChanged: (newStatus) {
                  setState(() {
                    selectedSector = newStatus!;
                  });
                },
                prefixIcon: Icons.category,
                errorMessage:
                    'Please select a Sector status', // Pass the custom error message
                isRequired: true, // Make the field required
              ),
              TextLabel("Occupation "),
              ReusableTextFormField(
                hintText: "Enter Occupation",
                controller: occupationController,
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
                controller: monthlyIncomeController,
                keyboardType: TextInputType.number,
                errorMessage: "monthlyIncome cannot be empty",
                leadingIcon: Icons.trending_up,
                // return '';
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Only allow numbers
                ],
                isRequired: true,
              ),
              // TextLabel("Banking Type"),
              // ReusableDropdown(
              //   selectedValue: selectedBankingType,
              //   items: ['Conventional', 'Alhuda'],
              //   hintText: 'Select Banking Type',
              //   onChanged: (String? newValue) {
              //     setState(() {
              //       selectedBankingType = newValue!;

              //       _filterAccountTypes(
              //           newValue); // Filter the account types based on the selected bankingType
              //       selectedAccountTypeId = null;
              //     });
              //   },
              //   prefixIcon: Icons.account_balance,
              //   errorMessage: 'Please select a banking type',
              //   isRequired: true, // Required field
              // ),
              // TextLabel(" Account Type"),
              // DropdownButtonFormField<String>(
              //   // value: selectedAccountTypeId != null
              //   //     ? filteredAccountTypes[0]['name']!
              //   //     : null,

              //   value: (filteredAccountTypes.isNotEmpty &&
              //           selectedAccountTypeId != null)
              //       ? filteredAccountTypes[0]['name']
              //       : null,

              //   items: filteredAccountTypes
              //       .map<DropdownMenuItem<String>>(
              //         (accountType) => DropdownMenuItem<String>(
              //           value: accountType['name'] as String,
              //           child: Text(
              //             accountType['name'] as String,
              //             overflow: TextOverflow
              //                 .visible, // Show full text in the dropdown
              //           ),
              //         ),
              //       )
              //       .toList(),
              //   hint: const Text('Select Account Type'),
              //   onChanged: (String? selectedAccountType) {
              //     if (selectedAccountType != null) {
              //       // Find the accountType object that matches the selected name
              //       var selectedAccountTypeDetails =
              //           filteredAccountTypes.firstWhere(
              //         (accountType) =>
              //             accountType['name'] == selectedAccountType,
              //       );
              //       selectedAccountTypeId = selectedAccountType;
              //       // Save the selected account type ID
              //       selectedAccountId = selectedAccountTypeDetails['id'];

              //       // Print the selected account type ID (for debugging purposes)
              //       print('Selected Account Type ID: $selectedAccountId');
              //     }
              //   },
              //   decoration: const InputDecoration(
              //     isDense: true,
              //     enabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.all(Radius.circular(10)),
              //       borderSide: BorderSide(
              //         color: Colors.black,
              //       ),
              //     ),
              //     focusedBorder: const OutlineInputBorder(
              //       borderRadius: BorderRadius.all(Radius.circular(10)),
              //       borderSide: BorderSide(color: Colors.blue),
              //     ),
              //     errorBorder: const OutlineInputBorder(
              //       borderRadius: BorderRadius.all(Radius.circular(10)),
              //       borderSide: BorderSide(color: Colors.red),
              //     ),
              //     focusedErrorBorder: const OutlineInputBorder(
              //       borderRadius: BorderRadius.all(Radius.circular(10)),
              //       borderSide: BorderSide(color: Colors.red),
              //     ),
              //   ),
              //   selectedItemBuilder: (BuildContext context) {
              //     return filteredAccountTypes.map<Widget>((accountType) {
              //       String accountName = accountType['name'] as String;
              //       return Text(
              //         accountName.length > 25
              //             ? accountName.substring(0, 25) +
              //                 '...' // Truncate to 20 chars
              //             : accountName,
              //         overflow: TextOverflow
              //             .ellipsis, // Truncate with ellipsis in the selected value field
              //       );
              //     }).toList();
              //   },
              // ),
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
              TextLabel("Payment Method"),
              PaymentMethodWidget(
                initialDepositController: initialDepositController,
                phoneNumberController: phoneNumberController,
              ),
            ],
          ),
        ),
      ),
      Step(
        title: Text(isSmallScreen ? "" : "Payment"),
        isActive: _activeStepIndex >= 5,
        state: _activeStepIndex > 5 ? StepState.complete : StepState.indexed,
        content: Form(
          key: globalFormKey5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextLabel("Title"),
              ReusableDropdown(
                selectedValue: selectedTitle,

                items: ListContants.title,
                hintText: 'Select title',
                onChanged: (newStatus) {
                  setState(() {
                    selectedTitle = newStatus!;
                  });
                },
                prefixIcon: Icons.person_outline,
                errorMessage:
                    'Please select a title', // Pass the custom error message
                isRequired: false, // Make the field required
              ),
              TextLabel("Full Name"),
              ReusableTextFormField(
                hintText: "Full Name",
                controller: fullNameController,
                keyboardType: TextInputType.text,
                errorMessage: "Full Name cannot be empty",
                leadingIcon: Icons.person,
                isRequired: true,
              ),

              TextLabel("SurName"),
              ReusableTextFormField(
                hintText: "SurName",
                controller: surNameController,
                keyboardType: TextInputType.text,
                errorMessage: "SurName cannot be empty",
                leadingIcon: Icons.person,
                isRequired: false,
              ),

              if (selectedCustomerType == 'INDIVIDUAL')
                TextLabel("Date of Birth"),
              if (selectedCustomerType == 'ORGANIZATION')
                TextLabel("Date of Estabilishment"),

              DatePickerField(
                controller: dateOfBirthController,
                hintText: (selectedCustomerType == 'INDIVIDUAL')
                    ? 'Date of Birth'
                    : "Date of Establishment",
                prefixIcon: Icons.date_range,
                initialDate: DateTime.now().add(const Duration(days: -10000)),
                firstDate: DateTime(1940),
                lastDate: DateTime.now(),
                isRequired: true,
                errorMessage: 'Please select a date of birth',
              ),

              // dateOfBirthWidget(),
              if (selectedCustomerType == 'INDIVIDUAL')
                TextLabel("Marital Status"),
              if (selectedCustomerType == 'INDIVIDUAL')
                ReusableDropdown(
                  selectedValue: selectedMaritalStatus,
                  items: ListContants.maritalStatuses,
                  hintText: 'Select Marital Status',
                  onChanged: (newStatus) {
                    setState(() {
                      selectedMaritalStatus = newStatus!;
                    });
                  },
                  prefixIcon: Icons.family_restroom,
                  errorMessage:
                      'Please select a marital status', // Pass the custom error message
                  isRequired: false, // Make the field required
                ),
              if (selectedCustomerType == 'INDIVIDUAL') TextLabel("Gender"),
              //Gender
              if (selectedCustomerType == 'INDIVIDUAL') genderWidget1(),
            ],
          ),
        ),
      ),
      Step(
        title: Text(isSmallScreen ? "" : "Personal Information "),
        isActive: _activeStepIndex >= 6,
        state: _activeStepIndex > 6 ? StepState.complete : StepState.indexed,
        content: Form(
            key: globalFormKey6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TextLabel("Country"),
                // countryWidget(),
                TextLabel("State"),
                ReusableDropdown(
                  selectedValue: selectedState,
                  items: ListContants.ethiopianStates,
                  hintText: 'Select State',
                  onChanged: (newState) {
                    setState(() {
                      selectedState = newState;
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
                  controller: cityController,
                  // keyboardType: TextInputType.number,
                  errorMessage: "Zone Subcity cannot be empty",
                  leadingIcon: Icons.location_city,
                  isRequired: false,
                ),

                TextLabel("Woreda"),
                ReusableTextFormField(
                  hintText: "Woreda",
                  controller: woredaController,
                  // keyboardType: TextInputType.number,
                  errorMessage: "Woreda cannot be empty",
                  leadingIcon: Icons.location_city,
                  isRequired: false,
                ),

                TextLabel("Legal ID"),
                ReusableTextFormField(
                  hintText: "Legal ID",
                  controller: legalIDController,
                  // keyboardType: TextInputType.number,
                  errorMessage: "Legal ID cannot be empty",
                  leadingIcon: Icons.badge,
                  isRequired: true,
                ),
                TextLabel("ISSUE AUTHORITY"),

                ReusableTextFormField(
                  hintText: "ISSUE AUTHORITY",
                  controller: issueAuthorityController,
                  // keyboardType: TextInputType.number,
                  errorMessage: "ISSUE AUTHORITY cannot be empty",
                  leadingIcon: Icons.verified,
                  isRequired: false,
                ),

                TextLabel("ISSUE DATE"),
                DatePickerField(
                  controller: issueDateController,
                  hintText: 'Issue Date',
                  prefixIcon: Icons.calendar_today,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(
                      const Duration(days: 365 * 15)), // 15 years before today
                  lastDate: DateTime.now(),
                  isRequired: false,
                  errorMessage: 'Please select an issue date',
                ),

                TextLabel("EXPIRY DATE"),
                DatePickerField(
                  controller: expireDateController,
                  hintText: 'Expire Date',
                  prefixIcon: Icons.event_busy,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(), // First date is today
                  lastDate: DateTime.now().add(const Duration(days: 365 * 12)),
                  isRequired: false,
                  errorMessage: 'Please select an expire date',
                ),
              ],
            )),
      ),

      /// Account TYPE
      Step(
        title: Text(isSmallScreen ? "" : "Account Type "),
        isActive: _activeStepIndex >= 7,
        state: _activeStepIndex > 7 ? StepState.complete : StepState.indexed,
        content: Form(
            key: globalFormKey7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Type',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 21,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end,
                ),
                const SizedBox(
                  height: 20,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['Conventional', 'Alhuda'].map((bankingType) {
                    bool isSelected = selectedBankingType == bankingType;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedBankingType = bankingType;
                          _filterAccountTypes(
                              bankingType); // Filter account types based on selected banking type
                          // selectedAccountTypeId =
                          //     null; // Reset account type selection
                        });
                      },
                      child: Card(
                        color: isSelected ? Colors.blue : Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Text(
                            bankingType,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

// Account Type List with Cards
                // TextLabel("Account Type"),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: filteredAccountTypes.map<Widget>((accountType) {
                      bool isSelected =
                          selectedAccountTypeId == accountType['name'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedAccountTypeId = accountType['name'];
                            // selectedAccountId = accountType[
                            //     'id']; // Save the selected account ID
                            print(
                                'Selected Account Type ID: $selectedAccountTypeId');
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            margin: const EdgeInsets.all(10),
                            color: isSelected ? Colors.blue : Colors.white,
                            // elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 1, horizontal: 2),
                              child: ListTile(
                                title: Text(
                                  accountType['name'] as String,
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  (int.tryParse(accountType['maxAge']
                                                      ?.toString() ??
                                                  '') ??
                                              0) >
                                          100
                                      ? 'Minimum Age: ${int.tryParse(accountType['minAge']?.toString() ?? '') != null ? int.parse(accountType['minAge'].toString()) : '___'}\n'
                                          'Min Amount: ${accountType['minAmount']}'
                                      : 'Age Range: ${int.tryParse(accountType['minAge']?.toString() ?? '') != null ? int.parse(accountType['minAge'].toString()) : '___'} - ${int.tryParse(accountType['maxAge']?.toString() ?? '0') ?? 0}\n'
                                          'Min Amount: ${accountType['minAmount']}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            )),
      ),

      Step(
        title: Text(isSmallScreen ? "" : "Terms & Conditions"),
        isActive: _activeStepIndex >= 8,
        state: _activeStepIndex > 8 ? StepState.complete : StepState.indexed,
        content: Form(
          key: globalFormKey8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terms and Conditions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                height: 200,
                child: const SingleChildScrollView(
                  child: Text(
                    // Replace with your actual terms and conditions
                    '''
1. Account Usage
- This account is for personal/business use only
- You must maintain minimum balance requirements
- Regular account activity monitoring will be conducted

2. Privacy Policy
- Your personal information will be protected
- Data sharing will comply with banking regulations
- You will be notified of any policy changes

3. Fees and Charges
- Standard banking fees apply
- Transaction limits may be imposed
- Interest rates are subject to change

4. Account Holder Responsibilities
- Keep account information secure
- Report unauthorized transactions
- Update personal information as needed

By accepting these terms, you agree to comply with all banking regulations and policies.
                    ''',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: termsAccepted,
                    onChanged: (bool? value) {
                      setState(() {
                        termsAccepted = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'I have read and agree to the terms and conditions',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    ];
  }

  void _showSignaturePadDialog(BuildContext context) {
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
                            _saveCombinedSignature();
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

  Padding signaturePadSelection() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _showSignaturePadDialog(context),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
            ),
            child: const Text("      Sign     "),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              showImagePicker(context, "signature");
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

  Center signatureCard() {
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
            child: _combinedSignature != null
                ? Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.memory(
                        _combinedSignature!,
                        fit: BoxFit.cover,
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

  Column personalPhoto() {
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
                child: profilePath.isEmpty
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
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.file(
                          File(profilePath),
                          height: MediaQuery.of(context).size.height * 0.7,
                          width: MediaQuery.of(context).size.width * 0.7,
                          fit: BoxFit.fill,
                        ),
                      ),
              ),
              const SizedBox(height: 40.0),
              ButtonUploadTakePhoto(
                onUploadPressed: () => _imgFromGallery("profile"),
                onCapturePressed: () => _imgFromCamera("profile"),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        )
      ],
    );
  }

  Padding countryWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: DropdownButtonFormField<String>(
        value: selectedCountry,
        // hint: const Text('Country *'),
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
        ),
        items: ['Ethiopia'].map((String country) {
          return DropdownMenuItem<String>(
            value: country,
            child: Text(country),
          );
        }).toList(),
        onChanged: null,

        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black),
          ),
          prefixIcon: Icon(Icons.public),
        ),
      ),
    );
  }

  Column idCardPhoto() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7, left: 10, right: 3),
          child: Text(
            "Front Photo of  $selectedDocumentType",
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
                child: residentPath.isEmpty
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
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.file(
                          File(residentPath),
                          height: 180.0,
                          width: MediaQuery.of(context).size.width * 0.7,
                          fit: BoxFit.fill,
                        ),
                      ),
              ),
              const SizedBox(height: 20.0),
              ButtonUploadTakePhoto(
                onUploadPressed: () => _imgFromGallery("resident"),
                onCapturePressed: () => _imgFromCamera("resident"),
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
            "Back Photo of $selectedDocumentType",
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
                child: residentCardBackPath.isEmpty
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
                          File(residentCardBackPath),
                          height: 180.0,
                          width: MediaQuery.of(context).size.width * 0.7,
                          fit: BoxFit.fill,
                        ),
                      ),
              ),
              const SizedBox(height: 20.0),
              ButtonUploadTakePhoto(
                onUploadPressed: () => _imgFromGallery("residentCardBack"),
                onCapturePressed: () => _imgFromCamera("residentCardBack"),
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

  Future<void> callApiAndUpdateControllers(Uint8List residentBytes) async {
    try {
      // API endpoint
      final url = Uri.parse('http://10.11.227.165:5000/process_id');
      final request = http.MultipartRequest('POST', url);

      request.files.add(http.MultipartFile.fromBytes(
        'image', // Field name in the API
        residentBytes,
        filename: 'residence_card.png', // Optional: Provide a filename
        contentType: MediaType('image', 'png'), // Set the appropriate MIME type
      ));

      // Send the multipart request
      final response = await request.send();

      if (response.statusCode == 200) {
        // Parse the response JSON
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);

        // Update TextEditingControllers
        setState(() {
          fullNameController.text =
              '${data['first_name']} ${data['middle_name']}';
          surNameController.text = data['surname'];
          String formattedDate = "";
          if (data['date_of_birth'] != null) {
            DateTime parsedDate = DateTime.parse(data['date_of_birth']);
            formattedDate = DateFormat('yyyy-MM-dd')
                .format(parsedDate); // Change to '-' separator
          }
          selectedGender = data['gender'].toUpperCase();
          dateController.text = formattedDate;
        });

        print("Controllers updated successfully");
      } else {
        print("Failed to call API: ${response.statusCode}");
      }
    } catch (e) {
      print("Error calling API: $e");
    }
  }

  Padding genderWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        hint: const Text(
          'Gender',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black,
          ),
        ),
        items: genders.map((String gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(gender),
          );
        }).toList(),
        onChanged: (String? newGender) {
          setState(() {
            selectedGender = newGender!;
          });
        },
        validator: (String? value) {
          if (value == null) {
            return 'Gender *';
          }
          return null;
        },
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black),
          ),
          prefixIcon: Icon(Icons.person),
        ),
      ),
    );
  }

  Padding genderWidget1() {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Male'),
                  value: 'MALE', // Radio button value
                  groupValue: selectedGender, // Current selected gender
                  onChanged: (String? value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Female'),
                  value: 'FEMALE', // Radio button value
                  groupValue: selectedGender, // Current selected gender
                  onChanged: (String? value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          if (selectedGender == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Gender *',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  int _activeStepIndex = 0;

  @override
  Widget build(BuildContext context) {
    final SignatureController _signatureController = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.black,
    );
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          title: const Text(
            "Customer Registration",
            style: TextStyle(
                fontSize: 19, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.sync_outlined), onPressed: () {}),
          ],
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
              children: [
                const SizedBox(
                  height: 30,
                ),
                Expanded(
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
                        controlsBuilder:
                            (BuildContext context, ControlsDetails details) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 20, left: 20, right: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                if (_activeStepIndex > 0)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: onStepCancel,
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                      child: const Text(
                                        '     Back     ',
                                        style: TextStyle(color: Colors.white),
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
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            _activeStepIndex == 8
                                                ? 'Submit'
                                                : 'Continue',
                                            style: const TextStyle(
                                                color: Colors.white),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showImagePicker(BuildContext context, String imageTypes) {
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
                        _imgFromGallery(imageTypes);
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
                        _imgFromCamera(imageTypes);
                        Navigator.pop(context);
                      },
                    ))
                  ],
                )),
          );
        });
  }

  _imgFromGallery(String imageTypes) async {
    FocusScope.of(context).unfocus();
    await picker
        .pickImage(source: ImageSource.gallery, imageQuality: 50)
        .then((value) {
      if (value != null) {
        _cropImage(File(value.path), imageTypes);
      }
    });
  }

  _imgFromCamera(String imageTypes) async {
    // Unfocus any text fields or inputs
    FocusScope.of(context).unfocus();
    await picker
        .pickImage(source: ImageSource.camera, imageQuality: 50)
        .then((value) {
      if (value != null) {
        _cropImage(File(value.path), imageTypes);

        // _cropImage(File(value.path));
      }
    });
  }

  _cropImage(File imgFile, String imageTypes) async {
    FocusScope.of(context).unfocus();
    final croppedFile =
        await ImageCropper().cropImage(sourcePath: imgFile.path, uiSettings: [
      AndroidUiSettings(
          toolbarTitle: "Image Cropper",
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      IOSUiSettings(
        title: "Image Cropper",
      )
    ]);
    if (croppedFile != null) {
      // imageCache.clear();
      setState(() {
        // imageFile = File(croppedFile.path);

        if (imageTypes == 'passport') {
          passportPath = croppedFile.path;
        } else if (imageTypes == 'profile') {
          profilePath = croppedFile.path;
        } else if (imageTypes == 'resident') {
          residentPath = croppedFile.path;
        } else if (imageTypes == 'residentCardBack') {
          residentCardBackPath = croppedFile.path;
        } else if (imageTypes == 'signature') {
          // signatureImagePath = croppedFile.path;
          // savedSignature = null;
          // _signatureController.clear();

          // Clear drawn signature
          _signatureController1.clear();
          _signatureController2.clear();
          _signatureController3.clear();
          savedSignature = null;

          // Set the uploaded image as the combined signature
          signatureImagePath = croppedFile.path;
          _combinedSignature = File(croppedFile.path).readAsBytesSync();
        } else if (imageTypes == 'form') {
          formPath = croppedFile.path;
        }
      });
    }
  }

  Future<Uint8List> _getImageBytes(String path) async {
    final imageFile = File(path);
    print("hello there");

    print(imageFile);
    print(await imageFile.exists());

    if (await imageFile.exists()) {
      // throw Exception("File does not exist.");
      print("file not exist");
    }
    return await imageFile.readAsBytes();
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
        await handleFirstStep();
      } else if (_activeStepIndex == 1) {
        handleSecondStep();
      } else if (_activeStepIndex == 2) {
        await handleThirdStep();
      } else if (_activeStepIndex == 3) {
        await handleStepFour();
      } else if (_activeStepIndex == 4) {
        await handleStepFive();
      } else if (_activeStepIndex == 5) {
        await basicInformation();
      } else if (_activeStepIndex == 6) {
        await addressInfo();
      } else if (_activeStepIndex == 7) {
        await handleStepSeven();
      }

      if (isLastStep) {
        print("step 999");
        await submitFormData1();
        // await submitFormData();
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

  bool validateData() {
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
        return globalFormKey1.currentState?.validate() ?? false;
      case 2:
        return globalFormKey2.currentState?.validate() ?? false;
      case 3:
        return globalFormKey3.currentState?.validate() ?? false;
      case 4:
        return globalFormKey4.currentState?.validate() ?? false;
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
                    SignatureButtons(
                      onDrawSignature: () => _showDrawSignatureDialog(context),
                      onUploadOrTake: () =>
                          showImagePicker(context, "signature"),
                    ),
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
              .timeout(const Duration(seconds: 14));

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
            print("response.body");

            print("object");
            registerStatus = false;
            const SnackBar(
              content: Text('Error Occour while register please try'),
            );
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
        DatabaseHelper dbHelper = DatabaseHelper();
        await dbHelper.database; // Ensure the database is initialized
        print(UserID);
        // Insert customer data
        var data = await dbHelper.insertCustomer({
          'phone': registrationData['phone'],
          // 'customerType'
          'email': registrationData['email'],
          'customerType': registrationData['customerType'],
          'status': 'INITIAL',
          "userId": UserID
        });

        print("data");
        print(data);

        setState(() {
          validate = true;
          circular = false;
          userID = data;
        });
        print(data);
        print("Customer data inserted successfully.");
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
    registrationData["maritalStatus"] = selectedMaritalStatus;
    registrationData["percentageCompleted"] = 75;
    isOnline
        ? registrationData['formCompleted'] = "false"
        : registrationData['formCompleted'] = 0;
    print(registrationData);
    registerStatus = true;
    // await updateUser();
  }

  // Step 1:
  Future<void> handleFirstStep() async {
//     // Call the function to get the details
//     var accountTypeDetails = getAccountTypeDetails(selectedAccountTypeId!);

// // Check if accountTypeDetails is not null and then get the id
//     var id = accountTypeDetails != null ? accountTypeDetails['id'] : null;
    registrationData['customerType'] = selectedCustomerType;
    registrationData['phone'] = '+251${phoneNumberController.text}';
    registrationData['email'] = emailController.text;
    // registrationData['signature'] = _combinedSignature;
    // registrationData['accountType1'] = id;

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

    // await callApiAndUpdateControllers(residentBytes!);

    await updateUser();
  }

// STEP 3:
  Future<void> handleThirdStep() async {
    // Uint8List? signatureBytes;
    // if (signatureImagePath != null) {
    //   signatureBytes = await _getImageBytes(signatureImagePath!);
    // } else if (savedSignature != null) {
    //   signatureBytes = await _signatureController.toPngBytes();
    // }
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
  Future<void> handleStepFour() async {
    Uint8List? profileBytes;
    if (profilePath.isNotEmpty) {
      profileBytes = await _getImageBytes(profilePath);
    }

    registrationData['photo'] = profileBytes;
    registrationData["percentageCompleted"] = 50;
    isOnline
        ? registrationData['formCompleted'] = "false"
        : registrationData['formCompleted'] = 0;

    print(registrationData);
    await updateUser();
  }

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
    registerStatus = true;
    await updateUser();
  }

  Future<void> submitFormData1() async {
    //     // Call the function to get the details

//     print(selectedAccountId);
//     var accountTypeDetails = getAccountTypeDetails(selectedAccountTypeId!);
//     var id;
//     if (accountTypeDetails != null) {
// // // Check if accountTypeDetails is not null and then get the id
//       id = accountTypeDetails != null ? accountTypeDetails['id'] : null;
//     }

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
    registerStatus = true;
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
        registerStatus = true;
        // Handle other exceptions
        print("An error occurred: $e");
      }
    } else if (isOnline == false) {
      // final DatabaseHelper dbHelper = DatabaseHelper();
      // registrationData['id'] = userID;
      // print(registrationData);
      // int rowsAffected = await dbHelper
      //     .updateCustomer(userID!, registrationData)
      //     .timeout(const Duration(seconds: 5));

      // if (rowsAffected > 0) {
      //   print("User updated successfully in the local database.");
      // }
      // else {
      //   registerStatus = false;
      //   // isLoading = false;
      //   print("Failed to update user in the local database.");
      // }

      try {
        final DatabaseHelper dbHelper = DatabaseHelper();
        registrationData['id'] = userID;

        // Apply timeout to the updateCustomer call
        int rowsAffected = await dbHelper
            .updateCustomer(userID!, registrationData)
            .timeout(const Duration(seconds: 10));

        if (rowsAffected > 0) {
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
  //   setState(() {
  //     filteredAccountTypes = accountTypes.where((accountType) {
  //       String safeBankingType = escapeSpecialChars(bankingType);
  //       return accountType['bankingType'] == safeBankingType;
  //     }).toList();
  //   });
  // }

// void _filterAccountTypes(String bankingType) {
//   print("Filtering account types...");
//   setState(() {
//     // Step 1: Parse Date of Birth
//     DateTime? dateOfBirth;
//     try {
//       dateOfBirth = DateTime.parse(dateOfBirthController.text.trim());
//     } catch (e) {
//       print('Invalid date format: ${dateOfBirthController.text}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Invalid Date of Birth format. Use yyyy-MM-dd.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     // Step 2: Calculate Age
//     int age = DateTime.now().year - dateOfBirth.year;
//     if (DateTime.now().month < dateOfBirth.month ||
//         (DateTime.now().month == dateOfBirth.month &&
//             DateTime.now().day < dateOfBirth.day)) {
//       age--;
//     }

//     print('User Age: $age, Selected Gender: $selectedGender');

//     // Step 3: Filter Account Types
//     filteredAccountTypes = accountTypes.where((accountType) {
//       // Banking type check
//       if (accountType['bankingType'] != bankingType) {
//         return false;
//       }

//       // Age restrictions
//       if (accountType['minAge'] != null &&
//           accountType['minAge'].toString().isNotEmpty) {
//         int minAge = int.tryParse(accountType['minAge'].toString()) ?? 0;
//         if (age < minAge) {
//           print('Excluded: Age is below minAge ${accountType['minAge']}');
//           return false;
//         }
//       }

//       if (accountType['maxAge'] != null &&
//           accountType['maxAge'].toString().isNotEmpty) {
//         int maxAge = int.tryParse(accountType['maxAge'].toString()) ?? 999;
//         if (age > maxAge) {
//           print('Excluded: Age is above maxAge ${accountType['maxAge']}');
//           return false;
//         }
//       }

//       // Gender check
//       if (accountType['sex'] != null &&
//           accountType['sex'].toString().isNotEmpty) {
//         if (accountType['sex'].toString() != selectedGender) {
//           print('Excluded: Gender does not match');
//           return false;
//         }
//       }

//       return true;
//     }).toList();

//     // Step 4: Clear selected account type if it's no longer valid
//     if (!filteredAccountTypes
//         .any((type) => type['name'] == selectedAccountTypeId)) {
//       selectedAccountTypeId = null;
//     }

//     // Step 5: Show feedback if no accounts are found
//     if (filteredAccountTypes.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'No account types available for your age ($age) and gender ($selectedGender).',
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }

//     print('Filtered Account Types: $filteredAccountTypes');
//   });
// }

  // void _filterAccountTypes(String bankingType) {
  //   print("Filtering account types...");
  //   setState(() {
  //     // Get user's age from date of birth
  //     DateTime? dateOfBirth;
  //     try {
  //       dateOfBirth = DateTime.parse(dateOfBirthController.text);
  //     } catch (e) {
  //       print('Invalid date format: ${dateOfBirthController.text}');
  //       return;
  //     }

  //     int age = DateTime.now().year - dateOfBirth.year;
  //     // Adjust age if birthday hasn't occurred this year
  //     if (DateTime.now().month < dateOfBirth.month ||
  //         (DateTime.now().month == dateOfBirth.month &&
  //             DateTime.now().day < dateOfBirth.day)) {
  //       age--;
  //     }

  //     // Filter account types based on banking type, age, and gender
  //     filteredAccountTypes = accountTypes.where((accountType) {
  //       print("gammee12");
  //       print(accountType);

  //       print(selectedGender);
  //       // Filter by banking type
  //       if (accountType['bankingType'] != bankingType) return false;

  //       // Validate age rang e
  //       int minAge = int.tryParse(accountType['minAge'] ?? '0') ?? 0;
  //       int maxAge = int.tryParse(accountType['maxAge'] ?? '999') ?? 999;

  //       if (age < minAge || age > maxAge) {
  //         return false; // Age out of range
  //       }

  //       // Validate sex: 'BOTH' applies to all genders
  //       if (accountType['sex'] != null &&
  //           accountType['sex'].isNotEmpty &&
  //           accountType['sex'] != 'BOTH') {
  //         if (accountType['sex'] != selectedGender.toUpperCase()) return false;
  //       }

  //       return true; // Passes all filters
  //     }).toList();

  //     // Clear selected account type if it's no longer in filtered list
  //     // if (!filteredAccountTypes
  //     //     .any((type) => type['name'] == selectedAccountTypeId)) {
  //     //   selectedAccountTypeId = null;
  //     // }

  //     // Show feedback if no accounts are available
  //     if (filteredAccountTypes.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             'No account types available for your age ($age) and gender ($selectedGender)',
  //             style: const TextStyle(color: Colors.white),
  //           ),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   });
  // }

  // void _filterAccountTypes(String bankingType) {
  //   print("Filtering account types...");
  //   setState(() {
  //     // Get user's age from date of birth
  //     DateTime? dateOfBirth;
  //     try {
  //       dateOfBirth = DateTime.parse(dateOfBirthController.text);
  //     } catch (e) {
  //       print('Invalid date format: ${dateOfBirthController.text}');
  //       return;
  //     }

  //     int age = DateTime.now().year - dateOfBirth.year;
  //     if (DateTime.now().month < dateOfBirth.month ||
  //         (DateTime.now().month == dateOfBirth.month &&
  //             DateTime.now().day < dateOfBirth.day)) {
  //       age--;
  //     }

  //     // Normalize gender
  //     String normalizedGender = selectedGender.trim().toUpperCase();

  //     filteredAccountTypes = accountTypes.where((accountType) {
  //       print("AccountType: ${accountType}");
  //       print("Selected Gender: $normalizedGender");

  //       // Check banking type
  //       if (accountType['bankingType'] != bankingType) {
  //         print(
  //             "BankingType mismatch: ${accountType['bankingType']} != $bankingType");
  //         return false;
  //       }

  //       // Validate age range
  //       int minAge = int.tryParse(accountType['minAge']?.trim() ?? '0') ?? 0;
  //       int maxAge =
  //           int.tryParse(accountType['maxAge']?.trim() ?? '999') ?? 999;
  //       if (age < minAge || age > maxAge) {
  //         print("Age out of range: $age not in [$minAge, $maxAge]");
  //         return false;
  //       }

  //       // Validate sex with 'BOTH' inclusion
  //       String accountTypeSex =
  //           accountType['sex']?.trim().toUpperCase() ?? 'BOTH';
  //       if (accountTypeSex != 'BOTH' && accountTypeSex != normalizedGender) {
  //         print("Gender mismatch: $normalizedGender != $accountTypeSex");
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
  //             'No account types available for your age ($age) and gender ($selectedGender)',
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
      // Get user's age from date of birth
      DateTime? dateOfBirth;
      try {
        dateOfBirth = DateTime.parse(dateOfBirthController.text);
      } catch (e) {
        print('Invalid date format: ${dateOfBirthController.text}');
        return;
      }

      int age = DateTime.now().year - dateOfBirth.year;
      if (DateTime.now().month < dateOfBirth.month ||
          (DateTime.now().month == dateOfBirth.month &&
              DateTime.now().day < dateOfBirth.day)) {
        age--;
      }

      // Normalize gender
      String normalizedGender = selectedGender.trim().toUpperCase();

      // Parse initial deposit
      double initialDeposit =
          double.tryParse(initialDepositController.text) ?? 0;

      filteredAccountTypes = accountTypes.where((accountType) {
        print("AccountType: ${accountType}");
        print("Selected Gender: $normalizedGender");

        // Check banking type
        if (accountType['bankingType'] != bankingType) {
          print(
              "BankingType mismatch: ${accountType['bankingType']} != $bankingType");
          return false;
        }

        // Validate age range
        int minAge = int.tryParse(accountType['minAge']?.trim() ?? '0') ?? 0;
        int maxAge =
            int.tryParse(accountType['maxAge']?.trim() ?? '999') ?? 999;
        if (age < minAge || age > maxAge) {
          print("Age out of range: $age not in [$minAge, $maxAge]");
          return false;
        }

        // Validate minimum amount
        double minAmount =
            double.tryParse(accountType['minAmount']?.toString() ?? '0') ?? 0;
        if (initialDeposit < minAmount) {
          print(
              "Initial deposit $initialDeposit less than required $minAmount");
          return false;
        }

        // Validate sex with 'BOTH' inclusion
        String accountTypeSex =
            accountType['sex']?.trim().toUpperCase() ?? 'BOTH';
        if (accountTypeSex != 'BOTH' && accountTypeSex != normalizedGender) {
          print("Gender mismatch: $normalizedGender != $accountTypeSex");
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
              'No account types available for your age ($age), gender ($selectedGender), and deposit ($initialDeposit)',
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

  void _saveCombinedSignature() async {
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
        _combinedSignature = combinedImage; // Store the combined signature
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
}
