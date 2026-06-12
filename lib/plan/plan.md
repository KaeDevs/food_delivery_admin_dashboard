# Admin Dashboard — 7-Day Flutter Implementation Plan
## On-Demand Convenience & Food Delivery Platform
**Version:** 1.0 | **Stack:** Flutter Web + Riverpod | **Data:** Mock / In-Memory | **Design:** Material 3

---

## Document Purpose

This plan is a complete, AI-parseable implementation guide for building a production-ready admin dashboard using Flutter Web and Riverpod. Every day is broken into tasks with exact file paths, package names, data structures, widget names, and acceptance criteria. An AI executing this plan should be able to work top-to-bottom without ambiguity.

---

## Technology Stack

| Concern | Choice | Version (min) |
|---|---|---|
| Framework | Flutter | 
| State Management | flutter_riverpod | 2.5+ |
| Routing | go_router | 14.0+ |
| Charts | fl_chart | 0.68+ |
| Maps | google_maps_flutter | 2.9+ |
| Local Persistence | shared_preferences | 2.3+ |
| Icons | material_symbols_icons | 4.2797+ |
| Date Formatting | intl | 0.19+ |
| Theming | Built-in Material 3 | — |
| Fake Data Seed | Built-in Dart random + hard-coded lists | — |

---

## Project Structure

```
lib/
├── main.dart
├── app.dart                          # MaterialApp.router + theme
├── core/
│   ├── theme/
│   │   ├── app_theme.dart            # Material 3 ColorScheme, TextTheme
│   │   └── app_colors.dart           # Semantic color tokens
│   ├── router/
│   │   └── app_router.dart           # go_router route definitions
│   ├── constants/
│   │   └── app_constants.dart        # KPI thresholds, enums, string keys
│   └── utils/
│       ├── formatters.dart           # Currency, date, percent formatters
│       └── extensions.dart           # BuildContext, String, DateTime extensions
├── data/
│   ├── models/                       # Pure Dart data classes (freezed-free, manual)
│   │   ├── admin_user.dart
│   │   ├── customer.dart
│   │   ├── restaurant.dart
│   │   ├── delivery_partner.dart
│   │   ├── order.dart
│   │   ├── menu_item.dart
│   │   ├── ticket.dart
│   │   ├── payment_transaction.dart
│   │   ├── alert_rule.dart
│   │   ├── campaign.dart
│   │   ├── audit_log.dart
│   │   └── kpi_snapshot.dart
│   ├── mock/
│   │   ├── mock_seed.dart            # Central seed call — call once at startup
│   │   ├── mock_orders.dart
│   │   ├── mock_restaurants.dart
│   │   ├── mock_riders.dart
│   │   ├── mock_customers.dart
│   │   ├── mock_tickets.dart
│   │   ├── mock_transactions.dart
│   │   ├── mock_campaigns.dart
│   │   └── mock_audit_logs.dart
│   └── repositories/                 # In-memory store; Riverpod providers read from here
│       ├── order_repository.dart
│       ├── restaurant_repository.dart
│       ├── rider_repository.dart
│       ├── customer_repository.dart
│       ├── ticket_repository.dart
│       ├── finance_repository.dart
│       ├── campaign_repository.dart
│       └── audit_repository.dart
├── providers/                        # All Riverpod StateNotifier / AsyncNotifier providers
│   ├── auth_provider.dart
│   ├── order_provider.dart
│   ├── restaurant_provider.dart
│   ├── rider_provider.dart
│   ├── customer_provider.dart
│   ├── ticket_provider.dart
│   ├── finance_provider.dart
│   ├── dispatch_provider.dart
│   ├── alert_provider.dart
│   ├── campaign_provider.dart
│   ├── audit_provider.dart
│   └── geo_provider.dart
├── features/
│   ├── auth/
│   │   └── login_screen.dart
│   ├── shell/
│   │   ├── shell_scaffold.dart       # Persistent side-nav + top-bar
│   │   └── nav_rail.dart
│   ├── executive/                    # Module 15 partial + KPI board — Screen Cluster 1
│   │   ├── executive_screen.dart
│   │   ├── widgets/
│   │   │   ├── kpi_card.dart
│   │   │   ├── gmv_chart.dart
│   │   │   ├── order_funnel_chart.dart
│   │   │   └── city_drill_down.dart
│   ├── live_ops/                     # Module 6 — Screen Cluster 2
│   │   ├── live_ops_screen.dart
│   │   └── widgets/
│   │       ├── order_list_tile.dart
│   │       ├── delayed_watchlist.dart
│   │       ├── sla_badge.dart
│   │       └── intervention_sheet.dart
│   ├── dispatch/                     # Module 7 — Screen Cluster 3
│   │   ├── dispatch_screen.dart
│   │   └── widgets/
│   │       ├── assignment_queue_table.dart
│   │       ├── fairness_chart.dart
│   │       └── surge_config_panel.dart
│   ├── merchant/                     # Modules 3 & 4 — Screen Cluster 4
│   │   ├── merchant_list_screen.dart
│   │   ├── merchant_detail_screen.dart
│   │   └── widgets/
│   │       ├── merchant_health_card.dart
│   │       ├── menu_governance_table.dart
│   │       └── rating_trend_chart.dart
│   ├── rider/                        # Module 5 — Screen Cluster 5
│   │   ├── rider_list_screen.dart
│   │   ├── rider_detail_screen.dart
│   │   └── widgets/
│   │       ├── rider_status_chip.dart
│   │       ├── earnings_chart.dart
│   │       └── discipline_timeline.dart
│   ├── finance/                      # Module 9 — Screen Cluster 6
│   │   ├── finance_screen.dart
│   │   └── widgets/
│   │       ├── payment_channel_chart.dart
│   │       ├── settlement_table.dart
│   │       └── refund_queue.dart
│   ├── trust_safety/                 # Module 12 — Screen Cluster 7
│   │   ├── trust_screen.dart
│   │   └── widgets/
│   │       ├── fraud_case_card.dart
│   │       ├── discipline_panel.dart
│   │       └── evidence_viewer.dart
│   ├── customer_intel/               # Modules 2 & 11 — Screen Cluster 8
│   │   ├── customer_screen.dart
│   │   ├── customer_detail_screen.dart
│   │   └── widgets/
│   │       ├── cohort_retention_chart.dart
│   │       ├── churn_risk_table.dart
│   │       └── promo_dependency_chart.dart
│   ├── geo_ops/                      # Module 8 — Screen Cluster 9
│   │   ├── geo_ops_screen.dart
│   │   └── widgets/
│   │       ├── live_map_widget.dart
│   │       ├── zone_health_panel.dart
│   │       └── layer_toggle_bar.dart
│   ├── support/                      # Module 13 — Screen Cluster 10
│   │   ├── support_screen.dart
│   │   └── widgets/
│   │       ├── ticket_card.dart
│   │       ├── compensation_panel.dart
│   │       └── root_cause_chart.dart
│   ├── identity/                     # Module 1
│   │   ├── identity_screen.dart
│   │   └── widgets/
│   │       ├── rbac_matrix_table.dart
│   │       └── admin_user_form.dart
│   ├── ratings/                      # Module 10
│   │   ├── ratings_screen.dart
│   │   └── widgets/
│   │       ├── rating_distribution_chart.dart
│   │       └── review_moderation_list.dart
│   ├── promotions/                   # Module 14
│   │   ├── promotions_screen.dart
│   │   └── widgets/
│   │       ├── campaign_card.dart
│   │       └── campaign_roi_chart.dart
│   └── reporting/                    # Module 15
│       ├── reporting_screen.dart
│       └── widgets/
│           ├── audit_trail_table.dart
│           └── export_button.dart
└── shared/
    ├── widgets/
    │   ├── app_data_table.dart       # Reusable sortable data table
    │   ├── app_search_bar.dart
    │   ├── status_chip.dart
    │   ├── section_header.dart
    │   ├── empty_state.dart
    │   ├── loading_shimmer.dart
    │   ├── confirmation_dialog.dart
    │   └── detail_drawer.dart        # Right-side 480px detail panel
    └── layouts/
        ├── dashboard_layout.dart     # Title + filter bar + content area
        └── two_pane_layout.dart      # List left / detail right for lg screens
```

---

## Mock Data Specification

### Counts (small but covering every edge case)

| Entity | Count | Notes |
|---|---|---|
| Admin Users | 8 | One per role defined in Section 2 of SRS |
| Customers | 30 | Mix of high/mid/low frequency; 3 marked churn risk; 2 promo abusers |
| Restaurants | 20 | Mix of ratings (2 below threshold), cuisines, statuses; 2 pending onboarding |
| Delivery Partners | 25 | Mix of active/suspended/pending; 2 with discipline cases |
| Orders | 60 | Spread across all statuses in the full state machine; 5 delayed; 3 cancelled |
| Menu Items | 40 | 2 per restaurant average; dietary mix; 3 with dietary tag errors |
| Support Tickets | 20 | Mix of customer/merchant/rider; some open, some resolved |
| Payment Transactions | 60 | One per order; mix of UPI/card/wallet/COD; 3 failed |
| Campaigns | 8 | Mix of active/paused/ended; different types |
| Audit Logs | 40 | Covering all major action types |
| Zones | 6 | Named city zones; each with demand/supply metrics |

### Enum Definitions (use in all models)

```dart
// order.dart
enum OrderStatus {
  placed, restaurantAccepted, preparing, ready,
  riderAssigned, riderAtRestaurant, pickedUp, onTheWay,
  delivered, cancelled, failed
}

enum CancellationReason {
  customerPrePrep, customerPostPrep, restaurantRejection,
  riderUnavailable, paymentFailure, systemError
}

// delivery_partner.dart
enum RiderStatus { available, assigned, delivering, offline, suspended }
enum DisciplineOutcome { cleared, formalWarning, shortSuspension, longSuspension, permanentBan }

// restaurant.dart  
enum RestaurantStatus { active, inactive, suspended, pendingOnboarding, underReview }
enum DocumentStatus { pending, underReview, approved, rejected, expired }

// ticket.dart
enum TicketStatus { open, inProgress, resolved, reopened }
enum TicketType { customer, merchant, rider }
enum TicketPriority { low, medium, high, critical }

// payment_transaction.dart
enum PaymentChannel { upi, card, wallet, netBanking, cod }
enum PaymentStatus { success, failed, pending, refunded }

// campaign.dart
enum CampaignType { percentOff, flatOff, freeDelivery, bogo, freeItem }
enum CampaignStatus { active, paused, ended, scheduled }

// alert_rule.dart
enum AlertSeverity { info, warning, critical }
```

### Model Schemas (minimal, typed)

```dart
// order.dart
class Order {
  final String id;
  final String customerId;
  final String restaurantId;
  final String? riderId;
  final OrderStatus status;
  final List<OrderItem> items;
  final double totalValue;
  final PaymentChannel paymentChannel;
  final DateTime placedAt;
  final DateTime? promisedDeliveryAt;
  final DateTime? actualDeliveryAt;
  final String zoneId;
  final CancellationReason? cancellationReason;
  final bool isSlaBreached;        // computed: actualDelivery > promised + 10min
  final String? supportTicketId;
}

class OrderItem {
  final String menuItemId;
  final String name;
  final int quantity;
  final double price;
}

// restaurant.dart
class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final String zoneId;
  final RestaurantStatus status;
  final double rating;             // weighted composite
  final double rejectionRate;      // 0.0–1.0
  final int avgPrepTimeMinutes;
  final int promisedPrepTimeMinutes;
  final DocumentStatus fssaiStatus;
  final DocumentStatus gstStatus;
  final DateTime? fssaiExpiry;
  final double weeklySettlementPending;
  final int totalOrdersThisMonth;
  final bool isOnline;
}

// delivery_partner.dart
class DeliveryPartner {
  final String id;
  final String name;
  final String phone;
  final String zoneId;
  final RiderStatus status;
  final double rating;
  final double acceptanceRate;
  final double completionRate;
  final double onTimeDeliveryRate;
  final double earningsThisWeek;
  final double earningsToday;
  final int deliveriesThisMonth;
  final int warningCount;          // rolling 30-day
  final bool isSuspended;
  final DocumentStatus licenceStatus;
  final DateTime? licenceExpiry;
  final List<DisciplineEvent> disciplineHistory;
}

class DisciplineEvent {
  final String id;
  final DateTime date;
  final String offenceType;
  final DisciplineOutcome outcome;
  final String adminNote;
}

// customer.dart
class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final int totalOrders;
  final double lifetimeValue;
  final double refundRate;         // refunds / completed orders
  final bool isPromoAbuser;
  final double churnRiskScore;     // 0.0–1.0
  final String subscriptionStatus; // 'none' | 'active' | 'expired'
  final DateTime lastOrderDate;
  final String acquisitionCohort;  // 'YYYY-MM'
}

// ticket.dart
class SupportTicket {
  final String id;
  final String orderId;
  final String raisedById;         // customer/rider/merchant ID
  final TicketType type;
  final TicketPriority priority;
  final TicketStatus status;
  final String issueCategory;
  final String description;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final double? compensationAmount;
  final String? assignedAdminId;
}

// payment_transaction.dart
class PaymentTransaction {
  final String id;
  final String orderId;
  final double amount;
  final PaymentChannel channel;
  final PaymentStatus status;
  final DateTime timestamp;
  final String? failureReason;
  final bool isRefunded;
  final double? refundAmount;
}

// campaign.dart
class Campaign {
  final String id;
  final String name;
  final CampaignType type;
  final CampaignStatus status;
  final double discountValue;
  final int redemptionCount;
  final int maxRedemptions;
  final double totalSubsidy;
  final double incrementalOrders;  // estimated lift
  final DateTime startDate;
  final DateTime endDate;
}

// audit_log.dart
class AuditLog {
  final String id;
  final String actorAdminId;
  final String actorRole;
  final String actionName;         // e.g. 'SUSPEND_RIDER', 'APPROVE_REFUND'
  final String entityType;         // 'order' | 'rider' | 'restaurant' | 'customer'
  final String entityId;
  final String beforeState;
  final String afterState;
  final String reasonCode;
  final DateTime timestamp;
}

// kpi_snapshot.dart (pre-computed for chart widgets)
class KpiSnapshot {
  final DateTime date;
  final int orderVolume;
  final double gmv;
  final double aov;
  final int activeRestaurants;
  final int activeRiders;
  final double onTimeRate;
  final double cancellationRate;
  final double refundRate;
}

// alert_rule.dart
class AlertRule {
  final String id;
  final String name;
  final AlertSeverity severity;
  final String triggerCondition;   // human-readable for mock
  final double thresholdValue;
  final bool isActive;
  final String ownerRole;
  final bool isFired;              // mock: some pre-fired
  final DateTime? firedAt;
}

// Zone (simple)
class Zone {
  final String id;
  final String name;
  final double centerLat;
  final double centerLng;
  final int activeOrders;
  final int availableRiders;
  final double demandSupplyRatio;  // >1.5 = shortage, <0.5 = oversupply
  final bool isSurgeActive;
}

// AdminUser
class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role;               // matches roles in Section 2
  final String scope;              // 'global' | city name
  final bool isActive;
  final DateTime lastLogin;
}
```

---

## Day-by-Day Implementation Plan

---

### DAY 1 — Project Foundation, Theme, Navigation Shell, Auth

**Goal:** Running Flutter Web app with full navigation shell, Material 3 theme, RBAC-aware routing, and a working login screen with role selection.

---

#### Task 1.1 — Project Bootstrap

**File:** `pubspec.yaml`

Add dependencies:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.7
  fl_chart: ^0.68.0
  google_maps_flutter: ^2.9.0
  google_maps_flutter_web: ^0.5.9
  shared_preferences: ^2.3.2
  material_symbols_icons: ^4.2797.0
  intl: ^0.19.0
```

**File:** `web/index.html`

Add Google Maps JS API script tag in `<head>`:
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_GOOGLE_MAPS_KEY"></script>
```
Replace `YOUR_GOOGLE_MAPS_KEY` with actual key. This is the only external dependency.

---

#### Task 1.2 — Material 3 Theme

**File:** `lib/core/theme/app_colors.dart`

Define semantic tokens:
```dart
// Seed color: deep indigo — professional, trustworthy
const Color kSeedColor = Color(0xFF3F4DC8);

// Status colors (used in chips, badges, charts)
const Color kSuccess   = Color(0xFF1B8A5A);
const Color kWarning   = Color(0xFFF5A623);
const Color kDanger    = Color(0xFFD93025);
const Color kInfo      = Color(0xFF1A73E8);
const Color kNeutral   = Color(0xFF6B7280);

// Chart palette (8 distinct colors)
const List<Color> kChartPalette = [
  Color(0xFF3F4DC8), Color(0xFF10B981), Color(0xFFF59E0B),
  Color(0xFFEF4444), Color(0xFF8B5CF6), Color(0xFF06B6D4),
  Color(0xFFF97316), Color(0xFF84CC16),
];
```

**File:** `lib/core/theme/app_theme.dart`

```dart
// Build ThemeData using ColorScheme.fromSeed(seedColor: kSeedColor, brightness: Brightness.light)
// Typography: use TextTheme with Google Fonts (Inter) if available, else system default
// NavigationRail theme: indicator color = colorScheme.primaryContainer
// Card theme: elevation 0, border = Border.all(color: colorScheme.outlineVariant, width: 1), borderRadius 12
// AppBar theme: surfaceTintColor = transparent, scrolledUnderElevation = 1
// DataTable theme: headingRowColor = colorScheme.surfaceVariant
// FilledButton theme: borderRadius 8
// Also define a dark ThemeData using Brightness.dark with same seed
```

---

#### Task 1.3 — Router

**File:** `lib/core/router/app_router.dart`

Routes:
```
/login                            → LoginScreen
/                                 → redirect to /executive (if logged in) or /login
/executive                        → ExecutiveScreen        (shell)
/live-ops                         → LiveOpsScreen          (shell)
/dispatch                         → DispatchScreen         (shell)
/merchants                        → MerchantListScreen     (shell)
/merchants/:id                    → MerchantDetailScreen   (shell)
/riders                           → RiderListScreen        (shell)
/riders/:id                       → RiderDetailScreen      (shell)
/finance                          → FinanceScreen          (shell)
/trust                            → TrustScreen            (shell)
/customers                        → CustomerScreen         (shell)
/customers/:id                    → CustomerDetailScreen   (shell)
/geo-ops                          → GeoOpsScreen           (shell)
/support                          → SupportScreen          (shell)
/identity                         → IdentityScreen         (shell)
/ratings                          → RatingsScreen          (shell)
/promotions                       → PromotionsScreen       (shell)
/reporting                        → ReportingScreen        (shell)
```

Shell route wraps all authenticated routes in `ShellScaffold`.

Redirect guard: if `authProvider.currentUser == null`, redirect to `/login`.

---

#### Task 1.4 — Login Screen

**File:** `lib/features/auth/login_screen.dart`

Layout:
- Centered card (480px wide, elevation 0, outlined border)
- Platform logo + "Admin Dashboard" title
- Email text field (pre-filled with mock email)
- Password field (pre-filled, obscured)
- Role dropdown: lists all 8 roles from SRS Section 2
- "Sign In" FilledButton

On submit:
- Look up mock admin user by selected role from `mockAdminUsers` list
- Set `authProvider.currentUser = matchedUser`
- Navigate to `/executive`

No real authentication. Role selection drives RBAC — show/hide nav items accordingly.

---

#### Task 1.5 — Navigation Shell

**File:** `lib/features/shell/shell_scaffold.dart`

Layout (use `Row` at top level):
- `NavigationRail` (left, 240px extended, always-visible labels)
- `VerticalDivider` 1px
- `Expanded` content area with `child` from router

**File:** `lib/features/shell/nav_rail.dart`

Nav destinations grouped by role visibility:

| Destination | Icon | Route | Visible to Roles |
|---|---|---|---|
| Executive | `dashboard` | /executive | All |
| Live Operations | `monitoring` | /live-ops | Super, Ops, Dispatch |
| Dispatch | `local_shipping` | /dispatch | Super, Ops, Dispatch |
| Merchants | `store` | /merchants | Super, Ops, Merchant |
| Riders | `delivery_dining` | /riders | Super, Ops, Dispatch |
| Finance | `payments` | /finance | Super, Finance |
| Trust & Safety | `security` | /trust | Super, TrustSafety |
| Customers | `people` | /customers | Super, Support, Analyst |
| Geo Operations | `map` | /geo-ops | Super, Ops, Dispatch |
| Support | `support_agent` | /support | Super, Support |
| Identity | `manage_accounts` | /identity | Super |
| Ratings | `star` | /ratings | Super, Merchant, Analyst |
| Promotions | `campaign` | /promotions | Super, Merchant |
| Reporting | `bar_chart` | /reporting | All |

Top of rail: avatar + admin name + role badge pill.
Bottom of rail: theme toggle (light/dark) + logout icon button.

**File:** `lib/features/shell/top_bar.dart`

Show: page title, breadcrumb if nested, global alert bell (badge count from `alertProvider.firedCount`), admin role chip.

---

#### Task 1.6 — Shared Widgets (scaffolding)

Create placeholder implementations (Day 1 scaffold; flesh out on relevant days):

**`lib/shared/widgets/app_data_table.dart`**
- Generic `AppDataTable<T>` widget
- Props: `columns: List<DataColumn>`, `rows: List<T>`, `rowBuilder: DataRow Function(T)`, `onRowTap: Function(T)?`
- Include: row count label, sort state, hover highlight
- Use Flutter's built-in `DataTable` wrapped with `SingleChildScrollView` (horizontal + vertical)

**`lib/shared/widgets/status_chip.dart`**
- `StatusChip({required String label, required Color color})`
- Renders a small pill with filled background (10% opacity) and colored text

**`lib/shared/widgets/kpi_card.dart`**
- `KpiCard({required String title, required String value, String? subtitle, IconData? icon, Color? trendColor, String? trendLabel})`
- Card with: icon top-left, value (headline large), title (label medium), optional trend arrow + label
- `onTap` → drill-down callback

**`lib/shared/widgets/section_header.dart`**
- `SectionHeader({required String title, String? subtitle, List<Widget> actions})`
- 24px title, divider below

**`lib/shared/widgets/detail_drawer.dart`**
- Right-side panel 480px wide
- Used for order detail, rider 360, merchant 360 without full navigation
- `showDetailDrawer(context, child)` helper function

**`lib/shared/widgets/confirmation_dialog.dart`**
- `showConfirmationDialog({title, message, confirmLabel, onConfirm})` — returns Future\<bool\>

---

#### Day 1 Acceptance Criteria
- [ ] `flutter run -d chrome` starts without errors
- [ ] Login screen renders; selecting any role and signing in navigates to Executive screen
- [ ] Navigation rail visible; all 14 destinations render (placeholder screens acceptable)
- [ ] Role-based nav items hidden appropriately per role
- [ ] Theme toggle switches light/dark correctly
- [ ] Router handles deep-link URL directly (e.g. typing `/merchants` in browser)

---

### DAY 2 — Mock Data Layer + Executive Command Centre

**Goal:** Full mock data seeded and available via Riverpod providers. Executive KPI board working with charts.

---

#### Task 2.1 — Mock Data Generation

**File:** `lib/data/mock/mock_seed.dart`

This is the single entry point. Call `MockSeed.initialize()` in `main.dart` before `runApp()`.

```dart
class MockSeed {
  static void initialize() {
    MockOrders.seed();
    MockRestaurants.seed();
    MockRiders.seed();
    MockCustomers.seed();
    MockTickets.seed();
    MockTransactions.seed();
    MockCampaigns.seed();
    MockAuditLogs.seed();
  }
}
```

Each seed file populates a static list. Repositories read from these lists.

**File:** `lib/data/mock/mock_restaurants.dart`

Seed 20 restaurants covering:
- 2 restaurants with rating < 3.5 (trigger quality alert)
- 2 restaurants with `status = pendingOnboarding`
- 1 restaurant with `fssaiStatus = expired`
- 3 restaurants with `rejectionRate > 0.15`
- Cuisine variety: Indian, Chinese, Italian, Fast Food, Biryani, Pizza, Healthy, Desserts
- Spread across all 6 zones

**File:** `lib/data/mock/mock_riders.dart`

Seed 25 riders covering:
- 5 with `status = offline`
- 2 with `isSuspended = true`
- 2 with `warningCount >= 2`
- 1 with `licenceStatus = expired`
- Spread across all 6 zones
- Earnings vary: some significantly above zone median (trigger fairness alert)

**File:** `lib/data/mock/mock_orders.dart`

Seed 60 orders covering:
- Full state machine coverage: at least 2 orders in every `OrderStatus`
- 5 orders where `isSlaBreached = true`
- 3 orders with `status = cancelled` with different `cancellationReason`
- 2 orders with `status = failed`
- 10 recently delivered (last 2 hours)
- 20 delivered today (for daily KPIs)

**File:** `lib/data/mock/mock_customers.dart`

Seed 30 customers:
- 3 with `churnRiskScore > 0.75`
- 2 with `isPromoAbuser = true`
- 3 with `refundRate > 0.3`
- Acquisition cohorts spanning last 6 months

**File:** `lib/data/mock/mock_kpi_snapshots.dart`

Generate 30 `KpiSnapshot` objects (one per day for the last 30 days) with realistic trends:
- GMV trending upward overall with some dips
- Cancellation rate spike on day 15 (simulate incident)
- On-time rate drop on days 20–22

**File:** `lib/data/mock/mock_audit_logs.dart`

40 entries covering all major action types:
```
SUSPEND_RIDER, REINSTATE_RIDER, APPROVE_REFUND, REJECT_REFUND,
FORCE_CLOSE_RESTAURANT, ISSUE_IMPROVEMENT_NOTICE, REASSIGN_ORDER,
UPDATE_DISPATCH_RULE, APPROVE_MERCHANT, REJECT_KYC,
ISSUE_WARNING, PERMANENT_BAN (1 — requires note)
```

---

#### Task 2.2 — Repository Layer

Each repository is a simple class with static methods that filter/sort the mock lists. No async needed — return synchronously. Wrap in `Future.value()` only if provider needs AsyncNotifier.

Example pattern:
```dart
// order_repository.dart
class OrderRepository {
  static List<Order> getAll() => MockOrders.orders;
  static List<Order> getByStatus(OrderStatus status) =>
      MockOrders.orders.where((o) => o.status == status).toList();
  static List<Order> getDelayed() =>
      MockOrders.orders.where((o) => o.isSlaBreached).toList();
  static Order? getById(String id) =>
      MockOrders.orders.firstWhereOrNull((o) => o.id == id);
  static List<Order> getByRestaurant(String restaurantId) =>
      MockOrders.orders.where((o) => o.restaurantId == restaurantId).toList();
  static void updateStatus(String id, OrderStatus newStatus) {
    final idx = MockOrders.orders.indexWhere((o) => o.id == id);
    if (idx != -1) {
      MockOrders.orders[idx] = MockOrders.orders[idx].copyWith(status: newStatus);
    }
  }
}
```

All models must implement `copyWith()` manually (no code gen).

---

#### Task 2.3 — Riverpod Providers

**File:** `lib/providers/order_provider.dart`

```dart
// StateNotifier holding List<Order>; exposes mutation methods
final orderListProvider = StateNotifierProvider<OrderNotifier, List<Order>>((ref) {
  return OrderNotifier(OrderRepository.getAll());
});

// Derived providers (use Provider, not StateNotifier)
final delayedOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(orderListProvider).where((o) => o.isSlaBreached).toList();
});

final ordersByStatusProvider = Provider.family<List<Order>, OrderStatus>((ref, status) {
  return ref.watch(orderListProvider).where((o) => o.status == status).toList();
});
```

Create similar patterns for all other domains. Key derived providers needed:
- `restaurantsBelowRatingThresholdProvider` — List\<Restaurant\> where rating < 3.5
- `ridersWithWarningsProvider` — List\<DeliveryPartner\> where warningCount >= 2
- `openTicketsProvider` — List\<SupportTicket\> where status != resolved
- `failedTransactionsProvider` — List\<PaymentTransaction\> where status == failed
- `churnRiskCustomersProvider` — List\<Customer\> where churnRiskScore > 0.7
- `alertsProvider` — StateNotifierProvider\<List\<AlertRule\>\>; pre-fire some alerts on seed

---

#### Task 2.4 — Executive Command Centre Screen

**File:** `lib/features/executive/executive_screen.dart`

Layout: `DashboardLayout` with scrollable content.

**Section 1: Top KPI Row (8 cards in a `Wrap` or responsive grid)**

| Card | Value Source | Trend |
|---|---|---|
| Gross Order Volume | count of all orders today | vs yesterday |
| Net Completed Orders | count where status == delivered | vs yesterday |
| GMV Today | sum of totalValue for today's delivered | vs yesterday |
| Average Order Value | GMV / orderCount | vs last week |
| Monthly Transacting Users | distinct customers with order this month | — |
| Active Restaurants | restaurants with order this month | — |
| Active Riders | riders with delivery this month | — |
| On-Time Delivery Rate | delivered on time / total delivered | — |

KPI cards use `KpiCard` widget. Trend arrow: green up / red down / grey neutral.

**Section 2: GMV & Order Volume Chart (30-day line chart)**

Use `fl_chart` `LineChart`. Two lines: GMV (left Y-axis) and Order Volume (right Y-axis). Use `kChartPalette[0]` and `kChartPalette[1]`. Show tooltip on touch. X-axis: last 30 days abbreviated.

**Section 3: Order Status Funnel (bar chart)**

`BarChart` showing count per `OrderStatus`. Color each bar by status severity (delivering = green, delayed = orange, cancelled = red, etc.)

**Section 4: Live Incident Feed (right panel, 320px)**

List of `AlertRule` where `isFired == true`, sorted by severity descending. Each row: severity icon + color, alert name, zone/entity, time fired. Tap → navigate to relevant screen.

**Section 5: City Drill-Down Table**

Simple table: Zone | Active Orders | Available Riders | D/S Ratio | SLA Breach Rate | Action button.

---

#### Day 2 Acceptance Criteria
- [ ] All mock data initialized on startup; no null errors
- [ ] Executive screen shows all 8 KPI cards with real mock values
- [ ] GMV line chart renders 30 data points correctly
- [ ] Live incident feed shows pre-fired alerts
- [ ] City drill-down table shows all 6 zones
- [ ] All providers return correct filtered data (verify with debug prints)

---

### DAY 3 — Live Ops + Dispatch + Order Lifecycle (Modules 6 & 7)

**Goal:** Real-time order command centre with intervention tools and dispatch fairness dashboard.

---

#### Task 3.1 — Live Operations Screen

**File:** `lib/features/live_ops/live_ops_screen.dart`

Layout: `TwoPaneLayout` — order list left, order detail right (or `DetailDrawer` on medium screens).

**Top Summary Bar (4 stat chips):**
- Orders Active | Delayed (red badge) | SLA At Risk | Avg ETA

**Filter Bar:**
- Zone dropdown (All + 6 zones)
- Status multi-select chips
- "Delayed Only" toggle
- Search by order ID / customer name

**Order List (`AppDataTable`):**

Columns: Order ID | Customer | Restaurant | Rider | Status | Value | Placed At | ETA | SLA Status

Rows sorted by: SLA at-risk first (exception-first design).

`SLA Badge` widget: shows green "On Time", amber "At Risk", red "Breached" based on time vs promised ETA.

**Order Detail Panel (right side / drawer):**

Shown when a row is tapped. Contents:
- Order header: ID, status chip, payment channel, total value
- Timeline stepper (vertical): each `OrderStatus` with timestamp; current step highlighted
- Items list: name, quantity, price
- Customer section: name, phone (masked), address
- Restaurant section: name, zone, prep time actual vs promised
- Rider section: name, phone (masked), current status
- **Intervention buttons** (role-gated — Ops Admin only):
  - "Reassign Rider" → opens `ReassignDialog` (select from available riders list + reason code dropdown)
  - "Extend ETA" → opens dialog with +10/+20/+30 min options + reason
  - "Force Cancel" → `ConfirmationDialog` with mandatory reason code
  - "Issue Compensation" → amount field + reason
  - "Contact Restaurant" → shows restaurant phone (unmasked for Ops Admin)
- Linked support ticket (if any): show ticket ID + status

**Delayed Order Watchlist (bottom section, collapsible):**

Table of orders where `isSlaBreached == true` or ETA is <5 min away and status != delivered. Quick action buttons: Reassign | Extend ETA | Escalate.

---

#### Task 3.2 — Dispatch Screen

**File:** `lib/features/dispatch/dispatch_screen.dart`

Layout: Three columns (on large screen) — Assignment Queue | Fairness Metrics | Config Panel.

**Column 1: Assignment Queue Table**

Columns: Order ID | Restaurant Zone | Assigned Rider | Assignment Mode (Auto/Manual) | Latency (seconds) | Fairness Score | Distance to Restaurant

Badge on "Manual" rows: amber chip.
Unassigned orders at top (if any in mock).

**Column 2: Fairness Metrics**

`FairnessChart` — BarChart showing orders delivered per rider for current day, sorted descending. Horizontal line = zone average. Bars significantly above threshold colored red (fairness violation indicator).

Below chart:
- Earnings Parity Index: single number (Gini coefficient, 0–1; lower = fairer) as a gauge or progress bar
- Idle Time Variance: per-zone table showing avg idle minutes and variance

**Column 3: Surge & Config Panel**

Per zone: toggle switch for "Surge Active", multiplier value (1.0x – 3.0x slider), active orders count, available riders count, D/S ratio badge.

"Zone Imbalance" alert banner (red) if any zone D/S ratio > 1.5.

Dispatch rules section (read-only display for MVP):
- Proximity Weight: 40%
- Fairness Weight: 30%
- SLA Weight: 30%
- Batch Eligibility: enabled
- Max Concurrent per Rider: 2

"Edit Rules" button → `ConfirmationDialog` → saves to `dispatchProvider` state (in-memory) + logs to `auditProvider`.

---

#### Task 3.3 — Order Provider Mutations

Add these mutation methods to `OrderNotifier`:

```dart
void reassignRider(String orderId, String newRiderId, String reasonCode)
void extendEta(String orderId, int extraMinutes, String reasonCode)
void forceCancel(String orderId, CancellationReason reason)
void issueCompensation(String orderId, double amount, String reason)
```

Each mutation:
1. Updates the order in mock list
2. Appends an `AuditLog` entry via `auditProvider.log(...)`
3. Calls `ref.notifyListeners()` so UI rebuilds

---

#### Day 3 Acceptance Criteria
- [ ] Live ops table shows all 60 orders; sorts delayed to top
- [ ] Tapping an order shows full detail panel with timeline stepper
- [ ] All 4 intervention buttons open correct dialogs
- [ ] Reassign rider updates order in list and creates audit log entry
- [ ] Dispatch fairness chart shows per-rider order counts
- [ ] Surge toggle updates zone state in provider and reflects in UI

---

### DAY 4 — Merchant, Rider, Ratings Modules (Modules 3, 4, 5, 10)

**Goal:** Full merchant cockpit with onboarding/menu governance, full rider 360 with discipline workflow, and ratings intelligence.

---

#### Task 4.1 — Merchant List Screen

**File:** `lib/features/merchant/merchant_list_screen.dart`

Filter bar: Status filter chips (All / Active / Pending / Suspended / Under Review), Zone dropdown, Rating filter (All / Below 3.5 / Above 4.0), Search by name.

`AppDataTable` columns:
Name | Cuisine | Zone | Status | Rating | Rejection Rate | Prep Time Accuracy | Settlement Pending | FSSAI Status | Actions

Actions column: "View" (→ detail), "Force Toggle Online/Offline" (Merchant Admin only).

Alert banner at top: "2 restaurants below rating threshold" (link scrolls to those rows, which are highlighted amber).

---

#### Task 4.2 — Merchant Detail Screen

**File:** `lib/features/merchant/merchant_detail_screen.dart`

Tabs: Overview | Menu & Catalogue | Settlement | Compliance | Analytics

**Tab: Overview**
- Header card: name, cuisine, zone, status chip, online toggle
- KPIs row: Rating | Orders This Month | Rejection Rate | Avg Prep Time | Pending Settlement
- Rating trend chart (last 30 days, `LineChart`)
- Recent orders table (last 10, from mock)

**Tab: Menu & Catalogue**
- `MenuGovernanceTable`: Item Name | Category | Price | Dietary Tag | Tag Error? | Stock Status | Last Updated
- Tag errors highlighted red
- "Flag Item" action per row (Admin)
- "Approve Image" / "Reject Image" for items with photo

**Tab: Settlement**
- Weekly settlement summary: Gross | Commission | Discount CoFund | GST | Net Payout
- Settlement history table: last 4 weeks
- "Dispute Settlement" button → opens form with amount + reason fields

**Tab: Compliance**
- Document checklist: FSSAI | GST | PAN | Bank Account — each with status chip + expiry date
- "Request Renewal" button per expired document

**Tab: Analytics**
- Peak hour heatmap (simplified: 7-column × 24-row grid with color intensity — use `GridView` with colored containers)
- Best-selling items: horizontal bar chart (top 5)

---

#### Task 4.3 — Rider List Screen

**File:** `lib/features/rider/rider_list_screen.dart`

Filter: Status chips (All / Available / Delivering / Offline / Suspended), Zone dropdown, "Has Warnings" toggle, Search.

`AppDataTable` columns:
Name | Zone | Status | Acceptance Rate | Completion Rate | On-Time Rate | Earnings Today | Warnings (30d) | Licence Status | Actions

Suspended riders: row background tinted red (10% opacity).
Riders with warnings: warning icon badge in Warnings column.

---

#### Task 4.4 — Rider Detail Screen

**File:** `lib/features/rider/rider_detail_screen.dart`

Tabs: Profile | Performance | Earnings | Discipline | Documents

**Tab: Profile**
- Avatar placeholder + name, phone, zone, vehicle type, status chip
- KPIs: Deliveries This Month | Rating | Acceptance Rate | Completion Rate

**Tab: Performance**
- `EarningsChart`: last 7 days bar chart
- Metrics table: On-Time Rate | Avg Delivery Time | Orders per Hour

**Tab: Earnings**
- Today's earnings breakdown: Base Pay + Distance + Tips + Incentives
- Weekly summary table

**Tab: Discipline**
- Warning counter pill: "X / 2 warnings (30-day window)"
- `DisciplineTimeline`: vertical list of `DisciplineEvent` with date, offence, outcome chip
- If `isSuspended`: show suspension details card + "Reinstate" button (Trust Admin only) → `ConfirmationDialog` → updates rider status + audit log
- If `warningCount >= 2`: show "Initiate Suspension Review" button → opens `SuspensionDialog` with outcome options (DisciplineOutcome enum) + evidence text area + reason code

**Tab: Documents**
- Licence | RC | Insurance: status chip, expiry date, "Request Renewal" button

---

#### Task 4.5 — Ratings Screen

**File:** `lib/features/ratings/ratings_screen.dart`

Two-column layout:

**Left: Ratings Intelligence**
- Platform average rating badge (restaurants vs riders side by side)
- `RatingDistributionChart`: grouped bar chart showing restaurant rating buckets (1–2, 2–3, 3–4, 4–5) and count
- "Declining Restaurants" alert list: restaurants where rating dropped >0.3 in last 30 days (mock 2 such restaurants)
- Rider rating percentile chart: horizontal bar chart showing top 5 riders by rating

**Right: Review Moderation Queue**
- List of reviews flagged by mock (mark 5 mock reviews as flagged — profanity / suspicious pattern)
- Each card: reviewer name (masked) | restaurant | rating | review text | flag reason
- Actions: "Approve" | "Hide" | "Escalate to T&S"
- Counter at top: `Pending: N`

---

#### Day 4 Acceptance Criteria
- [ ] Merchant list shows alert banner for 2 below-threshold restaurants
- [ ] Merchant detail all 5 tabs navigate and render correctly
- [ ] Menu governance table highlights dietary tag errors
- [ ] Rider list suspended rows tinted red
- [ ] Rider discipline tab shows "Initiate Suspension Review" when warningCount >= 2
- [ ] Suspension action updates rider state and creates audit log
- [ ] Ratings moderation queue shows 5 flagged reviews with working actions

---

### DAY 5 — Finance, Trust & Safety, Customer Intelligence (Modules 9, 12, 2, 11)

**Goal:** Finance control centre with reconciliation tools, Trust & Safety workbench, and customer behaviour analytics.

---

#### Task 5.1 — Finance Screen

**File:** `lib/features/finance/finance_screen.dart`

Layout: Full-width with tabs — Overview | Transactions | Settlements | Rider Payouts | Refunds & Disputes

**Tab: Overview**
- P&L snapshot row: GMV | Total Commission | Refund Cost | Payout Cost | Net Revenue (computed from mock)
- `PaymentChannelChart`: Donut/Pie chart showing transaction count by PaymentChannel. Use `PieChart` from fl_chart.
- Payment gateway health table: Channel | Success Rate | Failed Count | Last Failure. Mark rows red where success rate < 95%.
- COD summary: Total Collected | Expected | Variance (flag if variance > 0)

**Tab: Transactions**
- Search by order ID or transaction ID
- `AppDataTable`: Txn ID | Order ID | Customer | Amount | Channel | Status | Timestamp | Failure Reason
- Filter: Channel | Status | Date range (last 7d / 30d / custom)
- Failed transactions highlighted red with "Retry" action button (mock: updates status to success + audit log)

**Tab: Settlements**
- Per-restaurant settlement table: Restaurant | Gross | Commission | Discount | GST | Net | Status | Actions
- "Dispute" button → opens `DisputeDialog` with amount + reason
- "Mark Paid" button (Finance Admin) → updates settlement status + audit log

**Tab: Rider Payouts**
- Per-rider payout summary: Rider | Zone | Base Pay | Incentives | Tips | COD Collected | Net Payout | Status
- COD mismatch rows (mock 2): highlighted amber with "Flag for Review" action

**Tab: Refunds & Disputes**
- Open refund queue: Order ID | Customer | Amount | Reason | Days Open | Funding (Platform/Restaurant) | Actions
- "Approve" → `ConfirmationDialog` → updates transaction + deducts from restaurant settlement if restaurant-funded
- "Reject" → reason required
- Resolved refunds table below

---

#### Task 5.2 — Trust & Safety Screen

**File:** `lib/features/trust_safety/trust_screen.dart`

Layout: Left sidebar with case categories + main content panel.

**Sidebar categories:**
- All Cases (count badge)
- GPS Spoofing (count)
- Promo Fraud (count)
- Refund Abuse (count)
- Rider Policy Violation (count)
- Merchant Malpractice (count)

**Main content: Case Queue**

Each case card contains:
- Case ID, type badge, severity chip
- Entity: linked name (rider/customer/restaurant)
- Brief description
- Date flagged
- Status: Open / Under Review / Resolved
- Evidence available indicator

Tapping a case opens `CaseDetailDrawer` (480px right panel):
- Case header
- Entity profile summary
- Evidence section: list of evidence items (mock: GPS trace description, complaint count, order timeline)
- Timeline of events
- Action buttons (Trust Admin only):
  - "Issue Warning" → reason code required
  - "Short Suspension (1–7 days)" → duration + reason
  - "Long Suspension (8–30 days)" → duration + reason
  - "Permanent Ban" → requires confirmation dialog emphasising "This requires senior approval" + reason + legal note
  - "Clear Case (Vindicate)" → reason
- Each action → updates entity state + creates `AuditLog` + updates case status

Pre-populate with: 2 GPS spoofing cases (riders), 2 promo fraud (customers), 1 merchant malpractice, 2 refund abuse (customers).

---

#### Task 5.3 — Customer Intelligence Screen

**File:** `lib/features/customer_intel/customer_screen.dart`

Tabs: Overview | Cohort Analysis | Behaviour | Risk

**Tab: Overview**
- KPI row: Total Customers | Monthly Transacting | Avg Order Frequency | Avg LTV
- Customer search + list: Name | Phone (masked) | Orders | LTV | Churn Risk | Subscription | Last Order
- Tap → `CustomerDetailScreen`

**File:** `lib/features/customer_intel/customer_detail_screen.dart`

Sections:
- Profile header: name, email, phone, subscription badge
- Order history table (last 10 orders from mock)
- Refund history table
- Device/account risk flags (promo abuse, churn risk score badge)
- "Flag Account" / "Restrict Account" actions (Trust Admin only)

**Tab: Cohort Analysis**

`CohortRetentionChart`: 6-row × 6-column grid. Rows = acquisition month (last 6 months). Columns = Month 0 through Month 5 retention %. Color cells by retention rate intensity (use `ColorTween`). Mock data: typical SaaS-style declining retention (100% → 60% → 45% → 35% → 30% → 28%).

**Tab: Behaviour**

- `PromoDependencyChart`: stacked bar — orders with promo vs without, per week for last 4 weeks
- Conversion funnel: horizontal funnel chart (use `BarChart` horizontal): App Open → Search → View Menu → Add to Cart → Checkout → Delivered. Mock values: 1000 → 750 → 500 → 350 → 280 → 240.

**Tab: Risk**

- Churn risk table: customers where `churnRiskScore > 0.7`, sorted descending. Show score as a progress bar (red).
- Promo abuse table: customers where `isPromoAbuser == true`. "Restrict Promo Access" action.
- High refund rate table: customers where `refundRate > 0.3`.

---

#### Day 5 Acceptance Criteria
- [ ] Finance donut chart shows correct channel distribution
- [ ] Failed transactions table highlighted; "Retry" updates status
- [ ] Settlement "Dispute" creates audit log
- [ ] Trust safety case drawer opens with all evidence + action buttons
- [ ] Permanent Ban shows special confirmation dialog
- [ ] Customer cohort retention grid renders with color intensity
- [ ] Churn risk table shows 3 customers with progress bars

---

### DAY 6 — Geo-Operations, Support, Identity, Promotions, Reporting (Modules 1, 8, 13, 14, 15)

**Goal:** Google Maps integration live, support console operational, remaining modules complete.

---

#### Task 6.1 — Geo-Operations Screen

**File:** `lib/features/geo_ops/geo_ops_screen.dart`

Layout: Full-height `Stack` — map fills screen, overlay panels.

**Map Setup:**
- `GoogleMap` widget fills entire screen
- Initial camera: center on mock city (use Bengaluru: lat 12.9716, lng 77.5946, zoom 12)
- Enable: `myLocationEnabled: false`, `zoomControlsEnabled: true`, `mapToolbarEnabled: false`

**Markers:**

| Entity | Marker Color | Data |
|---|---|---|
| Active Riders (Available) | Green dot | All riders where status == available |
| Active Riders (Delivering) | Blue dot | All riders where status == delivering |
| Restaurants (Online) | Orange store icon | All active restaurants |
| Restaurants (Offline/Issues) | Red store icon | suspended / pendingOnboarding |
| Active Orders (Delivering) | Purple package icon | Orders in onTheWay status |
| Dark Stores (mock 2) | Dark grey icon | Hard-coded positions |

Use custom `BitmapDescriptor` with `defaultMarkerWithHue` for color differentiation.

**Zone Polygons:**
- Draw 6 zone polygons (approximate polygons for Bengaluru zones: Koramangala, Whitefield, Indiranagar, HSR Layout, Electronic City, Jayanagar)
- Zone fill color: green if D/S ratio 0.8–1.2 (balanced), amber if 1.2–1.5 (mild shortage), red if >1.5 (critical shortage), blue if <0.5 (oversupply)
- Zone fill opacity: 0.2

**Layer Toggle Bar (top-right overlay):**
- `LayerToggleBar` widget: row of toggle chips
- Layers: "Riders" | "Restaurants" | "Orders" | "Zones" | "Demand Heat" | "Supply Heat"
- Each toggles visibility of respective markers/polygons

**Demand/Supply Heatmap (simplified):**
- When "Demand Heat" toggled: add `Circle` widgets centered at each zone centroid, radius proportional to `activeOrders` count, fill color red with opacity 0.2–0.5
- When "Supply Heat" toggled: same but for `availableRiders` count, fill color green

**Zone Health Panel (left overlay, 300px card):**
- Scrollable list of 6 zones
- Each: Zone name | Active Orders | Available Riders | D/S Ratio badge | Surge status toggle
- Selecting a zone moves camera to that zone

**Info Window on Marker Tap:**
- Rider tap: name, status, zone, current assignment
- Restaurant tap: name, rating, online status, active orders
- Order tap: ID, customer name, ETA

---

#### Task 6.2 — Support Screen

**File:** `lib/features/support/support_screen.dart`

Layout: `TwoPaneLayout` — ticket list left, detail right.

**Ticket List:**
- Filter bar: Type (All/Customer/Merchant/Rider) | Priority | Status | Search
- Exception-first sort: Critical open tickets first
- Each row: Ticket ID | Type badge | Priority chip | Category | Entity Name | Created | SLA Clock | Assigned

SLA Clock: if ticket open > 24h, show time in red.

**Ticket Detail Panel:**

- Ticket header: ID, type, priority, status
- Linked order: Order ID → navigates to order in live-ops
- Issue description
- Order timeline summary (last 3 events)
- Compensation recommendation card: "Suggested: ₹50 — based on issue type (missing item) + customer tier (regular)"
- Resolution actions:
  - "Approve Compensation" → amount field (pre-filled with suggestion) + funding source dropdown
  - "Reassign Ticket" → admin picker
  - "Escalate" → priority up-level
  - "Resolve" → resolution notes required
- All actions → update ticket + audit log

**Root Cause Dashboard (bottom panel):**
- Horizontal bar chart: top 5 issue categories by ticket count
- "Recurring Issues" — flag if same category from same restaurant > 3 times in 30 days (mock: 1 such case)

---

#### Task 6.3 — Identity Screen (Module 1)

**File:** `lib/features/identity/identity_screen.dart`

Tabs: Admin Users | Roles & Permissions | Audit Log

**Tab: Admin Users**
- Table: Name | Email | Role | Scope | Status | Last Login | Actions
- "Invite User" button → opens `AdminUserForm` dialog (name, email, role, scope)
- "Deactivate" action on each row → confirmation dialog

**Tab: Roles & Permissions**
- `RbacMatrixTable`: scrollable table
  - Columns: Module names (15 modules)
  - Rows: 8 roles
  - Cell: "R" (read), "W" (write), "A" (approve), "—" (no access)
  - Color: write cells light blue, approve cells light green, no-access cells grey
- Hard-coded matrix matching SRS Section 2

**Tab: Audit Log**
- Full `AuditTrailTable`: all 40 audit entries
- Columns: Timestamp | Actor | Role | Action | Entity Type | Entity ID | Reason
- Filter: actor, entity type, action, date range
- Each action name uses monospace chip (e.g., `SUSPEND_RIDER`)
- "Before/After" popover on row tap

---

#### Task 6.4 — Promotions Screen (Module 14)

**File:** `lib/features/promotions/promotions_screen.dart`

Tabs: Campaigns | Subscriptions | Merchant Ads

**Tab: Campaigns**
- KPI row: Active Campaigns | Total Redemptions | Total Subsidy Cost | Avg Campaign ROI
- Campaign cards grid (2 columns):
  - Each card: name, type badge, status chip, redemption progress bar (redeemed/max), subsidy spent, start–end dates
  - "Pause" / "End" actions (active campaigns)
- "Create Campaign" → dialog form: name, type, discount value, validity dates, max redemptions, scope
- `CampaignRoiChart`: grouped bar chart — 8 campaigns, two bars each: subsidy cost (red) vs incremental GMV (green)

**Tab: Subscriptions**
- Summary KPIs: Active Subscribers | Renewal Rate | Avg Revenue per Subscriber
- Subscription plan card: showing configured benefits (free delivery threshold, discount %, verticals covered)
- "Edit Plan" → form dialog

**Tab: Merchant Ads**
- Table: Campaign | Restaurant | Budget | Spent | Impressions | Clicks | Conversions | ROAS
- Simple read-only for MVP

---

#### Task 6.5 — Reporting Screen (Module 15)

**File:** `lib/features/reporting/reporting_screen.dart`

Tabs: Dashboards | Saved Reports | Audit Trail | Metric Dictionary

**Tab: Dashboards**
- Period selector: Today / Last 7 days / Last 30 days / Custom range
- KPI comparison table: each executive KPI with current period value, previous period value, delta %, trend arrow
- "Export to CSV" button → shows `SnackBar("Export initiated — file will download shortly")` (UI mock)

**Tab: Saved Reports**
- Table of 5 mock scheduled reports: Name | Frequency | Last Generated | Format | Actions
- "Download" action → same mock SnackBar
- "Create Report" → form dialog

**Tab: Audit Trail**
- Same as identity/audit-log tab but globally accessible and filterable
- Full 40 entry dataset with full filter set

**Tab: Metric Dictionary**
- Searchable list of all KPIs with: name, formula, data source, update frequency, owner role
- Cover all KPIs from SRS Section 8 (8.1–8.5)

---

#### Day 6 Acceptance Criteria
- [ ] Google Maps loads with all markers (riders green/blue, restaurants orange/red)
- [ ] Zone polygons colored by D/S ratio
- [ ] Layer toggles show/hide correct marker groups
- [ ] Zone tap moves camera to zone centroid
- [ ] Support ticket detail shows compensation suggestion
- [ ] Resolve action updates ticket status
- [ ] RBAC matrix table renders all 8 roles × 15 modules
- [ ] Audit trail table shows all 40 entries with monospace action chips
- [ ] Campaign ROI chart renders correctly
- [ ] Reporting period selector changes all KPI values

---

### DAY 7 — Polish, Responsive Layout, Alert Engine, Cross-Linking, QA

**Goal:** Production-ready finish — responsive layout, working alert engine, cross-screen navigation, dark mode, and all edge cases handled.

---

#### Task 7.1 — Responsive Layout

All screens must adapt to three breakpoints:

| Breakpoint | Width | Layout Change |
|---|---|---|
| Compact | < 900px | Nav rail hidden (hamburger menu), single-column layouts |
| Medium | 900–1280px | Nav rail collapsed (icons only), two-column where applicable |
| Large | > 1280px | Nav rail extended (icons + labels), all multi-column layouts |

**Implementation:**
- Use `LayoutBuilder` in `ShellScaffold` to switch between `NavigationDrawer` (compact), collapsed `NavigationRail` (medium), and extended `NavigationRail` (large)
- `DashboardLayout` uses `Wrap` for KPI cards with `runSpacing` and `spacing`
- `TwoPaneLayout` collapses to single pane on medium; detail becomes bottom sheet on compact
- `AppDataTable` wraps in `SingleChildScrollView(scrollDirection: Axis.horizontal)` on all sizes
- All modals and dialogs max-width 600px; centered on large, full-width on compact

---

#### Task 7.2 — Alert Engine UI

**File:** `lib/providers/alert_provider.dart`

`AlertNotifier` holds `List<AlertRule>`. Pre-fire these alerts in mock seed:
1. "Rider shortage in Koramangala" — Critical — Dispatch
2. "Restaurant below rating threshold: Spice Garden" — Warning — Merchant
3. "Payment gateway failure spike: UPI" — Critical — Finance
4. "SLA breach rate exceeds threshold: Whitefield" — Critical — Ops
5. "Promo abuse pattern detected" — Warning — Trust

**Alert Bell (top bar):**
- Badge shows count of fired alerts
- Tapping opens `AlertPanel` — right-side slide-over panel (320px)
- Each alert: severity icon + name + time + "Go to" link (navigates to relevant screen)
- "Dismiss" per alert + "Dismiss All"

**Configurable Alert Rules Screen:**

Add section to `ReportingScreen` or as drawer within Executive screen:
- Table of all alert rules from `AppConstants.defaultAlertRules`
- Toggle enabled/disabled per rule
- Edit threshold value inline (double-tap cell → text field → save)
- All edits logged to audit trail

---

#### Task 7.3 — Cross-Screen Drill-Down Links

Implement these navigation shortcuts:
1. Executive KPI card "Delayed Orders" tap → `/live-ops?filter=delayed`
2. Executive incident feed tap → navigate to relevant module screen
3. Dispatch fairness chart bar tap → `/riders/:id` for that rider
4. Merchant list row tap → `/merchants/:id`
5. Rider list row tap → `/riders/:id`
6. Trust safety case "entity name" link → `/riders/:id` or `/customers/:id`
7. Finance failed transaction → order detail drawer
8. Support ticket "order ID" link → live-ops order detail

Implementation: use `go_router`'s `context.go('/route')` and `context.push('/route')` from tap callbacks. Pass query parameters using `?param=value` syntax.

---

#### Task 7.4 — Dark Mode Polish

Ensure all custom colors reference `Theme.of(context).colorScheme.*` tokens (not hardcoded hex). Verify:
- All `AppDataTable` header rows use `colorScheme.surfaceVariant`
- All cards use `colorScheme.surface` with `colorScheme.outlineVariant` border
- Status chips: use `colorScheme.errorContainer` / `tertiaryContainer` / `secondaryContainer` instead of raw reds/greens
- Charts: use `kChartPalette` but verify contrast in dark mode (adjust opacity if needed)
- Map overlay panels: use `Theme.of(context).cardColor` with 0.9 opacity for frosted look

---

#### Task 7.5 — Empty States & Error States

Every list/table must handle empty state:

**`EmptyState` widget:**
- Icon (outlined, 64px)
- Title: e.g., "No delayed orders"
- Subtitle: e.g., "All orders are running on time"

Apply to:
- Delayed watchlist when no delayed orders
- Trust safety queue when no open cases
- Support queue when all resolved
- Moderation queue when no flagged reviews

---

#### Task 7.6 — Loading Shimmer

**`LoadingShimmer` widget:**
- Animated shimmer using `AnimationController` + `ColorTween` (light grey → slightly lighter grey)
- `ShimmerCard`: rectangular block sized to match `KpiCard`
- `ShimmerRow`: full-width block 48px tall (for table rows)

Use in:
- Executive screen: show 8 `ShimmerCard`s for 500ms on first load
- All tables: show 5 `ShimmerRow`s while provider data loads

Simulate delay: `Future.delayed(Duration(milliseconds: 600))` in providers before returning data.

---

#### Task 7.7 — Final QA Checklist

Run through all items:

**Navigation:**
- [ ] Every route accessible from nav rail
- [ ] Back navigation works on detail screens
- [ ] Deep link URLs work directly in browser

**Data Integrity:**
- [ ] All mock totals add up (GMV = sum of delivered orders, etc.)
- [ ] No null pointer exceptions in any screen
- [ ] Derived providers return correct filtered lists

**RBAC:**
- [ ] Login as "Analyst" → write actions hidden on all screens
- [ ] Login as "Finance Admin" → only finance-relevant nav shown
- [ ] Login as "Support Admin" → trust/dispatch screens not in nav
- [ ] Login as "Super Admin" → all screens visible, all actions enabled

**Charts:**
- [ ] All fl_chart instances handle zero-data gracefully (no divide-by-zero)
- [ ] Tooltips show on touch/hover with correct formatted values
- [ ] Legend present on multi-series charts

**Maps:**
- [ ] Map loads without white screen (API key in index.html)
- [ ] All 25 rider markers render correctly
- [ ] All 20 restaurant markers render
- [ ] Zone polygons all colored correctly
- [ ] Info window appears on marker tap

**Dialogs & Actions:**
- [ ] All mutation dialogs have mandatory fields validated (cannot submit empty)
- [ ] Every action creates an audit log entry
- [ ] Audit trail table reflects all performed actions

**Responsive:**
- [ ] Compact layout (900px) — nav accessible via drawer
- [ ] Medium layout — rail collapsed
- [ ] All tables scrollable horizontally

---

## Shared Widget Specifications (Reference)

### `AppDataTable<T>`
```dart
class AppDataTable<T> extends StatefulWidget {
  final List<DataColumn> columns;
  final List<T> rows;
  final DataRow Function(T item) rowBuilder;
  final Function(T item)? onRowTap;
  final bool showRowCount;           // default: true
  final int? fixedRowHeight;         // default: 52

  // Internal state: sortColumnIndex, sortAscending
  // Wraps: SingleChildScrollView > DataTable
  // Empty state: shows EmptyState widget centered
}
```

### `TwoPaneLayout`
```dart
class TwoPaneLayout extends StatelessWidget {
  final Widget listPane;             // takes 40% width on large
  final Widget? detailPane;          // takes 60% width on large
  final double splitRatio;           // default: 0.4

  // On large: Row([listPane, VerticalDivider, detailPane])
  // On medium/compact: listPane only, detail in Navigator.push
}
```

### `DashboardLayout`
```dart
class DashboardLayout extends StatelessWidget {
  final String title;
  final List<Widget>? filterBar;
  final List<Widget> children;       // Stacked vertically with 24px gaps
  final EdgeInsets padding;          // default: EdgeInsets.all(24)
}
```

---

## Riverpod Provider Patterns

All providers follow one of two patterns:

**Pattern A: Mutable List (StateNotifier)**
```dart
// Used for: orders, riders, restaurants, customers, tickets, campaigns
class XNotifier extends StateNotifier<List<X>> {
  XNotifier() : super(XRepository.getAll());
  
  void updateItem(String id, X updated) {
    state = state.map((item) => item.id == id ? updated : item).toList();
  }
}
final xProvider = StateNotifierProvider<XNotifier, List<X>>((ref) => XNotifier());
```

**Pattern B: Derived/Computed (Provider)**
```dart
// Used for: filtered lists, KPI computations, derived stats
final filteredXProvider = Provider<List<X>>((ref) {
  final all = ref.watch(xProvider);
  return all.where((x) => x.someCondition).toList();
});
```

**Pattern C: Current Selection (StateProvider)**
```dart
// Used for: selected order, selected rider, selected zone filter
final selectedOrderIdProvider = StateProvider<String?>((ref) => null);
```

---

## Google Maps Configuration

**`web/index.html`** — add before closing `</head>`:
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_KEY&libraries=visualization"></script>
```

**`lib/features/geo_ops/widgets/live_map_widget.dart`**

```dart
class LiveMapWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riders = ref.watch(riderListProvider);
    final restaurants = ref.watch(restaurantListProvider);
    final orders = ref.watch(activeOrdersProvider);
    final zones = ref.watch(zoneProvider);
    final layers = ref.watch(layerToggleProvider); // Map<String, bool>

    Set<Marker> markers = {};
    Set<Polygon> polygons = {};
    Set<Circle> circles = {};

    if (layers['riders'] == true) {
      // Add rider markers
    }
    if (layers['restaurants'] == true) {
      // Add restaurant markers
    }
    if (layers['zones'] == true) {
      // Add zone polygons
    }
    // etc.

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(12.9716, 77.5946), // Bengaluru
        zoom: 12,
      ),
      markers: markers,
      polygons: polygons,
      circles: circles,
      onMapCreated: (controller) {
        ref.read(geoProvider.notifier).setController(controller);
      },
    );
  }
}
```

Zone polygon coordinates (approximate bounding boxes in Bengaluru — use real coords):
- Koramangala: centered 12.9352, 77.6245
- Whitefield: centered 12.9698, 77.7500
- Indiranagar: centered 12.9784, 77.6408
- HSR Layout: centered 12.9116, 77.6389
- Electronic City: centered 12.8399, 77.6770
- Jayanagar: centered 12.9308, 77.5826

Each zone: use a simple 4-point rectangular polygon (~2km x 2km box around centroid).

---

## fl_chart Usage Patterns

### LineChart (GMV trend)
```dart
LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: kpiSnapshots.asMap().entries.map((e) =>
          FlSpot(e.key.toDouble(), e.value.gmv)).toList(),
        isCurved: true,
        color: kChartPalette[0],
        barWidth: 2,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: kChartPalette[0].withOpacity(0.1),
        ),
      ),
    ],
    titlesData: FlTitlesData(/* date labels on X */),
    gridData: FlGridData(show: true, drawVerticalLine: false),
    borderData: FlBorderData(show: false),
    lineTouchData: LineTouchData(
      touchTooltip: LineTouchTooltipData(/* formatted value */),
    ),
  ),
)
```

### PieChart (payment channels)
```dart
PieChart(
  PieChartData(
    sections: PaymentChannel.values.map((channel) =>
      PieChartSectionData(
        value: transactionsByChannel[channel]?.toDouble() ?? 0,
        color: kChartPalette[channel.index],
        title: channel.name,
        radius: 80,
        titleStyle: TextStyle(fontSize: 11, color: Colors.white),
      )).toList(),
    sectionsSpace: 2,
    centerSpaceRadius: 40,
  ),
)
```

### BarChart (per-rider fairness)
```dart
BarChart(
  BarChartData(
    barGroups: riders.asMap().entries.map((e) =>
      BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.deliveriesThisMonth.toDouble(),
            color: e.value.deliveriesThisMonth > zoneAverage * 1.3
                ? kDanger : kSuccess,
            width: 16,
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      )).toList(),
    // average line via extraLinesData
    extraLinesData: ExtraLinesData(
      horizontalLines: [
        HorizontalLine(y: zoneAverage, color: kWarning, strokeWidth: 1.5,
          dashArray: [5, 5]),
      ],
    ),
  ),
)
```

---

## Data Formatting Utilities

**`lib/core/utils/formatters.dart`**

```dart
class Formatters {
  // Currency: ₹1,23,456.78
  static String currency(double amount) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);

  // Compact: ₹1.2L, ₹45K
  static String currencyCompact(double amount) {
    if (amount >= 100000) return '₹${(amount/100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount/1000).toStringAsFixed(1)}K';
    return currency(amount);
  }

  // Percent: 94.3%
  static String percent(double value) =>
      '${(value * 100).toStringAsFixed(1)}%';

  // Relative time: "2h ago", "just now"
  static String relativeTime(DateTime dt) { /* ... */ }

  // Date: "12 Jun 2026"
  static String date(DateTime dt) =>
      DateFormat('dd MMM yyyy').format(dt);

  // Time: "14:32"
  static String time(DateTime dt) =>
      DateFormat('HH:mm').format(dt);
}
```

---

## Constants

**`lib/core/constants/app_constants.dart`**

```dart
class AppConstants {
  // SLA thresholds
  static const double restaurantRatingThreshold = 3.5;
  static const int slaBreachMinutes = 10;        // minutes beyond promised ETA
  static const double riderWarningThreshold = 2; // warnings in 30 days → review
  static const double fairnessDeviationThreshold = 0.3; // 30% above zone avg
  static const double demandSupplyShortageRatio = 1.5;
  static const double demandSupplyOversupplyRatio = 0.5;
  static const double churnRiskThreshold = 0.7;
  static const double refundAbuseThreshold = 0.3;
  static const double promoAbuseThreshold = 0.6; // promo dependency
  static const int settlementCycleDays = 7;

  // Mock city center
  static const double cityLat = 12.9716;
  static const double cityLng = 77.5946;

  // Zone IDs
  static const List<String> zoneIds = [
    'koramangala', 'whitefield', 'indiranagar',
    'hsr_layout', 'electronic_city', 'jayanagar'
  ];
}
```

---

## File Creation Order (AI Execution Sequence)

To avoid import errors when executing this plan, create files in this order:

```
1.  pubspec.yaml
2.  web/index.html
3.  lib/core/constants/app_constants.dart
4.  lib/core/theme/app_colors.dart
5.  lib/core/theme/app_theme.dart
6.  lib/core/utils/formatters.dart
7.  lib/core/utils/extensions.dart
8.  lib/data/models/ (all 14 model files)
9.  lib/data/mock/ (all 9 mock files, seed last)
10. lib/data/repositories/ (all 8 repository files)
11. lib/shared/widgets/ (all 8 shared widgets)
12. lib/shared/layouts/ (2 layout files)
13. lib/providers/ (all 12 provider files)
14. lib/core/router/app_router.dart
15. lib/features/auth/login_screen.dart
16. lib/features/shell/ (scaffold + nav rail)
17. lib/features/executive/ (screen + widgets)
18. lib/features/live_ops/ (screen + widgets)
19. lib/features/dispatch/ (screen + widgets)
20. lib/features/merchant/ (screens + widgets)
21. lib/features/rider/ (screens + widgets)
22. lib/features/finance/ (screen + widgets)
23. lib/features/trust_safety/ (screen + widgets)
24. lib/features/customer_intel/ (screens + widgets)
25. lib/features/geo_ops/ (screen + widgets)
26. lib/features/support/ (screen + widgets)
27. lib/features/identity/ (screen + widgets)
28. lib/features/ratings/ (screen + widgets)
29. lib/features/promotions/ (screen + widgets)
30. lib/features/reporting/ (screen + widgets)
31. lib/app.dart
32. lib/main.dart
```

---

## Known Limitations (MVP Scope)

| Limitation | Reason | Future Fix |
|---|---|---|
| No real-time order status updates | Mock data is static | Add Streams + timer-based state mutation |
| Maps markers use static positions | No live GPS feed | Connect to WebSocket location stream |
| Export is UI mock only | No file generation implemented | Add `csv` package + file download via `dart:html` |
| No actual API authentication | Mock role selection | Connect to OAuth/SSO backend |
| Charts on small screens may overflow | MVP breakpoint handling | Add dedicated mobile chart view |
| No pagination on large tables | Small mock dataset fits in memory | Add server-side pagination when backend ready |
| Alert engine is not timer-driven | No auto-firing on threshold breach | Add periodic threshold checks via `Timer.periodic` |

---

## Summary Table

| Day | Modules Covered | Key Deliverables |
|---|---|---|
| 1 | Foundation | Project setup, theme, routing, login, shell nav |
| 2 | Module 15 (partial), KPI Framework | Mock data layer, Executive command centre, charts |
| 3 | Modules 6, 7 | Live ops screen, dispatch fairness, order interventions |
| 4 | Modules 3, 4, 5, 10 | Merchant cockpit, rider 360, ratings intelligence |
| 5 | Modules 9, 12, 2, 11 | Finance centre, trust & safety workbench, customer analytics |
| 6 | Modules 1, 8, 13, 14, 15 | Google Maps live ops, support console, promotions, reporting |
| 7 | All modules (cross-cutting) | Responsive polish, alert engine, drill-down links, QA |

**Total Modules Covered:** All 15 from SRS Section 7
**Total Screen Clusters:** All 10 from SRS Section 9
**Total KPIs Surfaced:** 35+ from SRS Section 8
**Total Mock Records:** ~275 across all entities
