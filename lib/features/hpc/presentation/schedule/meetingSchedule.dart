// ignore_for_file: use_build_context_synchronously

import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/features/crm/data/model/high_profile_clients/high_profile_clients.dart';
import 'package:coopengageplus/features/hpc/providers/meeting/meeting_provider.dart';
import 'package:coopengageplus/utils/language_store.dart';
import 'package:coopengageplus/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../common_widgets/button/btn_gradient.dart';
import '../../../../common_widgets/text/custom_nav_heading.dart';
import '../../../../common_widgets/textField/reusable_text_field.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/kconstant.dart';
import '../../../../constants/text_styles.dart';
import '../../../crm/providers/high_profile_clients.dart';


class MeetingSchedule extends ConsumerStatefulWidget {
  const MeetingSchedule({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MeetingScheduleState();
}

class _MeetingScheduleState extends ConsumerState<MeetingSchedule> {
  // For the dropdown of persons
  int? selectedPerson;
  final List<String> persons = ['John Doe', 'Jane Smith', 'Alex Brown'];

  bool isReminderEnabled = false; // Toggle state
  String? selectedReminderTime; // Store the selected reminder time
  List<String> reminderTimes = ["10", "30", "50"]; // Available reminder times
  final GlobalKey _globalKey = GlobalKey();
  // Text controllers
  TextEditingController descriptionController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  // Date and Time picker variables
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final DateTime _selectedDate = DateTime.now();
  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    final highProfileClients = ref.watch(highProfileClientsProvider);

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: CustomNavHeading(
          text: translation(context).newMeeting,
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
                      Text(
                        "CRM*",
                        style: titleStyle,
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.only(top: Sizes.p4),
                        padding: const EdgeInsets.only(left: Sizes.p8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(
                              Sizes.p12), // Match the border radius
                        ),
                        child: highProfileClients.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          data: (clients) => DropdownButtonFormField<int>(
                            value: selectedPerson,
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedPerson = newValue;
                              });
                            },
                            items: clients.map<DropdownMenuItem<int>>(
                                (HighProfileClientsModel client) {
                              return DropdownMenuItem<int>(
                                value: client.id,
                                child: Text(client.accHolderName),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              hintText: "Select Customer",
                              hintStyle: subtitleStyle,
                              isDense: true,
                              border: InputBorder.none, // Remove inner borders
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: Sizes.p8),
                            ),
                          ),
                          error: (error, stackTrace) => const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, color: Colors.red),
                                Text(
                                    "Failed to load CRM. Please try again later.",
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      gapH10,
                      gapH10,
                      InputTextField(
                        title: "Description",
                        hint: "Description",
                        textEditingController: descriptionController,
                        textInputType: TextInputType.multiline,
                      ),
                      gapH12,
                      Row(children: [
                        Expanded(
                          child: InputTextField(
                            title: "Date*",
                            // isDate: "true",
                            // dateAction: _setDateHandler,
                            hint: DateFormat.yMd().format(_selectedDate),

                            textEditingController: dateController,
                            textInputType: TextInputType.datetime,
                            widget: IconButton(
                              icon: Icon(Icons.calendar_today_outlined,
                                  color: Colors.grey[600]),
                              onPressed: () {
                                _setDateHandler(context);
                              },
                            ),
                          ),
                        ),
                        gapW16,
                        Expanded(
                          child: InputTextField(
                            title: "Time*",
                            // isDate: "true",
                            // dateAction: _setDateHandler,
                            hint: "Enter time (e.g. 03:30 PM)",

                            textEditingController: timeController,
                            textInputType: TextInputType.datetime,
                            widget: IconButton(
                              icon: Icon(Icons.access_time,
                                  color: Colors.grey[600]),
                              onPressed: () {
                                _setTimeHandler(context);
                              },
                            ),
                          ),
                        )
                      ]),
                      gapH10,
                      InputTextField(
                        title: "Address",
                        hint: "Address",
                        textEditingController: addressController,
                        textInputType: TextInputType.text,
                      ),
                      gapH12,
                      Container(
                        margin: const EdgeInsets.only(
                          top: Sizes.p4,
                        ),
                        padding: const EdgeInsets.all(Sizes.p4),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(Sizes.p12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with the 'Set Reminder' text and toggle switch
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Set Reminder",
                                    style: titleStyle,
                                  ),
                                  Switch(
                                    value: isReminderEnabled,
                                    activeColor: primaryBlue,
                                    onChanged: (bool value) {
                                      setState(() {
                                        isReminderEnabled = value;
                                        if (!isReminderEnabled) {
                                          selectedReminderTime =
                                              null; // Reset reminder time if off
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // Text and dropdown shown when reminder is enabled
                            if (isReminderEnabled)
                              const Padding(
                                padding: EdgeInsets.only(left: 10, top: 4),
                                child: Text(
                                  "Remind me Before",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ),
                            if (isReminderEnabled)
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 4),
                                child: DropdownButtonFormField<String>(
                                  value: reminderTimes.first,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedReminderTime = newValue;
                                    });
                                  },
                                  items: reminderTimes
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text('$value minutes'),
                                    );
                                  }).toList(),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            if (isReminderEnabled) const SizedBox(height: 15),
                          ],
                        ),
                      ),
                      gapH12,
                      Text(
                        "Color",
                        style: titleStyle,
                      ),
                      Wrap(
                        children: List<Widget>.generate(3, (int index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = index;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: Sizes.p8),
                              child: Container(
                                alignment: Alignment.center,
                                width: Sizes.p24,
                                height: Sizes.p24,
                                decoration: BoxDecoration(
                                    color: index == 0
                                        ? primaryBlue
                                        : index == 1
                                            ? yellowColor
                                            : Colors.orange,
                                    shape: BoxShape.circle),
                                child: _selectedColor == index
                                    ? const Icon(Icons.done,
                                        color: whiteColor, size: Sizes.p14)
                                    : const SizedBox(),
                              ),
                            ),
                          );
                        }),
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
              // Function to show time picker dialog
              color: primaryBlue,
              text: "Create Meeting",
              action: () async {
                try {
                  final meetingP = ref.read(meetingProvider.notifier);
                  final formattedTime =
                      convertTo24HourFormat(timeController.text);
                  final meeting = await meetingP.addMeeting(
                    highProfileCustomerId: selectedPerson as int,
                    token: AppConstants.access_token,
                    meetingDate: dateController.text,
                    meetingTime: formattedTime,
                    address: addressController.text,
                    reason: descriptionController.text,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Meeting created: ${meeting.reason}')),
                  );

                  // Get.to(() => Schedule());
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

  Padding dateWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: TextFormField(
        controller: dateController,
        onTap: () async {
          _setDateHandler(context);
        },
        decoration: const InputDecoration(
          hintText: "Date",
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Colors.black,
          ),
          suffixIcon: Icon(Icons.date_range),
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          // labelText: "Date of Birth *",
          labelStyle: TextStyle(fontSize: 15),
          isDense: true,
          // contentPadding: EdgeInsets.fromLTRB(
          //     20, 2, 2, 4), // Adjust the bottom value (40) for spacing
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
      ),
    );
  }

  Padding timeWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: TextFormField(
        controller: timeController,
        onTap: () async {
          _setTimeHandler(context);
        },
        decoration: const InputDecoration(
          hintText: "PickTime",
          hintStyle: TextStyle(
            fontSize: 13,
            color: Colors.black,
          ),
          suffixIcon: Icon(Icons.access_time),
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          labelStyle: TextStyle(fontSize: 15),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
      ),
    );
  }

  _setDateHandler(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(seconds: 1)),
      firstDate: DateTime(1950),
      lastDate: DateTime(2024, 12, 31),
    );
    if (picked != null) {
      {
        dateController.text = picked.toString().split(" ")[0];
      }
    }
  }

  Future<void> _setTimeHandler(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        timeController.text =
            picked.format(context); // Set the selected time in the text field
      });
    }
  }
}
