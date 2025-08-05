// import 'dart:convert';
// import 'package:coopengageplus/NetworkHandler.dart';
// import 'package:coopengageplus/features/onboarding/Indivudualaccount/ViewCustomerInfoPage.dart';
// import 'package:coopengageplus/features/onboarding/Update_IndividualAccount%20-/screens/registration_screen.dart';
// import 'package:coopengageplus/features/onboarding/pages/verifyCustomerInfo.dart';
// import 'package:coopengageplus/features/onboarding/Indivudualaccount/updateCustomerInfoScreen.dart';
// import 'package:coopengageplus/helper/databaseHelper.dart';
// import 'package:coopengageplus/main.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:scrollable_table_view/scrollable_table_view.dart';

// class UserListPage extends StatefulWidget {
//   final String title;

//   const UserListPage({Key? key, required this.title}) : super(key: key);

//   @override
//   _UserInfoPageState createState() => _UserInfoPageState();
// }

// enum SampleItem { view, edit, verify }

// class _UserInfoPageState extends State<UserListPage> {
//   final NetworkHandler networkHandler = NetworkHandler();
//   List<dynamic> users = [];
//   List<dynamic> filteredUsers = [];
//   bool isLoading1 = false;
//   String searchQuery = '';

//   SampleItem? selectedItem;
//   int? userId;

//   // // Mapping widget.title to category values
//   // Map<String, List<String>> titleStatusMapping = {
//   //   "New Applicants": ["INITIAL", "REGISTERED"],
//   //   "Awaiting Action": ["PENDING", "UNAUTHORIZED", "AUTHORIZED", "UNSETTLED"],
//   //   "Approved": ["APPROVED"],
//   //   "Rejected": ["REJECTED"],
//   // };
//   Map<String, List<String>> titleStatusMapping = isOnline
//       ? {
//           "New Applicants": ["INITIAL", "REGISTERED"],
//           "Awaiting Action": [
//             "PENDING",
//             "UNAUTHORIZED",
//             "AUTHORIZED",
//             "UNSETTLED"
//           ],
//           "Approved": ["APPROVED"],
//           "Rejected": ["REJECTED"],
//         }
//       : {
//           "New Applicants": ["INITIAL"],
//           "Awaiting Action": ["UNSETTLED"],
//           "Approved": ["APPROVED"],
//           "Rejected": ["REJECTED"],
//         };

//   List<String> dropdownOptions = [];
//   String? selectedCategory;

//   @override
//   void initState() {
//     super.initState();
//     _fetchToken();

//     dropdownOptions = titleStatusMapping[widget.title] ?? [];
//     if (dropdownOptions.isNotEmpty) {
//       selectedCategory = dropdownOptions[0];
//       fetchUsers(selectedCategory!);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: AppBar(
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 15),
//           child: IconButton(
//             icon:
//                 const Icon(Icons.arrow_back_ios, size: 25, color: Colors.blue),
//             onPressed: () => {
//               Navigator.pop(context)
            
//             },
//           ),
//         ),
//         backgroundColor: Colors.white,
//         title: Text(
//           " ${widget.title}",
//           style: const TextStyle(
//               fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
//         ),
//         // centerTitle: true,
//       ),
//       body: Container(
//         color: Colors.white,
//         child: Center(
//           child: Container(
//             width: width < 600 ? double.infinity : width * 0.5,
//             child: Padding(
//               padding: const EdgeInsets.only(top: 5),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     height: 10,
//                   ),
//                   if (dropdownOptions.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(left: 20),
//                       child: DropdownButton<String>(
//                         value: selectedCategory,
//                         onChanged: (String? newCategory) {
//                           setState(() {
//                             selectedCategory = newCategory!;
//                             fetchUsers(selectedCategory!);
//                           });
//                         },
//                         items: dropdownOptions
//                             .map<DropdownMenuItem<String>>((String value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Text(value),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 14),
//                     child: TextFormField(
//                       decoration: InputDecoration(
//                         hintText: 'Search...',
//                         isDense: true,
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       onChanged: (value) {
//                         setState(() {
//                           searchQuery = value;
//                           filterUsers();
//                         });
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   if (isLoading1)
//                     const Center(child: CircularProgressIndicator())
//                   else
//                     Expanded(
//                       child: filteredUsers.isEmpty
//                           ? const Padding(
//                               padding: EdgeInsets.only(top: 50),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   SizedBox(height: 40),
//                                   Center(
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Icon(Icons.folder_copy_sharp,
//                                             size: 64, color: Colors.blue),
//                                         SizedBox(height: 5),
//                                         Text(
//                                           'Empty',
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             color: Colors.black,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )
//                           : Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 10, right: 2),
//                               child: ScrollableTableView(
//                                 headers: [
//                                   "No",
//                                   "Full Name",
//                                   "PhoneNumber",
//                                   "Action"
//                                 ]
//                                     .map((label) =>
//                                         TableViewHeader(label: label))
//                                     .toList(),
//                                 rows:
//                                     filteredUsers.asMap().entries.map((entry) {
//                                   int index = entry.key;
//                                   var user = entry.value;
//                                   return TableViewRow(
//                                     height: 50,
//                                     cells: [
//                                       TableViewCell(
//                                           child: Text((index + 1).toString())),
//                                       TableViewCell(
//                                         child: Text(
//                                           user['fullName'] ?? '',
//                                           style: const TextStyle(
//                                               fontSize: 10,
//                                               fontWeight: FontWeight.bold),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                       TableViewCell(
//                                         child: Text(
//                                           user['phone'] ?? '',
//                                           style: const TextStyle(fontSize: 10),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                       TableViewCell(
//                                         child: Center(
//                                           child: PopupMenuButton<SampleItem>(
//                                             onSelected: (SampleItem item) {
//                                               setState(() {
//                                                 selectedItem = item;
//                                                 if (item == SampleItem.edit) {


//                                                   // Navigator.push(
//                                                   //   context,
//                                                   //   MaterialPageRoute(
//                                                   //     builder: (context) =>
//                                                   //         UpdateCustomerINFOScreen(
//                                                   //             userInfo: user),
//                                                   //   ),
//                                                   // );


//                                                    Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           UpdateUserRegistrationScreen(
//                                                               userInfo: user),
//                                                     ),
//                                                   );
//                                                 } else if (item ==
//                                                     SampleItem.view) {
//                                                   Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           ViewCustomerInfo(
//                                                               registrationData:
//                                                                   user,
//                                                               title:
//                                                                   widget.title),
//                                                     ),
//                                                   );
//                                                 } else if (item ==
//                                                     SampleItem.verify) {
//                                                   Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           Verifycustomerinfo(
//                                                               registrationData:
//                                                                   user,
//                                                               title:
//                                                                   widget.title),
//                                                     ),
//                                                   );
//                                                 }
//                                               });
//                                             },
//                                             iconColor: Colors.blue,
//                                             itemBuilder: (BuildContext
//                                                     context) =>
//                                                 <PopupMenuEntry<SampleItem>>[
//                                               const PopupMenuItem<SampleItem>(
//                                                 value: SampleItem.view,
//                                                 child: Text('View'),
//                                               ),
//                                               if (widget.title ==
//                                                       'New Applicants' &&
//                                                   selectedCategory == 'INITIAL')
//                                                 const PopupMenuItem<SampleItem>(
//                                                   value: SampleItem.edit,
//                                                   child: Text('Edit'),
//                                                 ),
//                                               if (isOnline &&
//                                                   widget.title ==
//                                                       'New Applicants' &&
//                                                   selectedCategory ==
//                                                       'REGISTERED')
//                                                 const PopupMenuItem<SampleItem>(
//                                                   value: SampleItem.verify,
//                                                   child: Text('Verify'),
//                                                 ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 }).toList(),
//                               ),
//                             ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> fetchUsers(String status) async {
//     setState(() {
//       isLoading1 = true;
//     });

//     const storage = FlutterSecureStorage();
//     String? token = await storage.read(key: "token");
//     if (token != null && token.isNotEmpty) {
//       var decodedToken = JwtDecoder.decode(token);
//       setState(() {
//         userId = decodedToken['userId'];
//       });
//     }

//     String url = '/api/v1/accounts?customerType=INDIVIDUAL&status=$status';

//     if (isOnline) {
//       try {
//         var response = await networkHandler.getUserData(url);
//         if (response.statusCode == 200) {
//           List<dynamic> fetchedUsers = jsonDecode(response.body);
//           setState(() {
//             users = fetchedUsers;
//             filterUsers();
//             isLoading1 = false;
//           });
//         } else {
//           throw Exception('Failed to load users');
//         }
//       } catch (error) {
//         print('Error fetching users: $error');
//         setState(() {
//           isLoading1 = false;
//         });
//       }
//     } else {
//       DatabaseHelper dbHelper = DatabaseHelper();
//       List<Map<String, dynamic>> localUsers =
//           await dbHelper.getCustomersByStatus(status, userId!);
//       setState(() {
//         users = localUsers;
//         filterUsers();
//         isLoading1 = false;
//       });
//     }
//   }

//   void filterUsers() {
//     setState(() {
//       filteredUsers = users
//           .where((user) => (user['fullName']?.toLowerCase() ?? '')
//               .contains(searchQuery.toLowerCase()))
//           .toList();
//     });
//   }

//   Future<void> _fetchToken() async {
//     const storage = FlutterSecureStorage();
//     String? token = await storage.read(key: "token");
//     if (token != null && token.isNotEmpty) {
//       var decodedToken = JwtDecoder.decode(token);
//       setState(() {
//         userId = decodedToken['userId'];
//       });
//     }
//   }
// }
