import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../data/mock/mock_seed.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _selectedRole = AppConstants.adminRoles.first;
  final _emailController = TextEditingController(text: 'admin@dashboard.com');
  final _passwordController = TextEditingController(text: '••••••••');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    final user = ref.read(authProvider.notifier).getUserByRole(_selectedRole);
    if (user != null) {
      ref.read(authProvider.notifier).login(user);
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 480,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: kSeedColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 24),
                Text(
                  'Admin Dashboard',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'On-Demand Delivery Platform',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                // Email
                Text('Email', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: 'Enter your email'),
                ),
                const SizedBox(height: 16),
                // Password
                Text('Password', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Enter password'),
                ),
                const SizedBox(height: 16),
                // Role selection
                Text('Role', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(),
                  items: AppConstants.adminRoles.map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedRole = value);
                  },
                ),
                const SizedBox(height: 32),
                // Sign In
                FilledButton(
                  onPressed: _onSignIn,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select a role to explore role-based access controls',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
