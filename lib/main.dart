import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/mock/mock_seed.dart';
import 'data/mock/mock_restaurants.dart';
import 'data/mock/mock_riders.dart';
import 'data/mock/mock_orders.dart';
import 'data/mock/mock_customers.dart';
import 'data/mock/mock_kpi_snapshots.dart';
import 'data/mock/mock_tickets.dart';
import 'data/mock/mock_transactions.dart';
import 'data/mock/mock_campaigns.dart';
import 'data/mock/mock_audit_logs.dart';
import 'data/mock/mock_alert_rules.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Seed all mock data
  MockAdminUsers.seed();
  MockZones.seed();
  MockRestaurants.seed();
  MockRiders.seed();
  MockOrders.seed();
  MockCustomers.seed();
  MockKpiSnapshots.seed();
  MockTickets.seed();
  MockTransactions.seed();
  MockCampaigns.seed();
  MockAuditLogs.seed();
  MockAlertRules.seed();

  runApp(
    const ProviderScope(
      child: AdminDashboardApp(),
    ),
  );
}
