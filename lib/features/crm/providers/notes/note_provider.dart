import 'dart:io';

import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/features/crm/data/model/notes/note_model.dart';
import 'package:coopengageplus/features/crm/data/repo/notes_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'note_provider.g.dart';

@riverpod
class Note extends _$Note {
  late final NoteRepository _noteRepository = ref.read(noteRepositoryProvider);

  @override
  FutureOr<List<NoteModel>> build() async {
    final String token = AppConstants.access_token;
    return _noteRepository.getNotes(token: token);
  }

  FutureOr<NoteModel> addNote(
      {required int highProfileCustomerId,
      required String token,
      required String title,
      required String content,
      String? color,
      File? voiceNote}) async {
    final response = await _noteRepository.addNote(
        highProfileCustomerId: highProfileCustomerId,
        token: token,
        title: title,
        content: content,
        color: color,
        voiceNote: voiceNote);

    // Fetch the updated list of notes
    final updatedNotes = await _noteRepository.getNotes(token: token);

    // Update the state with the new list of notes
    state = AsyncData(updatedNotes);

    return response;
  }
}
