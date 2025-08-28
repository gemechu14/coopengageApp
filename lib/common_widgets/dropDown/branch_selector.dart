import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';

class BranchSelector extends StatefulWidget {
  final Function(String?) onChanged;
  final String? initialValue;

  const BranchSelector({
    Key? key,
    required this.onChanged,
    this.initialValue,
  }) : super(key: key);

  @override
  _BranchSelectorState createState() => _BranchSelectorState();
}

class _BranchSelectorState extends State<BranchSelector> {
  final storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding),
  );
  List<Map<String, dynamic>> allBranches = [];
  String? selectedBranch;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeBranches();
  }

  void initializeBranches() async {
    try {
      print("BranchSelector: Initializing branches from database...");
      
      // Get branches from local database
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      
      // Get all branches from Branches table
      final List<Map<String, dynamic>> branchResults = await db.query('Branches');
      print("BranchSelector: Raw branches from database: $branchResults");
      
      if (branchResults.isNotEmpty) {
        // Convert database results to the expected format
        final List<Map<String, dynamic>> formattedBranches = branchResults.map((branch) {
          return {
            'id': branch['id'],
            'name': branch['branchName'] ?? 'Unnamed Branch',
            'branchCode': branch['branchCode'] ?? '',
            'companyName': branch['companyName'] ?? branch['branchName'] ?? 'Unnamed Branch',
          };
        }).toList();
        
        print("BranchSelector: Formatted branches: $formattedBranches");
        
        // Get main branch from Users table if available
        String? defaultBranchName;
        Map<String, dynamic>? mainBranchData;
        try {
          final users = await dbHelper.getUsers();
          if (users.isNotEmpty) {
            final user = users.first;
            if (user['mainBranchName'] != null) {
              defaultBranchName = user['mainBranchName'];
              mainBranchData = {
                'id': user['mainBranchId'] ?? 0,
                'name': user['mainBranchName'] ?? 'Main Branch',
                'branchCode': user['mainBranchCode'] ?? '',
                'companyName': user['mainBranchName'] ?? 'Main Branch',
              };
              print("BranchSelector: Main branch from user: $defaultBranchName");
            }
          }
        } catch (e) {
          print("BranchSelector: Error getting main branch: $e");
        }
        
        // Create final branches list including main branch
        final List<Map<String, dynamic>> allBranchesList = [];
        
        // Add main branch first if it exists
        if (mainBranchData != null) {
          allBranchesList.add(mainBranchData);
          print("BranchSelector: Added main branch to list: $mainBranchData");
        }
        
        // Add other branches
        allBranchesList.addAll(formattedBranches);
        print("BranchSelector: Final all branches list: $allBranchesList");
        
        setState(() {
          allBranches = allBranchesList;
          
          // Priority: initialValue > mainBranch > first branch
          selectedBranch = widget.initialValue ?? 
                          defaultBranchName ?? 
                          (allBranchesList.isNotEmpty ? allBranchesList.first['companyName'] : null);
          
          isLoading = false;
        });
        
        // Notify parent of initial value
        widget.onChanged(selectedBranch);
        
      } else {
        print("BranchSelector: No branches found in database");
        setState(() {
          allBranches = [];
          selectedBranch = null;
          isLoading = false;
        });
      }
      
    } catch (e) {
      print("BranchSelector: Error initializing branches: $e");
      setState(() {
        allBranches = [];
        selectedBranch = null;
        isLoading = false;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: isLoading ? null : selectedBranch,
            hint: isLoading
                ? const Text('Loading branches...')
                : const Text('Choose a branch'),
            onChanged: isLoading
                ? null
                : (String? newValue) {
                    setState(() {
                      selectedBranch = newValue;
                    });
                    widget.onChanged(newValue);
                  },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Branch is required';
              }
              return null;
            },
            items: isLoading
                ? [
                    const DropdownMenuItem(
                      value: null,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text('Loading...')
                        ],
                      ),
                    )
                  ]
                : allBranches.map<DropdownMenuItem<String>>((branch) {
                    final companyName = branch['companyName'] ?? '';
                    return DropdownMenuItem<String>(
                      value: companyName,
                      child: Text(companyName),
                    );
                  }).toList(),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.blue),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.red),
              ),
              prefixIcon: Icon(Icons.location_city),
            ),
          ),
        ],
      ),
    );
  }

  // Widget build(BuildContext context) {
  //   if (isLoading) {
  //     return const CircularProgressIndicator(); // or SizedBox.shrink()
  //   }

  //   return Padding(
  //     padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         DropdownButtonFormField<String>(
  //           value: selectedBranch,
  //           hint: const Text('Choose a branch'),
  //           onChanged: (String? newValue) {
  //             setState(() {
  //               selectedBranch = newValue;
  //             });
  //             widget.onChanged(newValue);
  //           },
  //           validator: (value) {
  //             if (value == null || value.isEmpty) {
  //               return 'Branch is required';
  //             }
  //             return null;
  //           },
  //           items: allBranches.map<DropdownMenuItem<String>>((branch) {
  //             final companyName = branch['companyName'] ?? '';
  //             return DropdownMenuItem<String>(
  //               value: companyName,
  //               child: Text(companyName),
  //             );
  //           }).toList(),
  //           decoration: const InputDecoration(
  //             isDense: true,
  //             contentPadding:
  //                 EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(10)),
  //             ),
  //             enabledBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(10)),
  //               borderSide: BorderSide(color: Colors.black),
  //             ),
  //             focusedBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(10)),
  //               borderSide: BorderSide(color: Colors.blue),
  //             ),
  //             errorBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(10)),
  //               borderSide: BorderSide(color: Colors.red),
  //             ),
  //             focusedErrorBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(10)),
  //               borderSide: BorderSide(color: Colors.red),
  //             ),
  //             prefixIcon: Icon(Icons.location_city),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
