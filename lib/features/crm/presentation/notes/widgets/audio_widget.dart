import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart'; // For audio recording
import 'package:path_provider/path_provider.dart'; // To get temporary directory

class RecordAudioWidget extends StatefulWidget {
  const RecordAudioWidget({Key? key}) : super(key: key);

  @override
  _RecordAudioWidgetState createState() => _RecordAudioWidgetState();
}

class _RecordAudioWidgetState extends State<RecordAudioWidget> {
  late FlutterSoundRecorder _recorder;
  bool isRecording = false;
  String formattedTime = "00:00:00";
  File? _audioFile;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  // Function to start recording
  void startRecording() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/recorded_audio.wav'; // Save as .wav or .mp3
      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.pcm16WAV,
      );
      setState(() {
        isRecording = true;
        _audioFile = File(filePath);
      });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  // Function to stop recording
  void stopRecording() async {
    try {
      await _recorder.stopRecorder();
      setState(() {
        isRecording = false;
      });
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  // Function to upload the audio file
  // void uploadNote() async {
  //   if (_audioFile != null) {
  //     // Call the addNote function with the audio file
  //     final newNote = await addNote(
  //       highProfileCustomerId: 1, // Replace with actual customer ID
  //       token: "your_token_here", // Replace with your actual token
  //       title: "Note Title",
  //       content: "Note Content",
  //       voiceNote: _audioFile, // Pass the recorded audio file
  //     );
  //     print("Note uploaded successfully: ${newNote.title}");
  //   } else {
  //     print("No audio file recorded.");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
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
          // const SizedBox(height: 16),
          // ElevatedButton(
          //   onPressed: uploadNote, // Upload the note with the recorded audio
          //   child: Text("Upload Note"),
          // ),
        ],
      ),
    );
  }
}
