import 'dart:convert';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/features/onboarding/Indivudualaccount/ViewCustomerInfoPage.dart';
import 'package:coopengageplus/features/onboarding/Update_IndividualAccount%20-/screens/registration_screen.dart';
import 'package:coopengageplus/features/onboarding/pages/userInfoList/OrganizationDetailPage.dart';
import 'package:coopengageplus/features/onboarding/pages/userInfoList/JointAccountDetailPage.dart';
import 'package:coopengageplus/features/onboarding/pages/verifyCustomerInfo.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';

class UserListPage extends StatefulWidget {
  final String title;

  const UserListPage({Key? key, required this.title}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

enum SampleItem { view, edit, verify }

class _UserInfoPageState extends State<UserListPage> {
  final NetworkHandler networkHandler = NetworkHandler();
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  bool isLoading1 = false;
  String searchQuery = '';

  SampleItem? selectedItem;
  int? userId;

  final List<String> customerTypes = ['INDIVIDUAL', 'JOINT', 'ORGANIZATION'];
  String selectedCustomerType = 'INDIVIDUAL';

  Map<String, List<String>> titleStatusMapping = isOnline
      ? {
          "New Applicants": ["INITIAL", "REGISTERED"],
          "Awaiting Action": [
            "PENDING",
            "UNAUTHORIZED",
            "AUTHORIZED",
            "UNSETTLED"
          ],
          "Approved": ["APPROVED"],
          "Rejected": ["REJECTED"],
        }
      : {
          "New Applicants": ["INITIAL"],
          "Awaiting Action": ["UNSETTLED"],
          "Approved": ["APPROVED"],
          "Rejected": ["REJECTED"],
        };

  List<String> dropdownOptions = [];
  String? selectedCategory;
  @override
  void initState() {
    super.initState();
    _fetchToken();

    dropdownOptions = titleStatusMapping[widget.title] ?? [];
    if (dropdownOptions.isNotEmpty) {
      selectedCategory = dropdownOptions[0];
      fetchUsers(selectedCategory!);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, size: 25, color: Colors.blue),
            onPressed: () => {Navigator.pop(context)},
          ),
        ),
        backgroundColor: Colors.white,
        title: Text(
          " ${widget.title}",
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
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
                  SizedBox(
                    height: 10,
                  ),
                  if (dropdownOptions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<String>(
                            value: selectedCategory,
                            onChanged: (String? newCategory) {
                              setState(() {
                                selectedCategory = newCategory!;
                                fetchUsers(selectedCategory!);
                              });
                            },
                            items: dropdownOptions
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          const SizedBox(width: 16),
                          // Customer type dropdown

                          isOnline
                              ? DropdownButton<String>(
                                  value: selectedCustomerType,
                                  underline: SizedBox(),
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: Colors.blue),
                                  items: customerTypes.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value,
                                          style: TextStyle(color: Colors.blue)),
                                    );
                                  }).toList(),
                                  onChanged: (String? newType) {
                                    if (newType != null) {
                                      setState(() {
                                        selectedCustomerType = newType;
                                        if (selectedCategory != null) {
                                          fetchUsers(selectedCategory!);
                                        }
                                      });
                                    }
                                  },
                                )
                              : SizedBox(
                                  width: 1,
                                ),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
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
                      child: selectedCustomerType == 'ORGANIZATION'
                          ? _buildOrganizationList()
                          : selectedCustomerType == 'JOINT'
                              ? _buildJointAccountList()
                              : filteredUsers.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.only(top: 50),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 40),
                                          Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.folder_copy_sharp,
                                                    size: 64,
                                                    color: Colors.blue),
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
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 2),
                                      child: ScrollableTableView(
                                        headers: [
                                          "No",
                                          "Full Name",
                                          "PhoneNumber",
                                          "Action"
                                        ]
                                            .map((label) =>
                                                TableViewHeader(label: label))
                                            .toList(),
                                        rows: filteredUsers
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          int index = entry.key;
                                          var user = entry.value;
                                          return TableViewRow(
                                            height: 50,
                                            cells: [
                                              TableViewCell(
                                                  child: Text(
                                                      (index + 1).toString())),
                                              TableViewCell(
                                                child: Text(
                                                  user['fullName'] ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                              TableViewCell(
                                                child: Center(
                                                  child: PopupMenuButton<
                                                      SampleItem>(
                                                    onSelected:
                                                        (SampleItem item) {
                                                      setState(() {
                                                        selectedItem = item;
                                                        if (item ==
                                                            SampleItem.edit) {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  UpdateUserRegistrationScreen(
                                                                      userInfo:
                                                                          user),
                                                            ),
                                                          );
                                                        } else if (item ==
                                                            SampleItem.view) {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ViewCustomerInfo(
                                                                      registrationData:
                                                                          user,
                                                                      title: widget
                                                                          .title),
                                                            ),
                                                          );
                                                        } else if (item ==
                                                            SampleItem.verify) {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  Verifycustomerinfo(
                                                                      registrationData:
                                                                          user,
                                                                      title: widget
                                                                          .title),
                                                            ),
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
                                                        child: Text('View'),
                                                      ),
                                                      if (widget.title ==
                                                              'New Applicants' &&
                                                          selectedCategory ==
                                                              'INITIAL')
                                                        const PopupMenuItem<
                                                            SampleItem>(
                                                          value:
                                                              SampleItem.edit,
                                                          child: Text('Edit'),
                                                        ),
                                                      if (isOnline &&
                                                          widget.title ==
                                                              'New Applicants' &&
                                                          selectedCategory ==
                                                              'REGISTERED')
                                                        const PopupMenuItem<
                                                            SampleItem>(
                                                          value:
                                                              SampleItem.verify,
                                                          child: Text('Verify'),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fetchUsers(String status) async {
    setState(() {
      isLoading1 = true;
    });

    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
    );
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      var decodedToken = JwtDecoder.decode(token);
      setState(() {
        userId = decodedToken['userId'];
      });
    }

    // String url = '/api/v1/accounts?customerType=$selectedCustomerType&status=$status&onlyUserCreated=true';
    String url =
        '/api/v1/accounts?customerType=$selectedCustomerType&status=$status&onlyUserCreated=true&size=100000';

    print("uurllldld");
    print(url);
    if (isOnline) {
      try {
        var response = await networkHandler.getUserData(url);
        print("uurllldldss");
        print(response.body);
        if (response.statusCode == 200) {
          List<dynamic> fetchedUsers = jsonDecode(response.body);
          setState(() {
            users = fetchedUsers;
            filterUsers();
            isLoading1 = false;
            // Remove expandedStates logic
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
      DatabaseHelper dbHelper = DatabaseHelper();
      List<Map<String, dynamic>> localUsers =
          await dbHelper.getCustomersByStatus(status, userId!);
      setState(() {
        users = localUsers;
        filterUsers();
        isLoading1 = false;
        // Remove expandedStates logic
      });
    }
  }

  void filterUsers() {
    setState(() {
      filteredUsers = users
          .where((user) => (user['fullName']?.toLowerCase() ?? '')
              .contains(searchQuery.toLowerCase()))
          .toList();
      // Remove expandedStates logic
    });
  }

  Future<void> _fetchToken() async {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
    );
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      var decodedToken = JwtDecoder.decode(token);
      setState(() {
        userId = decodedToken['userId'];
      });
    }
  }

  Widget _buildOrganizationList() {
    if (filteredUsers.isEmpty) {
      return Center(child: Text('No organizations found'));
    }
    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final org = filteredUsers[index];
        final List customers = org['customersInfo'] ?? [];
        // Remove expansion logic

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (modalContext) =>
                    OrganizationDetailPage(org: org, parentContext: context),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: graybackgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Company Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                org['companyName'] ?? org['companyName'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 16, color: Colors.blueGrey),
                            const SizedBox(width: 4),
                            Text(
                              org['companyPhoneNumber'] ??
                                  org['phoneNumber'] ??
                                  '',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.email, size: 16, color: Colors.blueGrey),
                            const SizedBox(width: 4),
                            Text(
                              org['companyEmail'] ?? org['email'] ?? '',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJointAccountList() {
    if (filteredUsers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.blue),
                  SizedBox(height: 5),
                  Text(
                    'No Joint Accounts Found',
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
      );
    }

    final List limitedJointAccounts = filteredUsers.take(100000).toList();

    return ListView.builder(
      itemCount: limitedJointAccounts.length,
      itemBuilder: (context, index) {
        final jointAccount = limitedJointAccounts[index];
        final String accountId = jointAccount['id']?.toString() ?? '';
        final String accountType = jointAccount['accountType'] ?? '';
        final String status = jointAccount['status'] ?? '';
        final double initialDeposit =
            (jointAccount['initialDeposit'] ?? 0.0).toDouble();
        final List customers = jointAccount['customersInfo'] ?? [];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (modalContext) => JointAccountDetailPage(
                    jointAccount: jointAccount, parentContext: context),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.people,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Joint Account #$accountId',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            accountType,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.attach_money,
                                  size: 14, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                'ETB ${initialDeposit.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${customers.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          'Holders',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      case 'INITIAL':
        return Colors.blue;
      case 'REGISTERED':
        return Colors.purple;
      case 'UNAUTHORIZED':
        return Colors.red[700]!;
      case 'AUTHORIZED':
        return Colors.blue[700]!;
      case 'UNSETTLED':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
