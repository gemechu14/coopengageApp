// ignore_for_file: unused_local_variable, constant_identifier_names, unused_element, avoid_print, unused_import, unnecessary_import, prefer_typing_uninitialized_variables, file_names, non_constant_identifier_names, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/common_widgets/textField/CustomTextFormField.dart';
import 'package:coopengageplus/common_widgets/textField/PhoneNumberWidget.dart';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import 'package:coopengageplus/features/onboarding/pages/old/HomePage.dart';
import 'package:coopengageplus/pages/MainPage.dart';
import 'package:coopengageplus/service/GlobalData.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:phonenumbers/phonenumbers.dart';
import 'package:pinput/pinput.dart';
import 'package:printing/printing.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';
// import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image/image.dart' as img;

class Marchentregistration extends StatefulWidget {
  const Marchentregistration({super.key});
  @override
  State<Marchentregistration> createState() => _Registration();
}

class _Registration extends State<Marchentregistration> {
  String? userId;
  int? userID;
  int? selectedDocument;
  List<String> branches = [];
  bool deliverDocument1 = false;
  bool deliverDocument2 = false;
  bool deliverDocument3 = false;
  List<String> filteredBranches = [];
  String? selectedBranch;
  List<Map<String, dynamic>> branch = [];
  List<Map<String, dynamic>> mainBranches = [];
  int? idOne;
  final Map<String, dynamic> registrationData = {};
  final Map<String, dynamic> otpRegistrationData = {};
  final Map<String, dynamic> phoneNUmber = {};
  final Map<String, dynamic> kycRegistrationData = {};
  final Map<String, dynamic> orderDeliveryData = {};

  Uint8List? englishQR;
  Uint8List? amharicQRCODE;
  Uint8List? afaanOromoQR;

  Map<String, dynamic> finalQRCODE = {};
  String? selectedAccountNumber;
  List<String> accountNumbers = [];
  String token = '';
  bool registerStatus = true;
  bool isAccountFetched = false;
  bool deliveryOptionChecked = false;
  var phoneNumber;
  bool isConventionalSelected = true;
  String? signatureImagePath;
  Uint8List? savedSignature;
  bool isDrawingSelected = false;
  String? selectedBranch1;
  List<Map<String, dynamic>> mergedBranches = [];
  bool isAccountTypeSelected = false;
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  bool isPinComplete() {
    return _pinController.text.length == 6;
  }

  String? errorMessage;
  Future<void> _initializeGlobalData() async {
    await GlobalData().fetchToken();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initializeGlobalData();
    globalData;
    GlobalData().fetchToken();
    paymentReasonController.text = 'MP2M';
    selectedState = ListContants.ethiopianStates.first;
    selectedCustomerType = ListContants.customerType.first;
    selectedSector = ListContants.sectors.first;
    selectedBusinessType = ListContants.businessTypes.first;
    issueAuthorityController.text = 'ET';
    // numberOfPring.text = "1";
  }

  bool isApiCallProcess = false;
  bool validate = false;
  bool circular = false;
  bool isValid = true;
  String? selectedTitle;
  String selectedGender = 'FEMALE';
  String? selectedBusinessType;
  String? selectedLanguagePreference;
  Image? _image;
  String? selectedAdditionalCustomer;
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
  int selectedAccountTypeValue = 1;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
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
  TextEditingController photoController = TextEditingController();
  TextEditingController signatureController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  final TextEditingController controller = TextEditingController();
  TextEditingController legalIDController = TextEditingController();
  TextEditingController issueDateController = TextEditingController();
  TextEditingController expireDateController = TextEditingController();
  TextEditingController issueAuthorityController = TextEditingController();
  TextEditingController specificAddressController = TextEditingController();
  FocusNode focusNode = FocusNode();
  NetworkHandler networkHandler = NetworkHandler();
  TextEditingController numberOfPring = TextEditingController();
  String initialCountry = 'ET';
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey1 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey2 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey3 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey4 = GlobalKey<FormState>();

  TextEditingController marchentNameController = TextEditingController();
  TextEditingController businessNameController = TextEditingController();
  TextEditingController businessTypeController = TextEditingController();
  TextEditingController businessAddressController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController tinController = TextEditingController();
  TextEditingController dateOfEstablishmentController = TextEditingController();
  TextEditingController websiteUrlController = TextEditingController();
  TextEditingController transactionAmountController = TextEditingController();
  TextEditingController storeLabelController = TextEditingController();
  TextEditingController terminalLabelController = TextEditingController();
  TextEditingController paymentReasonController = TextEditingController();
  TextEditingController merchantCityController = TextEditingController();
  TextEditingController localizedMerchantNameController =
      TextEditingController();
  TextEditingController localizedMerchantCityController =
      TextEditingController();

  Uint8List? qrcodeImage;
  String? accountNumber;
  int numberOfFields = 5;

  String? amount;
  String? description;

  List<Map<String, dynamic>>? branches1 = GlobalData()?.branches;
  int? UserID = GlobalData()?.userId;
  final globalData = GlobalData();

  List<Step> stepList() {
    bool isSmallScreen = MediaQuery.of(context).size.width < 1400;
    return [
      Step(
        title: Text(isSmallScreen ? "" : "PhoneNumber"),
        isActive: _activeStepIndex >= 0,
        // state: _activeStepIndex > 0 ? StepState.complete : StepState.indexed,
        state: isStepComplete(0) ? StepState.complete : StepState.indexed,
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextLabel("Phone Number"),
            IntlPhoneField(
              focusNode: focusNode,
              controller: phoneNumberController,
              decoration: const InputDecoration(
                // labelText: 'Phone Number',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.grey),
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
              ),
              validator: (phoneNumber) {
                if (phoneNumber == null || phoneNumber.number.isEmpty) {
                  return 'PhoneNumber cannot be empty'; // Set the error message
                }
              },
              // disableLengthCheck: true,
              initialCountryCode: 'ET',
              showDropdownIcon: false,
              onChanged: (phone) {
                print(phone.completeNumber);
              },
              onCountryChanged: (country) {
                print('Country changed to: ' + country.name);
                // Optional: Prevent any action if the user somehow changes the country
                if (country.code != 'ET') {
                  //  country.code ='ET'
                }
              },
            ),
          ],
        ),
      ),
      Step(
        title: Text(isSmallScreen ? "" : "OTP "),
        isActive: _activeStepIndex >= 1,
        state: _activeStepIndex > 1 ? StepState.complete : StepState.indexed,
        content: Form(
            key: globalFormKey1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextLabel("First Name"),
                CustomTextFormField(
                  hintText: "Enter First Name",
                  controller: firstNameController,
                  errorMessage: "First Name cannot be empty",
                ),
                TextLabel("Last Name"),
                CustomTextFormField(
                  hintText: "Enter Last Name",
                  controller: lastNameController,
                  errorMessage: "Last Name cannot be empty",
                ),
                TextLabel("Merchant Address *"),
                CustomTextFormField(
                  hintText: "Enter Merchant Address",
                  controller: merchantCityController,
                  errorMessage: "Merchant Address  cannot be empty",
                  isRequired: true,
                ),
                TextLabel("Business Type"),
                ReusableDropdown(
                  selectedValue: selectedBusinessType,
                  items: ListContants.businessTypes,
                  hintText: 'Select Business Type',
                  onChanged: (newStatus) {
                    setState(() {
                      selectedBusinessType = newStatus!;
                    });
                  },
                  isGreyBorder: true,
                  // prefixIcon: Icons.family_restroom,
                  errorMessage:
                      'Please select a Business Type', // Pass the custom error message
                  isRequired: false, // Make the field required
                ),
                TextLabel("Business Name"),
                CustomTextFormField(
                  hintText: "Enter Business Name",
                  controller: businessNameController,
                  errorMessage: "Business Type  cannot be empty",
                  isRequired: true,
                ),
                TextLabel("Business Address *"),
                CustomTextFormField(
                  hintText: "Enter business Address",
                  controller: businessAddressController,
                  errorMessage: "business Address  cannot be empty",
                  isRequired: true,
                ),
              ],
            )),
      ),
      Step(
        title: Text(isSmallScreen ? "" : "OTP "),
        isActive: _activeStepIndex >= 2,
        state: _activeStepIndex > 2 ? StepState.complete : StepState.indexed,
        content: Form(
            key: globalFormKey2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextLabel("Phone Number"),
                PhoneNumberWidget(
                  phoneNumberController: phoneNumberController,
                  greyBorder: true,
                ),
                const SizedBox(height: 16),
                // if (!isAccountFetched)
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      setState(() {
                        circular = true;
                      });
                      phoneNUmber['phoneNumber'] = phoneNumberController.text;
                      selectedAccountNumber = null;
                      isAccountFetched = false;
                      accountNumbers = [];
                      await fetchAccountNumer();

                      setState(() {
                        circular = false;
                      });
                    },
                    child: SizedBox(
                      width: 190,
                      height: 20,
                      child: Center(
                        child: circular
                            ? SizedBox(
                                width: 24, // Width of the spinner
                                height: 24, // Height of the spinner
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth:
                                      2, // Optional: You can adjust the thickness of the spinner
                                ),
                              )
                            : const Text(
                                "Fetch Account Number",
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ),
                ),

                if (isAccountFetched) ...[
                  SizedBox(height: 16), // Spacing before dropdown
                  TextLabel("Account Number"),
                  ReusableDropdown(
                    selectedValue: selectedAccountNumber,
                    items: accountNumbers,
                    hintText: 'Select Account Number',
                    onChanged: (newStatus) {
                      setState(() {
                        selectedAccountNumber = newStatus!;
                      });
                    },
                    isGreyBorder: true,
                    errorMessage: 'Please select an Account Number',
                    isRequired: true,
                  ),
                ],
              ],
            )),
      ),
      Step(
        title: Text(isSmallScreen ? "" : "Link Account "),
        isActive: _activeStepIndex >= 3,
        state: _activeStepIndex > 3 ? StepState.complete : StepState.indexed,
        content: Form(
          key: globalFormKey3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Available Documents",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              englishQR != null
                  ? Column(
                      children: [
                        Image.memory(
                          englishQR!,
                          height: 340,
                          width: 290,
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await saveQRCodeToGallery(englishQR!, context);
                          },
                          icon: Icon(Icons.download),
                          label: Text("Download QR Code"),
                        ),
                      ],
                    )
                  : Text("No QR code generated yet."),

              amharicQRCODE != null
                  ? Column(
                      children: [
                        Image.memory(
                          amharicQRCODE!,
                          height: 340,
                          width: 290,
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await saveQRCodeToGallery(amharicQRCODE!, context);
                          },
                          icon: Icon(Icons.download),
                          label: Text("Download QR Code"),
                        ),
                      ],
                    )
                  : Text("No QR code generated yet."),

              afaanOromoQR != null
                  ? Column(
                      children: [
                        Image.memory(
                          afaanOromoQR!,
                          height: 340,
                          width: 290,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await saveQRCodeToGallery(englishQR!, context);
                          },
                          icon: Icon(Icons.download),
                          label: Text("Download QR Code"),
                        ),
                      ],
                    )
                  : Text("No QR code generated yet."),

              CheckboxListTile(
                title: const Text(
                  "Order Delivery ",
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                value: deliveryOptionChecked,
                onChanged: (value) {
                  setState(() {
                    deliveryOptionChecked = value ?? false;
                  });
                },
              ),

              if (deliveryOptionChecked) ...[
                const Text(
                  "Select Delivery Document",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                RadioListTile<int>(
                  title: const Text("English Document"),
                  value: 1,
                  groupValue: selectedDocument, // Shared state variable
                  onChanged: englishQR != null
                      ? (value) {
                          setState(() {
                            selectedDocument = value;
                          });
                        }
                      : null,
                ),
                RadioListTile<int>(
                  title: const Text("Amharic Document"),
                  value: 2,
                  groupValue: selectedDocument,
                  onChanged: amharicQRCODE != null
                      ? (value) {
                          setState(() {
                            selectedDocument = value;
                          });
                        }
                      : null,
                ),
                RadioListTile<int>(
                  title: const Text("Afaan Oromo Document"),
                  value: 3,
                  groupValue: selectedDocument,
                  onChanged: afaanOromoQR != null
                      ? (value) {
                          setState(() {
                            selectedDocument = value;
                          });
                        }
                      : null,
                ),
              ],

              // Address Fields
              if (deliveryOptionChecked && selectedDocument != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Delivery Address",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextLabel("Region"),
                    ReusableDropdown(
                      selectedValue: selectedState,
                      items: ListContants.ethiopianStates,
                      hintText: 'Select State',
                      onChanged: (newState) {
                        setState(() {
                          selectedState = newState;
                        });
                      },
                      errorMessage: 'Please select a state',
                      isRequired: true,
                    ),
                    TextLabel("City"),
                    CustomTextFormField(
                      hintText: "Enter city ",
                      errorMessage: "City is required",
                      controller: cityController,
                      isRequired: true,
                    ),
                    TextLabel("Specific Address"),
                    CustomTextFormField(
                      hintText: "Enter specific address ",
                      errorMessage: "Specific address is required",
                      controller: specificAddressController,
                      isRequired: true,
                    ),
                    TextLabel("Number of Print"),
                    ReusableTextFormField(
                      hintText: "Enter Number of Print",
                      controller: numberOfPring,
                      keyboardType: TextInputType.number,
                      errorMessage: "Number of Print cannot be empty",
                      // leadingIcon: Icons.trending_up,
                      // return '';
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Only allow numbers
                      ],
                      isRequired: true,
                    ),
                  ],
                ),
            ],
          ),
        ),
      )
    ];
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
          // centerTitle: true,
          title: const Text(
            "Merchant Registration",
            style: TextStyle(
                fontSize: 19, fontWeight: FontWeight.bold, color: Colors.blue),
          ),

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
                                top: 30, left: 20, right: 20),
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
                                            _activeStepIndex == 3
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

    phoneNumber = phoneNumberController.text.isEmpty;

    if (phoneNumber) {
      print("phone number is empty");
    }
    isValid = EmailValidator.validate(emailController.text);
    if (form != null && form.validate()) {
      form.save();
      return true;
    }

    return false;
  }

  Future<void> onStepContinue() async {
    FocusScope.of(context).unfocus(); // Dismiss the keyboard
    setState(() {
      isLoading = true;
    });

    final formIsValid = validateData();
    print(formIsValid);

    if (formIsValid) {
      final isLastStep = _activeStepIndex == stepList().length - 1;
      print("isLastStep: $isLastStep");

      if (_activeStepIndex == 0) {
        if (phoneNumberController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter Phone Number.")),
          );
          setState(() {
            isLoading = false;
          });
          return;
        } else {
          _pinController.text = '';

          registerStatus = true;
          await handleRegistrationProcess();
          // await handleFirstStep();
        }
      } else if (_activeStepIndex == 1) {
        // registerStatus = true;
        await handleSecondStep();
      } else if (_activeStepIndex == 2) {
        if (selectedAccountNumber == null) {
          registerStatus = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Account number is required.")),
          );
        } else {
          await qrCodeRequest();
        }
      }

      // If it's the last step, submit the form
      if (isLastStep) {
        await submitFormData1();
        // await submitFormData();
      } else {
        // Move to the next step
        setState(() {
          if (registerStatus) {
            _activeStepIndex += 1;
            print("_activeStepIndex: $_activeStepIndex");
          }
        });
      }
    } else {
      // Handle validation failure (optional: display a message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields.")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  bool validateData() {
    bool isValid = true;

    switch (_activeStepIndex) {
      case 0:
        if (phoneNumberController.text.isEmpty) {
          isValid = false;
        }
        return (globalFormKey.currentState?.validate() ?? false);

      case 1:
        if (_pinController.text.isEmpty) {
          isValid = false;
        }
        return globalFormKey1.currentState?.validate() ?? false;

      case 2:
        // Step 2 validation
        return globalFormKey2.currentState?.validate() ?? false;

      case 3:
        // Step 3 validation
        return globalFormKey3.currentState?.validate() ?? false;

      case 4:
        // Step 4 validation
        return globalFormKey4.currentState?.validate() ?? false;

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

  Future<void> submitStepData() async {
    try {
      // Replace '/api/v1/accounts' with the full URL to your endpoint
      String fullUrl = '${AppConstants.soupBaseURL}/merchant/register';
      print(fullUrl);
      var response = await networkHandler
          .post(fullUrl, registrationData)
          .timeout(const Duration(seconds: 20));

      var responseData = json.decode(response.body);
      print("dddddd");
      print(response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          validate = true;
          circular = false;

          registerStatus = true;
        });
        // showOtpDialog();
      } else {
        String errorMessage =
            responseData['message'] ?? 'Error occurred. Please try again.';
        // showOtpDialog();
        registerStatus = false;
      }
    } on TimeoutException catch (_) {
      registerStatus = false;

      // Optionally, show a SnackBar or any other UI feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("The request timed out. Please try again.")),
      );
    } catch (_e) {
      setState(() {
        registerStatus = false; // Stop loading indicator
      });

      // print(_e);
      // Handle any other exceptions (e.g., network error)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("The request didn't reach the server. Please try again.")),
      );
    }
  }

/////////Second Step
  Future<void> handleSteptwo() async {
    try {
      print("token");

      // Replace '/api/v1/accounts' with the full URL to your endpoint
      String fullUrl = '${AppConstants.soupBaseURL}/eky/create';

      var response = await networkHandler
          .postFormData(fullUrl, kycRegistrationData, token)
          .timeout(const Duration(seconds: 20));
      var responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          validate = true;
          circular = false;
          // userId = responseData['id'].toString();
          registerStatus = true;
        });
      } else if (response.statusCode == 409) {
        print("getData");
        String fullUrl = '${AppConstants.soupBaseURL}/eky/getKyc';

        var response = await networkHandler
            .getData(fullUrl, token)
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          var responseBody = jsonDecode(response.body);

          // Extract the relevant fields
          String firstName = responseBody['first_name'] ?? '';
          String lastName = responseBody['last_name'] ?? '';
          String businessAddress = responseBody['business_address'] ?? '';
          String businessName = responseBody['business_name'] ?? '';
          String merchantCity = responseBody['merchant_city'] ?? '';

          String businessType = responseBody['business_type'] ?? '';

          setState(() {
            firstNameController.text = firstName;
            lastNameController.text = lastName;
            businessAddressController.text = businessAddress;
            businessNameController.text = businessName;
            merchantCityController.text = merchantCity;
            businessType = businessType;
            registerStatus = true;
          });
        } else {
          registerStatus = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("An Error occor please try again.")),
          );
        }
        setState(() {
          validate = true;
          circular = false;
          // registerStatus = false;
        });
      } else {
        String errorMessage =
            responseData['error'] ?? 'Error occurred. Please try again.';
        // Show SnackBar with an error message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
            ),
          );
        });

        registerStatus = false;
      }
    } on TimeoutException catch (_) {
      // Handle timeout exception
      registerStatus = false;
      print("The request timed out. Please try again.");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("The request timed out. Please try again.")),
      );
    } catch (_e) {
      print("token");
      print(token);
      setState(() {
        registerStatus = false;
      });
      print(_e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An unexpected error occurred. . Please try again.")),
      );
    }
  }

  Future<void> handleFirstStep() async {
    registrationData['username'] = "0" + phoneNumberController.text;
    registrationData['password'] = '123456';
    registrationData["source"] = "ETH_QR";
    print(registrationData);
    await submitStepData();
  }

  //STEP 2:
  Future<void> handleSecondStep() async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int merchantId = decodedToken['merchant_id'] ?? 0;
    kycRegistrationData['first_name'] = firstNameController.text;
    kycRegistrationData['last_name'] = lastNameController.text;
    kycRegistrationData['business_name'] = businessNameController.text;
    kycRegistrationData['business_type'] = selectedBusinessType;
    kycRegistrationData['business_address'] = businessAddressController.text;
    kycRegistrationData['merchant_id'] = merchantId.toString();
    kycRegistrationData['merchant_city'] = merchantCityController.text;
    kycRegistrationData['country_code'] = 'ET';

    print(kycRegistrationData);
    print(businessTypeController.text);
    await handleSteptwo();
  }

  Future<void> submitFormData1() async {
    bool atLeastOneQRExists =
        englishQR != null || amharicQRCODE != null || afaanOromoQR != null;
    bool atLeastOneDocumentSelected = selectedDocument != null;

    print(atLeastOneQRExists);
    print(atLeastOneDocumentSelected);
    print(deliveryOptionChecked);
    print(deliveryOptionChecked &&
        atLeastOneQRExists &&
        !atLeastOneDocumentSelected);
    if (!deliveryOptionChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thank you for your submission!")),
      );
      registerStatus = true;
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
          (route) => false);
    } else if (deliveryOptionChecked &&
        atLeastOneQRExists &&
        !atLeastOneDocumentSelected) {
      registerStatus = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select atleast one Documents!"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      registerStatus = false;
      await orderDelivery();
    }

    print("final stage");
    // registrationData['phoneNumber'] = phoneNumberController.text;
    // registrationData['marchentName'] = firstNameController.text;
    // registrationData['merchantCity'] = businessAddressController.text;
    // registrationData['emailAddress'] = emailController.text;
    // registrationData['merchantAccountNumber'] = selectedAccountNumber;
    // registrationData['businessType'] = selectedBusinessType;
    // registrationData['businessName'] = businessNameController.text;
    // registrationData['tin'] = tinController.text;
    // registrationData['dateOfEstablishment'] =
    //     dateOfEstablishmentController.text;
    // registrationData['transactionalAmount'] = transactionAmountController.text;
    // registrationData['storeLabel'] = storeLabelController.text;
    // registrationData['terminalLabel'] = terminalLabelController.text;
    // registrationData['paymentReason'] = paymentReasonController.text;

    // registrationData['languagePreference'] = selectedLanguagePreference;
    // registrationData['localizedMarchentName'] =
    //     localizedMerchantNameController.text;
    // registrationData['localizedMarchentAddress'] =
    //     localizedMerchantCityController.text;
    // registrationData['qrcode'] = 'assets/qr2.png';

    // registrationData['countryCode'] = 'ET';
    // registrationData['currency'] = "230";
    // registrationData['transactionReason'] = "Payment";
    // registrationData['doingBusinessAsName'] = firstNameController.text;
    // registrationData['ttc'] = 400;
    // registrationData['mcc'] = 1234;
    // await qrCodeRequest();
  }

  Future<void> validatePin(String pin) async {
    // Example API request using pin
    try {
      // Replace '/api/v1/accounts' with the full URL to your endpoint
      String fullUrl = '${AppConstants.soupBaseURL}/activateEthQrOtpCode';
      phoneNumber = "0" + phoneNumberController.text;
      otpRegistrationData['phone_number'] = "0" + phoneNumberController.text;
      otpRegistrationData['otpCode'] = _pinController.text;

      print(registrationData);
      var response = await networkHandler
          .post(fullUrl, otpRegistrationData)
          .timeout(const Duration(seconds: 20));

      var responseData = json.decode(response.body);
      print("response.statusCode");
      print(response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _activeStepIndex += 1;
          validate = true;
          circular = false;
          // userId = responseData['id'].toString();
          registerStatus = false;
        });
        await loginUser();
      }
      // registerStatus = true;
      else {
        String errorMessage = responseData['error'] ??
            'Error occurred. Please try again.'; // Customize this based on your backend response structure

        // Show SnackBar with an error message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
            ),
          );
        });

        registerStatus = false;
      }
    } catch (e) {
      registerStatus = false;
      // Handle network or other errors
      print('Error validating pin: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An error occurred. Please try again later.")),
      );
    }
  }

  bool isOtpSent = false;

  Future<void> handleRegistrationProcess() async {
    print("token");
    print(token);
    if (phoneNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Phone Number.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      registrationData['username'] = "0" + phoneNumberController.text;
      registrationData['password'] = 'CBO@merchant123';
      registrationData["source"] = "ETH_QR";

      String fullUrl = '${AppConstants.soupBaseURL}/merchant/register';
      var response = await networkHandler
          .post(fullUrl, registrationData)
          .timeout(const Duration(seconds: 20));
      var responseData = json.decode(response.body);

      print(response.body);
      print("dddddd");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Registration successful! Sending OTP...")),
        );

        // Step 3: Send OTP
        await sendOtp();

        // Step 4: Show OTP Dialog and validate OTP
        await showOtpDialog();
      } else if (response.statusCode == 400) {
        await loginUser();

        // await sendOtp();

        // // Step 4: Show OTP Dialog and validate OTP
        // await showOtpDialog();
      } else {
        print(response.statusCode);
        registerStatus = false;
        throw Exception(responseData['message'] ?? "Registration failed1.");
      }
    } catch (e) {
      print("object");
      print(e);
      registerStatus = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Registration failed")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Mock function to verify OTP
  Future<void> verifyOtp(String otp) async {
    // Simulate OTP verification
    print("Verifying OTP: $otp");
    await Future.delayed(Duration(seconds: 2));
    if (otp == "123456") {
      print("OTP verified successfully!");
      // Proceed to the next step if OTP is correct
      Navigator.of(context).pop(); // Close the OTP dialog
    } else {
      print("Invalid OTP");
    }
  }

  Future<void> callFinalQrAPIs(Uint8List qrImage) async {
    // Define the list of URLs for the APIs
    List<String> apiUrls = [
      'http://10.12.53.40:5000/api/process_qr_oro/',
      'http://10.12.53.40:5000/api/process_qr_eng/',
      'http://10.12.53.40:5000/api/process_qr_amh/',
    ];

    try {
      englishQR = null;
      amharicQRCODE = null;
      afaanOromoQR = null;

      final Map<String, dynamic> finalQRCODE = {
        'merchant_name':
            firstNameController.text + " " + lastNameController.text,
        'merchant_id': selectedAccountNumber,
        'qr_code': qrImage,
      };

      for (String url in apiUrls) {
        var response = await networkHandler
            .postWithFormData(url, finalQRCODE)
            .timeout(const Duration(seconds: 20));

        // Process the response
        if (response.statusCode == 200) {
          registerStatus = true;
          print("QR uploaded successfully for $url");
          SnackBar(content: Text("QR code successfully processed."));

          // Handle specific responses (e.g., storing `response.bodyBytes`)
          if (url.contains('process_qr_oro')) {
            afaanOromoQR = response.bodyBytes;
          } else if (url.contains('process_qr_eng')) {
            englishQR = response.bodyBytes;
            // Add additional logic for English QR processing if needed
          } else if (url.contains('process_qr_amh')) {
            amharicQRCODE = response.bodyBytes;
          }

          deliverDocument1 = false;
          deliverDocument2 = false;
          deliverDocument3 = false;
          deliveryOptionChecked = false;
          selectedDocument = null;
        } else {
          registerStatus = false;
          print("Failed to upload QR for $url: ${response.statusCode}");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  "Failed to process the QR code. Please try again later.")));
        }
      }
    } on TimeoutException catch (_) {
      registerStatus = false;
      print("The request timed out.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("The request timed out.")),
      );
    } catch (e) {
      registerStatus = false;
      print("Error during the request: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "An error occurred while processing the request. Please try again."),
      ));
    }
  }

  Future<void> callMultipleApis(Uint8List qrImage) async {
    String qrUrlEng = 'http://10.12.53.40:5000/process_qr_eng';
    String qrUrlAmh = 'http://10.12.53.40:5000/process_qr_amh';
    String qrUrlOro = 'http://10.12.53.40:5000/process_qr_oro';

    try {
      englishQR = null;
      amharicQRCODE = null;
      afaanOromoQR = null;
      final Map<String, dynamic> finalQRCODE = {};
      finalQRCODE['merchant_name'] =
          firstNameController.text + " " + lastNameController.text;
      finalQRCODE['merchant_id'] = selectedAccountNumber;
      finalQRCODE['qr_code'] = qrImage;

      var firstdata;
      var seconddata;
      var thirddata;

      registerStatus = false;

      var responses = await Future.wait([
        networkHandler
            .postWithFormData(qrUrlEng, finalQRCODE)
            .timeout(const Duration(seconds: 20)),
        networkHandler
            .postWithFormData(qrUrlAmh, finalQRCODE)
            .timeout(const Duration(seconds: 20)),
        networkHandler
            .postWithFormData(qrUrlOro, finalQRCODE)
            .timeout(const Duration(seconds: 20)),
      ]);

      bool allSuccessful = true;

      firstdata = responses[0];
      seconddata = responses[1];
      thirddata = responses[2];

      // Check the status of each response and assign data accordingly
      if (firstdata.statusCode == 200) {
        englishQR = firstdata.bodyBytes;
        print("firstdata.bodyBytes");
        print(firstdata.bodyBytes);

        // Store English QR
      } else {
        allSuccessful = false;
        print("Failed to upload English QR: ${firstdata.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Failed to upload English QR with status code: ${firstdata.statusCode}")),
        );
      }

      if (seconddata.statusCode == 200) {
        amharicQRCODE = seconddata.bodyBytes; // Store Amharic QR
        print("seconddata.bodyBytes");
        print(seconddata.bodyBytes);
      } else {
        allSuccessful = false;
        print("Failed to upload Amharic QR: ${seconddata.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Failed to upload Amharic QR with status code: ${seconddata.statusCode}")),
        );
      }

      if (thirddata.statusCode == 200) {
        afaanOromoQR = thirddata.bodyBytes; // Store Oromo QR
        print("thirddata.bodyBytes");
        print(thirddata.bodyBytes);
      } else {
        allSuccessful = false;
        print("Failed to upload Oromo QR: ${thirddata.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Failed to upload Oromo QR with status code: ${thirddata.statusCode}")),
        );
      }

      // Set registerStatus based on whether all API calls were successful
      if (allSuccessful) {
        registerStatus = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All QR codes uploaded successfully")),
        );
      } else {
        registerStatus = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Some QR codes failed to upload.")),
        );
      }
    } on TimeoutException catch (_) {
      registerStatus = false;
      print("The request timed out.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("The request timed out.")),
      );
    } catch (e) {
      registerStatus = false;
      print("Error during the request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> sendOtp() async {
    // Mock sending OTP (replace with your backend logic)
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isOtpSent = true;
    });
  }

  Future<void> validateOtp(String pin) async {
    setState(() {
      isLoading = true;
    });

    try {
      otpRegistrationData['phone_number'] = "0" + phoneNumberController.text;
      otpRegistrationData['otpCode'] = pin;

      String fullUrl = '${AppConstants.soupBaseURL}/activateEthQrOtpCode';
      var response = await networkHandler
          .post(fullUrl, otpRegistrationData)
          .timeout(const Duration(seconds: 20));
      var responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("OTP verified successfully! Logging in...")),
        );
        _pinController.text = '';
        registerStatus = false;
        // Proceed to login
        await loginUser();

        if (registerStatus) {
          Navigator.of(context).pop();
        }
      } else {
        _pinController.text = '';
        registerStatus = false;
        throw Exception(responseData['error'] ?? "OTP verification failed.");
      }
    } catch (e) {
      registerStatus = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: OTP verification failed")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> showOtpDialog() async {
    registerStatus = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("OTP Verification"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                      children: [
                        const TextSpan(
                          text: "An OTP has been sent to your phone number ",
                        ),
                        TextSpan(
                          text: '+251' + phoneNumberController.text,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: ". Please enter the OTP to verify.",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // if (isLoading)
                  //   const CircularProgressIndicator() // Show loading spinner
                  // else
                  Pinput(
                    controller: _pinController,
                    length: 6,
                    // onCompleted: (pin) async {
                    //   setState(() {
                    //     isLoading = true; // Show loading spinner
                    //   });

                    //   await validateOtp(pin);

                    //   setState(() {
                    //     isLoading = false; // Hide loading spinner
                    //   });

                    //   Navigator.of(context).pop();
                    // },
                    defaultPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 212, 203, 203),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color.fromARGB(255, 224, 217, 217)),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue, // Text color
                    ),
                    onPressed: () async {
                      if (_pinController.length == 6 &&
                          _pinController != null) {
                        setState(() {
                          isLoading = true;
                        });

                        await validateOtp(_pinController.text);

                        setState(() {
                          isLoading = false;
                        });

                        // Navigator.of(context).pop();
                      }
                    },
                    child: isLoading
                        ? SizedBox(
                            width: 24, // Width of the spinner
                            height: 24, // Height of the spinner
                            child: const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth:
                                  3, // Optional: You can adjust the thickness of the spinner
                            ),
                          ) // Show loading spinner
                        : Text("Continue"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> loginUser() async {
    String fullUrl = '${AppConstants.soupBaseURL}/merchant/login';

    Map<String, dynamic> loginData = {
      "username": "0" + phoneNumberController.text,
      "password": "CBO@merchant123"
    };

    try {
      // Make the POST request
      var response = await networkHandler
          .post(fullUrl, loginData)
          .timeout(const Duration(seconds: 20));

      var responseData = json.decode(response.body);
      print("response.statusCode: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Navigator.of(context).pop();
        setState(() {
          validate = true;
          // _activeStepIndex += 1;
          circular = false;
          registerStatus = true;
          _pinController.clear();
        });

        token = responseData['token'] ?? '';

        print(token);
        print("Login successful, token: $token");
      } else {
        // Handle unsuccessful login
        String errorMessage = responseData['message'] ??
            'Invalid username or password. Please try again.';
        print("Error: $errorMessage");
        registerStatus = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } on TimeoutException catch (_) {
      registerStatus = false;
      // Handle timeout exception
      print("The request timed out. Please try again.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("The request timed out. Please try again.")),
      );
    } catch (e) {
      registerStatus = false;
      // Handle other exceptions
      print("An error occurred: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An unexpected error occurred. Please try again.")),
      );
    }
  }

  qrCodeRequest() async {
    // Replace with your API endpoint
    String fullUrl =
        'https://souqpass.coopbankoromiasc.com/generate/v1/qr-code/generate-static';

    try {
      Map<String, dynamic> merchantData = {
        "merchantAccountNumber": selectedAccountNumber,
        "countryCode": 'ET',
        "currency": '230',
        "transactionReason": 'MP2M',
        "mcc": '1234',
        "doingBusinessAsName": businessNameController.text,
        "merchantCity": merchantCityController.text,
        "ttc": 400,
      };

      // Make the POST request
      var response = await networkHandler
          .post(fullUrl, merchantData)
          .timeout(const Duration(seconds: 20));

      // var responseData = json.decode(response.body);
      print("response.statusCode: ${response.statusCode}");
      print(response.body);

      if (response.headers['content-type']?.contains('image/png') == true) {
        qrcodeImage = response.bodyBytes;
        // registerStatus = true;

        await callFinalQrAPIs(qrcodeImage!);
        // await callMultipleApis(qrcodeImage!);

        print(qrcodeImage);
        setState(() {
          _image = Image.memory(qrcodeImage!);
        });
      } else {
        registerStatus = false;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to get the QR Code")),
        );
        // If the response is not an image, attempt to decode as JSON
        var responseData = json.decode(response.body);
        print(responseData);
      }
    } on TimeoutException catch (_) {
      setState(() {
        registerStatus = false;
      });
      print("The request timed out. Please try again.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("The request timed out. Please try again.")),
      );
    } catch (e) {
      registerStatus = false;
      // Handle other exceptions
      print("An error occurreddddd: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An unexpected error occurred. Please try again.")),
      );
    }
  }

/////////Second Step
  Future<void> fetchAccountNumer() async {
    try {
      print("token");

      // Replace '/api/v1/accounts' with the full URL to your endpoint
      String fullUrl = "${AppConstants.soupBaseURL}/user/userinfo";

      var response = await networkHandler
          .postData(fullUrl, phoneNUmber, AppConstants.suuptoken)
          .timeout(const Duration(seconds: 20));

      var responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Extract account numbers
        List<dynamic> accounts = responseData['userInfo']['accounts'];
        setState(() {
          validate = true;
          circular = false;
          isAccountFetched = true;
          registerStatus = true;

          accountNumbers = accounts
              .map((account) => account['accountNumber'].toString())
              .toList();
        });
      } else {
        String errorMessage = responseData['error'] ??
            'Error occurred. Please try again.'; // Customize this based on your backend response structure
        // Show SnackBar with an error message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
            ),
          );
        });
        isAccountFetched = false;
        registerStatus = false;
      }
    } on TimeoutException catch (_) {
      // Handle timeout exception
      registerStatus = false;
      isAccountFetched = false;
      print("The request timed out. Please try again.");

      // Optionally, show a SnackBar or any other UI feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("The request timed out. Please try again.")),
      );
    } catch (_e) {
      setState(() {
        isAccountFetched = false;
        registerStatus = false; // Stop loading indicator
      });
      print(_e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An error occurred while processing your request.")),
      );
    }
  }

  Future<void> saveQRCodeToGallery(
      Uint8List imageBytes, BuildContext context) async {
    try {
      // Get a temporary directory to save the file
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/QRCode.png';

      // Save the image to a file
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      // Save the file directly to the gallery
      final isSaved =
          await GallerySaver.saveImage(file.path, albumName: "QR Codes");

      // Provide feedback to the user
      if (isSaved == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("QR Code image saved to gallery successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to save QR Code image to gallery.")),
        );
      }
    } catch (e) {
      // Handle errors
      print("Error saving image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save QR Code image: $e")),
      );
    }
  }

  Future<void> downloadQRCode(
      Uint8List qrCodeBytes, BuildContext context) async {
    try {
      // Use app's internal documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/qrcode.png';

      // Write the QR code bytes to the file
      final file = File(filePath);
      await file.writeAsBytes(qrCodeBytes);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("QR Code saved to app's directory: $filePath")),
      );

      // // Optionally open the file location
      // print("File saved at: $filePath");
    } catch (e) {
      // Handle errors
      print("Error saving QR Code: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save QR Code: $e")),
      );
    }
  }

  orderDelivery() async {
    const url = "https://souqpass.coopbankoromiasc.com/api/eky/qrRequest";

    Uint8List? qrFile;
    if (selectedDocument == 1) {
      qrFile = englishQR;
    } else if (selectedDocument == 2) {
      qrFile = amharicQRCODE;
    } else if (selectedDocument == 3) {
      qrFile = afaanOromoQR;
    }
    final Map<String, dynamic> deliveryData = {
      'merchantName': firstNameController.text + " " + lastNameController.text,
      'merchantAccountNumber': selectedAccountNumber,
      'transactionReason': "reason",
      'mcc': "400",
      'doingBusinessAsName': businessNameController.text,
      'merchantCity': merchantCityController.text,
      'ttc': "400",
      'deliveryAddress': specificAddressController.text,
      'numberOfPrints': numberOfPring.text,
      'qrFile': qrFile,
    };

    var response = await networkHandler
        .postFormData(url, deliveryData, token)
        .timeout(const Duration(seconds: 20));

    print(response.body);

    print(response.statusCode);

    if (response.statusCode == 200 || response.statusCode == 201) {
      registerStatus = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thanks for making the order!")),
      );
      if (registerStatus == true) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainPage(),
            ),
            (route) => false);
      }
    } else {
      registerStatus = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Un expected error occur try again!")),
      );
    }
  }
}
