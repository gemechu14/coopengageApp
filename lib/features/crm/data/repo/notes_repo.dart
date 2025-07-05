// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/features/crm/data/model/notes/note_model.dart';

abstract class NoteRepo {
  Future<List<NoteModel>> getNotes({required String token});
  Future<NoteModel> addNote(
      {required int highProfileCustomerId,
      required String token,
      required String title,
      required String content,
      String? color,
      File? voiceNote});
}

final noteRepositoryProvider = Provider(NoteRepository.new);

class NoteRepository implements NoteRepo {
  final Ref _ref;

  NoteRepository(this._ref);

  @override
  Future<List<NoteModel>> getNotes({required String token}) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/notes');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Access-Control_Allow_Origin": "*",
          "accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP error: ${response.statusCode}');
      }

      // Decode response
      final List<dynamic> jsonData = json.decode(response.body);

      // Parse into a list of models
      final List<NoteModel> notes =
          jsonData.map((data) => NoteModel.fromJson(data)).toList();

      return notes;
    } catch (e, stackTrace) {
      log('Error in getNotes: $e', stackTrace: stackTrace);
      print(e);
      throw Exception('Failed to load notes');
    }
  }

  @override
  // Future<NoteModel> addNote(
  //     {required int highProfileCustomerId,
  //     required String token,
  //     required String title,
  //     required String content,
  //     String? color,
  //     File? voiceNote}) async {
  //   try {
  //     final url = Uri.parse('${AppConstants.baseUrl}/notes');
  //     final body = {
  //       "highProfileCustomerId": highProfileCustomerId,
  //       "title": title,
  //       "content": content,
  //       "color": color ?? "",
  //       "voiceNote": voiceNote ?? null
  //     };
  //     var request = http.MultipartRequest('POST', url);

  //     // Add headers
  //     request.headers.addAll(
  //         {"Access-Control-Allow-Origin": "*", "accept": "application/json"});

  //     // Add form fields
  //     request.fields['highProfileCustomerId'] =
  //         highProfileCustomerId.toString();
  //     request.fields['title'] = title;
  //     request.fields['content'] = content;
  //     request.fields['color'] = color ?? "";

  //     // Add a file as form-data
  //     var file = await http.MultipartFile.fromPath(
  //       'voiceNote', // The form field name, should match the server expectation
  //       'path/to/your/file.mp3', // Replace with actual file path
  //       contentType: MediaType('audio', 'mp3'), // Set content type if needed
  //     );
  //     request.files.add(voiceNote??null);
  //     print("Request body: ${jsonEncode(body)}");
  //     final response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Access-Control_Allow_Origin": "*",
  //         "accept": "application/json",
  //         "Authorization": "Bearer $token",
  //       },
  //     );

  //     if (response.statusCode != 201) {
  //       throw Exception('HTTP error: ${response.statusCode}');
  //     }

  //     final responseData = json.decode(response.body) as Map<String, dynamic>;
  //     final newNote = NoteModel.fromJson(responseData);
  //     print(responseData);
  //     return newNote;
  //   } catch (e, stackTrace) {
  //     log('Error creating a Note: $e', stackTrace: stackTrace);
  //     print(e);
  //     print(stackTrace);
  //     throw Exception('Failed to create Note');
  //   }
  // }

  Future<NoteModel> addNote({
    required int highProfileCustomerId,
    required String token,
    required String title,
    required String content,
    String? color,
    File? voiceNote,
  }) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/notes');

      // Create multipart request
      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers.addAll({
        "Access-Control-Allow-Origin": "*",
        "accept": "application/json",
        "Authorization": "Bearer $token", // Ensure the token is added for auth
      });

      // Add form fields (non-file fields)
      request.fields['highProfileCustomerId'] =
          highProfileCustomerId.toString();
      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['color'] = color ?? "";

      // If a file is present, add it as form-data
      if (voiceNote != null) {
        var file = await http.MultipartFile.fromPath(
          'voiceNote', // Form field name (should match server's expected field name)
          voiceNote.path, // Path to the actual file
          contentType:
              MediaType('audio', 'mp3'), // Adjust content type if needed
        );
        request.files.add(file);
      }

      // Send the request
      final response = await request.send();

      // Check the status code of the response
      if (response.statusCode != 200) {
        throw Exception('HTTP error: ${response.statusCode}');
      }

      // Read the response data and parse the returned JSON
      final responseData = await response.stream.bytesToString();
      final responseJson = json.decode(responseData) as Map<String, dynamic>;

      // Convert the response JSON into a NoteModel object
      final newNote = NoteModel.fromJson(responseJson);

      print(responseJson); // Log the response for debugging
      return newNote;
    } catch (e, stackTrace) {
      log('Error creating a Note: $e', stackTrace: stackTrace);
      print(e);
      print(stackTrace);
      throw Exception('Failed to create Note');
    }
  }
}
