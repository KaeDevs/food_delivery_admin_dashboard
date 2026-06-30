import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/admin_user.dart';
import '../../data/models/audit_log.dart';
import '../../data/mock/mock_seed.dart';
import '../../providers/audit_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/section_header.dart';

class IdentityScreen extends ConsumerStatefulWidget {
  const IdentityScreen({super.key});

  @override
  ConsumerState<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends ConsumerState<IdentityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<AdminUser> _users;
  String _auditEntityFilter = 'All';
  String _auditActionFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _users = List.from(MockAdminUsers.users);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _deactivateUser(AdminUser user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(user.isActive ? 'Deactivate User' : 'Activate User'),
        content: Text('Are you sure you want to ${user.isActive ? 'deactivate' : 'activate'} ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                final idx = _users.indexWhere((u) => u.id == user.id);
                if (idx != -1) {
                  _users[idx] = _users[idx].copyWith(isActive: !user.isActive);
                  MockAdminUsers.users = List.from(_users);
                }
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.name} status updated.')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showInviteUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = 'Support Admin';
    String selectedScope = 'global';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Invite Admin User'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email Address'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: [
                      'Super Admin',
                      'Operations Admin',
                      'Dispatch Admin',
                      'Finance Admin',
                      'Trust & Safety Admin',
                      'Merchant Success Admin',
                      'Support Admin',
                      'Analyst'
                    ].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedRole = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedScope,
                    decoration: const InputDecoration(labelText: 'Scope'),
                    items: ['global', 'Bengaluru', 'Mumbai', 'Delhi'].map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedScope = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (nameController.text.isEmpty || emailController.text.isEmpty) return;
                  final newUser = AdminUser(
                    id: 'admin-${Random().nextInt(1000)}',
                    name: nameController.text,
                    email: emailController.text,
                    role: selectedRole,
                    scope: selectedScope,
                    isActive: true,
                    lastLogin: DateTime.now(),
                  );
                  setState(() {
                    _users.add(newUser);
                    MockAdminUsers.users = List.from(_users);
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invited user ${newUser.name} successfully.')),
                  );
                },
                child: const Text('Send Invitation'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auditLogs = ref.watch(auditProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(text: 'Admin Users'),
              Tab(text: 'Roles & Permissions'),
              Tab(text: 'Audit Log'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Admin Users Tab
          _buildAdminUsersTab(theme),

          // 2. Roles & Permissions Tab
          _buildRbacMatrixTab(theme),

          // 3. Audit Log Tab
          _buildAuditLogTab(theme, auditLogs),
        ],
      ),
    );
  }

  Widget _buildAdminUsersTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search admin name, email or role...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                label: const Text('Invite User'),
                onPressed: _showInviteUserDialog,
              )
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Role')),
                      DataColumn(label: Text('Scope')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Last Login')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: _users.where((u) {
                      final q = _searchQuery.toLowerCase();
                      return u.name.toLowerCase().contains(q) ||
                          u.email.toLowerCase().contains(q) ||
                          u.role.toLowerCase().contains(q);
                    }).map((user) {
                      return DataRow(cells: [
                        DataCell(Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(user.email)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user.role,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                            ),
                          ),
                        ),
                        DataCell(Text(user.scope)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: user.isActive ? kSuccess.withOpacity(0.12) : kDanger.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: user.isActive ? kSuccess : kDanger),
                            ),
                          ),
                        ),
                        DataCell(Text(Formatters.relativeTime(user.lastLogin))),
                        DataCell(
                          IconButton(
                            icon: Icon(
                              user.isActive ? Icons.lock_outline : Icons.lock_open_outlined,
                              color: user.isActive ? kDanger : kSuccess,
                              size: 18,
                            ),
                            onPressed: () => _deactivateUser(user),
                            tooltip: user.isActive ? 'Deactivate User' : 'Activate User',
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRbacMatrixTab(ThemeData theme) {
    // 8 Roles
    final roles = [
      'Super Admin',
      'Operations Admin',
      'Dispatch Admin',
      'Finance Admin',
      'Trust & Safety Admin',
      'Merchant Success Admin',
      'Support Admin',
      'Analyst'
    ];

    // 14 Modules
    final modules = [
      'Dashboard KPI',
      'Live Ops Feed',
      'Dispatch Control',
      'Merchant Ops',
      'Rider Governance',
      'Finance Settlement',
      'Fraud Trust & Safety',
      'Customer Intel',
      'Geo Heatmaps',
      'Support Console',
      'RBAC & Identity',
      'Ratings Moderation',
      'Promo Campaign',
      'Saved Reporting'
    ];

    // Hard-coded matrix matching permissions structure
    // R = Read (Grey), W = Write (Blue), A = Approve (Green), — = No Access (Dark Grey)
    final Map<String, List<String>> matrix = {
      'Super Admin': List.filled(14, 'A'), // Full Admin
      'Operations Admin': ['W', 'W', 'W', 'W', 'W', 'R', 'R', 'R', 'W', 'R', 'R', 'R', 'R', 'W'],
      'Dispatch Admin': ['R', 'W', 'W', '—', 'W', '—', '—', '—', 'W', 'R', '—', '—', '—', 'R'],
      'Finance Admin': ['R', '—', '—', '—', '—', 'A', '—', '—', '—', '—', '—', '—', '—', 'W'],
      'Trust & Safety Admin': ['R', '—', '—', '—', 'W', '—', 'A', 'R', '—', '—', '—', '—', '—', 'R'],
      'Merchant Success Admin': ['R', '—', '—', 'W', '—', '—', '—', '—', '—', '—', '—', 'W', 'W', 'R'],
      'Support Admin': ['R', 'R', '—', '—', '—', '—', '—', 'R', '—', 'W', '—', '—', '—', 'R'],
      'Analyst': ['R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', '—', 'R', 'R', 'W'],
    };

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Role-Based Access Control (RBAC) Matrix',
            subtitle: 'Overview of modules permissions across core admin directory roles.',
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    columns: [
                      const DataColumn(label: Text('System Role')),
                      ...modules.map((m) => DataColumn(label: Text(m, style: const TextStyle(fontSize: 11)))),
                    ],
                    rows: roles.map((role) {
                      final perms = matrix[role] ?? List.filled(14, '—');
                      return DataRow(cells: [
                        DataCell(Text(role, style: const TextStyle(fontWeight: FontWeight.bold))),
                        ...perms.map((p) {
                          Color bgColor = theme.colorScheme.surfaceVariant.withOpacity(0.4);
                          Color textColor = theme.colorScheme.onSurfaceVariant;

                          if (p == 'W') {
                            bgColor = theme.colorScheme.primaryContainer.withOpacity(0.4);
                            textColor = theme.colorScheme.primary;
                          } else if (p == 'A') {
                            bgColor = kSuccess.withOpacity(0.12);
                            textColor = kSuccess;
                          } else if (p == '—') {
                            bgColor = theme.colorScheme.outlineVariant.withOpacity(0.15);
                            textColor = theme.colorScheme.outline;
                          }

                          return DataCell(
                            Center(
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: textColor.withOpacity(0.15)),
                                ),
                                child: Center(
                                  child: Text(
                                    p,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList()
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogTab(ThemeData theme, List<AuditLog> auditLogs) {
    // Unique list of actors and entities for filtering
    final actors = ['All', ...auditLogs.map((log) => log.actorAdminId).toSet()];
    final entityTypes = ['All', ...auditLogs.map((log) => log.entityType).toSet()];

    final filteredLogs = auditLogs.where((log) {
      if (_auditEntityFilter != 'All' && log.entityType != _auditEntityFilter) return false;
      if (_auditActionFilter != 'All' && log.actorAdminId != _auditActionFilter) return false;
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              _buildDropdownFilter(
                label: 'Actor Admin',
                value: _auditActionFilter,
                items: actors,
                onChanged: (val) => setState(() => _auditActionFilter = val!),
              ),
              const SizedBox(width: 12),
              _buildDropdownFilter(
                label: 'Entity Area',
                value: _auditEntityFilter,
                items: entityTypes,
                onChanged: (val) => setState(() => _auditEntityFilter = val!),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Timestamp')),
                      DataColumn(label: Text('Actor')),
                      DataColumn(label: Text('Role')),
                      DataColumn(label: Text('Action Type')),
                      DataColumn(label: Text('Target Entity')),
                      DataColumn(label: Text('Description / Notes')),
                    ],
                    rows: filteredLogs.map((log) {
                      return DataRow(
                        onSelectChanged: (_) => _showAuditDetails(log, theme),
                        cells: [
                          DataCell(Text(Formatters.dateTime(log.timestamp))),
                          DataCell(Text(log.actorAdminId)),
                          DataCell(Text(log.actorRole, style: const TextStyle(fontSize: 11))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                log.actionName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text('${log.entityType}: ${log.entityId}')),
                          DataCell(Text(log.reasonCode, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAuditDetails(AuditLog log, ThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Audit Entry details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogDetailRow('Action performed', log.actionName, theme),
            _buildDialogDetailRow('Actor user', '${log.actorAdminId} (${log.actorRole})', theme),
            _buildDialogDetailRow('Entity target', '${log.entityType} with ID ${log.entityId}', theme),
            _buildDialogDetailRow('Timestamp', Formatters.dateTime(log.timestamp), theme),
            _buildDialogDetailRow('Change reason', log.reasonCode, theme),
            const SizedBox(height: 12),
            const Text('State Change Diff:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Before state', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kDanger)),
                        const SizedBox(height: 4),
                        Text(log.beforeState, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: theme.colorScheme.outlineVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('After state', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kSuccess)),
                        const SizedBox(height: 4),
                        Text(log.afterState, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: value,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
