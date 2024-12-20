import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:coopengageplus/crm12/CRMMainScreen.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

class MeetingSchedule extends StatefulWidget {
  const MeetingSchedule({super.key});

  @override
  _MeetingScheduleState createState() => _MeetingScheduleState();
}

class _MeetingScheduleState extends State<MeetingSchedule> {
  // For the dropdown of persons
  String? selectedPerson;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Meeting'),
        leading: IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CRMMainScreen(),
                  ),
                  (route) => false);
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _globalKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextLabel("Select Customer *"),
              DropdownButtonFormField<String>(
                value: selectedPerson,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPerson = newValue;
                  });
                },
                items: persons.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  hintText: "Select Customer",

                  isDense: true,
                  // contentPadding:
                  //     const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              TextLabel("Description"),
              reusableTextFormField(
                hintText: "Description",
                controller: descriptionController,
                // errorMessage: "e cannot be empty",
                // leadingIcon: Icons.person,
              ),
              TextLabel("Date*"),
              dateWidget(),
              TextLabel("Time*"),
              timeWidget(),
              TextLabel("Address"),
              reusableTextFormField(
                hintText: "Address",
                controller: addressController,
                // errorMessage: "e cannot be empty",
                // leadingIcon: Icons.person,
              ),
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 1.0, vertical: 1.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Toggle for reminder
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Set Reminder',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black),
                            ),
                            Switch(
                              value: isReminderEnabled,
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
                      if (isReminderEnabled)
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            "Remind me Before",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      // Dropdown for reminder time, shown when toggle is on
                      if (isReminderEnabled)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          child: DropdownButtonFormField<String>(
                            value: reminderTimes.first,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedReminderTime = newValue;
                              });
                            },
                            items: reminderTimes
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text('$value minutes'),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              // labelText: 'Select Reminder Time',
                              isDense: true,
                              border: InputBorder.none, // Removes all borders
                              enabledBorder: InputBorder
                                  .none, // Removes border when enabled
                              focusedBorder: InputBorder
                                  .none, // Removes border when focused
                              errorBorder:
                                  InputBorder.none, // Removes border on error
                            ),
                            // decoration: const InputDecoration(
                            //   // labelText: 'Select Reminder Time',
                            //   isDense: true,
                            //   // border: OutlineInputBorder(
                            //   //   borderRadius:
                            //   //       BorderRadius.all(Radius.circular(5)),
                            //   // ),
                            //   enabledBorder: OutlineInputBorder(
                            //     borderRadius:
                            //         BorderRadius.all(Radius.circular(5)),
                            //     borderSide: BorderSide(color: Colors.black),
                            //   ),
                            //   focusedBorder: OutlineInputBorder(
                            //     borderRadius:
                            //         BorderRadius.all(Radius.circular(5)),
                            //     borderSide: BorderSide(color: Colors.blue),
                            //   ),
                            // ),
                          ),
                        ),
                      if (isReminderEnabled)
                        const SizedBox(
                          height: 15,
                        ),
                    ],
                  ),
                ),
              ),

              // const SizedBox(
              //   height: 8,
              // ),
              // // Toggle for reminder
              // Padding(
              //   padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
              //   child: TextFormField(
              //     readOnly: true,
              //     decoration: InputDecoration(
              //       hintText: "Set Reminder",
              //       hintStyle: const TextStyle(
              //           fontWeight: FontWeight.bold,
              //           fontSize: 16,
              //           color: Colors.black),
              //       isDense: true,
              //       suffixIcon: Switch(
              //         value: isReminderEnabled,
              //         onChanged: (bool value) {
              //           setState(() {
              //             isReminderEnabled = value;
              //             if (!isReminderEnabled) {
              //               selectedReminderTime =
              //                   null; // Reset when toggled off
              //             }
              //           });
              //         },
              //       ),
              //       border: const OutlineInputBorder(
              //         borderRadius: BorderRadius.all(Radius.circular(5)),
              //       ),
              //       enabledBorder: const OutlineInputBorder(
              //         borderRadius: BorderRadius.all(Radius.circular(5)),
              //         borderSide: BorderSide(color: Colors.black),
              //       ),
              //       focusedBorder: const OutlineInputBorder(
              //         borderRadius: BorderRadius.all(Radius.circular(5)),
              //         borderSide: BorderSide(color: Colors.blue),
              //       ),
              //     ),
              //   ),
              // ),
              // // SwitchListTile(
              // //   title: const Text('Set Reminder'),
              // //   value: isReminderEnabled,
              // //   dense: true,
              // //   onChanged: (bool value) {
              // //     setState(() {
              // //       isReminderEnabled = value;
              // //       if (!isReminderEnabled) {
              // //         selectedReminderTime = null; // Reset if toggled off
              // //       }
              // //     });
              // //   },
              // // ),

              // if (isReminderEnabled) TextLabel("Remind me Before"),
              // // const Align(
              // //   alignment: Alignment.topLeft,
              // //   child: Text(
              // //     'Remind me before',
              // //     style: TextStyle(fontSize: 16),
              // //   ),
              // // ),
              // const SizedBox(height: 10),

              // // Dropdown for reminder time (only shows when reminder is enabled)
              // if (isReminderEnabled)
              //   Padding(
              //     padding: const EdgeInsets.only(left: 7, right: 7),
              //     child: DropdownButtonFormField<String>(
              //       value: selectedReminderTime,
              //       onChanged: (String? newValue) {
              //         setState(() {
              //           selectedReminderTime = newValue;
              //         });
              //       },
              //       items: reminderTimes
              //           .map<DropdownMenuItem<String>>((String value) {
              //         return DropdownMenuItem<String>(
              //           value: value,
              //           child: Text('$value minutes'),
              //         );
              //       }).toList(),
              //       decoration: const InputDecoration(
              //         // labelText: "Select Reminder Time",
              //         isDense: true,

              //         border: OutlineInputBorder(
              //           borderRadius: BorderRadius.all(Radius.circular(5)),
              //         ),
              //         enabledBorder: OutlineInputBorder(
              //           borderRadius: BorderRadius.all(Radius.circular(5)),
              //           borderSide: BorderSide(color: Colors.black),
              //         ),
              //         focusedBorder: OutlineInputBorder(
              //           borderRadius: BorderRadius.all(Radius.circular(5)),
              //           borderSide: BorderSide(color: Colors.blue),
              //         ),
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        shape: const CircularNotchedRectangle(), // Optional notch for a FAB
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 7.0),
          child: FormHelper.submitButton(
            "Create Meeting",
            fontSize: 15,
            fontWeight: FontWeight.normal,
            width: MediaQuery.of(context).size.width * 0.5,
            btnColor: Colors.blueAccent,
            borderColor: Colors.blueAccent,
            () async {},
          ),
        ),
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

  // Method to create a reusable TextFormField
  Padding reusableTextFormField({
    required String hintText,
    required TextEditingController controller,
    String? errorMessage,
    IconData? leadingIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: Container(
        width: width < 600 ? double.infinity : width * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                ),
                labelStyle: const TextStyle(fontSize: 5),
                isDense: true,
                // contentPadding:
                //     const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                errorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(color: Colors.red),
                ),
                prefixIcon: leadingIcon != null ? Icon(leadingIcon) : null,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return errorMessage ?? 'This field is required';
                }
                // return errorMessage; // Return the error message if exists
              },
            ),
          ],
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
