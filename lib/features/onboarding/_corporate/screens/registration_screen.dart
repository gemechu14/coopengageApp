import 'package:coopengageplus/constants/kconstant.dart';
import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';
import '../widgets/company_info_form.dart';
import '../widgets/account_type_form.dart';
import '../widgets/document_upload_form.dart';
import '../widgets/representative_form.dart';
import '../widgets/submit_button.dart';

const Color kPrimaryColor = Color(0xFF00BCD4); // cyan blue

class CorporateRegistrationScreen extends StatefulWidget {
  const CorporateRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<CorporateRegistrationScreen> createState() =>
      _CorporateRegistrationScreenState();
}

class _CorporateRegistrationScreenState
    extends State<CorporateRegistrationScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  final GlobalKey<FormState> _companyInfoFormKey = GlobalKey<FormState>();

  late final List<Widget> _steps;

  final List<String> _titles = [
    'Company Info',
    'Account',
    'Documents',
    'Representatives',
    'Submit',
  ];

  @override
  void initState() {
    super.initState();
    _steps = [
      CompanyInfoForm(formKey: _companyInfoFormKey),
      const AccountTypeForm(),
      const RepresentativeForm(),
      const DocumentUploadForm(),
      const SubmitButton(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Corporate Registration',
            style: TextStyle(fontSize: 20, color: cyanblueColor),
          ),
          backgroundColor: whiteColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: cyanblueColor,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      EasyStepper(
                        activeStep: _currentStep,
                        stepShape: StepShape.circle,
                        stepRadius: 16,
                        borderThickness: 2,
                        finishedStepBorderColor: cyanblueColor,
                        activeStepBorderColor: cyanblueColor,
                        activeStepTextColor: cyanblueColor,
                        finishedStepTextColor: cyanblueColor,
                        unreachedStepTextColor: Colors.grey,
                        unreachedStepBorderColor: Colors.grey.shade300,
                        showLoadingAnimation: false,
                        internalPadding: 0,
                        steps: List.generate(
                          _steps.length,
                          (index) => EasyStep(
                            icon: Icon(_getStepIcon(index),
                                size: 16,
                                color: _currentStep == index
                                    ? kPrimaryColor
                                    : Colors.grey),
                            title: _currentStep == index ? _titles[index] : '',
                          ),
                        ),
                        onStepReached: (index) {
                          setState(() {
                            _currentStep = index;
                          });
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        color: Colors.white,
                        child: _steps[_currentStep],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (_currentStep > 0)
                ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _currentStep--;
                          });
                        },
                  label: Text(
                    _isLoading ? 'Please wait...' : 'Previous',
                    style: TextStyle(fontSize: 13),
                  ),
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading ? Colors.grey : cyanblueColor,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 1, vertical: 10),
                    textStyle: const TextStyle(fontSize: 13),
                    minimumSize: const Size(100, 36),
                  ),
                )
              else
                const SizedBox(width: 100),
              ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          if (_currentStep == 0) {
                            if (_companyInfoFormKey.currentState?.validate() !=
                                true) {
                              return;
                            }
                          }
                          if (_currentStep < _steps.length - 1) {
                            setState(() {
                              _currentStep++;
                            });
                          } else {
                            // Final step - complete registration
                            // TODO: Add registration completion logic
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : _currentStep == _steps.length - 1
                        ? const Icon(Icons.check, size: 16)
                        : const Icon(Icons.arrow_forward, size: 16),
                label: Text(
                    _isLoading
                        ? 'Processing...'
                        : _currentStep == _steps.length - 1
                            ? 'Complete'
                            : 'Continue',
                    style: const TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cyanblueColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  textStyle: const TextStyle(fontSize: 13),
                  minimumSize: const Size(100, 36),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStepIcon(int index) {
    switch (index) {
      case 0:
        return Icons.business;
      case 1:
        return Icons.account_balance;
      case 2:
        return Icons.upload_file;
      case 3:
        return Icons.people;
      case 4:
        return Icons.check;
      default:
        return Icons.circle;
    }
  }
}
