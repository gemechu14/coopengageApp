import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:coopengageplus/core/config/config.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/core/database/database_helper.dart';

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
    // If initialValue is provided, set it immediately without loading
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      print("BranchSelector: Initial value provided (${widget.initialValue}), setting without API call");
      setState(() {
        selectedBranch = widget.initialValue;
        isLoading = false;
      });
      // Don't call initializeBranches at all - branches list will be loaded lazily if needed
      // This prevents unnecessary API calls when user navigates back
      return;
    }
    // Only load branches if no initial value is provided
    initializeBranches();
  }

  void initializeBranches({bool skipSelection = false}) async {
    try {
      print("BranchSelector: Initializing branches from API...");
      
      // Try to fetch from API first
      String? token = await storage.read(key: "token");
      Map<String, dynamic>? mainBranchData;
      String? defaultBranchName;
      List<Map<String, dynamic>> formattedBranches = [];
      
      if (token != null && token.isNotEmpty) {
        try {
          // Call API to get user data
          final url = '${AppConstants.baseUrl}/users/me';
          print("BranchSelector: Calling API: $url");
          
          final response = await http.get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
          
          print("BranchSelector: API response status: ${response.statusCode}");
          
          if (response.statusCode == 200) {
            final Map<String, dynamic> userData = jsonDecode(response.body);
            print("BranchSelector: API response data: $userData");
            
            // Extract mainBranch
            if (userData['mainBranch'] != null) {
              final mainBranch = userData['mainBranch'] as Map<String, dynamic>;
              defaultBranchName = mainBranch['name']?.toString();
              mainBranchData = {
                'id': mainBranch['id'],
                'name': mainBranch['name']?.toString() ?? 'Main Branch',
                'branchCode': mainBranch['branchCode']?.toString() ?? '',
                'companyName': mainBranch['name']?.toString() ?? 'Main Branch',
              };
              print("BranchSelector: Main branch from API: $defaultBranchName");
            }
            
            // Extract branches array
            if (userData['branches'] != null && userData['branches'] is List) {
              final branchesList = userData['branches'] as List;
              formattedBranches = branchesList.map((branch) {
                final branchMap = branch as Map<String, dynamic>;
                return {
                  'id': branchMap['id'],
                  'name': branchMap['name']?.toString() ?? 'Unnamed Branch',
                  'branchCode': branchMap['branchCode']?.toString() ?? '',
                  'companyName': branchMap['name']?.toString() ?? 'Unnamed Branch',
                };
              }).toList();
              print("BranchSelector: Branches from API: $formattedBranches");
            }
          } else {
            print("BranchSelector: API call failed with status ${response.statusCode}, falling back to database");
            throw Exception('API call failed');
          }
        } catch (e) {
          print("BranchSelector: Error calling API: $e, falling back to database");
          // Fallback to database if API fails
          await _initializeFromDatabase();
          return;
        }
      } else {
        print("BranchSelector: No token found, falling back to database");
        await _initializeFromDatabase();
        return;
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
      print("BranchSelector: Default branch name: $defaultBranchName");
      
      setState(() {
        allBranches = allBranchesList;
        
        // If skipSelection is true, keep the existing selectedBranch (from initialValue)
        if (skipSelection && selectedBranch != null) {
          // Validate that the selectedBranch exists in the list
          String trimmedSelected = selectedBranch!.trim();
          bool branchExists = allBranchesList.any((branch) {
            String branchCompanyName = (branch['companyName'] ?? '').toString().trim();
            return branchCompanyName == trimmedSelected;
          });
          
          if (!branchExists) {
            // If selected branch doesn't exist in list, try to find a match or use default
            String? proposedBranch = defaultBranchName ?? 
                                     (allBranchesList.isNotEmpty ? allBranchesList.first['companyName'] : null);
            if (proposedBranch != null) {
              selectedBranch = proposedBranch.toString().trim();
            }
          }
        } else {
          // Priority: initialValue > mainBranch > first branch
          String? proposedBranch = widget.initialValue ?? 
                                   defaultBranchName ?? 
                                   (allBranchesList.isNotEmpty ? allBranchesList.first['companyName'] : null);
          
          print("BranchSelector: Proposed branch: $proposedBranch");
          
          // Ensure the proposed branch actually exists in our list
          if (proposedBranch != null) {
            // Trim and compare to handle whitespace issues
            String trimmedProposed = proposedBranch.trim();
            bool branchExists = allBranchesList.any((branch) {
              String branchCompanyName = (branch['companyName'] ?? '').toString().trim();
              bool matches = branchCompanyName == trimmedProposed;
              if (!matches) {
                print("BranchSelector: Comparing '$trimmedProposed' with '$branchCompanyName': $matches");
              }
              return matches;
            });
            
            if (branchExists) {
              // Find the exact match from the list to ensure consistency
              var matchingBranch = allBranchesList.firstWhere(
                (branch) => (branch['companyName'] ?? '').toString().trim() == trimmedProposed,
              );
              selectedBranch = matchingBranch['companyName']?.toString().trim();
              print("BranchSelector: Selected branch set to: $selectedBranch");
            } else {
              // Fallback to first branch if proposed branch doesn't exist
              selectedBranch = allBranchesList.isNotEmpty ? allBranchesList.first['companyName']?.toString().trim() : null;
              print("BranchSelector: Proposed branch '$proposedBranch' not found in list, using first branch: $selectedBranch");
            }
          } else {
            selectedBranch = null;
          }
        }
        
        isLoading = false;
      });
      
      print("BranchSelector: Final selectedBranch after setState: $selectedBranch");
      
      // Notify parent of initial value
      widget.onChanged(selectedBranch);
      
    } catch (e) {
      print("BranchSelector: Error initializing branches: $e");
      // Fallback to database on error
      await _initializeFromDatabase();
    }
  }

  /// Fallback method to initialize from database
  Future<void> _initializeFromDatabase() async {
    try {
      print("BranchSelector: Initializing branches from database (fallback)...");
      
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
            'companyName': branch['branchName'] ?? 'Unnamed Branch',
          };
        }).toList();
        
        // Get main branch from database
        String? defaultBranchName;
        Map<String, dynamic>? mainBranchData;
        try {
          String? token = await storage.read(key: "token");
          Map<String, dynamic>? currentUser;
          
          if (token != null && token.isNotEmpty) {
            currentUser = await dbHelper.getUserByToken(token);
          }
          
          if (currentUser == null) {
            final users = await dbHelper.getUsers();
            if (users.isNotEmpty) {
              currentUser = users.first;
            }
          }
          
          if (currentUser != null && currentUser['mainBranchName'] != null) {
            defaultBranchName = currentUser['mainBranchName'];
            mainBranchData = {
              'id': currentUser['mainBranchId'] ?? 0,
              'name': currentUser['mainBranchName'] ?? 'Main Branch',
              'branchCode': currentUser['mainBranchCode'] ?? '',
              'companyName': currentUser['mainBranchName'] ?? 'Main Branch',
            };
          }
        } catch (e) {
          print("BranchSelector: Error getting main branch from database: $e");
        }
        
        // Create final branches list
        final List<Map<String, dynamic>> allBranchesList = [];
        final Set<String> seenCompanyNames = {};
        
        if (mainBranchData != null) {
          allBranchesList.add(mainBranchData);
          seenCompanyNames.add(mainBranchData['companyName'] as String);
        }
        
        for (var branch in formattedBranches) {
          final companyName = branch['companyName'] as String;
          if (!seenCompanyNames.contains(companyName)) {
            allBranchesList.add(branch);
            seenCompanyNames.add(companyName);
          }
        }
        
        setState(() {
          allBranches = allBranchesList;
          selectedBranch = widget.initialValue ?? 
                          defaultBranchName ?? 
                          (allBranchesList.isNotEmpty ? allBranchesList.first['companyName']?.toString().trim() : null);
          isLoading = false;
        });
        
        widget.onChanged(selectedBranch);
      } else {
        setState(() {
          allBranches = [];
          selectedBranch = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("BranchSelector: Error initializing from database: $e");
      setState(() {
        allBranches = [];
        selectedBranch = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lazy load branches if we have selectedBranch but no branches list yet
    // This happens when user navigates back with initialValue
    if (!isLoading && selectedBranch != null && allBranches.isEmpty) {
      // Load branches in background without showing loading state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && allBranches.isEmpty && !isLoading) {
          initializeBranches(skipSelection: true);
        }
      });
    }
    
    // Validate that selectedBranch exists in allBranches
    String? validatedValue;
    if (!isLoading && selectedBranch != null) {
      // Trim both values for comparison to handle whitespace issues
      String trimmedSelected = selectedBranch!.trim();
      bool exists = allBranches.any((branch) {
        String branchCompanyName = (branch['companyName'] ?? '').toString().trim();
        return branchCompanyName == trimmedSelected;
      });
      
      if (exists) {
        // Find the exact match from the list to ensure we use the same string reference
        var matchingBranch = allBranches.firstWhere(
          (branch) => (branch['companyName'] ?? '').toString().trim() == trimmedSelected,
        );
        validatedValue = matchingBranch['companyName']?.toString().trim();
      } else {
        // If selected branch doesn't exist, clear it
        print("BranchSelector: Selected branch '$selectedBranch' not found in dropdown items, clearing selection");
        print("BranchSelector: Available branches: ${allBranches.map((b) => b['companyName']).toList()}");
        validatedValue = null;
      }
    }
    
    final mutedColor = Colors.blueGrey.shade400;

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 3, right: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: isLoading ? null : validatedValue,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: cyanblueColor.withOpacity(0.7),
            ),
            dropdownColor: Colors.white,
            style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade900),
            hint: Text(
              isLoading ? 'Loading branches...' : 'Choose a branch',
              style: TextStyle(
                fontSize: 13,
                color: mutedColor.withOpacity(0.7),
              ),
            ),
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
                    DropdownMenuItem(
                      value: null,
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cyanblueColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Loading...',
                            style: TextStyle(
                              fontSize: 13,
                              color: mutedColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  ]
                : allBranches.map<DropdownMenuItem<String>>((branch) {
                    final companyName = branch['companyName'] ?? '';
                    return DropdownMenuItem<String>(
                      value: companyName,
                      child: Text(
                        companyName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey.shade900,
                        ),
                      ),
                    );
                  }).toList(),
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              prefixIcon: Icon(
                Icons.location_city,
                size: 20,
                color: cyanblueColor.withOpacity(0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: cyanblueColor.withOpacity(0.30)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: cyanblueColor.withOpacity(0.30)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: cyanblueColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Colors.redAccent, width: 1.3),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blueGrey.shade100),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
