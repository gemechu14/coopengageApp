import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/features/onboarding/_IndividualAccount/widgets/steps/basic_info_step.dart';
import 'package:coopengageplus/features/onboarding/_IndividualAccount/widgets/steps/id_type_step.dart';
import 'package:coopengageplus/features/onboarding/_IndividualAccount/widgets/steps/signature_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/registration_data.dart';
import '../widgets/steps/step_account_type.dart';
import '../widgets/steps/step_terms_conditions.dart';
import '../widgets/registration_summary_dialog.dart';
import '../widgets/steps/step_financial_info.dart';
import 'package:coopengageplus/pages/MainPage.dart';
import '../widgets/steps/step_payment.dart';
import '../widgets/steps/step_personal_info.dart';
import '../widgets/steps/step_personal_photo.dart';
import '../widgets/steps/step_signature.dart';
import '../providers/registration_providers.dart';
import '../controllers/registration_controller.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _StepInfo {
  final String title;
  final Widget widget;
  final String stepNumber;

  const _StepInfo(this.title, this.widget, this.stepNumber);
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the registration process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reset any previous state
      ref.read(registrationControllerProvider).resetAllSteps();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(registrationStepProvider);
    final stepCompleted = ref.watch(stepCompletionProvider);
    final registrationData = ref.watch(registrationDataProvider);
    final isOnline = ref.watch(connectivityProvider);

    final steps = [
      _StepInfo('Basic Info', const BasicInfoStep(), '1/9'),
      _StepInfo('ID Type', const IdTypeStep(), '2/9'),
      _StepInfo('Signature', const SignatureStep(), '3/9'),
      _StepInfo('Personal Photo', const StepPersonalPhoto(), '4/9'),
      _StepInfo('Financial Information', const StepFinancialInfo(), '5/9'),
      _StepInfo('Personal Info', const StepPersonalInfo(), '6/9'),
      _StepInfo('Address Information', const StepPayment(), '7/9'),
      _StepInfo('Account Type', const StepAccountType(), '8/9'),
      _StepInfo('Terms & Conditions', const StepTermsConditions(), '9/9'),
    ];

    void _goToStep(int index) {
      // Check if this is the Terms & Conditions step (index 8)
      if (index == 8) {
        // Check if all previous steps are completed
        final allPreviousStepsCompleted = stepCompleted.take(8).every((completed) => completed);
        
        if (!allPreviousStepsCompleted) {
          // Show message that all previous steps must be completed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Please complete all previous steps before proceeding to Terms & Conditions',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.orange.shade600,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
          return;
        }
      }
      
      ref.read(registrationStepProvider.notifier).goToStep(index);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StepDetailScreen(
            stepIndex: index,
            currentStep: currentStep,
            steps: steps,
            onStepChanged: (newIndex) {
              ref.read(registrationStepProvider.notifier).goToStep(newIndex);
            },
            stepCompleted: stepCompleted,
            registrationData: registrationData,
            isOnline: isOnline,
          ),
        ),
      );
    }

    Widget _buildStepIcon(int index) {
      const double iconSize = 11;
      if (stepCompleted[index]) {
        return CircleAvatar(
          radius: iconSize,
          backgroundColor: cyanblueColor,
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 12,
          ),
        );
      } else if (index == currentStep) {
        return CircleAvatar(
          radius: iconSize,
          backgroundColor: Colors.blue,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: whiteColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
      } else {
        return CircleAvatar(
          radius: iconSize,
          backgroundColor: Colors.grey.shade400,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: graybackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
          color: cyanblueColor,
        ),
        titleSpacing: 0,
        title: const Text(
          'Customer Registration',
          style: TextStyle(color: cyanblueColor),
        ),
        backgroundColor: whiteColor,
      ),
      body: Column(
        children: [
          // Progress bar at the top
          Container(
            width: double.infinity,
            height: 4,
            color: Colors.grey.shade200,
            child: LinearProgressIndicator(
              value: stepCompleted.where((completed) => completed).length / 9,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(cyanblueColor),
            ),
          ),
          // Percentage display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stepCompleted.where((completed) => completed).isEmpty
                      ? 'Step ${currentStep + 1} of 9'
                      : 'Progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  '${((stepCompleted.where((completed) => completed).length / 9) * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: cyanblueColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Expanded(
            child: Container(
              color: graybackgroundColor,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  final isActive = index == currentStep;
                  final isCompleted = stepCompleted[index];
                  
                  // Check if this is the Terms & Conditions step (index 8)
                  final isTermsStep = index == 8;
                  
                  // Check if all previous steps are completed (for Terms step)
                  final allPreviousStepsCompleted = isTermsStep 
                      ? stepCompleted.take(8).every((completed) => completed)
                      : true;
                  
                  // Determine if step is clickable
                  final isClickable = !isTermsStep || allPreviousStepsCompleted;
                  
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: 1, left: 10, right: 10, top: 5),
                    child: Material(
                      color: isClickable ? whiteColor : Colors.grey.shade100,
                      elevation: isActive ? 4 : 1,
                      borderRadius: BorderRadius.circular(10),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        leading: _buildStepIcon(index),
                        minLeadingWidth: 28,
                        title: Text(
                          step.title,
                          style: TextStyle(
                            fontSize: 15,
                            color: isClickable 
                                ? (isCompleted ? blackColor : Colors.black87)
                                : Colors.grey.shade500,
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: isCompleted
                            ? Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: cyanblueColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : isTermsStep && !allPreviousStepsCompleted
                                ? Text(
                                    'Complete all previous steps ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : null,
                        trailing: Icon(
                          Icons.arrow_forward_ios, 
                          size: 10,
                          color: isClickable ? null : Colors.grey.shade400,
                        ),
                        onTap: isClickable ? () => _goToStep(index) : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatErrorMessages(Map<String, String?> validationErrors) {
    final errorMessages = validationErrors.values
        .where((error) => error != null && error.isNotEmpty)
        .map((error) => error!)
        .toList();

    if (errorMessages.isEmpty) return '';

    if (errorMessages.length == 1) {
      return errorMessages.first;
    }

    return errorMessages.join('\n• ');
  }

  Future<void> _completeRegistration(BuildContext context, WidgetRef ref,
      RegistrationController controller) async {
    final registrationData = ref.read(registrationDataProvider);
    
    // Show summary dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RegistrationSummaryDialog(
          registrationData: registrationData,
          onConfirm: () async {
            // Close the dialog
            Navigator.of(context).pop();
            
            // Submit the registration
            final success = await controller.submitRegistration(ref);

            if (!context.mounted) return;

            if (success) {
              // Show success message and navigate back to main screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Registration completed successfully!'),
                  backgroundColor: Colors.blueAccent,
                  duration: Duration(seconds: 3),
                ),
              );
              Navigator.pop(context); // Close step detail screen
              Navigator.pop(context); // Go back to main screen
            } else {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to complete registration. Please try again.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
          onCancel: () {
            // Just close the dialog and stay on the registration screen
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class StepDetailScreen extends ConsumerWidget {
  final int stepIndex;
  final int currentStep;
  final List<_StepInfo> steps;
  final ValueChanged<int> onStepChanged;
  final List<bool> stepCompleted;
  final RegistrationData registrationData;
  final bool isOnline;

  const StepDetailScreen({
    super.key,
    required this.stepIndex,
    required this.currentStep,
    required this.steps,
    required this.onStepChanged,
    required this.stepCompleted,
    required this.registrationData,
    required this.isOnline,
  });

  Widget _buildStepIcon(int index) {
    const double iconSize = 11;
    if (stepCompleted[index]) {
      return CircleAvatar(
        radius: iconSize,
        backgroundColor: cyanblueColor,
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 12,
        ),
      );
    } else if (index == currentStep) {
      return CircleAvatar(
        radius: iconSize,
        backgroundColor: Colors.blue,
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            color: whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: iconSize,
        backgroundColor: Colors.grey.shade400,
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = steps[stepIndex];
    final isActive = stepIndex == currentStep;
    final isCompleted = stepCompleted[stepIndex];
    final registrationController = ref.read(registrationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.blue,
            )),
        title: Row(
          children: [
            Text(
              step.title,
              style: TextStyle(
                fontSize: 17,
                color: isActive
                    ? Colors.blue
                    : isCompleted
                        ? Colors.blue
                        : Colors.black87,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isCompleted) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Completed',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      body: step.widget,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (stepIndex > 0)
              ElevatedButton.icon(
                onPressed: () {
                  onStepChanged(stepIndex - 1);
                  Navigator.pop(context);
                },
                label: const Text('Previous', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
              onPressed: () async {
                // Handle step completion based on current step
                bool canProceed = true;

                // Use the controller's validateAndSaveStep method for steps 0-7 and 8
                if (stepIndex <= 7 || stepIndex == 8) {
                  canProceed = await registrationController.validateAndSaveStep(
                      stepIndex, ref);

                  // Show validation errors in SnackBar if validation fails
                  if (!canProceed) {
                    final validationErrors = ref.read(formValidationProvider);
                    final errorMessage = _formatErrorMessages(validationErrors);

                    if (errorMessage.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Please fix the following errors:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                errorMessage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 4),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    }
                  }
                }

                if (canProceed && stepIndex < steps.length - 1) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${step.title} completed successfully!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: cyanblueColor,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                  onStepChanged(stepIndex + 1);
                  Navigator.pop(context);
                } else if (canProceed && stepIndex == steps.length - 1) {
                  // Final step - complete registration
                  await _completeRegistration(
                      context, ref, registrationController);
                }
              },
              icon: stepIndex == steps.length - 1
                  ? const Icon(Icons.check, size: 16)
                  : const Icon(Icons.arrow_forward, size: 16),
              label: Text(
                  stepIndex == steps.length - 1 ? 'Complete' : 'Continue',
                  style: const TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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
    );
  }

  String _formatErrorMessages(Map<String, String?> validationErrors) {
    final errorMessages = validationErrors.values
        .where((error) => error != null && error.isNotEmpty)
        .map((error) => error!)
        .toList();

    if (errorMessages.isEmpty) return '';

    if (errorMessages.length == 1) {
      return errorMessages.first;
    }

    return errorMessages.join('\n• ');
  }

  Future<void> _completeRegistration(BuildContext context, WidgetRef ref,
      RegistrationController controller) async {
    final registrationData = ref.read(registrationDataProvider);
    
    // Show summary dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RegistrationSummaryDialog(
          registrationData: registrationData,
          onConfirm: () async {
            // Close the dialog
            Navigator.of(context).pop();
            
            // Submit the registration
            final success = await controller.submitRegistration(ref);

            if (!context.mounted) return;

            if (success) {
              // Show success message and navigate back to main screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Registration completed successfully!'),
                  backgroundColor: Colors.blueAccent,
                  duration: Duration(seconds: 3),
                ),
              );
              Navigator.pop(context); // Close step detail screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
                (route) => false,
              );
            } else {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to complete registration. Please try again.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
          onCancel: () {
            // Just close the dialog and stay on the registration screen
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
