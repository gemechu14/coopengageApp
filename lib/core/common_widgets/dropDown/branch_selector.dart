import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
      print("BranchSelector: Initializing branches from JWT token...");

      String? token = await storage.read(key: "token");
      if (token == null || token.isEmpty) {
        print("BranchSelector: No token found");
        setState(() {
          allBranches = [];
          selectedBranch = null;
          isLoading = false;
        });
        return;
      }

      final parts = token.split(".");
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      final branchList =
          List<Map<String, dynamic>>.from(payload['branch'] ?? []);

      if (branchList.isEmpty) {
        print("BranchSelector: No branches found in token");
        setState(() {
          allBranches = [];
          selectedBranch = null;
          isLoading = false;
        });
        return;
      }

      final List<Map<String, dynamic>> formattedBranches =
          branchList.map((branch) {
        return {
          'id': branch['id'],
          'name': branch['name']?.toString() ?? 'Unnamed Branch',
          'branchCode': branch['branchCode']?.toString() ?? '',
          'companyName': branch['name']?.toString() ?? 'Unnamed Branch',
        };
      }).toList();

      final List<Map<String, dynamic>> allBranchesList = [];
      final Set<String> seenCompanyNames = {};

      for (var branch in formattedBranches) {
        final companyName = branch['companyName'] as String;
        if (!seenCompanyNames.contains(companyName)) {
          allBranchesList.add(branch);
          seenCompanyNames.add(companyName);
        }
      }

      print(
          "BranchSelector: Final branches list (${allBranchesList.length} branches)");

      setState(() {
        allBranches = allBranchesList;

        String? proposedBranch = widget.initialValue ??
            (allBranchesList.isNotEmpty
                ? allBranchesList.first['companyName']
                : null);

        if (proposedBranch != null) {
          bool branchExists = allBranchesList
              .any((branch) => branch['companyName'] == proposedBranch);
          if (branchExists) {
            selectedBranch = proposedBranch;
          } else {
            selectedBranch = allBranchesList.isNotEmpty
                ? allBranchesList.first['companyName']
                : null;
          }
        } else {
          selectedBranch = null;
        }

        isLoading = false;
      });

      widget.onChanged(selectedBranch);
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
}
