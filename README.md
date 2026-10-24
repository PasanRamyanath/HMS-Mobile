# Sri Lanka Cloud SaaS HMS — Mobile App (Web-Parity Redesigned Edition)

A complete ground-up UI/UX redesign of the **Sri Lanka Cloud SaaS Hospitality Management System (`hms_mobile`)** built with Flutter, engineered to match the **Web Version (`hms-frontend`)** in theme, color tokens, curated Ceylon luxury palettes, photography assets, and responsive mobile layouts with **zero screen overflow**.

## Key Highlights of the Redesign

### 1. Full Web Version Theme Parity (Light Default + Dark & System Switcher)
- **Web Version Default Light Theme**: Warm Alabaster canvas (`#F4F7F5`), crisp white surface cards (`#FFFFFF`), subtle inner surfaces (`#F8FAFC`), Slate borders (`#E2E8F0`), high-contrast Slate typography (`#0F172A`), and **Ceylon Botanical Emerald** (`#0B6E4F` / `#0D7450`) primary brand accent with soft mint tinting (`#ECFDF5` / `#A7F3D0`).
- **Comprehensive Dark Mode (`#0B1120`)**: Deep navy-slate canvas (`#0B1120`), Slate 900 cards (`#111827`), Slate 800 inner surfaces (`#1E293B`), and glowing semantic status badges.
- **1-Tap Light / Dark / System Switcher**: Toggle between Light Mode and Dark Mode directly from the **Login Screen**, the **Top Status Bar**, the **Navigation Drawer**, or **System Settings**.
- **8 Curated Ceylon Luxury Palettes** (1:1 parity with `hms-frontend/src/lib/themeColor.ts`):
  1. **Ceylon Emerald** (`#0B6E4F`) — Botanical rainforest & tea estate luxury
  2. **Ocean Sapphire** (`#0284C7`) — Galle Fort maritime & southern coastline
  3. **Sunset Coral** (`#E8772E`) — Bentota & Mirissa golden hour warmth
  4. **Royal Amethyst** (`#7C3AED`) — Highland boutique villas & luxury suites
  5. **Kandyan Gold** (`#D97706`) — Kingdom of Kandy heritage brass & amber
  6. **Obsidian Slate** (`#334155`) — Minimalist executive monochrome
  7. **Cinnamon Ruby** (`#BE123C`) — Ceylon spice island deep crimson
  8. **Palm Leaf** (`#15803D`) — Tropical palm grove fresh lime & jade

### 2. Web Version Photography & Brand Assets Integrated (`assets/images/` & `assets/icons/`)
- `assets/images/galle-fort-villa-hero.jpg` — Galle Fort Lighthouse Villa infinity pool hero banner
- `assets/images/boutique-courtyard-login.jpg` — Boutique courtyard showcase on Login & Superior rooms
- `assets/images/room-deluxe-ocean.jpg` — Deluxe Ocean View Room photography
- `assets/images/room-beachfront-pool-villa.jpg` — Grand Beachfront Pool Villa photography
- `assets/images/room-heritage-master-suite.jpg` — Colonial Suite & Banquets photography
- `assets/images/spa-ayurveda-pavilion.jpg` — Ayurveda & Tridosha Wellness Spa pavilion photography
- `assets/images/dish-jaffna-crab-hoppers.jpg` — Jaffna Lagoon Crab Curry & Crispy Egg Hoppers
- `assets/images/dish-cuttlefish-arrack.jpg` — Hot Butter Cuttlefish & Ceylon Arrack Cocktails
- `assets/images/rooms/*.webp` & `assets/icons/icon-*.png`

### 3. Zero-Overflow Responsive Mobile Engineering
- **Two-Tier `TopStatusBar`**: Separates brand identity, `Expanded` multi-tenant property switcher, Light/Dark toggle, Trilingual switcher (`EN · සිං · த`), and logout button from the horizontally scrollable telemetry strip (`CBSL 1:LKR`, `Cloud`, active role, occupancy, and `IRD 4-Stage Tax 1.34343×`).
- **Overflow-Safe Cards & Controls**: Every screen uses `Expanded`, `Flexible`, `Wrap`, `isExpanded: true` dropdowns, and `SingleChildScrollView` filter bars so buttons, long room/dish/excursion titles, and Sinhala/Tamil translations never clip or overflow mobile viewports.
