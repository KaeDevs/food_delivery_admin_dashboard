import 'dart:math';
import 'package:admin_dashboard/features/dashboard/widgets/kpi_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/campaign_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/audit_provider.dart';
import '../../data/models/campaign.dart';
import '../../data/models/audit_log.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/extensions.dart';
import '../../shared/widgets/section_header.dart';

class PromotionsScreen extends ConsumerStatefulWidget {
  const PromotionsScreen({super.key});

  @override
  ConsumerState<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends ConsumerState<PromotionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Subscription configuration parameters
  double _subscriptionThreshold = 299.0;
  double _subscriptionDiscountPercent = 10.0;
  bool _subFreeDelivery = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateCampaignDialog() {
    final nameController = TextEditingController();
    final discountController = TextEditingController(text: '15');
    final maxRedemptionsController = TextEditingController(text: '500');
    CampaignType selectedType = CampaignType.percentOff;
    String selectedScope = 'All';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Create Discount Campaign'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Campaign Name',
                      hintText: 'e.g. Monsoon Midday Feast',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<CampaignType>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Campaign Type',
                    ),
                    items: CampaignType.values.map((t) {
                      String label = 'Discount';
                      if (t == CampaignType.percentOff)
                        label = 'Percent Off (%)';
                      if (t == CampaignType.flatOff) label = 'Flat Off (₹)';
                      if (t == CampaignType.freeDelivery)
                        label = 'Free Delivery';
                      if (t == CampaignType.bogo) label = 'BOGO';
                      if (t == CampaignType.freeItem) label = 'Free Item';
                      return DropdownMenuItem(value: t, child: Text(label));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  if (selectedType == CampaignType.percentOff ||
                      selectedType == CampaignType.flatOff)
                    TextField(
                      controller: discountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: selectedType == CampaignType.percentOff
                            ? 'Discount Value (%)'
                            : 'Discount Value (₹)',
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: maxRedemptionsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Redemptions Capacity',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedScope,
                    decoration: const InputDecoration(
                      labelText: 'Restricted Scope',
                    ),
                    items: ['All', 'Bengaluru Only', 'Select Cuisines'].map((
                      s,
                    ) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null)
                        setDialogState(() => selectedScope = val);
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
                  final discount =
                      double.tryParse(discountController.text) ?? 0.0;
                  final maxRedemptions =
                      int.tryParse(maxRedemptionsController.text) ?? 500;

                  final newCampaign = Campaign(
                    id: 'camp-${Random().nextInt(1000)}',
                    name: nameController.text,
                    type: selectedType,
                    status: CampaignStatus.active,
                    discountValue: discount,
                    redemptionCount: 0,
                    maxRedemptions: maxRedemptions,
                    totalSubsidy: 0.0,
                    incrementalOrders: 0.0,
                    startDate: DateTime.now(),
                    endDate: DateTime.now().add(const Duration(days: 7)),
                  );

                  ref.read(campaignProvider.notifier).addCampaign(newCampaign);

                  // Create Audit Log
                  final actor = ref.read(authProvider);
                  ref
                      .read(auditProvider.notifier)
                      .log(
                        AuditLog(
                          id: 'audit-${Random().nextInt(10000)}',
                          actorAdminId: actor?.name ?? 'Admin-001',
                          actorRole: actor?.role ?? 'Super Admin',
                          actionName: 'CREATE_CAMPAIGN',
                          entityType: 'campaign',
                          entityId: newCampaign.id,
                          beforeState: 'none',
                          afterState: 'active',
                          reasonCode: 'Created new discount marketing campaign',
                          timestamp: DateTime.now(),
                        ),
                      );

                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Campaign "${newCampaign.name}" created successfully.',
                      ),
                    ),
                  );
                },
                child: const Text('Create Campaign'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditSubscriptionDialog() {
    final thresholdController = TextEditingController(
      text: _subscriptionThreshold.toStringAsFixed(0),
    );
    final discountController = TextEditingController(
      text: _subscriptionDiscountPercent.toStringAsFixed(0),
    );
    bool freeDelivery = _subFreeDelivery;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Subscription Plan Config'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: thresholdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min Order for Free Delivery (₹)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: discountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Platform Direct Discount (%)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Free Delivery Benefit'),
                      Switch(
                        value: freeDelivery,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (val) =>
                            setDialogState(() => freeDelivery = val),
                      ),
                    ],
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
                  setState(() {
                    _subscriptionThreshold =
                        double.tryParse(thresholdController.text) ?? 299.0;
                    _subscriptionDiscountPercent =
                        double.tryParse(discountController.text) ?? 10.0;
                    _subFreeDelivery = freeDelivery;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subscription parameters updated.'),
                    ),
                  );
                },
                child: const Text('Save Plan Config'),
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
    final campaigns = ref.watch(campaignProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: theme.colorScheme.surface,
          // border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
          child: TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(text: 'Campaigns'),
              Tab(text: 'Subscriptions'),
              Tab(text: 'Merchant Ads'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Campaigns Tab
          _buildCampaignsTab(theme, campaigns),

          // 2. Subscriptions Tab
          _buildSubscriptionsTab(theme),

          // 3. Merchant Ads Tab
          _buildMerchantAdsTab(theme),
        ],
      ),
    );
  }

  Widget _buildCampaignsTab(ThemeData theme, List<Campaign> campaigns) {
    // Campaign summary stats
    final activeCount = campaigns
        .where((c) => c.status == CampaignStatus.active)
        .length;
    final totalRedemptions = campaigns.fold<int>(
      0,
      (sum, c) => sum + c.redemptionCount,
    );
    final totalSubsidy = campaigns.fold<double>(
      0,
      (sum, c) => sum + c.totalSubsidy,
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI row
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              KpiCard(
                title: 'Active Campaigns',
                value: activeCount.toString(),
                icon: Icons.campaign_outlined,
              ),
              KpiCard(
                title: 'Total Redemptions',
                value: totalRedemptions.toString(),
                icon: Icons.check_circle_outline,
              ),
              KpiCard(
                title: 'Subsidy Disbursed',
                value: Formatters.currencyCompact(totalSubsidy),
                icon: Icons.currency_rupee,
                trendColor: kDanger,
              ),
              const KpiCard(
                title: 'Avg Campaign ROI',
                value: '3.4x',
                icon: Icons.trending_up,
                trendColor: kSuccess,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Active Campaign Portfolios',
            actions: [
              FilledButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Campaign'),
                onPressed: _showCreateCampaignDialog,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: context.isLarge
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cards grid list (Left)
                      Expanded(
                        flex: 3,
                        child: _buildCampaignsList(campaigns, theme),
                      ),
                      const SizedBox(width: 24),
                      // ROI Bar chart panel (Right)
                      Expanded(flex: 2, child: _buildRoiChartPanel(theme)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ROI Bar chart panel on top for smaller screens
                      SizedBox(height: 260, child: _buildRoiChartPanel(theme)),
                      const SizedBox(height: 24),
                      // Cards grid list
                      Expanded(child: _buildCampaignsList(campaigns, theme)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignsList(List<Campaign> campaigns, ThemeData theme) {
    return ListView.builder(
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        final c = campaigns[index];
        final progress = c.maxRedemptions > 0
            ? c.redemptionCount / c.maxRedemptions
            : 0.0;

        Color statusColor = kNeutral;
        if (c.status == CampaignStatus.active) statusColor = kSuccess;
        if (c.status == CampaignStatus.paused) statusColor = kWarning;
        if (c.status == CampaignStatus.ended) statusColor = kDanger;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      c.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        c.statusLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${c.typeLabel} • Discount: ${c.discountValue.toStringAsFixed(0)}% • Incremental Orders: ${c.incrementalOrders.toStringAsFixed(0)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: theme.colorScheme.outlineVariant
                            .withOpacity(0.3),
                        color: theme.colorScheme.primary,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${c.redemptionCount}/${c.maxRedemptions}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subsidy Spent: ${Formatters.currency(c.totalSubsidy)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (c.status == CampaignStatus.active)
                      Row(
                        children: [
                          TextButton(
                            onPressed: () =>
                                _updateCampaignStatus(c, CampaignStatus.paused),
                            child: const Text(
                              'Pause',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                _updateCampaignStatus(c, CampaignStatus.ended),
                            style: TextButton.styleFrom(
                              foregroundColor: kDanger,
                            ),
                            child: const Text(
                              'End',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoiChartPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROI Breakdown (Incremental GMV)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.legend_toggle, size: 12, color: kDanger),
              SizedBox(width: 4),
              Text('Subsidy Cost', style: TextStyle(fontSize: 10)),
              SizedBox(width: 16),
              Icon(Icons.show_chart, size: 12, color: kSuccess),
              SizedBox(width: 4),
              Text('GMV Return', style: TextStyle(fontSize: 10)),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRoiRow('Welcome 50', 120, 420, theme),
                  const SizedBox(height: 12),
                  _buildRoiRow('Monsoon Feast', 85, 310, theme),
                  const SizedBox(height: 12),
                  _buildRoiRow('Free Del 299', 60, 240, theme),
                  const SizedBox(height: 12),
                  _buildRoiRow('BOGO Friday', 40, 180, theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoiRow(
    String name,
    double subsidy,
    double gmv,
    ThemeData theme,
  ) {
    final maxVal = 500.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            // Subsidy Cost bar
            Container(
              width: (subsidy / maxVal) * 200,
              height: 8,
              decoration: BoxDecoration(
                color: kDanger.withOpacity(0.8),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(4),
                ),
              ),
            ),
            // GMV Return bar
            Container(
              width: (gmv / maxVal) * 200,
              height: 8,
              decoration: BoxDecoration(
                color: kSuccess.withOpacity(0.8),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(gmv / subsidy).toStringAsFixed(1)}x',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: kSuccess,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubscriptionsTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              KpiCard(
                title: 'Active Subscribers',
                value: '1,420',
                icon: Icons.stars,
              ),
              KpiCard(
                title: 'Renewal Rate',
                value: '82%',
                icon: Icons.refresh,
                trendColor: kSuccess,
              ),
              KpiCard(
                title: 'Avg Sub Revenue',
                value: '₹149/mo',
                icon: Icons.payments,
                trendColor: kSuccess,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Subscription Benefits Settings'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars, color: kSeedColor, size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Swiggy Pass (Active tier)',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Configuration parameters for active platform-wide benefits.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit Plan'),
                        onPressed: _showEditSubscriptionDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSubConfigRow(
                    'Free Delivery Minimum Order',
                    '₹${_subscriptionThreshold.toStringAsFixed(0)}',
                  ),
                  _buildSubConfigRow(
                    'Direct Platform Discount',
                    '${_subscriptionDiscountPercent.toStringAsFixed(0)}% Off',
                  ),
                  _buildSubConfigRow(
                    'Free Delivery Enabled',
                    _subFreeDelivery ? 'Yes' : 'No',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: kSeedColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantAdsTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Sponsored Listings performance',
            subtitle:
                'Advertising campaigns promoted by partner restaurants directly.',
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Campaign')),
                      DataColumn(label: Text('Merchant Restaurant')),
                      DataColumn(label: Text('Budget')),
                      DataColumn(label: Text('Spent')),
                      DataColumn(label: Text('Clicks')),
                      DataColumn(label: Text('ROAS')),
                    ],
                    rows: [
                      _buildAdRow(
                        'Veggie Treats Ad',
                        'Green Kitchen',
                        '₹15,000',
                        '₹8,420',
                        '1,420',
                        '4.2x',
                      ),
                      _buildAdRow(
                        'Monsoon Mega Ads',
                        'Burger House',
                        '₹20,000',
                        '₹18,210',
                        '3,450',
                        '3.8x',
                      ),
                      _buildAdRow(
                        'Biryani Boosters',
                        'Paradise Spices',
                        '₹10,000',
                        '₹5,410',
                        '920',
                        '5.1x',
                      ),
                      _buildAdRow(
                        'Dessert Special',
                        'Sweet Delights',
                        '₹5,000',
                        '₹4,900',
                        '650',
                        '2.7x',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildAdRow(
    String name,
    String rest,
    String budget,
    String spent,
    String clicks,
    String roas,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataCell(Text(rest)),
        DataCell(Text(budget)),
        DataCell(Text(spent)),
        DataCell(Text(clicks)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: kSuccess.withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              roas,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: kSuccess,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _updateCampaignStatus(Campaign campaign, CampaignStatus status) {
    final updated = campaign.copyWith(status: status);
    ref.read(campaignProvider.notifier).updateCampaign(campaign.id, updated);

    // Save audit log
    final actor = ref.read(authProvider);
    ref
        .read(auditProvider.notifier)
        .log(
          AuditLog(
            id: 'audit-${Random().nextInt(10000)}',
            actorAdminId: actor?.name ?? 'Admin-001',
            actorRole: actor?.role ?? 'Super Admin',
            actionName: status == CampaignStatus.paused
                ? 'PAUSE_CAMPAIGN'
                : 'END_CAMPAIGN',
            entityType: 'campaign',
            entityId: campaign.id,
            beforeState: campaign.status.name,
            afterState: status.name,
            reasonCode: 'Manual campaign status modification',
            timestamp: DateTime.now(),
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Campaign "${campaign.name}" status updated.')),
    );
  }
}
