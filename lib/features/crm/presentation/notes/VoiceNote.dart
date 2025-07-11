// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:coopengageplus/common_widgets/button/btn_gradient.dart';
import 'package:coopengageplus/common_widgets/textField/reusable_text_field.dart';
import 'package:coopengageplus/constants/app_sizes.dart';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/constants/text_styles.dart';
import 'package:coopengageplus/features/crm/CRMMainScreen.dart';
import 'package:coopengageplus/features/crm/providers/notes/note_provider.dart';
import 'package:coopengageplus/features/hpc/providers/high_profile/high_profile_clients.dart';
import 'package:coopengageplus/utils/language_store.dart';

class VoiceNote extends ConsumerStatefulWidget {
  const VoiceNote({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VoiceNoteState();
}

class _VoiceNoteState extends ConsumerState<VoiceNote> {
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
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController voiceController = TextEditingController();

  // Date and Time picker variables
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  bool isRecording = false;
  int recordDuration = 0;
  Timer? timer;

  int recordingSeconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startRecording() {
    setState(() {
      isRecording = true;
      recordingSeconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        recordingSeconds++;
      });
    });
  }

  void stopRecording() {
    setState(() {
      isRecording = false;
    });
    _timer?.cancel();
  }

  String get formattedTime {
    final minutes = recordingSeconds ~/ 60;
    final seconds = recordingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool isDropDownEnabled = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final clientId = Get.arguments;
    selectedPerson = clientId ?? null;
    isDropDownEnabled = clientId != null ? false : true;
  }

  @override
  Widget build(BuildContext context) {
    final highProfileClients = ref.watch(highProfileClientsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: Text(
          translation(context).voiceNote,
          style: subHeadingStyle,
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                    margin: EdgeInsets.only(top: Sizes.p4),
                    padding: EdgeInsets.only(left: Sizes.p8, top: Sizes.p8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(Sizes.p12),
                    ),
                    child: highProfileClients.when(
                      loading: () => CircularProgressIndicator(),
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
                        // items: clients.map<DropdownMenuItem<int>>(
                        //     (HighProfileClientsModel client) {
                        //   return DropdownMenuItem<int>(
                        //     value: client.id,
                        //     child: Text(client.accHolderName),
                        //   );
                        // }).toList(),
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
                        items: [],
                      ),
                      error: (error, stackTrace) => Text("Error"),
                    )),
                gapH10,
                InputTextField(
                  title: "Title",
                  hint: "Title",
                  textEditingController: titleController,
                  errorMessage: "Title is required",
                  isRequired: true,
                  textInputType: TextInputType.text,
                ),
                gapH12,
                InputTextField(
                  title: "Description",
                  hint: "Description",
                  textEditingController: descriptionController,
                  errorMessage: "Description is required",
                  isRequired: true,
                  textInputType: TextInputType.text,
                ),
                gapH12,
                // RecordAudioWidget(),
                // Recording Section
                Center(
                  child: Column(
                    children: [
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isRecording
                            ? "Recording..."
                            : "Tap on Record button to start recording",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        iconSize: 60,
                        icon: Icon(
                          isRecording ? Icons.stop_circle : Icons.mic,
                          color: isRecording ? Colors.red : Colors.blue,
                        ),
                        onPressed: () {
                          if (isRecording) {
                            stopRecording();
                          } else {
                            startRecording();
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isRecording ? "Stop" : "Record",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        shape: const CircularNotchedRectangle(), // Optional notch for a FAB
        child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 26.0, vertical: 7.0),
            child: BtnGradient(
              text: "Add Note",
              action: () async {
                try {
                  final noteP = ref.read(noteProvider.notifier);
                  print({selectedPerson});

                  final note = await noteP.addNote(
                    highProfileCustomerId: selectedPerson as int,
                    token: AppConstants.access_token,
                    title: titleController.text,
                    content: descriptionController.text,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('note added: ${note.title}')),
                  );

                  Get.to(() => CRMMainScreen(initialIndex: 2));
                } catch (e) {
                  print(e);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add note: $e')),
                  );
                }
              },
            )),
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

  // // Function to show time picker dialog
  // Future<void> _setTimeHandler(BuildContext context) async {
  //   final TimeOfDay? picked = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay.now(),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       timeController.text =
  //           picked.format(context); // Set the selected time in the text field
  //     });
  //   }
  // }

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
