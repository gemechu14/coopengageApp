// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'package:coopengageplus/common_widgets/text/custom_nav_heading.dart';
import 'package:coopengageplus/common_widgets/textField/reusable_text_field.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/features/crm/providers/high_profile_clients.dart';
import 'package:coopengageplus/features/hpc/Dashboard/dashboard.dart';
import 'package:coopengageplus/features/hpc/providers/meeting/meeting_provider.dart';
import 'package:coopengageplus/utils/language_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../../common_widgets/button/btn_gradient.dart';
import '../../../../common_widgets/textField/description_text_field.dart';
import '../../../../constants/app_sizes.dart';


class HPCFeedback extends ConsumerStatefulWidget {
  const HPCFeedback({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HPCFeedbackState();
}

class _HPCFeedbackState extends ConsumerState<HPCFeedback> {
  // For the dropdown of persons
  int? selectedPerson;
  final List<String> persons = ['John Doe', 'Jane Smith', 'Alex Brown'];

  bool isReminderEnabled = false; // Toggle state
  String? selectedReminderTime; // Store the selected reminder time
  List<String> reminderTimes = ["10", "30", "50"]; // Available reminder times
  final GlobalKey _globalKey = GlobalKey();
  // Text controllers
  TextEditingController descriptionController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  // Date and Time picker variables
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final DateTime _selectedDate = DateTime.now();
  final int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    final highProfileClients = ref.watch(highProfileClientsProvider);

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: CustomNavHeading(
          text: translation(context).feedback,
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: Padding(
          padding: EdgeInsets.all(Sizes.p12),
          child: SingleChildScrollView(
              child: Form(
                  key: _globalKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      gapH12,
                      InputTextField(
                        title: "Title",
                        hint: "Enter title",
                        textEditingController: titleController,
                        textInputType: TextInputType.multiline,
                      ),
                      gapH12,
                      DescriptionTextField(
                        title: "Description",
                        hint: "Enter your description",
                        textEditingController: descriptionController,
                        textInputType: TextInputType.multiline,
                        maxLines: 5, // Allow up to 5 lines.
                      ),
                    ],
                  )))),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        shape: const CircularNotchedRectangle(), // Optional notch for a FAB
        child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 26.0, vertical: 7.0),
            child: BtnGradient(
              text: "Create Feedback",
              action: () async {
                try {
                  final meetingP = ref.read(meetingProvider.notifier);
                  // final meeting = await meetingP.addMeeting(
                  //   highProfileCustomerId: selectedPerson as int,
                  //   token: AppConstants.access_token,
                  //   reason: descriptionController.text,
                  // );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Feedback is is requested successfully')),
                  );

                  await Future.delayed(const Duration(seconds: 1));
                  Get.offAll(() => HPCDashBoard());
                } catch (e) {
               
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add task: $e')),
                  );
                }
              },
            )),
      ),
    );
  }
}
