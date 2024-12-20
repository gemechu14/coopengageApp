import 'package:coopengageplus/features/crm/CRMMainScreen.dart';
import 'package:coopengageplus/features/crm/presentation/client_details/client_details.dart';
import 'package:coopengageplus/features/crm/providers/high_profile_clients.dart';
import 'package:coopengageplus/utils/language_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../constants/kconstant.dart';
import '../../constants/text_styles.dart';
// import 'package:/constants/kconstant.dart';
// import 'package:coopengageplus/constants/text_styles.dart';
// import 'package:coopengageplus/features/crm/CRMMainScreen.dart';
// import 'package:coopengageplus/features/crm/presentation/client_details/client_details.dart';
// import 'package:coopengageplus/features/hpc/providers/high_profile/high_profile_clients.dart';
// import 'package:coopengageplus/utils/language_store.dart';

class Listofcustomers extends ConsumerStatefulWidget {
  const Listofcustomers({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ListofcustomersState();
}

class _ListofcustomersState extends ConsumerState<Listofcustomers> {
  void initState() {
    // TODO: implement initState

    super.initState();
    filteredUsers = users;
  }

  final List<Map<String, String>> users = [
    {
      "name": "Daniel Zerihun",
      "phoneNumber": "098767676",
      "email": "danailzerihun.com"
    },
    {
      "name": "Samuel Tola",
      "phoneNumber": "09876543",
      "email": "samueltola.com"
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
    final highProfileClients = ref.watch(highProfileClientsProvider);
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
          backgroundColor: whiteColor,
          title: Text(
            translation(context).listOfCustomers,
            style: subHeadingStyle,
          ),
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back_ios)),
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
                  child: highProfileClients.when(
                loading: () => Center(child: CircularProgressIndicator()),
                error: (err, stk) => Text("error"),
                data: (clients) => ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final user = clients[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        color: Colors.white,
                        child: ListTile(
                          title: Text(user.accHolderName),
                          subtitle: Text(user.phone),
                          leading: Text((index + 1).toString()),
                          onTap: () {
                            Get.to(() => ClientDetails(), arguments: user);
                          },
                        ),
                      ),
                    );
                  },
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
