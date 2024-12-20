// // // ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/features/onboarding/pages/ViewCustomerInfoPage.dart';
import 'package:coopengageplus/features/onboarding/screens/updateCustomerInfoScreen.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:scrollable_table_view/scrollable_table_view.dart';

class UserListPage extends StatefulWidget {
  final String title;

  const UserListPage({Key? key, required this.title}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

enum SampleItem { view, edit }

class _UserInfoPageState extends State<UserListPage> {
  final NetworkHandler networkHandler = NetworkHandler();
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  bool isLoading1 = false;
  String searchQuery = '';

  SampleItem? selectedItem;

  int? userId;

  @override
  void initState() {
    super.initState();
    _fetchToken();
    fetchUsers(widget.title);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    SampleItem? selectedItem;
    int index = 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          " ${widget.title}",
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Container(
            width: width < 600 ? double.infinity : width * 0.5,
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        isDense: true,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                          filterUsers();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isLoading1)
                    const Center(child: CircularProgressIndicator())
                  else
                    Expanded(
                        child: filteredUsers.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.only(top: 50),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 40),
                                    Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.folder_copy_sharp,
                                              size: 64, color: Colors.blue),
                                          SizedBox(height: 5),
                                          Text(
                                            'Empty',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 2),
                                child: ScrollableTableView(
                                  headers: [
                                    "No",
                                    "Full Name",
                                    "PhoneNumber",
                                    "Action",
                                  ].map((label) {
                                    return TableViewHeader(
                                      label: label,
                                    );
                                  }).toList(),
                                  rows: filteredUsers
                                      .asMap()
                                      .map((index, user) {
                                        return MapEntry(
                                          index,
                                          TableViewRow(
                                            height: 50,
                                            cells: [
                                              TableViewCell(
                                                child: Text((index + 1)
                                                    .toString()), // Display row number
                                              ),
                                              // Full Name column
                                              TableViewCell(
                                                child: Text(
                                                  // "${user['fullName']} ${user['surName'] ?? ''}",
                                                  user['fullName'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  // textAlign:,
                                                ),
                                              ),

                                              TableViewCell(
                                                child: Text(
                                                  user['phone'] ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 10),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              // Email column

                                              // if (widget.title == "Initial")
                                              TableViewCell(
                                                child: Center(
                                                  child: PopupMenuButton<
                                                      SampleItem>(
                                                    onSelected:
                                                        (SampleItem item) {
                                                      setState(() {
                                                        selectedItem = item;
                                                        print(
                                                            "Selected item: $selectedItem");

                                                        print(
                                                            "Selected item: $selectedItem");
                                                        print(
                                                            "User data: $user");

                                                        if (selectedItem ==
                                                            SampleItem.edit) {
                                                          // Navigate to UpdateCustomerINFOScreen
                                                          Navigator
                                                              .pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  UpdateCustomerINFOScreen(
                                                                userInfo:
                                                                    user, // Pass user info if necessary
                                                              ),
                                                            ),
                                                            (route) =>
                                                                false, // Remove all routes from stack
                                                          );
                                                        } else if (selectedItem ==
                                                            SampleItem.view) {
                                                          Navigator
                                                              .pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ViewCustomerInfo(
                                                                      registrationData:
                                                                          user,
                                                                      title: widget
                                                                          .title

                                                                      // Pass user info if necessary
                                                                      ),
                                                            ),
                                                            (route) =>
                                                                false, // Remove all routes from stack
                                                          );
                                                        }
                                                      });
                                                    },
                                                    iconColor: Colors.blue,
                                                    itemBuilder: (BuildContext
                                                            context) =>
                                                        <PopupMenuEntry<
                                                            SampleItem>>[
                                                      const PopupMenuItem<
                                                          SampleItem>(
                                                        value: SampleItem.view,
                                                        child: Text('view'),
                                                      ),
                                                      if (widget.title ==
                                                          'Initial')
                                                        const PopupMenuItem<
                                                            SampleItem>(
                                                          value:
                                                              SampleItem.edit,
                                                          child: Text('Edit'),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      })
                                      .values
                                      .toList(),
                                ),
                              )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fetchUsers(String title) async {
    setState(() {
      isLoading1 = true;
    });

    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      // Decode the token to get user details
      var decodedToken = JwtDecoder.decode(token);
      print(decodedToken);
      setState(() {
        userId = decodedToken['userId'];
        print(userId);
      });
    }

    print("title");
    print(title);

    String url = '/api/v1/accounts';
    int? SIZE;

    String status;

    switch (title) {
      case "Total":
        status = "";
        break;
      case "Approved":
        status = "APPROVED";
        SIZE = TOTALAPPROVED;
        break;
      case "Unsettled":
        status = "UNSETTLED";
        SIZE = TOTALUNSETTLED;
        break;
      case "Pending":
        status = "PENDING";
        SIZE = TOTALPENDING;
        break;
      case "Initial":
        status = "INITIAL";
        SIZE = TOTALINITIAL;
        break;
      default:
        status = "";
    }

    if (status.isNotEmpty) {
      url += '?status=$status';
    }

    print('Fetching users from URL: $url');
    if (isOnline) {
      try {
        SIZE = SIZE ?? 1000;

        print("SIZE");
        print(SIZE);
        int size = 1000;
        String urlWithParams = '$url&size= 10000';
        print(urlWithParams);

        var response = await networkHandler.getUserData(urlWithParams);
        // var response = '$url?size=10';

        print("daaaaaaaaa");
        print(response.body);

        if (response.statusCode == 200) {
          List<dynamic> fetchedUsers = jsonDecode(response.body);
          print(fetchedUsers);
          setState(() {
            users = fetchedUsers;
            filterUsers();
            isLoading1 = false;
          });
        } else {
          throw Exception('Failed to load users');
        }
      } catch (error) {
        print('Error fetching users: $error');
        setState(() {
          isLoading1 = false;
        });
      }
    } else {
      try {
        // Initialize DatabaseHelper
        DatabaseHelper dbHelper = DatabaseHelper();

        List<Map<String, dynamic>> localUsers = await dbHelper
            .getCustomersByStatus(title == "Total" ? "Total" : status, userId!);

        if (localUsers.isNotEmpty) {
          setState(() {
            // Assign localUsers to users
            users = localUsers;
            // Call filterUsers after assigning users
            filterUsers();
            isLoading1 = false;
          });
        } else {
          print('No users found in local storage');
          throw Exception('Failed to load users');
        }
      } catch (error) {
        print('Error fetching users from local storage: $error');
        setState(() {
          isLoading1 = false;
        });
      }
    }
  }

  void filterUsers() {
    setState(() {
      filteredUsers = users
          .where((user) => (user['fullName']?.toLowerCase() ?? '')
              .contains(searchQuery.toLowerCase()))
          .toList();
      print("filteredusers");
      print(filteredUsers);
    });
  }

  Future<void> _fetchToken() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      // Decode the token to get user details
      var decodedToken = JwtDecoder.decode(token);
      print(decodedToken);
      setState(() {
        userId = decodedToken['userId'];
        print(userId);
      });
    } else {
      setState(() {});
    }
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:coopengageplus/NetworkHandler.dart';
// import 'package:coopengageplus/helper/databaseHelper.dart';
// import 'package:coopengageplus/main.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// class UserListPage extends StatefulWidget {
//   final String title;

//   const UserListPage({Key? key, required this.title}) : super(key: key);

//   @override
//   _UserInfoPageState createState() => _UserInfoPageState();
// }

// class _UserInfoPageState extends State<UserListPage> {
//   final NetworkHandler networkHandler = NetworkHandler();
//   List<dynamic> users = [];
//   List<dynamic> filteredUsers = [];
//   bool isLoading1 = false;
//   String searchQuery = '';
//   int currentPage = 1; // Current page for pagination
//   int pageSize = 5; // Set number of items per page
//   late PagingController<int, dynamic> _pagingController;
//   int? userId;

//   @override
//   void initState() {
//     super.initState();
//     _fetchToken();

//     _pagingController = PagingController(firstPageKey: 0);
//     _pagingController.addPageRequestListener((pageKey) {
//       fetchUsers(widget.title, pageKey, pageSize);
//     });
//   }

//   @override
//   void dispose() {
//     _pagingController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Text(
//           " ${widget.title}",
//           style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
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
//                   Expanded(
//                     child: PagedListView<int, dynamic>(
//                       pagingController: _pagingController,
//                       builderDelegate: PagedChildBuilderDelegate<dynamic>(
//                         itemBuilder: (context, user, index) {
//                           return ListTile(
//                             title: Text(user['fullName'] ?? ''),
//                             subtitle: Text(user['phone'] ?? ''),
//                             onTap: () {
//                               // Add your navigation or any action on user tap
//                             },
//                           );
//                         },
//                         firstPageProgressIndicatorBuilder: (_) =>
//                             const Center(child: CircularProgressIndicator()),
//                         newPageProgressIndicatorBuilder: (_) =>
//                             const Center(child: CircularProgressIndicator()),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> fetchUsers(String title, int page, int size) async {
//     try {
//       String url = '/api/v1/accounts?page=$page&size=$size';

//       String status;

//       switch (title) {
//         case "Total":
//           status = "";
//           break;
//         case "Approved":
//           status = "APPROVED";
//           break;
//         case "Unsettled":
//           status = "UNSETTLED";
//           break;
//         case "Pending":
//           status = "PENDING";
//           break;
//         case "Initial":
//           status = "INITIAL";
//           break;
//         default:
//           status = "";
//       }

//       if (status.isNotEmpty) {
//         url += '&status=$status';
//       }

//       const storage = FlutterSecureStorage();
//       String? token = await storage.read(key: "token");
//       if (token != null && token.isNotEmpty) {
//         var decodedToken = JwtDecoder.decode(token);
//         setState(() {
//           userId = decodedToken['userId'];
//         });
//       }

//       if (isOnline) {
//         var response = await networkHandler.getUserData(url);

//         if (response.statusCode == 200) {
//           List<dynamic> fetchedUsers = jsonDecode(response.body);

//           if (fetchedUsers.isEmpty) {
//             _pagingController.appendLastPage(fetchedUsers);
//           } else {
//             _pagingController.appendPage(fetchedUsers, page + 1);
//           }
//         } else {
//           _pagingController.error = 'Failed to load users';
//         }
//       } else {
//         DatabaseHelper dbHelper = DatabaseHelper();
//         List<Map<String, dynamic>> localUsers = await dbHelper
//             .getCustomersByStatus(title == "Total" ? "Total" : status, userId!);

//         if (localUsers.isNotEmpty) {
//           _pagingController.appendPage(localUsers, page + 1);
//         } else {
//           _pagingController.error = 'Failed to load users from local storage';
//         }
//       }
//     } catch (error) {
//       _pagingController.error = 'Error fetching users: $error';
//     }
//   }

//   // void filterUsers() {
//   //   if (searchQuery.isEmpty) {
//   //     filteredUsers = users;

//   //     print("filteredUsers");
//   //     print(filteredUsers.length);
//   //   } else {
//   //     filteredUsers = users.where((user) {
//   //       String fullName = user['fullName'].toLowerCase();
//   //       return fullName.contains(searchQuery.toLowerCase());
//   //     }).toList();
//   //   }
//   //   setState(() {});
//   // }

//   void filterUsers() {
//     print("Search Query: $searchQuery");
//     print("Users list length: ${users.length}");

//     if (searchQuery.isEmpty) {
//       filteredUsers = users;
//     } else {
//       filteredUsers = users.where((user) {
//         String fullName = user['fullName']?.toLowerCase() ?? '';
//         return fullName.contains(searchQuery.toLowerCase());
//       }).toList();
//     }
//     print("Filtered Users length: ${filteredUsers.length}");
//     setState(() {});
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

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:coopengageplus/NetworkHandler.dart';
// import 'package:coopengageplus/helper/databaseHelper.dart';
// import 'package:coopengageplus/main.dart';

// class UserTableDataSource extends DataTableSource {
//   final List<dynamic> _users;
//   final BuildContext context;

//   UserTableDataSource(this._users, this.context);

//   @override
//   DataRow? getRow(int index) {
//     if (index >= _users.length) return null;

//     final user = _users[index];
//     return DataRow.byIndex(
//       index: index,
//       cells: [
//         DataCell(Text(user['fullName'] ?? 'N/A')),
//         DataCell(Text(user['phone'] ?? 'N/A')),
//         DataCell(Text(user['status'] ?? 'N/A')),
//         DataCell(
//           TextButton(
//             onPressed: () {
//               // Define the action for the row
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Selected: ${user['fullName']}')),
//               );
//             },
//             child: const Text('Details'),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   bool get isRowCountApproximate => false;

//   @override
//   int get rowCount => _users.length;

//   @override
//   int get selectedRowCount => 0;
// }

// class UserListPage extends StatefulWidget {
//   final String title;

//   const UserListPage({Key? key, required this.title}) : super(key: key);

//   @override
//   _UserListPageState createState() => _UserListPageState();
// }

// class _UserListPageState extends State<UserListPage> {
//   final NetworkHandler networkHandler = NetworkHandler();
//   List<dynamic> users = [];
//   bool isLoading = false;
//   int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
//   int totalUsers = 0; // Total count of users from the server
//   int currentPage = 0;
//   int pageSize = 20;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUsers(currentPage, pageSize);
//   }

//   Future<void> _fetchUsers(int page, int size) async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       String title = widget.title;
//       String status;

//       switch (title) {
//         case "Total":
//           status = "";
//           break;
//         case "Approved":
//           status = "APPROVED";
//           break;
//         case "Unsettled":
//           status = "UNSETTLED";
//           break;
//         case "Pending":
//           status = "PENDING";
//           break;
//         case "Initial":
//           status = "INITIAL";
//           break;
//         default:
//           status = "";
//       }

//       String url = '/api/v1/accounts?page=$page&size=$size&status=$status';
//       const storage = FlutterSecureStorage();
//       String? token = await storage.read(key: "token");

//       if (token != null && token.isNotEmpty) {
//         var decodedToken = JwtDecoder.decode(token);
//         int? userId = decodedToken['userId'];

//         if (userId != null) {
//           if (isOnline) {
//             var response = await networkHandler.getUserData(url);

//             if (response.statusCode == 200) {
//               // Print the response body to debug the structure
//               print('Response body: ${response.body}');

//               final body = jsonDecode(response.body);

//               if (body is Map<String, dynamic>) {
//                 // Assuming 'users' and 'totalCount' are the fields
//                 if (body.containsKey('users') &&
//                     body.containsKey('totalCount')) {
//                   setState(() {
//                     users.addAll(body['users']);
//                     totalUsers = body['totalCount'];
//                   });
//                 } else {
//                   throw Exception('Missing expected fields in response');
//                 }
//               } else if (body is List) {
//                 // Handle case if the response is directly a list
//                 setState(() {
//                   users.addAll(body);
//                   totalUsers =
//                       body.length; // Assume the length is the total count
//                 });
//               } else {
//                 throw Exception('Unexpected response format');
//               }
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Failed to fetch users')),
//               );
//             }
//           } else {
//             DatabaseHelper dbHelper = DatabaseHelper();
//             final localUsers =
//                 await dbHelper.getCustomersByStatus(widget.title, userId);
//             setState(() {
//               users.addAll(localUsers);
//             });
//           }
//         }
//       }
//     } catch (e) {
//       print(e);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching users: $e')),
//       );
//     }

//     setState(() {
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dataSource = UserTableDataSource(users, context);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Text(
//           " ${widget.title}",
//           style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: PaginatedDataTable(
//                 header: const Text('User List'),
//                 columns: const [
//                   DataColumn(label: Text('Full Name')),
//                   DataColumn(label: Text('Phone')),
//                   DataColumn(label: Text('Status')),
//                   DataColumn(label: Text('Actions')),
//                 ],
//                 source: dataSource,
//                 rowsPerPage: rowsPerPage,
//                 availableRowsPerPage: const [5, 10, 20],
//                 onRowsPerPageChanged: (value) {
//                   if (value != null) {
//                     setState(() {
//                       rowsPerPage = value;
//                       // Reset to first page when rows per page is changed
//                       currentPage = 0;
//                       users.clear();
//                     });
//                     _fetchUsers(currentPage, rowsPerPage); // Fetch new data
//                   }
//                 },
//                 onPageChanged: (page) {
//                   currentPage = page; // Update the current page
//                   // Fetch users when user navigates to a new page
//                   if (currentPage * rowsPerPage >= users.length &&
//                       users.length < totalUsers) {
//                     _fetchUsers(currentPage, rowsPerPage);
//                   }
//                 },
//               ),
//             ),
//     );
//   }
// }

///45678

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:coopengageplus/NetworkHandler.dart';
// import 'package:coopengageplus/features/onboarding/pages/ViewCustomerInfoPage.dart';
// import 'package:coopengageplus/features/onboarding/screens/updateCustomerInfoScreen.dart';
// import 'package:coopengageplus/helper/databaseHelper.dart';
// import 'package:coopengageplus/main.dart';
// import 'package:scrollable_table_view/scrollable_table_view.dart';

// class UserListPage extends StatefulWidget {
//   final String title;

//   const UserListPage({Key? key, required this.title}) : super(key: key);

//   @override
//   _UserListPageState createState() => _UserListPageState();
// }

// enum SampleItem { view, edit }

// class _UserListPageState extends State<UserListPage> {
//   final NetworkHandler networkHandler = NetworkHandler();
//   List<dynamic> users = [];
//   bool isLoading = false;
//   int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
//   int totalUsers = 0; // Total count of users from the server
//   int currentPage = 0;
//   int pageSize = 5;
//   final ScrollController _scrollController = ScrollController();
//   bool isLoading1 = true; // Assume data is loading initially
//   List<Map<String, dynamic>> filteredUsers =
//       []; // This will hold the filtered users
//   SampleItem? selectedItem;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUsers(currentPage, pageSize);
//     _scrollController.addListener(_scrollListener);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_scrollListener);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchUsers(int page, int size) async {
//     setState(() {
//       isLoading = true; // Start loading when the fetch begins
//     });

//     try {
//       String title = widget.title;
//       String status;

//       // Set status based on the page title
//       switch (title) {
//         case "Total":
//           status = "";
//           break;
//         case "Approved":
//           status = "APPROVED";
//           break;
//         case "Unsettled":
//           status = "UNSETTLED";
//           break;
//         case "Pending":
//           status = "PENDING";
//           break;
//         case "Initial":
//           status = "INITIAL";
//           break;
//         default:
//           status = "";
//       }

//       // Construct the URL with query parameters
//       String url = '/api/v1/accounts?page=$page&size=$size&status=$status';

//       // Retrieve the token from secure storage
//       const storage = FlutterSecureStorage();
//       String? token = await storage.read(key: "token");

//       if (token != null && token.isNotEmpty) {
//         var decodedToken = JwtDecoder.decode(token);
//         int? userId = decodedToken['userId'];

//         if (userId != null) {
//           if (isOnline) {
//             // Fetch data from the network
//             var response = await networkHandler.getUserData(url);

//             if (response.statusCode == 200) {
//               final body = jsonDecode(response.body);

//               setState(() {
//                 isLoading = false; // Set loading to false after the response
//               });

//               // Handle response format
//               if (body is List) {
//                 setState(() {
//                   filteredUsers.addAll(List<Map<String, dynamic>>.from(
//                       body)); // Add more users to the list
//                   totalUsers = body.length; // Update total user count if needed
//                 });
//               } else if (body is Map<String, dynamic>) {
//                 setState(() {
//                   filteredUsers.addAll(
//                       List<Map<String, dynamic>>.from(body['users'] ?? []));
//                   totalUsers = body['totalCount'] ??
//                       0; // Update total count if present in the response
//                 });
//               } else {
//                 throw Exception('Unexpected response format');
//               }
//             } else {
//               setState(() {
//                 isLoading =
//                     false; // Stop loading if the response is not successful
//               });
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Failed to fetch users')),
//               );
//             }
//           } else {
//             DatabaseHelper dbHelper = DatabaseHelper();
//             final localUsers =
//                 await dbHelper.getCustomersByStatus(widget.title, userId);
//             setState(() {
//               filteredUsers.addAll(List<Map<String, dynamic>>.from(localUsers));
//               isLoading = false;
//             });
//           }
//         } else {
//           setState(() {
//             isLoading = false;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('User ID is invalid')),
//           );
//         }
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Token not found')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching users: $e')),
//       );
//     }
//   }

//   void _scrollListener() {
//     if (_scrollController.position.pixels ==
//         _scrollController.position.maxScrollExtent) {
//       if (!isLoading && filteredUsers.length < totalUsers) {
//         // Fetch more data when user reaches the bottom
//         setState(() {
//           isLoading1 = true;
//           currentPage++; // Increment page number
//         });
//         _fetchUsers(currentPage, pageSize);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Text(
//           " ${widget.title}",
//           style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           const SizedBox(height: 12),
//           if (isLoading)
//             const Center(child: CircularProgressIndicator())
//           else
//             Expanded(
//               child: filteredUsers.isEmpty
//                   ? const Padding(
//                       padding: EdgeInsets.only(top: 50),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           SizedBox(height: 40),
//                           Center(
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.folder_copy_sharp,
//                                     size: 64, color: Colors.blue),
//                                 SizedBox(height: 5),
//                                 Text(
//                                   'Empty',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   : Padding(
//                       padding: const EdgeInsets.only(left: 10, right: 2),
//                       child: ScrollableTableView(
//                         headers: [
//                           "No",
//                           "Full Name",
//                           "PhoneNumber",
//                           "Action",
//                         ].map((label) {
//                           return TableViewHeader(
//                             label: label,
//                           );
//                         }).toList(),
//                         rows: filteredUsers
//                             .asMap()
//                             .map((index, user) {
//                               return MapEntry(
//                                 index,
//                                 TableViewRow(
//                                   height: 50,
//                                   cells: [
//                                     TableViewCell(
//                                       child: Text((index + 1)
//                                           .toString()), // Display row number
//                                     ),
//                                     // Full Name column
//                                     TableViewCell(
//                                       child: Text(
//                                         user['fullName'] ?? '',
//                                         style: const TextStyle(
//                                           fontSize: 10,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                     TableViewCell(
//                                       child: Text(
//                                         user['phone'] ?? '',
//                                         style: const TextStyle(fontSize: 10),
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                     // Action column with PopupMenuButton
//                                     TableViewCell(
//                                       child: Center(
//                                         child: PopupMenuButton<SampleItem>(
//                                           onSelected: (SampleItem item) {
//                                             setState(() {
//                                               selectedItem = item;
//                                               print(
//                                                   "Selected item: $selectedItem");

//                                               if (selectedItem ==
//                                                   SampleItem.edit) {
//                                                 // Navigate to UpdateCustomerINFOScreen
//                                                 Navigator.pushAndRemoveUntil(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         UpdateCustomerINFOScreen(
//                                                       userInfo:
//                                                           user, // Pass user info if necessary
//                                                     ),
//                                                   ),
//                                                   (route) =>
//                                                       false, // Remove all routes from stack
//                                                 );
//                                               } else if (selectedItem ==
//                                                   SampleItem.view) {
//                                                 Navigator.pushAndRemoveUntil(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         ViewCustomerInfo(
//                                                       registrationData: user,
//                                                       title: widget
//                                                           .title, // Pass user info if necessary
//                                                     ),
//                                                   ),
//                                                   (route) =>
//                                                       false, // Remove all routes from stack
//                                                 );
//                                               }
//                                             });
//                                           },
//                                           iconColor: Colors.blue,
//                                           itemBuilder: (BuildContext context) =>
//                                               <PopupMenuEntry<SampleItem>>[
//                                             const PopupMenuItem<SampleItem>(
//                                               value: SampleItem.view,
//                                               child: Text('view'),
//                                             ),
//                                             if (widget.title == 'Initial')
//                                               const PopupMenuItem<SampleItem>(
//                                                 value: SampleItem.edit,
//                                                 child: Text('Edit'),
//                                               ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             })
//                             .values
//                             .toList(),
//                       ),
//                     ),
//             ),
//         ],
//       ),
//     );
//   }
// }
