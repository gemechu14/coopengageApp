// import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Database Helper Implementation
class RegistrationDatabase {
  static Database? _database;
  static const String _tableName = 'customers';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'coopengage.db');

    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            phone TEXT,
            email TEXT,
            branch TEXT,
            documentName TEXT,
            residenceCard BLOB,
            residenceCardBack BLOB,
            signature BLOB,
            photo BLOB,
            occupation TEXT,
            monthlyIncome TEXT,
            initialDeposit TEXT,
            sector TEXT,
            country TEXT,
            issueAuthority TEXT,
            issueDate TEXT,
            expirayDate TEXT,
            legalId TEXT,
            state TEXT,
            zoneSubCity TEXT,
            streetAddress TEXT,
            accountType TEXT,
            currency TEXT,
            percentageCompleted REAL DEFAULT 0,
            status TEXT DEFAULT 'INITIAL',
            formCompleted INTEGER DEFAULT 0,
            userId TEXT,
            createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
            updatedAt TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  Future<int> insertCustomer(Map<String, dynamic> data) async {
    final db = await database;
    
    // Add timestamps
    final now = DateTime.now().toIso8601String();
    data['createdAt'] = now;
    data['updatedAt'] = now;
    
    try {
      final id = await db.insert(_tableName, data);
      return id;
    } catch (e) {
      throw Exception('Failed to insert customer: $e');
    }
  }

  Future<int> updateCustomer(int id, Map<String, dynamic> data) async {
    final db = await database;
    
    // Add updated timestamp
    data['updatedAt'] = DateTime.now().toIso8601String();
    
    try {
      final rowsAffected = await db.update(
        _tableName,
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (rowsAffected > 0) {
      } else {
     
      }
      
      return rowsAffected;
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  Future<Map<String, dynamic>?> getCustomer(int id) async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (results.isNotEmpty) {
        return results.first;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get customer: $e');
    }
  }

  Future<Map<String, dynamic>?> getCustomerByPhone(String phone) async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        where: 'phone = ?',
        whereArgs: [phone],
      );
      
      if (results.isNotEmpty) {
        return results.first;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get customer by phone: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    final db = await database;
    
    try {
      return await db.query(_tableName, orderBy: 'createdAt DESC');
    } catch (e) {
      throw Exception('Failed to get customers: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCustomersByStatus(String status) async {
    final db = await database;
    
    try {
      return await db.query(
        _tableName,
        where: 'status = ?',
        whereArgs: [status],
        orderBy: 'createdAt DESC',
      );
    } catch (e) {
      throw Exception('Failed to get customers by status: $e');
    }
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    
    try {
      final rowsAffected = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      return rowsAffected;
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Utility methods
  Future<int> getCustomerCount() async {
    final db = await database;
    
    try {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
      return result.first['count'] as int;
    } catch (e) {
      throw Exception('Failed to get customer count: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchCustomers(String query) async {
    final db = await database;
    
    try {
      return await db.query(
        _tableName,
        where: 'phone LIKE ? OR email LIKE ? OR branch LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'createdAt DESC',
      );
    } catch (e) {
      throw Exception('Failed to search customers: $e');
    }
  }

  Future<void> clearAllData() async {
    final db = await database;
    
    try {
      await db.delete(_tableName);
    } catch (e) {
      throw Exception('Failed to clear customer data: $e');
    }
  }
} 