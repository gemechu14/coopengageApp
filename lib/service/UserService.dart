import 'package:coopengageplus/helper/databaseHelper.dart';

class UserService {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    return await dbHelper.getAllCustomers();
  }
}
