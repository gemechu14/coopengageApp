import 'dart:typed_data';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'my_database.db');
    return await openDatabase(
      path,
      version: 2, // Incremented version for schema changes
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            password TEXT NOT NULL,
            clientId TEXT,
            userId INTEGER UNIQUE,
            token  TEXT,
            role TEXT
          )
        ''');

        // Create Branches table
        await db.execute('''
          CREATE TABLE Branches(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            branchName TEXT NOT NULL,
            branchCode TEXT NOT NULL,
            companyName TEXT
          )
        ''');

        // Create UserBranches table for many-to-many relationship
        await db.execute('''
          CREATE TABLE UserBranches(
            userId INTEGER,
            branchId INTEGER,
            PRIMARY KEY (userId, branchId),
            FOREIGN KEY (userId) REFERENCES Users(userId),
            FOREIGN KEY (branchId) REFERENCES Branches(id)
          )
        ''');

        ///ACCOUNT TYPE
        await db.execute('''
  CREATE TABLE AccountTypes(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    minAge TEXT ,
    maxAge TEXT ,
    minAmount TEXT,
    sex TEXT ,
    bankingType TEXT NOT NULL
  ) 
''');

        await db.execute('''
CREATE TABLE monthlytargets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  achievements REAL NOT NULL,
  target REAL NOT NULL
)
''');

        await db.execute('''
CREATE TABLE auth_tokens  (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  token TEXT NOT NULL

)
''');

        await db.execute('''
CREATE TABLE selected_language  (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  language_code TEXT NOT NULL

)
''');
        await db.execute('''CREATE TABLE Customers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firstName TEXT,
            fullName TEXT,
            surName TEXT,
            sex TEXT,  
            motherName TEXT,
            phoneNumber TEXT,
            email TEXT,
            gender TEXT,
            address TEXT,
            streetAddress TEXT,
            street TEXT,
            state TEXT,
            residenceAddress TEXT,
            nationality TEXT,
            country TEXT,
            city TEXT,
            zipCode TEXT,
            accountCurrency TEXT,
            currency TEXT,
            status TEXT,
            occupation TEXT,
            initialDeposit REAL,
            monthlyIncome REAL,
            branch TEXT,
            formCompleted INTEGER,
            accountType TEXT,
            dateOfBirth TEXT,
            residenceCard BLOB,
            residenceCardBack  BLOB,
            dateOfEstablishment  TEXT,
            percentageCompleted INTEGER,
            passport BLOB,
            photo BLOB,
            legalId  TEXT,
            signature BLOB,
            date TEXT,
            phone TEXT,
            customerType TEXT,            
            documentType  TEXT,
            documentName TEXT,
            issueAuthority TEXT,
            issueDate TEXT,
            zoneSubCity TEXT,
            title TEXT,
            maritalStatus TEXT,
            expirayDate TEXT,

            userId TEXT
          )''');
      },
      // onUpgrade: (db, oldVersion, newVersion) async {
      //   if (oldVersion < 2) {
      //     // Add the 'sex' column in this upgrade
      //     await db.execute('ALTER TABLE Customers ADD COLUMN sex TEXT');
      //   }
      // },
    );
  }

//FETCH CHECK  ACCOUNT
  Future<bool> isAccountTypeTableEmpty() async {
    final db = await database;
    final result = await db.query('AccountTypes');
    return result.isEmpty;
  }

  // Future<void> insertAccountTypes(
  //     List<Map<String, dynamic>> accountTypes) async {
  //   final db = await database;

  //   for (var accountType in accountTypes) {
  //     await db.insert(
  //       'AccountTypes',
  //       {
  //         "id": accountType["id"],
  //         "name": accountType["name"],
  //         "type": accountType["type"],
  //         "minAge": accountType["minAge"] ?? "",
  //         "maxAge": accountType["maxAge"] ?? "",
  //         "minAmount": accountType["minAmount"] ?? "",
  //         "sex": accountType["sex"] ?? "",
  //         "bankingType": accountType["bankingType"],
  //       },
  //       conflictAlgorithm: ConflictAlgorithm.replace, // Prevent duplicates
  //     );
  //   }
  // }

  Future<void> insertAccountTypes(
      List<Map<String, dynamic>> accountTypes) async {
    final db = await database;

    for (var accountType in accountTypes) {
      // Ensure proper encoding or sanitization of the 'name' field
      String name = accountType["name"];

      // Handle any special characters or sanitize if necessary
      name = sanitizeSpecialCharacters(name);

      await db.insert(
        'AccountTypes',
        {
          "id": accountType["id"],
          "name": name,
          "type": accountType["type"],
          "minAge": accountType["minAge"] ?? "",
          "maxAge": accountType["maxAge"] ?? "",
          "minAmount": accountType["minAmount"] ?? "",
          "sex": accountType["sex"] ?? "",
          "bankingType": accountType["bankingType"],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  String sanitizeSpecialCharacters(String name) {
    name = name.replaceAll('’', '');
    name = name.replaceAll(
        RegExp(r'[^\x00-\x7F]+'), ''); // Remove non-ASCII characters

    return name;
  }

  //GET ALL ACCOUNT TYPE
  Future<List<Map<String, dynamic>>> getAllAccountTypes() async {
    final db = await database;
    return await db.query('AccountTypes');
  }

  Future<int?> insertCustomer(Map<String, dynamic> customer) async {
    if (await isTableCreated('Customers')) {
      final db = await database;
      return await db.insert('Customers', customer);
    } else {
      print("Customers table does not exist.");
      return null;
    }
  }

  Future<bool> syncCustomersToServer(
      List<Map<String, dynamic>> customers, String token) async {
    const url = '${AppConstants.baseUrl}/accounts/bulk/individual';
    Map<String, String> requestBody = {};

    for (var i = 0; i < customers.length; i++) {
      requestBody['accounts[$i].customerInfo.fullName'] =
          customers[i]['fullName']?.toString() ?? '';
      requestBody['accounts[$i].customerInfo.surname'] =
          customers[i]['surname']?.toString() ?? '';
      requestBody['accounts[$i].customerInfo.phone'] =
          customers[i]['phone']?.toString() ?? '';
      requestBody['accounts[$i].customerInfo.email'] =
          customers[i]['email']?.toString() ?? '';
      requestBody['accounts[$i].customerInfo.motherName'] =
          customers[i]['motherName']?.toString() ?? '';
      requestBody['accounts[$i].customerInfo.sex'] =
          customers[i]['sex']?.toString() ?? '';
      requestBody['accounts[$i].customerInfo.streetAddress'] =
          customers[i]['streetAddress']?.toString() ?? '';
      requestBody['accounts[$i].customerInfo.city'] =
          customers[i]['city']?.toString() ?? '';
      requestBody['accounts[$i].customerInfo.state'] =
          customers[i]['state']?.toString() ?? '';
      requestBody['accounts[$i].accountCurrency'] =
          customers[i]['accountCurrency']?.toString() ?? '';
      requestBody['accounts[$i].customerInfo.dateOfBirth'] =
          customers[i]['dateOfBirth']?.toString() ?? '';
      requestBody['accounts[$i].customerInfo.zipCode'] =
          customers[i]['zipCode']?.toString() ?? '';
      requestBody['accounts[$i].customerInfo.country'] =
          customers[i]['country']?.toString() ?? '';
      requestBody['accounts[$i].customerInfo.occupation'] =
          customers[i]['occupation']?.toString() ?? '';
      requestBody['accounts[$i].initialDeposit'] =
          customers[i]['initialDeposit']?.toString() ?? '';
      requestBody['accounts[$i].monthlyIncome'] =
          customers[i]['monthlyIncome']?.toString() ?? '';
      requestBody['accounts[$i].branch'] =
          customers[i]['branch']?.toString() ?? '';
      requestBody['accounts[$i].currency'] =
          customers[i]['currency']?.toString() ?? '';
      requestBody['accounts[$i].percentageCompleted'] =
          customers[i]['percentageCompleted']?.toString() ?? '';
      requestBody['accounts[$i].accountType'] =
          customers[i]['accountType']?.toString() ?? '';
      requestBody['accounts[$i].formCompleted'] =
          (customers[i]['formCompleted'] == 1) ? "true" : "false";

      requestBody['accounts[$i].customerType'] =
          customers[i]['customerType']?.toString() ?? '';
      requestBody['accounts[$i].customerInfo.documentName'] =
          customers[i]['documentName']?.toString() ?? '';

      requestBody['accounts[$i].customerInfo.issueAuthority'] =
          customers[i]['issueAuthority']?.toString() ?? '';

      requestBody['accounts[$i].customerInfo.issueDate'] =
          customers[i]['issueDate']?.toString() ?? '';

      requestBody['accounts[$i].customerInfo.zoneSubCity'] =
          customers[i]['zoneSubCity']?.toString() ?? '';
      requestBody['accounts[$i].customerInfo.title'] =
          customers[i]['title']?.toString() ?? '';
      requestBody['accounts[$i].customerInfo.maritalStatus'] =
          customers[i]['maritalStatus']?.toString() ?? '';
      requestBody['accounts[$i].customerInfo.expirayDate'] =
          customers[i]['expirayDate']?.toString() ?? '';
    }

    try {
      var response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': 'Bearer $token',
            },
            body: requestBody,
          )
          .timeout(const Duration(seconds: 7));
      print(requestBody);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Customers synced successfully.");
        // Delete synced customers from local database
        for (var customer in customers) {
          await deleteCustomer(customer['id']);
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error syncing customers: $e");
      return false;
    }
  }

  // Delete customer from local database
  Future<void> deleteCustomer(int customerId) async {
    final db = await database;
    await db.delete(
      'Customers',
      where: 'id = ?',
      whereArgs: [customerId],
    );
  }

  Future<void> storeMonthlyTarget(
      Database db, Map<String, dynamic> data) async {
    await db.insert('monthlytargets', {
      'name': data['name'],
      'achievements': data['achievements'],
      'target': data['target'],
    });
  }

  Future<List<Map<String, dynamic>>> getMonthlyTargets(Database db) async {
    return await db.query('monthlytargets');
  }

  Future<void> updateAchievements(
      Database db, int id, double newAchievements) async {
    await db.update(
      'monthlytargets',
      {'achievements': newAchievements},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fetch unsynced customers by userId
  Future<List<Map<String, dynamic>>> getUnsyncedCustomersByUserId(
      int userId) async {
    final db = await database;
    return await db.query(
      'Customers',
      where: 'userId = ?',
      whereArgs: [userId], // Fetch customers by userId only
    );
  }

  // Get all customers
  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    final db = await database;
    return await db.query(
      'Customers',
    );
  }

  // Update Customer based on ID
  Future<int> updateCustomer(int id, Map<String, dynamic> updatedData) async {
    final db = await database;
    return await db.update(
      'Customers',
      updatedData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Print tables for debugging
  Future<void> printTables() async {
    final db = await database;
    var result = await db.rawQuery(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name='Customers'");
    print(result);
  }

  // Method to check if the Customers table exists
  Future<bool> isTableCreated(String tableName) async {
    final db = await database;
    var result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName]);
    return result.isNotEmpty;
  }

  // Fetch all unsynced customers for sync
  Future<List<Map<String, dynamic>>> getUnsyncedCustomers() async {
    final db = await database;
    return await db.query('Customers', where: 'synced = ?', whereArgs: [0]);
  }

  Future<void> insertUser(String username, String password) async {
    final db = await _initDB();
    await db.insert('Users', {
      'username': username,
      'password': password,
    });
  }

  ///////////////////////
  ///INSERT
  // Future<void> insertAuthToken(String token) async {
  //   final db = await _initDB();

  //   await db.insert('auth_tokens', {
  //     'token': token,
  //   });
  // }

  // Future<void> insertAuthToken({
  //   required String token,
  // }) async {
  //   final db = await database;

  //   await db.insert(
  //     'auth_tokens',
  //     {
  //       'token': token,
  //     },
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  Future<void> insertAuthToken(String token) async {
    final db = await database;

    await db.insert(
      'auth_tokens',
      {
        "id": token,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertLanguage(String languageCode) async {
    final db = await database;

    // Check if there's an existing record
    final List<Map<String, dynamic>> existingLanguage =
        await db.query('selected_language');

    if (existingLanguage.isEmpty) {
      await db.insert(
        'selected_language',
        {
          'language_code': languageCode,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      // If a record exists, update it
      await db.update(
        'selected_language',
        {'language_code': languageCode},
        where: 'id = ?', // We know there's only one row
        whereArgs: [existingLanguage.first['id']], // Get the first row's id
      );
    }
  }

  Future<void> ensureLanguageSet() async {
    final db = await database;

    // Query the table to check if any record exists
    final List<Map<String, dynamic>> existingLanguage =
        await db.query('selected_language');

    if (existingLanguage.isEmpty) {
      // If the table is empty, insert the default language ('eng')
      await db.insert(
        'selected_language',
        {
          'language_code': 'eng',
        },
        conflictAlgorithm: ConflictAlgorithm
            .replace, // Replace if the record exists (although it won't in this case)
      );
    }
  }

  Future<String> getSelectedLanguage() async {
    final db = await database;
    final List<Map<String, dynamic>> result =
        await db.query('selected_language');

    // Check if there is any result, then return the language code, else return a default value
    if (result.isNotEmpty) {
      return result.first['language_code'] as String;
    } else {
      // Default to English if no language is set
      return 'en';
    }
  }

  Future<void> insertToken(String token) async {
    final db = await database;

    await db.delete('auth_tokens');
    await db.insert(
      'auth_tokens',
      {
        'token': token,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

////GET
  // Future<List<Map<String, dynamic>>> getAuthToken() async {
  //   final db = await _initDB();
  //   return await db.query('auth_tokens');
  // }

  Future<String?> getAuthToken() async {
    final db = await _initDB();
    final result = await db.query('auth_tokens', limit: 1); // Limit to 1 row

    if (result.isNotEmpty) {
      return result.first['token'] as String?;
    }

    return null; // Return null if no token is found
  }
  /////////////////////////

  Future<bool> userExists(String username) async {
    final db = await _initDB();
    final List<Map<String, dynamic>> result = await db.query(
      'Users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await _initDB();
    return await db.query('Users');
  }

///////////////////////////////////////////////////////////
  Future<void> insertUser1({
    required String username,
    required String password,
    required int userId,
    String? clientId,
    String? token,
    required String role,
    List<Map<String, dynamic>>? branches,
  }) async {
    final db = await database;

    // Insert or update the user with userId, clientId, and role
    await db.insert(
      'Users',
      {
        'username': username,
        'password': password,
        'userId': userId,
        'clientId': clientId,
        "token": token,
        'role': role,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert branches and establish relationships in UserBranches if branches data is provided
    if (branches != null) {
      for (var branch in branches) {
        // Insert branch if it doesn't exist
        final branchId = await db.insert(
          'Branches',
          {
            'branchName': branch['companyName'],
            'branchCode': branch['branchCode'],
            'id': branch['id'],
          },
          conflictAlgorithm:
              ConflictAlgorithm.ignore, // Prevent duplicate branches
        );

        // Link user with branch in UserBranches table
        await db.insert(
          'UserBranches',
          {
            'userId': userId,
            'branchId': branchId,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
  }

/////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////

  Future<List<Map<String, dynamic>>> getCustomers(int userId) async {
    final db = await _initDB();

    return await db.query(
      'Customers',
      where: 'userId = ? ',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getLocalUsersFromDB() async {
    final db = await openDatabase('customers.db');
    return await db.query('Customers');
  }

  Future<List<Map<String, dynamic>>> getCustomersByStatus(
      String status, int userId) async {
    print("data12");
    print(userId);
    final db = await database;

    if (status == "Total") {
      final List<Map<String, dynamic>> result = await db.query(
        'customers',
        where: 'userId = ? ',
        whereArgs: [userId],
      );

      return result;
    } else {
      final List<Map<String, dynamic>> result = await db.query(
        'customers', // Replace with your actual table name
        where: 'status = ? AND userId = ?',
        whereArgs: [status, userId],
      );
      return result;
    }
  }
}
