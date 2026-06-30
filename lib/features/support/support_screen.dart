import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ticket_provider.dart';
import '../../data/models/ticket.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/extensions.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/detail_drawer.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  String _selectedType = 'All';
  String _selectedPriority = 'All';
  String _selectedStatus = 'All';
  String _searchQuery = '';
  String? _activeTicketId;



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tickets = ref.watch(ticketProvider);

    // Filter tickets
    final filteredTickets = tickets.where((t) {
      if (_selectedType != 'All' && t.type.name.toLowerCase() != _selectedType.toLowerCase()) {
        return false;
      }
      if (_selectedPriority != 'All' && t.priority.name.toLowerCase() != _selectedPriority.toLowerCase()) {
        return false;
      }
      if (_selectedStatus != 'All' && t.status.name.toLowerCase() != _selectedStatus.toLowerCase()) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return t.id.toLowerCase().contains(query) ||
            t.description.toLowerCase().contains(query) ||
            t.issueCategory.toLowerCase().contains(query) ||
            t.raisedById.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    // Exception-first sort: critical open tickets first, then newest
    filteredTickets.sort((a, b) {
      if (a.status != TicketStatus.resolved && b.status == TicketStatus.resolved) return -1;
      if (a.status == TicketStatus.resolved && b.status != TicketStatus.resolved) return 1;
      if (a.priority == TicketPriority.critical && b.priority != TicketPriority.critical) return -1;
      if (a.priority != TicketPriority.critical && b.priority == TicketPriority.critical) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    // Active ticket detail
    final activeTicket = _activeTicketId != null
        ? tickets.firstWhere((t) => t.id == _activeTicketId, orElse: () => filteredTickets.first)
        : (filteredTickets.isNotEmpty ? filteredTickets.first : null);

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Pane: Ticket List Queue (100% on small screens, 60% on desktop)
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: theme.colorScheme.outlineVariant)),
              ),
              child: Column(
                children: [
                  // Filter header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Support Ticket Queue', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (val) => setState(() => _searchQuery = val),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.search, size: 18),
                                  hintText: 'Search ticket ID, description...',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildDropdownFilter(
                                label: 'Type',
                                value: _selectedType,
                                items: ['All', 'Customer', 'Merchant', 'Rider'],
                                onChanged: (val) => setState(() => _selectedType = val!),
                              ),
                              const SizedBox(width: 8),
                              _buildDropdownFilter(
                                label: 'Priority',
                                value: _selectedPriority,
                                items: ['All', 'Critical', 'High', 'Medium', 'Low'],
                                onChanged: (val) => setState(() => _selectedPriority = val!),
                              ),
                              const SizedBox(width: 8),
                              _buildDropdownFilter(
                                label: 'Status',
                                value: _selectedStatus,
                                items: ['All', 'Open', 'In Progress', 'Resolved', 'Reopened'],
                                onChanged: (val) => setState(() => _selectedStatus = val!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  // List
                  Expanded(
                    child: filteredTickets.isEmpty
                        ? const EmptyState(
                            icon: Icons.support_agent,
                            title: 'No tickets found',
                            subtitle: 'No tickets match your filters.',
                          )
                        : ListView.separated(
                            itemCount: filteredTickets.length,
                            separatorBuilder: (_, __) => Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                            itemBuilder: (context, index) {
                              final t = filteredTickets[index];
                              final isSelected = t.id == activeTicket?.id;

                              final priorityColor = t.priority == TicketPriority.critical
                                  ? kDanger
                                  : t.priority == TicketPriority.high
                                      ? kWarning
                                      : t.priority == TicketPriority.medium
                                          ? kInfo
                                          : kNeutral;

                              // SLA Clock: If ticket open > 24h, show red
                              final openDuration = DateTime.now().difference(t.createdAt);
                              final isSlaBreached = openDuration.inHours > 24 && t.status != TicketStatus.resolved;

                              return ListTile(
                                selected: isSelected,
                                selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.08),
                                onTap: () {
                                  setState(() {
                                    _activeTicketId = t.id;
                                  });
                                  if (!context.isLarge) {
                                    showDetailDrawer(
                                      context,
                                      DetailDrawer(
                                        title: 'Ticket ${t.id.toUpperCase()}',
                                        scrollable: false,
                                        child: _buildTicketDetailPanel(context, t, theme),
                                      ),
                                    );
                                  }
                                },
                                title: Row(
                                  children: [
                                    Text(
                                      t.id.toUpperCase(),
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: priorityColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        t.priority.name.toUpperCase(),
                                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: priorityColor),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      Formatters.relativeTime(t.createdAt),
                                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      '${t.type.name.toUpperCase()} • ${t.issueCategory}',
                                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      t.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_filled,
                                              size: 12,
                                              color: isSlaBreached ? kDanger : theme.colorScheme.outline,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              t.status == TicketStatus.resolved
                                                  ? 'Resolved'
                                                  : '${openDuration.inHours}h ${openDuration.inMinutes % 60}m elapsed',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: isSlaBreached ? FontWeight.bold : FontWeight.normal,
                                                color: isSlaBreached ? kDanger : theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (t.assignedAdminId != null)
                                          Text(
                                            'Assigned: ${t.assignedAdminId}',
                                            style: theme.textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic),
                                          )
                                        else
                                          Text(
                                            'UNASSIGNED',
                                            style: theme.textTheme.labelSmall?.copyWith(color: kWarning, fontWeight: FontWeight.bold),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  // Bottom Root Cause Analytics Dashboard Panel
                  Container(
                    height: 180,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                      border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Root Cause Analysis & Trends', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Row(
                            children: [
                              // Chart representation
                              Expanded(
                                flex: 4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildRootCauseRow('Missing Item', 0.85, '12 cases', theme),
                                    _buildRootCauseRow('Late Delivery', 0.62, '8 cases', theme),
                                    _buildRootCauseRow('Cold Food', 0.40, '5 cases', theme),
                                    _buildRootCauseRow('Payment Failed', 0.25, '3 cases', theme),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Quality warning card
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: kWarning.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: kWarning.withOpacity(0.2)),
                                  ),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.warning, color: kWarning, size: 16),
                                          const SizedBox(width: 4),
                                          Text('Recurring Merchant Flag', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kWarning)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Burger House has triggered 4 "Missing Item" tickets in the last 7 days.',
                                        style: TextStyle(fontSize: 9, height: 1.3),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Pane: Detail Panel (40% - only visible on large screens)
          if (context.isLarge)
            Expanded(
              flex: 4,
              child: activeTicket == null
                  ? const Center(child: Text('Select a ticket to inspect details.'))
                  : _buildTicketDetailPanel(context, activeTicket, theme),
            ),
        ],
      ),
    );
  }

  Widget _buildTicketDetailPanel(BuildContext context, SupportTicket activeTicket, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top detail header
            Row(
              children: [
                Text(
                  'TICKET ${activeTicket.id.toUpperCase()}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: activeTicket.status == TicketStatus.resolved
                        ? kSuccess.withOpacity(0.12)
                        : kSeedColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    activeTicket.statusLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: activeTicket.status == TicketStatus.resolved ? kSuccess : kSeedColor,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),

            // Profile summary metadata
            _buildMetadataRow('Ticket Type', activeTicket.type.name.toUpperCase(), theme),
            _buildMetadataRow('Raised By ID', activeTicket.raisedById, theme),
            _buildMetadataRow('Linked Order', activeTicket.orderId, theme, buttonText: 'View Order'),
            _buildMetadataRow('Created At', Formatters.dateTime(activeTicket.createdAt), theme),
            const Divider(height: 24),

            // Issue Description
            Text('Issue Description', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Text(
                activeTicket.description,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
            const SizedBox(height: 20),

            // Compensation Recommendation Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kSuccess.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kSuccess.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: kSuccess, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recommended Compensation',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kSuccess),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Suggested: ₹50 — Missing item (Beverage) + Customer Tier (High Retention).',
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action inputs
            if (activeTicket.status == TicketStatus.resolved)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kSuccess.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: kSuccess, size: 16),
                        const SizedBox(width: 8),
                        const Text('Resolved Case Summary', style: TextStyle(fontWeight: FontWeight.bold, color: kSuccess)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Compensation: ₹${activeTicket.compensationAmount ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text('Case notes: Resolved missing item complaint via credit refund.', style: TextStyle(fontSize: 11)),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.hourglass_empty, color: theme.colorScheme.onSurfaceVariant, size: 16),
                    const SizedBox(width: 8),
                    Text('Ticket is pending resolution.', style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
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

  Widget _buildMetadataRow(String label, String value, ThemeData theme, {String? buttonText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Row(
            children: [
              Text(value, style: theme.textTheme.titleSmall?.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
              if (buttonText != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text(buttonText, style: const TextStyle(fontSize: 11)),
                ),
              ],
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRootCauseRow(String title, double fillPercent, String label, ThemeData theme) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500))),
        Expanded(
          child: LinearProgressIndicator(
            value: fillPercent,
            backgroundColor: theme.colorScheme.outlineVariant.withOpacity(0.3),
            color: theme.colorScheme.primary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(width: 50, child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
      ],
    );
  }


}
