import 'dart:io';

import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/features/crm/data/model/notes/note_model.dart';
import 'package:coopengageplus/features/crm/data/repo/notes_repo.dart';
import 'package:coopengageplus/features/providers/token_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'note_provider.g.dart';

@riverpod
class Note extends _$Note {
  late final NoteRepository _noteRepository = ref.read(noteRepositoryProvider);
  late final tokenAsyncValue = ref.watch(tokenProvider);
  @override
  FutureOr<List<NoteModel>> build() async {
    final String token = AppConstants.access_token;
    return _noteRepository.getNotes(token: token
        //tokenAsyncValue.toString()

        );
  }
  // FutureOr<List<NoteModel>> build() async {
  //   final tokenAsyncValue = ref.watch(tokenProvider);

  //   return tokenAsyncValue.when(
  //     data: (token) {
  //       if (token != null) {
  //         return _noteRepository.getNotes(token: token.toString());
  //       } else {
  //         throw Exception('Token is null');
  //       }
  //     },
  //     loading: () => Future.value([]),
  //     error: (error, stack) =>
  //         Future.error(error),
  //   );
  // }

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

    state = AsyncData(updatedNotes);

    return response;
  }
}
