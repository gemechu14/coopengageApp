import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:coopengageplus/crm12/TextNote.dart';
import 'package:coopengageplus/crm12/VoiceNote.dart';

class Notescreen extends StatefulWidget {
  const Notescreen({super.key});

  @override
  State<Notescreen> createState() => _NotescreenState();
}

class _NotescreenState extends State<Notescreen> {
  TextEditingController searchController = TextEditingController();
  List<String> notes = [];
  List<String> filteredNotes = [];

  @override
  void initState() {
    super.initState();
    filteredNotes = notes;
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notes",
          style: TextStyle(
              fontSize: 21, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search notes...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _filterNotes,
            ),
          ),
          Expanded(
            child: filteredNotes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
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
                : ListView.builder(
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredNotes[index]),
                        leading: const Icon(Icons.note),
                        onTap: () {
                          print("Tapped on note: ${filteredNotes[index]}");
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
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
    );
  }
}
