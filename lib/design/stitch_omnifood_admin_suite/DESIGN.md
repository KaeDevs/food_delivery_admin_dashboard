---
name: Lumina Admin
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#3c4a42'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#6c7a71'
  outline-variant: '#bbcabf'
  surface-tint: '#006c49'
  primary: '#006c49'
  on-primary: '#ffffff'
  primary-container: '#10b981'
  on-primary-container: '#00422b'
  inverse-primary: '#4edea3'
  secondary: '#b90538'
  on-secondary: '#ffffff'
  secondary-container: '#dc2c4f'
  on-secondary-container: '#fffbff'
  tertiary: '#a43a3a'
  on-tertiary: '#ffffff'
  tertiary-container: '#fc7c78'
  on-tertiary-container: '#711419'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#6ffbbe'
  primary-fixed-dim: '#4edea3'
  on-primary-fixed: '#002113'
  on-primary-fixed-variant: '#005236'
  secondary-fixed: '#ffdadb'
  secondary-fixed-dim: '#ffb2b7'
  on-secondary-fixed: '#40000d'
  on-secondary-fixed-variant: '#92002a'
  tertiary-fixed: '#ffdad7'
  tertiary-fixed-dim: '#ffb3af'
  on-tertiary-fixed: '#410005'
  on-tertiary-fixed-variant: '#842225'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  display:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
  data-mono:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: -0.01em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 16px
  md: 24px
  lg: 32px
  xl: 48px
  container-max: 1440px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 32px
---

## Brand & Style

The design system is engineered for high-density enterprise data management within the food logistics sector. The brand personality is **precise, transparent, and authoritative**, moving away from the chaotic energy of consumer-facing apps toward a calm, "control center" atmosphere.

The aesthetic blends **Modern Minimalism** with functional **Glassmorphism**. By using semi-transparent layers for navigational elements and overlays, the system maintains a sense of depth and spatial awareness without sacrificing the clarity required for complex dashboards. The "Wireframe-Plus" philosophy ensures that structural integrity and information hierarchy always take precedence over decorative elements, using subtle translucency to signify temporary or elevated states.

## Colors

The palette is rooted in a professional "Slate" scale to ensure a sophisticated wireframe-inspired foundation.

- **Primary (Success Green):** Used for growth metrics, positive status indicators, and primary "Accept Order" actions.
- **Secondary (Brand Red):** Used sparingly for urgent alerts, cancellations, and critical health metrics.
- **Neutrals:** A range of Slates from 50 (backgrounds) to 900 (headings). Slate-500 is the designated color for secondary metadata and icons.
- **Functional Surfaces:** 
  - **Light Mode:** White surfaces on a Slate-50 canvas.
  - **Dark Mode:** Deep Slate-950 surfaces with Slate-900 canvas.
- **Glassmorphic Accents:** Semi-transparent white (or slate in dark mode) with a 12px backdrop blur, used primarily for sidebars and top navigation.

## Typography

This design system utilizes **Inter** exclusively for its exceptional legibility in data-heavy environments. 

- **Hierarchy:** Use `headline-lg` for dashboard titles and `headline-sm` for card titles.
- **Tabular Data:** Use `data-mono` (Inter with tabular lining figures enabled) for order IDs, price points, and timestamps to ensure vertical alignment.
- **Labels:** Allcaps `label-md` should be used for chart axis titles and table headers to provide clear distinction from row content.
- **Accessibility:** Maintain a minimum 4.5:1 contrast ratio for all body text against glassmorphic backgrounds.

## Layout & Spacing

The system uses a **Fluid-Fixed Hybrid Grid**. 
- **Desktop (1440px+):** 12-column grid with a fixed sidebar (280px). Content resides in a centered container with 32px margins.
- **Tablet (768px - 1439px):** 8-column grid. Sidebar collapses into a glassmorphic rail or hamburger menu.
- **Mobile (Up to 767px):** 4-column grid with 16px horizontal margins.

**Spacing Rhythm:** All dimensions follow a 4px baseline. KPI cards should use `md` (24px) internal padding, while dense data tables use `sm` (16px) vertical padding to maximize information density.

## Elevation & Depth

Visual hierarchy is achieved through **Tonal Layering** and **Backdrop Blurs**:

1.  **Level 0 (Canvas):** `Slate-50`. The lowest plane.
2.  **Level 1 (Cards):** White surface with a 1px `Slate-200` border and a soft ambient shadow (`Y: 2px, B: 4px, Color: rgba(0,0,0,0.04)`).
3.  **Level 2 (Glass Overlays):** Navigation bars and sticky headers. Background: `rgba(255, 255, 255, 0.7)` with a 12px blur. Includes a bottom `Slate-200` border.
4.  **Level 3 (Modals/Popovers):** White surface with a deep diffused shadow (`Y: 12px, B: 24px, Color: rgba(0,0,0,0.08)`).

Avoid heavy dropshadows; rely on borders to define structural boundaries in the wireframe style.

## Shapes

The design system employs a **Rounded** aesthetic to soften the professional tone. 

- **Standard Elements:** Buttons, input fields, and small UI components use `rounded` (8px).
- **Containers:** Large dashboard cards and KPI containers use `rounded-lg` (16px).
- **Status Badges:** Chips and tags use `rounded-xl` (24px) to create a distinct "pill" shape that contrasts with rectangular data rows.
- **Interactive States:** On hover, backgrounds for list items should use a `4px` rounded corner to indicate selection without overwhelming the row structure.

## Components

### KPI Cards
Display essential metrics (e.g., "Total Orders", "Revenue").
- **Structure:** `label-md` for title (top), `headline-lg` for value (center), and `body-sm` for trend percentage (bottom).
- **Visuals:** 16px corner radius, 1px Slate-200 border.

### Data Tables
The core of the admin dashboard.
- **Header:** `label-md` text, Slate-100 background, sticky position.
- **Rows:** 1px bottom border only (Slate-100). 56px minimum height. 
- **Interaction:** Row highlight on hover using `Slate-50`.

### Glassmorphic Navigation
- **Sidebar:** Fixed left, `rgba(255,255,255,0.8)` background, 12px blur.
- **Active State:** A vertical 4px bar on the left edge in `Primary Green` with a subtle `Slate-100` background fill.

### Buttons
- **Primary:** Solid `Slate-900` for high contrast or `Primary Green` for "Success" actions. 8px radius.
- **Secondary:** White background with `Slate-200` border.
- **Ghost:** Transparent background, `Slate-500` text, used for less frequent actions like "Export".

### Charts
- **Palette:** Use a sequence of Slates (900, 600, 400) with `Primary Green` used as the highlight series.
- **Gridlines:** `Slate-100`, 1px dashed.
- **Tooltips:** Glassmorphic (80% opacity) with `body-sm` text.