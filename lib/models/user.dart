class User {
  final String clientId;
  final String role;
  final dynamic userId;
  final List<Map<String, dynamic>> branches;

  User({
    required this.clientId,
    required this.role,
    required this.userId,
    required this.branches,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      clientId: map['clientId']?.toString() ?? '',
      role: map['role']?[0] ?? '',
      userId: map['userId'],
      branches: List<Map<String, dynamic>>.from(map['branch'] ?? []),
    );
  }
} 