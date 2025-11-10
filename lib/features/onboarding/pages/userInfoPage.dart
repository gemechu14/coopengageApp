// // ignore_for_file: library_private_types_in_public_api

// import 'dart:convert';
// import 'package:coopengageplus/core/network/network_handler.dart';
// import 'package:coopengageplus/features/onboarding/Indivudualaccount/updateCustomerInfoScreen.dart';
// import 'package:coopengageplus/core/database/database_helper.dart';
// import 'package:coopengageplus/main.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';

// import 'package:scrollable_table_view/scrollable_table_view.dart';

// class UserInfoPage extends StatefulWidget {
//   final String title;

//   const UserInfoPage({Key? key, required this.title}) : super(key: key);

//   @override
//   _UserInfoPageState createState() => _UserInfoPageState();
// }

// enum SampleItem { view, edit }

// class _UserInfoPageState extends State<UserInfoPage> {
//   final NetworkHandler networkHandler = NetworkHandler();
//   List<dynamic> users = [];
//   List<dynamic> filteredUsers = [];
//   bool isLoading1 = false;
//   String searchQuery = '';

//   SampleItem? selectedItem;

//   int? userId;

//   @override
//   void initState() {
//     super.initState();
//     _fetchToken();
//     fetchUsers(widget.title);
//     print("title");
//     print(widget.title);
//   }

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     SampleItem? selectedItem;
//     int index = 0;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Text(
//           " ${widget.title}",
//           style: const TextStyle(
//               fontSize: 27, fontWeight: FontWeight.bold, color: Colors.blue),
//         ),
//         centerTitle: true,
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
//                   Padding(
//                     padding: const EdgeInsets.only(left: 14, right: 14),
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
//                         child: filteredUsers.isEmpty
//                             ? const Padding(
//                                 padding: EdgeInsets.only(top: 50),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     SizedBox(height: 40),
//                                     Center(
//                                       child: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Icon(Icons.folder_copy_sharp,
//                                               size: 64, color: Colors.blue),
//                                           SizedBox(height: 5),
//                                           Text(
//                                             'Empty',
//                                             style: TextStyle(
//                                               fontSize: 18,
//                                               color: Colors.black,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             : Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 10, right: 2),
//                                 child: ScrollableTableView(
//                                   headers: [
//                                     "No",
//                                     "Full Name",
//                                     "PhoneNumber",
//                                     "Action",
//                                   ].map((label) {
//                                     return TableViewHeader(
//                                       label: label,
//                                     );
//                                   }).toList(),
//                                   rows: filteredUsers
//                                       .asMap()
//                                       .map((index, user) {
//                                         return MapEntry(
//                                           index,
//                                           TableViewRow(
//                                             height: 50,
//                                             cells: [
//                                               TableViewCell(
//                                                 child: Text((index + 1)
//                                                     .toString()), // Display row number
//                                               ),
//                                               // Full Name column
//                                               TableViewCell(
//                                                 child: Text(
//                                                   "${user['fullName']} ${user['surName'] ?? ''}",
//                                                   style: const TextStyle(
//                                                     fontSize: 10,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                   // textAlign:,
//                                                 ),
//                                               ),

//                                               TableViewCell(
//                                                 child: Text(
//                                                   user['phone'] ?? '',
//                                                   style: const TextStyle(
//                                                       fontSize: 10),
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                               // Email column

//                                               // if (widget.title == "Initial")
//                                               TableViewCell(
//                                                 child: Center(
//                                                   child: PopupMenuButton<
//                                                       SampleItem>(
//                                                     onSelected:
//                                                         (SampleItem item) {
//                                                       setState(() {
//                                                         selectedItem = item;
//                                                         print(
//                                                             "Selected item: $selectedItem");

//                                                         if (selectedItem ==
//                                                             SampleItem.edit) {
//                                                           // Navigate to UpdateCustomerINFOScreen
//                                                           Navigator
//                                                               .pushAndRemoveUntil(
//                                                             context,
//                                                             MaterialPageRoute(
//                                                               builder: (context) =>
//                                                                   UpdateCustomerINFOScreen(
//                                                                 userInfo:
//                                                                     user, // Pass user info if necessary
//                                                               ),
//                                                             ),
//                                                             (route) =>
//                                                                 false, // Remove all routes from stack
//                                                           );
//                                                         }
//                                                       });
//                                                     },
//                                                     iconColor: Colors.blue,
//                                                     itemBuilder: (BuildContext
//                                                             context) =>
//                                                         <PopupMenuEntry<
//                                                             SampleItem>>[
//                                                       const PopupMenuItem<
//                                                           SampleItem>(
//                                                         value: SampleItem.view,
//                                                         child: Text('view'),
//                                                       ),
//                                                       if (widget.title ==
//                                                           'Initial')
//                                                         const PopupMenuItem<
//                                                             SampleItem>(
//                                                           value:
//                                                               SampleItem.edit,
//                                                           child: Text('Edit'),
//                                                         ),
//                                                     ],
//                                                   ),
//                                                 ),

//                                                 // showMenu(
//                                                 //   context: context,
//                                                 //   position:
//                                                 //       RelativeRect.fromLTRB(
//                                                 //           100.0,
//                                                 //           100.0,
//                                                 //           0.0,
//                                                 //           0.0), // Position of the menu
//                                                 //   items: [
//                                                 //     PopupMenuItem<String>(
//                                                 //       value: 'view',
//                                                 //       child: Text('View'),
//                                                 //     ),
//                                                 //     PopupMenuItem<String>(
//                                                 //       value: 'edit',
//                                                 //       child: Text('Edit'),
//                                                 //     ),
//                                                 //   ],
//                                                 // ).then((value) {
//                                                 //   // Handle the option selected
//                                                 //   if (value == 'view') {
//                                                 //     // Handle view action
//                                                 //     print('View selected');
//                                                 //   } else if (value ==
//                                                 //       'edit') {
//                                                 //     // Handle edit action
//                                                 //     print('Edit selected');
//                                                 //   }
//                                                 // }); // Navigator
//                                                 //     .pushAndRemoveUntil(
//                                                 //   context,
//                                                 //   MaterialPageRoute(
//                                                 //     builder: (context) =>
//                                                 //         UpdateCustomerINFOScreen(
//                                                 //       userInfo: user,
//                                                 //     ),
//                                                 //   ),
//                                                 //   (route) => false,
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       })
//                                       .values
//                                       .toList(),
//                                 ),
//                               )),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> fetchUsers(String title) async {
//     setState(() {
//       isLoading1 = true;
//     });

//     const storage = FlutterSecureStorage(
//       aOptions: AndroidOptions(
//         encryptedSharedPreferences: true,
//         storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
//       ),
//     );
//     String? token = await storage.read(key: "token");
//     if (token != null && token.isNotEmpty) {
//       // Decode the token to get user details
//       var decodedToken = JwtDecoder.decode(token);
//       print(decodedToken);
//       setState(() {
//         userId = decodedToken['userId'];
//         print(userId);
//       });
//     }

//     String url = '/api/v1/accounts?size=1000';

//     String status;

//     switch (title) {
//       case "Total":
//         status = "";
//         break;
//       case "Approved":
//         status = "APPROVED";
//         break;
//       case "Unsettled":
//         status = "UNSETTLED";
//         break;
//       case "Pending":
//         status = "PENDING";
//         break;
//       case "Initial":
//         status = "INITIAL";
//         break;
//       default:
//         status = "";
//     }

//     if (status.isNotEmpty) {
//       url += '&status=$status';
//     }

//     print('Fetching users from URL: $url');
//     if (isOnline) {
//       try {
//         var response = await networkHandler.getUserData(url);

//         print("daaaaaaaaa");
//         print(response);

//         if (response.statusCode == 200) {
//           List<dynamic> fetchedUsers = jsonDecode(response.body);
//           print(fetchedUsers);
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
//       try {
//         // Initialize DatabaseHelper
//         DatabaseHelper dbHelper = DatabaseHelper();

//         List<Map<String, dynamic>> localUsers = await dbHelper
//             .getCustomersByStatus(title == "Total" ? "Total" : status, userId!);

//         if (localUsers.isNotEmpty) {
//           setState(() {
//             // Assign localUsers to users
//             users = localUsers;
//             // Call filterUsers after assigning users
//             filterUsers();
//             isLoading1 = false;
//           });
//         } else {
//           print('No users found in local storage');
//           throw Exception('Failed to load users');
//         }
//       } catch (error) {
//         print('Error fetching users from local storage: $error');
//         setState(() {
//           isLoading1 = false;
//         });
//       }
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
//     const storage = FlutterSecureStorage(
//       aOptions: AndroidOptions(
//         encryptedSharedPreferences: true,
//         storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
//       ),
//     );
//     String? token = await storage.read(key: "token");
//     if (token != null && token.isNotEmpty) {
//       // Decode the token to get user details
//       var decodedToken = JwtDecoder.decode(token);
//       print(decodedToken);
//       setState(() {
//         userId = decodedToken['userId'];
//         print(userId);
//       });
//     } else {
//       setState(() {
//         // isLoading = false; // Set loading to false if no token found
//       });
//     }
//   }
// }
