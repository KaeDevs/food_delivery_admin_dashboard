import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/audit_provider.dart';
import '../../data/models/audit_log.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/section_header.dart';

class ReportingScreen extends ConsumerStatefulWidget {
  const ReportingScreen({super.key});

  @override
  ConsumerState<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends ConsumerState<ReportingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Last 30 Days';
  String _auditEntityFilter = 'All';
  String _auditActionFilter = 'All';
  String _dictionarySearchQuery = '';

  // Saved reports mock state
  final List<Map<String, String>> _savedReports = [
    {
      'name': 'Monthly Financial Settlement',
      'frequency': 'Monthly',
      'lastGenerated': '01 Jun 2026',
      'format': 'PDF',
    },
    {
      'name': 'Rider Fairness Analytics',
      'frequency': 'Weekly',
      'lastGenerated': '14 Jun 2026',
      'format': 'CSV',
    },
    {
      'name': 'Merchant Quality Scorecard',
      'frequency': 'Weekly',
      'lastGenerated': '14 Jun 2026',
      'format': 'XLSX',
    },
    {
      'name': 'Daily Orders SLA Report',
      'frequency': 'Daily',
      'lastGenerated': '15 Jun 2026',
      'format': 'CSV',
    },
    {
      'name': 'Customer Churn Watchlist',
      'frequency': 'Real-time',
      'lastGenerated': '15 Jun 2026 (14:30)',
      'format': 'CSV',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _triggerExport(String reportName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Export initiated for "$reportName" — file will download shortly.',
        ),
        backgroundColor: kSuccess,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showCreateReportDialog() {
    final nameController = TextEditingController();
    String selectedFrequency = 'Weekly';
    String selectedFormat = 'CSV';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Schedule Custom Report'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Report Name',
                      hintText: 'e.g. Zone Surge Activity',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedFrequency,
                    decoration: const InputDecoration(labelText: 'Frequency'),
                    items: ['Daily', 'Weekly', 'Monthly', 'Real-time'].map((f) {
                      return DropdownMenuItem(value: f, child: Text(f));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null)
                        setDialogState(() => selectedFrequency = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedFormat,
                    decoration: const InputDecoration(labelText: 'Format'),
                    items: ['CSV', 'PDF', 'XLSX'].map((f) {
                      return DropdownMenuItem(value: f, child: Text(f));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null)
                        setDialogState(() => selectedFormat = val);
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
                  if (nameController.text.isEmpty) return;
                  setState(() {
                    _savedReports.add({
                      'name': nameController.text,
                      'frequency': selectedFrequency,
                      'lastGenerated': 'Pending...',
                      'format': selectedFormat,
                    });
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Custom report scheduled successfully.'),
                    ),
                  );
                },
                child: const Text('Save Report'),
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
            border: Border(
              bottom: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(text: 'Dashboards'),
              Tab(text: 'Saved Reports'),
              Tab(text: 'Audit Trail'),
              Tab(text: 'Metric Dictionary'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Dashboards comparison tab
          _buildDashboardsTab(theme),

          // 2. Saved Reports list tab
          _buildSavedReportsTab(theme),

          // 3. Audit Trail log tab
          _buildAuditTrailTab(theme, auditLogs),

          // 4. Metric Dictionary tab
          _buildMetricDictionaryTab(theme),
        ],
      ),
    );
  }

  Widget _buildDashboardsTab(ThemeData theme) {
    // Static KPI rows representing the comparative intervals
    final kpiData = [
      {
        'kpi': 'Gross Order Volume',
        'curr': '2,420',
        'prev': '2,140',
        'delta': '+13.0%',
        'trend': 'up',
      },
      {
        'kpi': 'Gross Merchandise Value (GMV)',
        'curr': '₹12,42,000',
        'prev': '₹10,54,000',
        'delta': '+17.8%',
        'trend': 'up',
      },
      {
        'kpi': 'Average Order Value (AOV)',
        'curr': '₹513',
        'prev': '₹492',
        'delta': '+4.2%',
        'trend': 'up',
      },
      {
        'kpi': 'Platform Cancellation Rate',
        'curr': '1.8%',
        'prev': '2.4%',
        'delta': '-25.0%',
        'trend': 'down',
      },
      {
        'kpi': 'Customer Churn Watchlist Rate',
        'curr': '4.1%',
        'prev': '3.9%',
        'delta': '+5.1%',
        'trend': 'up',
      },
      {
        'kpi': 'SLA Breach Delivery Ratio',
        'curr': '3.2%',
        'prev': '4.5%',
        'delta': '-28.8%',
        'trend': 'down',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Report Interval: ',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  _buildDropdownFilter(
                    label: 'Period',
                    value: _selectedPeriod,
                    items: [
                      'Today',
                      'Last 7 Days',
                      'Last 30 Days',
                      'Custom Range',
                    ],
                    onChanged: (val) => setState(() => _selectedPeriod = val!),
                  ),
                ],
              ),
              FilledButton.icon(
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Export Current View'),
                onPressed: () => _triggerExport('Comparative Dashboard View'),
              ),
            ],
          ),
          Expanded(
            child: Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Metric Identifier')),
                      DataColumn(label: Text('Current Period')),
                      DataColumn(label: Text('Prior Period')),
                      DataColumn(label: Text('Delta Variance')),
                      DataColumn(label: Text('Performance')),
                    ],
                    rows: kpiData.map((d) {
                      final trendUp = d['trend'] == 'up';
                      final positiveMetric =
                          d['kpi']!.contains('Rate') ||
                          d['kpi']!.contains('Breach');
                      // Invert good/bad colors for cancellation rate or breaches
                      final isGood = positiveMetric ? !trendUp : trendUp;
                      final deltaColor = isGood ? kSuccess : kDanger;

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              d['kpi']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(Text(d['curr']!)),
                          DataCell(Text(d['prev']!)),
                          DataCell(
                            Text(
                              d['delta']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: deltaColor,
                              ),
                            ),
                          ),
                          DataCell(
                            Icon(
                              trendUp
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: deltaColor,
                              size: 20,
                            ),
                          ),
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

  Widget _buildSavedReportsTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Scheduled Platform Reports',
              actions: [
                FilledButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Schedule Report'),
                  onPressed: _showCreateReportDialog,
                ),
              ],
            ),
            Expanded(
              child: Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Report Name')),
                          DataColumn(label: Text('Schedule Frequency')),
                          DataColumn(label: Text('Last Run Generation')),
                          DataColumn(label: Text('Format')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: _savedReports.map((report) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  report['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(Text(report['frequency']!)),
                              DataCell(Text(report['lastGenerated']!)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    report['format']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.download, size: 18),
                                  onPressed: () =>
                                      _triggerExport(report['name']!),
                                  tooltip: 'Download Report',
                                ),
                              ),
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
        ),
      );
    }

  Widget _buildAuditTrailTab(ThemeData theme, List<AuditLog> auditLogs) {
    final actors = ['All', ...auditLogs.map((log) => log.actorAdminId).toSet()];
    final entityTypes = [
      'All',
      ...auditLogs.map((log) => log.entityType).toSet(),
    ];

    final filteredLogs = auditLogs.where((log) {
      if (_auditEntityFilter != 'All' && log.entityType != _auditEntityFilter)
        return false;
      if (_auditActionFilter != 'All' && log.actorAdminId != _auditActionFilter)
        return false;
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              _buildDropdownFilter(
                label: 'Actor Name',
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
              const Spacer(),
              FilledButton.icon(
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Export logs'),
                onPressed: () => _triggerExport('Platform Audit Logs Trail'),
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
                      DataColumn(label: Text('Actor ID')),
                      DataColumn(label: Text('Role scope')),
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
                          DataCell(
                            Text(
                              log.actorRole,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer
                                    .withOpacity(0.08),
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
                          DataCell(
                            Text(
                              log.reasonCode,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
        title: const Text('Audit Log Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogDetailRow('Action Type', log.actionName, theme),
            _buildDialogDetailRow(
              'Performed by',
              '${log.actorAdminId} (${log.actorRole})',
              theme,
            ),
            _buildDialogDetailRow(
              'Target target',
              '${log.entityType}: ${log.entityId}',
              theme,
            ),
            _buildDialogDetailRow(
              'Timestamp',
              Formatters.dateTime(log.timestamp),
              theme,
            ),
            _buildDialogDetailRow('Notes reason', log.reasonCode, theme),
            const SizedBox(height: 12),
            const Text(
              'State Change Diff:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                        const Text(
                          'Before state',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: kDanger,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          log.beforeState,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'After state',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: kSuccess,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          log.afterState,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
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
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricDictionaryTab(ThemeData theme) {
    // Cover core KPIs defined in SRS Section 8
    final dictionary = [
      {
        'name': 'GMV (Gross Merchandise Value)',
        'formula': 'SUM(Delivered Order Total Value)',
        'source': 'Finance DB',
        'freq': 'Real-time',
        'owner': 'Finance / Executives',
      },
      {
        'name': 'AOV (Average Order Value)',
        'formula': 'GMV / Delivered Order Volume',
        'source': 'Calculated',
        'freq': 'Real-time',
        'owner': 'Finance / Business',
      },
      {
        'name': 'Order Cancellation Rate',
        'formula': 'Cancelled Orders / Placed Orders',
        'source': 'Order Repository',
        'freq': 'Hourly',
        'owner': 'Operations / Support',
      },
      {
        'name': 'Rider Fairness Coefficient',
        'formula': 'StdDev(Orders Delivered) / Mean(Orders Delivered)',
        'source': 'Dispatch DB',
        'freq': 'Daily',
        'owner': 'Operations / Dispatch',
      },
      {
        'name': 'Cohort Retention Ratio',
        'formula': 'Subscribers Active Month N / Subscribers Cohort Start',
        'source': 'Customer CRM',
        'freq': 'Monthly',
        'owner': 'Business Analyst',
      },
      {
        'name': 'SLA Breach Rate',
        'formula': 'Delayed Orders (> Promised + 10min) / Placed Orders',
        'source': 'Order Repos',
        'freq': 'Hourly',
        'owner': 'Operations / Dispatch',
      },
    ];

    final filteredDictionary = dictionary.where((item) {
      if (_dictionarySearchQuery.isEmpty) return true;
      final q = _dictionarySearchQuery.toLowerCase();
      return item['name']!.toLowerCase().contains(q) ||
          item['formula']!.toLowerCase().contains(q) ||
          item['owner']!.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => _dictionarySearchQuery = val),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search dictionary metric names, formulas...',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: filteredDictionary.length,
              itemBuilder: (context, index) {
                final d = filteredDictionary[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d['name']!,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDictionaryMetaRow('Formula', d['formula']!),
                        _buildDictionaryMetaRow('Data Source', d['source']!),
                        _buildDictionaryMetaRow('Update cadence', d['freq']!),
                        _buildDictionaryMetaRow('Strategic Owner', d['owner']!),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDictionaryMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
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
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
