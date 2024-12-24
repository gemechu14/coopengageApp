import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Create a provider that fetches the token from the database
final tokenProvider = FutureProvider<String?>((ref) async {
  DatabaseHelper db = DatabaseHelper();
  final List<Map<String, dynamic>> result = await db.getAuthToken();
  if (result.isNotEmpty) {
    return result.first['token'] as String?;
  }
  return null; // Return null if no token is found
});
