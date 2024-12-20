// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:coopengageplus/crm12/CRMMainScreen.dart';
import 'package:coopengageplus/crm12/UserDetailScreen.dart';
// ignore: unused_import

class Listofcustomers extends StatefulWidget {
  const Listofcustomers({super.key});

  @override
  State<Listofcustomers> createState() => _ListofcustomersState();
}

class _ListofcustomersState extends State<Listofcustomers> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    filteredUsers = users;
  }

  final List<Map<String, String>> users = [
    {
      "name": "John Doe",
      "phoneNumber": "098767676",
      "email": "john.doe@example.com"
    },
    {
      "name": "Jane Smith",
      "phoneNumber": "09876543",
      "email": "jane.smith@example.com"
    },
    {
      "name": "Robert Johnson",
      "phoneNumber": "098767676",
      "email": "robert.johnson@example.com"
    },
    {
      "name": "Emily Davis",
      "phoneNumber": "0987434343",
      "email": "emily.davis@example.com"
    },
  ];

  List<Map<String, String>> filteredUsers = [];
  String searchQuery = '';

  // Filter users based on search query
  void _filterUsers(String query) {
    final results = users.where((user) {
      final nameLower = user["name"]!.toLowerCase();
      final searchLower = query.toLowerCase();
      return nameLower.contains(searchLower);
    }).toList();

    setState(() {
      searchQuery = query;
      filteredUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const CRMMainScreen(),
            ),
            (route) => false);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'List of Customers',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CRMMainScreen(),
                    ),
                    (route) => false);
              },
              icon: const Icon(Icons.arrow_back)),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: _filterUsers,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        color: Colors.white,
                        child: ListTile(
                          title: Text(user["name"]!),
                          subtitle: Text(user["phoneNumber"]!),
                          leading: Text((index + 1).toString()),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailScreen(user: user),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
