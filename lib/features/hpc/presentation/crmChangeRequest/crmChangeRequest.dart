import 'package:coopengageplus/shared/widgets/button/btn_gradient.dart';
import 'package:coopengageplus/shared/widgets/text/custom_nav_heading.dart';
import 'package:coopengageplus/shared/widgets/textField/description_text_field.dart';
import 'package:coopengageplus/shared/widgets/textField/reusable_text_field.dart';
import 'package:coopengageplus/core/constants/app_sizes.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/features/hpc/Dashboard/dashboard.dart';
import 'package:coopengageplus/core/utils/language_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class HPCCRMChangeRequest extends ConsumerStatefulWidget {
  const HPCCRMChangeRequest({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HPCCRMChanfeRequestState();
}

class _HPCCRMChanfeRequestState extends ConsumerState<HPCCRMChangeRequest> {
  final GlobalKey _globalKey = GlobalKey();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    // final highProfileClients = ref.watch(highProfileClientsProvider);

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: CustomNavHeading(
          text: translation(context).crmchangerequest,
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: Padding(
          padding: const EdgeInsets.all(Sizes.p12),
          child: SingleChildScrollView(
              child: Form(
                  key: _globalKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      gapH12,
                      InputTextField(
                        title: "Reason",
                        hint: "Enter Reason",
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
              text: "Submit",
              action: () async {
                try {
                  // final meetingP = ref.read(meetingProvider.notifier);
                  // final meeting = await meetingP.addMeeting(
                  //   highProfileCustomerId: selectedPerson as int,
                  //   token: AppConstants.access_token,
                  //   reason: descriptionController.text,
                  // );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Submitted successfully')),
                  );
                  await Future.delayed(const Duration(seconds: 1));
                  Get.offAll(() => HPCDashBoard());
                } catch (e) {
                  print(e);
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
