import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      var decodedToken = JwtDecoder.decode(token);

      List<Map<String, dynamic>> regularBranches =
          decodedToken.containsKey("branch")
              ? List<Map<String, dynamic>>.from(decodedToken["branch"])
              : [];

      List<Map<String, dynamic>> branches = [];
      String? defaultBranchName;

      if (decodedToken.containsKey("mainBranch")) {
        branches.add(decodedToken["mainBranch"]);
        defaultBranchName = decodedToken["mainBranch"]["companyName"];
      }

      branches.addAll(regularBranches);

      setState(() {
        allBranches = branches;

        // Priority: initialValue > alreadySelected > mainBranch
        selectedBranch =
            widget.initialValue ?? selectedBranch ?? defaultBranchName;

        isLoading = false;
      });

      // Notify parent of initial value
      widget.onChanged(selectedBranch);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator(); // or SizedBox.shrink()
    }

    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: selectedBranch,
            hint: const Text('Choose a branch'),
            onChanged: (String? newValue) {
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
            items: allBranches.map<DropdownMenuItem<String>>((branch) {
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
