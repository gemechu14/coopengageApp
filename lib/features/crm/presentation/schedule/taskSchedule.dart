// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:coopengageplus/features/crm/data/model/high_profile_clients/high_profile_clients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import "package:get/get.dart";
import 'package:coopengageplus/common_widgets/button/btn_gradient.dart';
import 'package:coopengageplus/common_widgets/textField/reusable_text_field.dart';
import 'package:coopengageplus/constants/app_sizes.dart';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/constants/text_styles.dart';
import 'package:coopengageplus/features/crm/CRMMainScreen.dart';
import 'package:coopengageplus/features/crm/providers/high_profile_clients.dart';
import 'package:coopengageplus/features/crm/providers/task/task.dart';
import 'package:coopengageplus/utils/language_store.dart';
import 'package:coopengageplus/utils/time_utils.dart';

import '../../../../common_widgets/textField/textfield_with_icon.dart';

class Taskschedule extends ConsumerStatefulWidget {
  const Taskschedule({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskscheduleState();
}

class _TaskscheduleState extends ConsumerState<Taskschedule> {
  // For the dropdown of persons
  int? selectedPerson;
  final List<String> persons = ['John Doe', 'Jane Smith', 'Alex Brown'];
  DateTime _selectedDate = DateTime.now();
  bool isReminderEnabled = false; // Toggle state
  String? selectedReminderTime; // Store the selected reminder time
  List<String> reminderTimes = ["10", "30", "50"]; // Available reminder times
  final GlobalKey _globalKey = GlobalKey();
  // Text controllers
  TextEditingController descriptionController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  TextEditingController addressController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController remindController = TextEditingController();
  int _selectedColor = 0;
  // Date and Time picker variables
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isDropDownEnabled = true;

  @override
  void initState() {

    super.initState();
    final clientId = Get.arguments;
    selectedPerson = clientId ?? null;
    isDropDownEnabled = clientId != null ? false : true;
  }

  @override
  Widget build(BuildContext context) {
    final highProfileClients = ref.watch(highProfileClientsProvider);
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: Text(
          translation(context).newTask,
          style: subHeadingStyle,
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
                        "Link Customer*",
                        style: titleStyle,
                      ),
                      Container(
                          height: 50,
                          margin: const EdgeInsets.only(top: Sizes.p4),
                          padding: const EdgeInsets.only(
                              left: Sizes.p8, top: Sizes.p8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(Sizes.p12),
                          ),
                          child: highProfileClients.when(
                            loading: () => const CircularProgressIndicator(),
                            data: (clients) => DropdownButtonFormField<int>(
                              value: selectedPerson,
                              onChanged: isDropDownEnabled
                                  ? (int? newValue) {
                                      setState(() {
                                        selectedPerson =
                                            newValue; // Update the selected person ID
                                      });
                                    }
                                  : null,
                              items: clients.map<DropdownMenuItem<int>>(
                                  (HighProfileClientsModel client) {
                                return DropdownMenuItem<int>(
                                  value: client.id,
                                  child: Text(client.accHolderName),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                counterStyle: titleStyle,
                                hintText: "Select Customer",
                                hintStyle: subtitleStyle,
                                isDense: true,
                                border: InputBorder
                                    .none, // Removes the inner border of the dropdown
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                              ),
                            ),
                            error: (error, stackTrace) => const Text("Error"),
                          )),
                      gapH10,
                      InputTextField(
                        title: "Title",
                        hint: "Title",
                        textEditingController: titleController,
                        textInputType: TextInputType.multiline,
                      ),
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
                          child: TextfieldWithIcon(
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
                          child: TextfieldWithIcon(
                            title: "Time*",
                            // isDate: "true",
                            // dateAction: _setDateHandler,
                            hint: DateFormat.HOUR_MINUTE_TZ,

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
              text: "Create Task",
              action: () async {
                try {
                  final tasksP = ref.read(tasksProvider.notifier);
                  // print({selectedPerson});
                  final formattedTime =
                      convertTo24HourFormat(timeController.text);
                  final task = await tasksP.addTask(
                    highProfileCustomerId: selectedPerson as int,
                    token: AppConstants.access_token,
                    taskDate: dateController.text,
                    taskTime: formattedTime,
                    title: titleController.text,
                    address: addressController.text,
                    description: descriptionController.text,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task added successfully')),
                  );

                  Get.to(() => CRMMainScreen(initialIndex: 1));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add task: $e')),
                  );
                }
              },
            )),
      ),
    );
    //  InputTextField(
    //               title: "Remind*",
    //               // isDate: "true",
    //               // dateAction: _setDateHandler,
    //               hint: "$_selectRemind minutes",
    //               textEditingController: remindController,
    //               textInputType: TextInputType.text,
    //               widget: DropdownButton<String>(
    //                 iconSize: 32,
    //                 elevation: 4,
    //                 style: subtitleStyle,
    //                 underline: Container(height: 0),
    //                 icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
    //                 items: reminderTimes
    //                     .map<DropdownMenuItem<String>>((String value) {
    //                   return DropdownMenuItem<String>(
    //                     value: value,
    //                     child: Text(value),
    //                   );
    //                 }).toList(),
    //                 onChanged: (String? newValue) {
    //                   // Handle the selection
    //                 },
    //               )),
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
            color: Colors.grey,
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
            borderSide: BorderSide(color: blueColor),
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
            color: Colors.grey,
          ),
          suffixIcon: Icon(Icons.access_time),
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          labelStyle: TextStyle(fontSize: 15),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: blueColor),
          ),
        ),
      ),
    );
  }

  _setDateHandler(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(seconds: 1)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2024, 12, 31),
    );
    if (picked != null) {
      {
        dateController.text = picked.toString().split(" ")[0];
      }
    }
  }

  // Function to show time picker dialog
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

  ///
  Padding TextLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 13, // You can customize the text style here
            fontWeight: FontWeight.normal,
            color: Colors.grey),
      ),
    );
  }
}
