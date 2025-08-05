// // ignore_for_file: file_names, use_super_parameters, library_private_types_in_public_api, deprecated_member_use, avoid_print, sized_box_for_whitespace

// import 'dart:convert';

// import 'package:coopengageplus/NetworkHandler.dart';
// import 'package:flutter/material.dart';

// class HomeBody extends StatefulWidget {
//   const HomeBody({Key? key}) : super(key: key);

//   @override
//   _HomeBodyState createState() => _HomeBodyState();
// }

// class _HomeBodyState extends State<HomeBody> {
//   final NetworkHandler networkHandler =
//       NetworkHandler(); // Initialize the NetworkHandler
//   int? totalUsers;
//   int? approvedUsers;
//   int? pendingUsers;
//   int? initialStatus;
//   bool isLoading = true;
//   List<dynamic> users = []; // This will hold all the fetched users
//   List<dynamic> filteredUsers = []; // This will hold the filtered users
//   String dropdownValue = 'ALL';
//   bool isLoading1 = false;
//   String searchQuery = '';
//   @override
//   void initState() {
//     super.initState();
//     fetchUserCounts();
//     fetchUsers();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 5),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//             // Total column
//             Column(
//               children: [
//                 const Text(
//                   'Initial',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 totalUsers == null
//                     ? const CircularProgressIndicator() // Show loading indicator while fetching
//                     : Text(
//                         '$initialStatus', // Show total users value
//                         style: const TextStyle(
//                           fontSize: 19,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue,
//                         ),
//                       ),
//               ],
//             ),
//             // Approved column
//             Column(
//               children: [
//                 const Text(
//                   'Approved',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 approvedUsers == null
//                     ? const CircularProgressIndicator()
//                     : Text(
//                         '$approvedUsers', // Use the fetched approved users value
//                         style: const TextStyle(
//                           fontSize: 19,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green,
//                         ),
//                       ),
//               ],
//             ),
//             // Pending column
//             Column(
//               children: [
//                 const Text(
//                   'Pending',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 pendingUsers == null
//                     ? CircularProgressIndicator()
//                     : Text(
//                         '$pendingUsers', // Use the fetched pending users value
//                         style: TextStyle(
//                           fontSize: 19,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.orange,
//                         ),
//                       ),
//               ],
//             ),
//           ]),
//           const SizedBox(height: 20),
//           Padding(
//             padding: const EdgeInsets.only(left: 30, right: 15),
//             child: Text(
//               dropdownValue,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Padding(
//             padding: const EdgeInsets.only(left: 14, right: 14),
//             child: TextFormField(
//               decoration: InputDecoration(
//                 hintText: 'Search...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 // Dropdown as a trailing icon inside the TextField
//                 suffixIcon: DropdownButton<String>(
//                   value: dropdownValue,
//                   icon: const Icon(Icons.arrow_drop_down),
//                   underline: Container(), // To remove the underline of dropdown
//                   items: <String>['ALL', 'APPROVED', 'PENDING', 'INITIAL']
//                       .map<DropdownMenuItem<String>>((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(
//                         value,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       dropdownValue = newValue!;
//                       fetchUsers();
//                     });
//                   },
//                 ),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   searchQuery = value;
//                   filterUsers();
//                 });
//               },
//             ),
//           ),
//           const SizedBox(height: 12),
//           if (isLoading1)
//             const Center(child: CircularProgressIndicator())
//           else
//             Expanded(
//                 child: filteredUsers.isEmpty
//                     ? const Padding(
//                         padding: EdgeInsets.only(top: 50),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             SizedBox(height: 40),
//                             Center(
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(Icons.folder_copy_sharp,
//                                       size: 64, color: Colors.blue),
//                                   SizedBox(height: 5),
//                                   Text(
//                                     'Empty',
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : ListView.builder(
//                         itemCount: filteredUsers.length,
//                         itemBuilder: (context, index) {
//                           return Padding(
//                             padding: const EdgeInsets.only(
//                               left: 11.0,
//                               top: 5.0,
//                               right: 10.0,
//                             ),
//                             child: GestureDetector(
//                               onTap: () {
//                                 print(filteredUsers[index]['fullName']);
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.all(9),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(8),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.grey.withOpacity(0.2),
//                                       spreadRadius: 2,
//                                       blurRadius: 5,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Expanded(
//                                       child: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             filteredUsers[index]['fullName'] +
//                                                     filteredUsers[index]
//                                                         ['surName'] ??
//                                                 '',
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                             overflow: TextOverflow
//                                                 .ellipsis, // Prevent overflow
//                                           ),
//                                           Text(
//                                             filteredUsers[index]['email'] ?? '',
//                                             style: const TextStyle(
//                                               fontSize: 9,
//                                             ),
//                                             overflow: TextOverflow
//                                                 .ellipsis, // Prevent overflow
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     // Show Update icon only if dropdown value is 'INITIAL'
//                                     if (dropdownValue == 'INITIAL')
//                                       Container(
//                                         width:
//                                             35, // Optional: set a width for the icon button area
//                                         child: Center(
//                                           child: IconButton(
//                                             icon: Icon(Icons.edit,
//                                                 color: Colors.blue),
//                                             onPressed: () {
//                                               // Navigator.pushAndRemoveUntil(
//                                               //   context,
//                                               //   MaterialPageRoute(
//                                               //     builder: (context) =>
//                                               //         CustomerINFO(
//                                               //       userInfo:
//                                               //           filteredUsers[index],
//                                               //     ), // Pass user info here
//                                               //   ),
//                                               //   (route) => false,
//                                               // );
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       )),
//         ],
//       ),
//     );
//   }

//   // Function to fetch data from the API
//   Future<void> fetchUserCounts() async {
//     String url = '/api/v1/accounts/status-count?userId=2'; // API endpoint

//     try {
//       var response = await networkHandler.fetchData(url);
//       print(response);
//       print(response.statusCode);
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         print(data['APPROVED']);
//         // Assuming the API response contains these fields:
//         // {"total": 10, "approved": 5, "pending": 3}
//         setState(() {
//           totalUsers = data['APPROVED'] + data["PENDING"] + data["INITIAL"];
//           approvedUsers = data['APPROVED'];
//           pendingUsers = data['PENDING'];
//           initialStatus = data['INITIAL'];
//           isLoading = false;
//         });
//       } else {
//         throw Exception('Failed to load user counts');
//       }
//     } catch (error) {
//       print('Error fetching user data: $error');
//       setState(() {
//         isLoading = false; // Stop loading even if there is an error
//       });
//     }
//   }

//   // Function to fetch users based on selected filter and search query
//   Future<void> fetchUsers() async {
//     setState(() {
//       isLoading1 = true; // Show loading
//     });

//     String url = '/api/v1/accounts?clientId=1';
//     if (dropdownValue == 'APPROVED') {
//       url += '&status=APPROVED';
//     } else if (dropdownValue == 'PENDING') {
//       url += '&status=PENDING';
//     } else if (dropdownValue == 'INITIAL') {
//       url += '&status=INITIAL';
//     }

//     try {
//       var response = await networkHandler.fetchData(url);

//       if (response.statusCode == 200) {
//         print(response.body);
//         List<dynamic> fetchedUsers = jsonDecode(response.body);
//         setState(() {
//           users = fetchedUsers;
//           filterUsers();
//           isLoading1 = false;
//         });
//       } else {
//         throw Exception('Failed to load users');
//       }
//     } catch (error) {
//       print('Error fetching users: $error');
//       setState(() {
//         isLoading1 = false;
//       });
//     }
//   }

//   void filterUsers() {
//     setState(() {
//       filteredUsers = users
//           .where((user) => user['fullName']
//               .toLowerCase()
//               .contains(searchQuery.toLowerCase()))
//           .toList();
//     });
//   }
// }
