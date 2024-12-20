// ignore_for_file: file_names, non_constant_identifier_names

import 'package:coopengageplus/pages/LoginPage.dart';
import 'package:coopengageplus/pages/UserListPage.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

String dropdownValue = 'ALL';
// final String username = "John Doe"; // Replace this with the actual username
// final String firstLetter = username.isNotEmpty ? username[0].toUpperCase() : '';
// const storage = FlutterSecureStorage();

final storage = FlutterSecureStorage();
bool isLoading = true; // Loading state
String username = ""; // Default username
String firstLetter = "";
List<String> users = [
  // 'Alice Johnson',
  // 'Bob Smith',
  // 'Charlie Brown',
  // 'David Wilson',
  // 'Eve Davis',
  // 'Frank Miller',
  // 'Alice Johnson',
  // 'Bob Smith',
  // 'Charlie Brown',
  // 'David Wilson',
  // 'Eve Davis',
  // 'Frank Miller',
  // 'Alice Johnson',
  // 'Bob Smith',
  // 'Charlie Brown',
  // 'David Wilson',
  // 'Eve Davis',
  // 'Frank Miller',
  // 'Alice Johnson',
  // 'Bob Smith',
  // 'Charlie Brown',
  // 'David Wilson',
  // 'Eve Davis',
  // 'Frank Miller',
  // 'Alice Johnson',
  // 'Bob Smith',
  // 'Charlie Brown',
  // 'David Wilson',
  // 'Eve Davis',
  // 'Frank Miller',
  // Add more users as needed
];

List<String> filteredUsers = [];

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();
    _fetchToken();
    filteredUsers = users;
  }

  Future<void> _fetchToken() async {
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      // Decode the token to get user details
      var decodedToken = JwtDecoder.decode(token);

      setState(() {
        username = decodedToken['sub'] ?? "User"; // Set username
        firstLetter = username.isNotEmpty
            ? username[0].toUpperCase()
            : ''; // Get first letter
        isLoading = false; // Set loading to false
      });
    } else {
      setState(() {
        isLoading = false; // Set loading to false if no token found
      });
    }
  }

  void filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredUsers = users; // Show all users if search is empty
      } else {
        filteredUsers = users
            .where((user) => user.toLowerCase().contains(query.toLowerCase()))
            .toList(); // Filter users based on query
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(context),
      appBar: AppBar(
        title: const Text(""),
        centerTitle: true,
      ),
      body: HomeBody(),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        shape: const CircularNotchedRectangle(), // Optional notch for a FAB
        child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 26.0, vertical: 7.0),
            child: FormHelper.submitButton("Add New Customer",
                fontSize: 19,
                width: MediaQuery.of(context).size.width * 0.5,
                btnColor: Colors.blueAccent,
                borderColor: Colors.blueAccent, () {
              // Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => const Registration(),
              //     ),
              //     (route) => false);
            })),
      ),
    );
  }

  Padding homeBody() {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Total column
              Column(
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8), // Space between text and value
                  Text(
                    '0', // The value
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              // Approved column
              Column(
                children: [
                  Text(
                    'Approved',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '0', // The value
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              // Pending column
              Column(
                children: [
                  Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '0', // The value
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.only(left: 30, right: 15),
            child: Text(
              '$dropdownValue',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // Dropdown as a trailing icon inside the TextField
                suffixIcon: DropdownButton<String>(
                  value: dropdownValue,
                  // isDense: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  underline: Container(), // To remove the underline of dropdown
                  items: <String>['ALL', 'APPROVED', 'PENDING']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                ),
              ),
            ),
          ),

          // ListView to display filtered users
          // ListView to display filtered users with dividers
          // ListView to display filtered users with dividers
          // Expanded(
          //   child: ListView.separated(
          //     itemCount: filteredUsers.length,
          //     itemBuilder: (context, index) {
          //       return Padding(
          //         padding: const EdgeInsets.only(
          //             left: 14.0, top: 8.0, bottom: 8.0),
          //         child: GestureDetector(
          //           onTap: () {
          //             // Handle item tap
          //             print("Tapped on: ${filteredUsers[index]}");
          //           },
          //           child: Container(
          //             padding:
          //                 EdgeInsets.all(12), // Inner padding for ListTile
          //             decoration: BoxDecoration(
          //               color: Colors.white,
          //               borderRadius: BorderRadius.circular(8),
          //               boxShadow: [
          //                 BoxShadow(
          //                   color: Colors.grey.withOpacity(0.2),
          //                   spreadRadius: 1,
          //                   blurRadius: 5,
          //                   offset:
          //                       Offset(0, 2), // changes position of shadow
          //                 ),
          //               ],
          //             ),
          //             child: Row(
          //               children: [
          //                 // Displaying the number
          //                 Text(
          //                   '${index + 1}.', // Numbering starts from 1
          //                   style: const TextStyle(
          //                       fontSize: 16, fontWeight: FontWeight.bold),
          //                 ),
          //                 SizedBox(width: 8), // Space between number and text
          //                 Expanded(
          //                   child: Text(
          //                     filteredUsers[index],
          //                     style: TextStyle(fontSize: 16),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       );
          //     },
          //     separatorBuilder: (context, index) => Divider(
          //       color: Colors.grey.shade300,
          //       height: 0.1,
          //       thickness: 0.5,
          //       indent: 14,
          //       endIndent: 14,
          //     ),
          //   ),
          // ),

          // Check if filteredUsers is empty
          Expanded(
            child: filteredUsers.isEmpty
                ? const Padding(
                    padding:
                        EdgeInsets.only(top: 50), // Adjust this value as needed
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.start, // Align to the top
                      children: [
                        SizedBox(
                            height:
                                50), // Add space from the top to push content down
                        Center(
                          // Center the content horizontally
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
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'No registered Customer',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 14.0, top: 8.0, bottom: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            // Handle item tap
                            // print("Tapped on: ${filteredUsers[index]}");
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${index + 1}.',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    filteredUsers[index],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.grey.shade300,
                      height: 1,
                      thickness: 1,
                      indent: 14,
                      endIndent: 14,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Drawer CustomDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          // DrawerHeader(
          //   decoration: const BoxDecoration(
          //     color:
          //         Colors.blue, // Set the background color of the DrawerHeader
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: <Widget>[
          //       Container(
          //         decoration: BoxDecoration(
          //           shape: BoxShape.circle,
          //           border: Border.all(
          //             color: Colors.white, // Border color
          //             width: 3, // Border width
          //           ),
          //         ),
          //         child: CircleAvatar(
          //           radius: 30,
          //           backgroundColor: Colors.black,
          //           child: Text(
          //             firstLetter,
          //             style: TextStyle(
          //               fontSize: 24,
          //               color: Colors.white,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //       ),
          //       SizedBox(width: 10), // Spacing between avatar and text
          //       Text(
          //         username, // Full username
          //         style: TextStyle(
          //           fontSize: 20,
          //           color: Colors.white, // Text color of the username
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          DrawerHeader(
            decoration: const BoxDecoration(
              color:
                  Colors.blue, // Set the background color of the DrawerHeader
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular Progress Indicator
                if (isLoading)
                  const CircularProgressIndicator(), // Show loading indicator when fetching token
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 3, // Border width
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.black,
                        child: Text(
                          isLoading
                              ? ''
                              : firstLetter, // Show first letter only when not loading
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                        width: 10), // Spacing between avatar and text
                    Expanded(
                      child: Text(
                        isLoading ? '' : username,
                        maxLines: 1, // Set maximum number of lines
                        overflow: TextOverflow
                            .ellipsis, // Show username only when not loading
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.black, // Text color of the username
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16.0), // Padding for the settings title
            child: Text(
              "Settings",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Color of the settings title
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.info,
              color: Colors.blue,
            ),
            title: const Text(
              "About",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.black, // Color of the settings title
              ),
            ),
            // trailing: const Icon(Icons.launch),

            // onTap: () {
            //   Navigator.of(context).push(
            //       MaterialPageRoute(builder: (context) => const Profile()));
            // },
          ),
          // ListTile(
          //   title: const Text("News"),
          //   leading: const Icon(Icons.launch),
          //   onTap: () {
          //     //  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddBlog()));
          //   },
          // ),
          const Divider(
            thickness: 0.3,
            color: Colors.blue,
            indent: 16.0, // Add indentation to the left
            endIndent: 16.0, // Add indentation to the right
          ),
          ListTile(
            title: const Text("Help",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.black, // Color of the settings title
                )),
            leading: const Icon(
              Icons.help,
              color: Colors.blue,
            ),
            // onTap: () {
            //   Navigator.push(context,
            //       MaterialPageRoute(builder: (context) => const Setting()));
            // },
          ),
          const Divider(
            thickness: 0.3,
            color: Colors.blue,
            indent: 16.0, // Add indentation to the left
            endIndent: 16.0, // Add indentation to the right
          ),
          ListTile(
            title: const Text("Logout",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.black, // Color of the settings title
                )),

            leading: const Icon(
              Icons.power_settings_new_outlined,
              color: Colors.blue,
            ),
            onTap: logout,

            // onTap: logout,
          ),
        ],
      ),
    );
  }

  void logout() async {
    await storage.delete(key: "token");
    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false);
  }
}
