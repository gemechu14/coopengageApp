import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class UserListState {
  final List<dynamic> users;
  final List<dynamic> filteredUsers;
  final bool isLoading;
  final String searchQuery;
  final String selectedCustomerType;
  final String? selectedCategory;
  final int? userId;
  final List<String> dropdownOptions;

  UserListState({
    required this.users,
    required this.filteredUsers,
    required this.isLoading,
    required this.searchQuery,
    required this.selectedCustomerType,
    required this.selectedCategory,
    required this.userId,
    required this.dropdownOptions,
  });

  UserListState copyWith({
    List<dynamic>? users,
    List<dynamic>? filteredUsers,
    bool? isLoading,
    String? searchQuery,
    String? selectedCustomerType,
    String? selectedCategory,
    int? userId,
    List<String>? dropdownOptions,
  }) {
    return UserListState(
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCustomerType: selectedCustomerType ?? this.selectedCustomerType,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      userId: userId ?? this.userId,
      dropdownOptions: dropdownOptions ?? this.dropdownOptions,
    );
  }
}

class UserListNotifier extends StateNotifier<UserListState> {
  UserListNotifier()
      : super(UserListState(
          users: [],
          filteredUsers: [],
          isLoading: false,
          searchQuery: '',
          selectedCustomerType: 'INDIVIDUAL',
          selectedCategory: null,
          userId: null,
          dropdownOptions: [],
        ));

  void setUsers(List<dynamic> users) {
    state = state.copyWith(users: users);
    filterUsers();
  }

  void setFilteredUsers(List<dynamic> filteredUsers) {
    state = state.copyWith(filteredUsers: filteredUsers);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    filterUsers();
  }

  void setSelectedCustomerType(String type) {
    state = state.copyWith(selectedCustomerType: type);
  }

  void setSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setUserId(int? userId) {
    state = state.copyWith(userId: userId);
  }

  void setDropdownOptions(List<String> options) {
    state = state.copyWith(dropdownOptions: options);
  }

  void filterUsers() {
    final filtered = state.users
        .where((user) => (user['fullName']?.toLowerCase() ?? '')
            .contains(state.searchQuery.toLowerCase()))
        .toList();
    setFilteredUsers(filtered);
  }

  // Async fetch users from network (replace with real logic)
  Future<void> fetchUsers({
    required String status,
    required String customerType,
    required bool isOnline,
    int? userId,
  }) async {
    setLoading(true);
    try {
      // Simulate token fetch
      const storage = FlutterSecureStorage();
      String? token = await storage.read(key: "token");
      // Simulate userId from token
      int? fetchedUserId = userId;
      if (token != null && token.isNotEmpty) {
        // You can decode token here if needed
        fetchedUserId = fetchedUserId ?? 1; // Simulated userId
      }
      setUserId(fetchedUserId);

      // Simulate network/database fetch
      await Future.delayed(Duration(milliseconds: 500));
      List<dynamic> fetchedUsers = [];
      if (isOnline) {
        // TODO: Replace with real network call
        // Example:
        // var response = await networkHandler.getUserData(url);
        // if (response.statusCode == 200) {
        //   fetchedUsers = jsonDecode(response.body);
        // }
        fetchedUsers = [
          {
            'fullName': 'John Doe',
            'phone': '123456789',
            'companyName': 'Acme Corp',
            'customersInfo': [
              {'fullName': 'John Doe', 'phone': '123456789', 'email': 'john@example.com'}
            ],
          },
          {
            'fullName': 'Jane Smith',
            'phone': '987654321',
            'companyName': 'Beta LLC',
            'customersInfo': [
              {'fullName': 'Jane Smith', 'phone': '987654321', 'email': 'jane@example.com'}
            ],
          },
        ];
      } else {
        // TODO: Replace with real local DB fetch
        fetchedUsers = [
          {
            'fullName': 'Offline User',
            'phone': '000000000',
            'companyName': 'Offline Inc',
            'personalInfo': [
              {'fullName': 'Offline User', 'phone': '000000000', 'email': 'offline@example.com'}
            ],
          },
        ];
      }
      setUsers(fetchedUsers);
      setLoading(false);
    } catch (e) {
      setLoading(false);
    }
  }
}

final userListProvider = StateNotifierProvider<UserListNotifier, UserListState>(
    (ref) => UserListNotifier()); 