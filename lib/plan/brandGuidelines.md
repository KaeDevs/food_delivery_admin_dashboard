# Admin Dashboard Brand & UI Guidelines

Version 1.0

## Product Identity

Product Type:
Enterprise Admin Dashboard

Domain:
On-Demand Convenience & Food Delivery Platform

Primary Users:

* Super Admin
* Operations Admin
* Dispatch Admin
* Finance Admin
* Trust & Safety Admin
* Merchant Success Admin
* Support Admin
* Analyst

Design Goals:

* Fast operational decision making
* Exception-first workflows
* High information density
* Professional enterprise appearance
* Consistent data visualization
* Minimal visual noise

---

# Design Principles

## 1. Function Before Decoration

The dashboard exists to help admins make decisions.

Never add visual elements that do not improve:

* Monitoring
* Analysis
* Investigation
* Intervention

Avoid:

* Glassmorphism
* Heavy gradients
* Neumorphism
* Excessive shadows
* Decorative animations

---

## 2. Exception First

Users should notice problems before healthy entities.

Priority order:

1. Critical Alerts
2. SLA Breaches
3. Failed Payments
4. Suspended Entities
5. Warnings
6. Healthy Data

Tables and dashboards should sort important exceptions first.

---

## 3. Drill Down Everywhere

Every KPI should support navigation to root cause.

Example:

GMV
→ Orders

Restaurant Rating
→ Restaurant Profile

Rider Performance
→ Rider Detail

Zone Health
→ Zone Detail

Users should never be trapped on a summary screen.

---

## 4. Consistency Over Creativity

If a pattern already exists, reuse it.

Never create:

* Multiple table styles
* Multiple filter styles
* Multiple card styles
* Multiple drawer styles

One pattern should be reused everywhere.

---

# Color System

## Seed Color

Primary:
#3F4DC8

Purpose:
Brand identity and primary actions

---

## Semantic Colors

Success:
#1B8A5A

Warning:
#F5A623

Danger:
#D93025

Info:
#1A73E8

Neutral:
#6B7280

---

## Color Usage Rules

Green:

* Success
* Healthy metrics
* Delivered orders
* Active entities

Amber:

* Warning
* At-risk entities
* Delayed preparation

Red:

* Critical alerts
* Failures
* Suspensions
* SLA breaches

Blue:

* Informational status
* Links
* Primary actions

Never use colors outside semantic meaning.

---

# Typography

Font Family:
Inter

Fallback:
System Default

Hierarchy:

Page Title:
24px
Weight 700

Section Title:
20px
Weight 600

Card Value:
28px
Weight 700

Body:
14px
Weight 400

Caption:
12px
Weight 400

Avoid more than five font sizes.

---

# Layout System

Desktop First

Target Width:
1280px+

Grid:
8px spacing system

Allowed spacing:
8
16
24
32
40
48

Avoid arbitrary spacing values.

---

# Navigation

Navigation Rail:
Left side
Persistent

Width:
240px

Always Visible:
Desktop layouts

Structure:

Executive
Live Operations
Dispatch
Merchants
Riders
Finance
Trust & Safety
Customers
Geo Operations
Support
Identity
Ratings
Promotions
Reporting

Navigation order must remain consistent.

---

# Cards

All KPI cards must:

Display:

* Value
* Label
* Trend

Optional:

* Icon

Must support:

* Drill-down action

Card Style:

* Radius 12
* Elevation 0
* Outlined border

---

# Tables

Tables are the primary UI component.

Requirements:

* Sortable columns
* Sticky headers when practical
* Search support
* Filter support
* Hover state
* Empty state

Default row height:
56px

Prioritize readability over compactness.

---

# Forms

Rules:

* Labels always visible
* Required fields marked
* Validation messages below field
* Submit button fixed at bottom of form

Never rely on placeholder text as labels.

---

# Charts

Chart Library:
fl_chart

Allowed Chart Types:

* Line Chart
* Bar Chart
* Pie Chart
* Area Chart

Avoid:

* 3D charts
* Decorative charts
* Unnecessary animations

Every chart must answer a business question.

---

# Detail Drawers

Preferred over opening new screens.

Width:
480px

Used For:

* Order Detail
* Rider Detail
* Merchant Detail
* Ticket Detail

Keep context visible while investigating.

---

# Status Chips

Use consistent chip styling.

Examples:

Delivered
Preparing
Suspended
Pending
Approved
Rejected

Never invent new chip styles.

---

# Empty States

Every screen must have:

* Empty state
* Loading state
* Error state

No blank screens.

---

# Responsive Behaviour

Desktop:
Primary target

Tablet:
Supported

Mobile:
Not required

Do not optimize for mobile at the expense of desktop usability.

---

# Accessibility

Minimum contrast:
WCAG AA

Do not communicate information using color alone.

Icons and labels should accompany status colors.

---

# Auditability

All actions that change state must:

* Require confirmation
* Record actor
* Record timestamp
* Record reason

Examples:

Suspend Rider
Approve Refund
Reject Merchant
Cancel Order

Actions should never silently mutate data.

---

# Development Rules

Use:

* Flutter
* Riverpod
* Material 3

Avoid:

* Global state
* Business logic in widgets
* Duplicate components

Prefer:

* Reusable widgets
* Feature-first architecture
* Small focused screens

---

# Definition of Done

A screen is complete only if:

* Compiles without warnings
* Uses shared components
* Supports loading state
* Supports error state
* Supports empty state
* Responsive on desktop
* Connected to mock data
* Follows semantic color rules
* Matches typography rules
* Supports drill-down where applicable
