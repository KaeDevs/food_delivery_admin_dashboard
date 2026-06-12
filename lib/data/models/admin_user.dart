class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String scope;
  final bool isActive;
  final DateTime lastLogin;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.scope,
    required this.isActive,
    required this.lastLogin,
  });

  AdminUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? scope,
    bool? isActive,
    DateTime? lastLogin,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      scope: scope ?? this.scope,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
