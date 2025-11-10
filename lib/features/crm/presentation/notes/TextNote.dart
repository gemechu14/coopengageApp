// ignore_for_file: use_build_context_synchronously

import 'package:coopengageplus/features/crm/data/model/high_profile_clients/high_profile_clients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:coopengageplus/shared/widgets/button/btn_gradient.dart';
import 'package:coopengageplus/shared/widgets/textField/reusable_text_field.dart';
import 'package:coopengageplus/core/constants/app_sizes.dart';
import 'package:coopengageplus/core/config/config.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/core/constants/text_styles.dart';
import 'package:coopengageplus/features/crm/CRMMainScreen.dart';
import 'package:coopengageplus/features/crm/providers/high_profile_clients.dart';
import 'package:coopengageplus/features/crm/providers/notes/note_provider.dart';
import 'package:coopengageplus/core/utils/language_store.dart';

class TextNote extends ConsumerStatefulWidget {
  const TextNote({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TextNoteState();
}

class _TextNoteState extends ConsumerState<TextNote> {
  // For the dropdown of persons
  int? selectedPerson;

  final GlobalKey<FormState> _globalKey =
      GlobalKey<FormState>(); // Text controllers
  TextEditingController descriptionController = TextEditingController();
  TextEditingController titleController = TextEditingController();

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
  bool isDropDownEnabled = true;
  bool isSubmitted = false;
  @override
  void initState() {
    super.initState();
    final clientId = Get.arguments;
    selectedPerson = clientId ?? null;
    isDropDownEnabled = clientId != null ? false : true;
  }

  void submitForm() async {
    setState(() {
      isSubmitted = true;
    });
    try {
      final noteP = ref.read(noteProvider.notifier);
      print({selectedPerson});

      // Trigger form validation
      if (_globalKey.currentState?.validate() ?? false) {
        // All fields are valid
        final note = await noteP.addNote(
          highProfileCustomerId: selectedPerson as int,
          token: AppConstants.access_token,
          title: titleController.text,
          content: descriptionController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note added: ${note.title}')),
        );

        Get.to(() => CRMMainScreen(initialIndex: 2));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all the required fields')),
        );
      }
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add note: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final highProfileClients = ref.watch(highProfileClientsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: Text(
          translation(context).textNote,
          style: subHeadingStyle,
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: Padding(
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
              Text(
                "Tag",
                style: titleStyle,
              ),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 26.0, vertical: 7.0),
            child: BtnGradient(text: "Add Note", action: submitForm)),
      ),
    );
  }

  // Method to create a reusable TextFormField
}
