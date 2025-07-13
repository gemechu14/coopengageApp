// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:coopengageplus/common_widgets/textField/search_field.dart';
import 'package:coopengageplus/constants/app_sizes.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/features/crm/presentation/notes/TextNote.dart';
import 'package:coopengageplus/features/crm/presentation/notes/VoiceNote.dart';

import 'package:coopengageplus/features/crm/presentation/notes/widgets/notes_card.dart';
import 'package:coopengageplus/features/crm/providers/notes/note_provider.dart';
import 'package:coopengageplus/utils/language_store.dart';
// import 'package:coopengageplus/Screen/TextNote.dart';
// import 'package:coopengageplus/Screen/VoiceNote.dart';
// import 'package:coopengageplus/Screen/meetingSchedule.dart';
// import 'package:coopengageplus/Screen/taskSchedule.dart';

class Notescreen extends ConsumerStatefulWidget {
  const Notescreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotescreenState();
}

class _NotescreenState extends ConsumerState<Notescreen> {
  TextEditingController searchController = TextEditingController();
  List<String> notes = []; // Initialize with an empty list of notes
  List<String> filteredNotes = [];

  @override
  void initState() {
    super.initState();
    filteredNotes = notes; // Initialize filtered notes
  }

  // Function to filter notes based on search query
  void _filterNotes(String query) {
    final results = notes
        .where((note) => note.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredNotes = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(noteProvider);
    print({notes});
    return Scaffold(
      backgroundColor: lightBG,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          translation(context).notes,
          style: TextStyle(
              fontSize: 21, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          // Search bar
          SearchField(),
          // Conditional content for notes or empty state
          gapH16,
          notes.when(
              loading: () => Center(child: CircularProgressIndicator()),
              data: (note) => note.length == 0
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_add_outlined,
                            size: 100,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "No notes available",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: note.map((nt) {
                        return NoteCard(
                          title: nt.title,
                          content: nt.content,
                          // color: nt.color != null
                          //     ? Color(int.parse(nt.color as String))
                          //     : Colors.blue,
                        );
                      }).toList(),
                    ),
              error: (err, stk) => Text("Error fetching notes")),
        ],
      )),

      // Floating Action Button with Speed Dial
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.blue,
        icon: Icons.add,
        activeIcon: Icons.close,
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            shape: const StadiumBorder(),
            backgroundColor: const Color.fromARGB(255, 49, 114, 167),
            child: const Icon(Icons.task, color: Colors.white),
            label: "Text Note",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TextNote(),
                ),
              );
            },
          ),
          SpeedDialChild(
            backgroundColor: const Color.fromARGB(255, 75, 17, 137),
            shape: const StadiumBorder(),
            child: const Icon(Icons.mic, color: Colors.white),
            label: "Voice Note",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoiceNote(),
                ),
              );
            },
          ),
        ],
      ),
      // bottomNavigationBar: GoogleButtomNavBar(showBottomNavBar: true),
    );
  }
}
