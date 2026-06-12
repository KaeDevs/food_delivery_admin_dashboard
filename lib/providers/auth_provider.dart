import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/admin_user.dart';
import '../data/mock/mock_seed.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AdminUser?>((ref) {
  return AuthNotifier();
});

final currentRoleProvider = Provider<String>((ref) {
  return ref.watch(authProvider)?.role ?? '';
});

class AuthNotifier extends StateNotifier<AdminUser?> {
  AuthNotifier() : super(null);

  void login(AdminUser user) {
    state = user;
  }

  void logout() {
    state = null;
  }

  bool hasRole(String role) {
    return state?.role == role || state?.role == 'Super Admin';
  }

  bool canAccess(List<String> allowedRoles) {
    if (state == null) return false;
    if (state!.role == 'Super Admin') return true;
    return allowedRoles.contains(state!.role);
  }

  AdminUser? getUserByRole(String role) {
    try {
      return MockAdminUsers.users.firstWhere((u) => u.role == role);
    } catch (_) {
      return null;
    }
  }
}
