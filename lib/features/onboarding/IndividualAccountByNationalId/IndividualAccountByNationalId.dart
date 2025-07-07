import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:coopengageplus/constants/kconstant.dart';

class IndividualAccountByNationalId extends StatefulWidget {
  const IndividualAccountByNationalId({Key? key}) : super(key: key);

  @override
  State<IndividualAccountByNationalId> createState() => _IndividualAccountByNationalIdState();
}

class _IndividualAccountByNationalIdState extends State<IndividualAccountByNationalId> {
  int activeStep = 0;
  int upperBound = 0;
  List<GlobalKey<FormState>> formKeys = [];

  @override
  void initState() {
    super.initState();
    upperBound = 2; // Only 3 steps (0, 1, 2)
    formKeys = List.generate(3, (index) => GlobalKey<FormState>());
  }

  List<EasyStep> steps = [
    EasyStep(
      title: 'Phone & FAN',
      icon: Icon(Icons.phone),
    ),
    EasyStep(
      title: 'OTP Verification',
      icon: Icon(Icons.verified),
    ),
    EasyStep(
      title: 'Complete',
      icon: Icon(Icons.check_circle),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: cyanblueColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'National ID Registration',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: cyanblueColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper Header - Reduced Height
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: EasyStepper(
                activeStep: activeStep,
                lineStyle: LineStyle(
                  lineLength: 50,
                  lineSpace: 0,
                  lineType: LineType.normal,
                  defaultLineColor: Colors.grey.shade300,
                  finishedLineColor: cyanblueColor,
                  lineThickness: 2,
                ),
                stepShape: StepShape.circle,
                stepBorderRadius: 20,
                borderThickness: 2,
                padding: const EdgeInsets.all(15),
                stepRadius: 20,
                finishedStepTextColor: Colors.white,
                finishedStepBackgroundColor: cyanblueColor,
                activeStepTextColor: cyanblueColor,
                activeStepBackgroundColor: Colors.white,
                showLoadingAnimation: true,
                steps: steps,
                onStepReached: (index) => setState(() => activeStep = index),
              ),
            ),
            
            // Content Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKeys[activeStep],
                    child: Column(
                      children: [
                        _buildStepContent(activeStep),
                        const SizedBox(height: 100), // Extra space for keyboard
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous Button - Always Visible
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: activeStep > 0 ? () {
                  setState(() {
                    activeStep--;
                  });
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: activeStep > 0 ? Colors.grey.shade700 : Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(color: activeStep > 0 ? Colors.grey.shade300 : Colors.grey.shade200),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, size: 20),
                    SizedBox(width: 8),
                    Text('Previous', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            
            // Next/Submit Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [cyanblueColor, cyanblueColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cyanblueColor.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (formKeys[activeStep].currentState!.validate()) {
                    if (activeStep < upperBound) {
                      setState(() {
                        activeStep++;
                      });
                    } else {
                      // Submit registration
                      await _submitRegistration();
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      activeStep == upperBound ? 'Submit' : 'Next',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      activeStep == upperBound ? Icons.check : Icons.arrow_forward,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _buildPhoneAndFanStep();
      case 1:
        return _buildOtpVerificationStep();
      case 2:
        return _buildCompleteStep();
      default:
        return const Center(child: Text('Step not found'));
    }
  }

  Widget _buildPhoneAndFanStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone & FAN Number',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Enter your phone number and FAN number to receive OTP',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 30),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Phone Number',
              labelStyle: TextStyle(color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: cyanblueColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.red.shade300),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.phone, color: cyanblueColor),
              hintText: 'e.g., 0912345678',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 25),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'FAN Number',
              labelStyle: TextStyle(color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: cyanblueColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.red.shade300),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.credit_card, color: cyanblueColor),
              hintText: 'e.g., 1234567890123456',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your FAN number';
              }
              if (value.length < 16) {
                return 'Please enter a valid FAN number';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOtpVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OTP Verification',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Enter the 6-digit OTP sent to your phone number',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 30),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'OTP Code',
              labelStyle: TextStyle(color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: cyanblueColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.red.shade300),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.lock, color: cyanblueColor),
              hintText: 'e.g., 123456',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              counterText: '',
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the OTP code';
              }
              if (value.length != 6) {
                return 'Please enter a 6-digit OTP code';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Text(
              "Didn't receive OTP? ",
              style: TextStyle(color: Colors.grey),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement resend OTP
              },
              child: const Text(
                'Resend OTP',
                style: TextStyle(color: cyanblueColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompleteStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          size: 80,
          color: Colors.green,
        ),
        const SizedBox(height: 20),
        const Text(
          'Registration Complete!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Your National ID registration has been successfully completed.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            border: Border.all(color: Colors.green.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Column(
            children: [
              Icon(Icons.info_outline, color: Colors.green),
              SizedBox(height: 10),
              Text(
                'You will receive a confirmation SMS shortly.',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }



  Future<void> _submitRegistration() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: cyanblueColor,
        ),
      ),
    );

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Close loading dialog
    Navigator.pop(context);

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration Successful'),
        content: const Text('Your account registration has been submitted successfully. We will review your application and contact you soon.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 