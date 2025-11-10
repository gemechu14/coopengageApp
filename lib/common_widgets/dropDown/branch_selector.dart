import 'package:coopengageplus/core/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:coopengageplus/helper/databaseHelper.dart';

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
        
        // Get main branch from the CURRENT logged-in user
        String? defaultBranchName;
        Map<String, dynamic>? mainBranchData;
        try {
          // Get token to identify current user (matching profileScreen.dart logic)
          String? token = await storage.read(key: "token");
          print("BranchSelector: Token found: ${token != null ? 'Yes' : 'No'}");
          
          Map<String, dynamic>? currentUser;
          
          // Try to get user by token first
          if (token != null && token.isNotEmpty) {
            currentUser = await dbHelper.getUserByToken(token);
            print("BranchSelector: User found by token: ${currentUser != null ? 'Yes' : 'No'}");
          }
          
          // If no user found by token, try to get first user as fallback
          if (currentUser == null) {
            final users = await dbHelper.getUsers();
            if (users.isNotEmpty) {
              currentUser = users.first;
              print("BranchSelector: Using first user from database as fallback");
            }
          }
          
          // Set main branch from current user
          if (currentUser != null && currentUser['mainBranchName'] != null) {
            defaultBranchName = currentUser['mainBranchName'];
            mainBranchData = {
              'id': currentUser['mainBranchId'] ?? 0,
              'name': currentUser['mainBranchName'] ?? 'Main Branch',
              'branchCode': currentUser['mainBranchCode'] ?? '',
              'companyName': currentUser['mainBranchName'] ?? 'Main Branch',
            };
            print("BranchSelector: Main branch from current user: $defaultBranchName");
          }
        } catch (e) {
          print("BranchSelector: Error getting main branch: $e");
        }
        
        // Create final branches list including main branch
        final List<Map<String, dynamic>> allBranchesList = [];
        final Set<String> seenCompanyNames = {}; // Track unique company names
        
        // Add main branch first if it exists
        if (mainBranchData != null) {
          final mainCompanyName = mainBranchData['companyName'] as String;
          allBranchesList.add(mainBranchData);
          seenCompanyNames.add(mainCompanyName);
          print("BranchSelector: Added main branch to list: $mainBranchData");
        }
        
        // Add other branches, excluding duplicates by companyName
        for (var branch in formattedBranches) {
          final companyName = branch['companyName'] as String;
          
          // Skip if we've already seen this companyName
          if (seenCompanyNames.contains(companyName)) {
            print("BranchSelector: Skipping duplicate branch: $companyName");
            continue;
          }
          
          allBranchesList.add(branch);
          seenCompanyNames.add(companyName);
        }
        print("BranchSelector: Final all branches list (${allBranchesList.length} branches): $allBranchesList");
        
        setState(() {
          allBranches = allBranchesList;
          
          // Priority: initialValue > mainBranch > first branch
          String? proposedBranch = widget.initialValue ?? 
                                   defaultBranchName ?? 
                                   (allBranchesList.isNotEmpty ? allBranchesList.first['companyName'] : null);
          
          // Ensure the proposed branch actually exists in our list
          if (proposedBranch != null) {
            bool branchExists = allBranchesList.any((branch) => branch['companyName'] == proposedBranch);
            if (branchExists) {
              selectedBranch = proposedBranch;
            } else {
              // Fallback to first branch if proposed branch doesn't exist
              selectedBranch = allBranchesList.isNotEmpty ? allBranchesList.first['companyName'] : null;
              print("BranchSelector: Proposed branch '$proposedBranch' not found in list, using first branch: $selectedBranch");
            }
          } else {
            selectedBranch = null;
          }
          
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
  Widget build(BuildContext context) {
    // Validate that selectedBranch exists in allBranches
    String? validatedValue;
    if (!isLoading && selectedBranch != null) {
      bool exists = allBranches.any((branch) => branch['companyName'] == selectedBranch);
      if (exists) {
        validatedValue = selectedBranch;
      } else {
        // If selected branch doesn't exist, clear it
        print("BranchSelector: Selected branch '$selectedBranch' not found in dropdown items, clearing selection");
        validatedValue = null;
      }
    }
    
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: isLoading ? null : validatedValue,
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
