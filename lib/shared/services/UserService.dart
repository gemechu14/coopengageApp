import 'package:coopengageplus/core/database/database_helper.dart';

class UserService {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    return await dbHelper.getAllCustomers();
  }
}
