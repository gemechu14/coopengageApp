import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:coopengageplus/crm12/CRMMainScreen.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

class TextNote extends StatefulWidget {
  const TextNote({super.key});

  @override
  _TextNoteState createState() => _TextNoteState();
}

class _TextNoteState extends State<TextNote> {
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
  // For color selection
  Color selectedColor = Colors.blue;
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.brown,
    Colors.indigo,
  ];
  // Date and Time picker variables
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Text Note',
        ),
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
              TextLabel("Link Customer *"),
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
              TextLabel("Tag"),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: 16,
                        child: selectedColor == color
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
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
            "Create Text Note",
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
