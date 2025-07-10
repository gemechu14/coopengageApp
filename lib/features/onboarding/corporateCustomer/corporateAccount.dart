// ignore_for_file: unused_local_variable, constant_identifier_names, unused_element, avoid_print, unused_import, unnecessary_import, prefer_typing_uninitialized_variables, file_names, non_constant_identifier_names, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:coopengageplus/common_widgets/AlertDialog/DialogHelper%20.dart';
import 'package:coopengageplus/features/onboarding/HomePage/AccountOpeningHomePage.dart';
import 'package:coopengageplus/features/onboarding/HomePage/homepage.dart';
import 'package:coopengageplus/features/onboarding/corporateCustomer/RegistrationServices.dart';
import 'package:coopengageplus/features/onboarding/pages/ConfirmationPage.dart';
import 'package:coopengageplus/pages/MainPage.dart';
import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path_provider/path_provider.dart';
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
import '../../../common_widgets/dropDown/documentUploads.dart';
import '../pages/home/HomePage.dart';
import 'providers/registration_providers.dart';
import 'services/registration_service.dart' as reg_service;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/basic_info_step.dart';

bool isConventionalSelected = true;
List<Map<String, dynamic>> allBranches = [];
String? selectedBranch;
List<List<bool>> isExpandedPersonalList = [];
List<List<bool>> isExpandedAddressInfoList = [];
List<List<bool>> isExpandedDocumentInfoList = [];
List<List<bool>> isExpandedIDInfoList = [];
String? selectedAccountTypeId;
bool isFirstPersonExpanded = false;
bool isSecondPersonExpanded = false;
bool isExpandedPersonalInformation = false;
List<bool> isExpandedList = [false, false];
String? expandedAccountTypeId;

// File? licenseFile;
// File? articleFile;
// File? letterOfRequestFile;
String? licenseFile;
String? articleFile;
String? letterOfRequestFile;
String? tinNumberPhoto;
String? tradeName;

List<File> selectedFiles = [];
// List<bool> isExpandedList = [];
List<GlobalKey<FormState>> formKeys = [];
List<TextEditingController> fullNameControllers = [];
List<TextEditingController> phoneControllers = [];
List<TextEditingController> emailControllers = [];

List<TextEditingController> monthlyIncomeControllers = [];
List<TextEditingController> motherNameControllers = [];
List<TextEditingController> DateofBirthControllers = [];
List<TextEditingController> occupationControllers = [];

class CorporateCustomerRegistration extends ConsumerStatefulWidget {
  const CorporateCustomerRegistration({Key? key}) : super(key: key);

  @override
  ConsumerState<CorporateCustomerRegistration> createState() => _CorporateCustomerRegistrationState();
}

class _CorporateCustomerRegistrationState extends ConsumerState<CorporateCustomerRegistration> {
  int _activeStepIndex = 0;

  final List<Widget> _steps = [
    BasicInfoStep(),
    SignatureStep(),
    PersonalInfoStep(),
    FinancialInfoStep(),
    DocumentUploadStep(),
    AccountTypeStep(),
  ];

  @override
  Widget build(BuildContext context) {
    final registrationState = ref.watch(registrationProvider);
    final registrationService = reg_service.RegistrationService();
    final isLastStep = _activeStepIndex == _steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Corporate Customer Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Step indicator (optional)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_steps.length, (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _activeStepIndex == index ? Colors.blue : Colors.grey[300],
                ),
              )),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _steps[_activeStepIndex],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_activeStepIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _activeStepIndex -= 1;
                      });
                    },
                    child: const Text('Back'),
                  ),
                ElevatedButton(
                  onPressed: () async {
                    if (!isLastStep) {
                      setState(() {
                        _activeStepIndex += 1;
                      });
                    } else {
                      // Final step: submit registration
                      // TODO: Build requestData from provider state
                      // await registrationService.registerAllUsers(requestData);
                    }
                  },
                  child: Text(isLastStep ? 'Submit' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class SignatureStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(); // TODO: Implement
  }
}
class PersonalInfoStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(); // TODO: Implement
  }
}
class FinancialInfoStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(); // TODO: Implement
  }
}
class DocumentUploadStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(); // TODO: Implement
  }
}
class AccountTypeStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(); // TODO: Implement
  }
}
