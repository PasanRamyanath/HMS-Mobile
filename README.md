# Ceylon Heritage HMS — Cross-Platform Mobile App (Flutter & Dart)

Unified Apple Human Interface Guidelines (HIG) mobile application for the **Sri Lankan Cloud SaaS Hotel Management System (HMS)**. Purpose-built for luxury resorts, heritage villas, and boutique rest houses across Sri Lanka (Colombo, Galle Fort, Kandy, Nuwara Eliya, Bentota, Sigiriya).

---

## 🌟 Overview & Key Features

Built with **Flutter & Dart**, this application brings the complete web suite (`HMS-Frontend`) into native mobile experiences for both **iOS** and **Android**.

### 1. Executive Command & Headcount Planner
- Live **ADR**, **RevPAR**, and **Occupancy %** calculation with Central Bank of Sri Lanka (CBSL) dual currency conversion (LKR & USD at indicative mid-rate `1 USD = LKR 298.50`).
- F&B Headcount Forecast: Breakfast, Lunch, and Dinner distribution categorized by meal plans (**RO, BB, HB, FB, AI**).
- Real-time today's arrivals and departures tracking.

### 2. Front Desk PMS & 14-Day Tape Chart
- Interactive **14-day timeline tape chart** showing room availability, status, and bookings.
- **Express Check-In** with Sri Lankan **National Identity Card (NIC)** validator (supporting both classic 9-digit + `V`/`X` and modern 12-digit formats) and International Passports.

### 3. Waiter POS & Smart Tables
- Multi-dining outlet management: Ocean Terrace, Main Dutch Hall, Sunset Pool Bar.
- Sri Lankan culinary catalog (Negombo Lagoon Crab Curry, Jaffna Mutton, Crispy Egg Hoppers, Yellowfin Tuna, Arrack Sour, Fresh Thambili).
- Course sequencing (**Appetizers, Mains, Desserts, Beverages**) & authentic spice level selectors (**Mild, Medium, Sri Lankan Spicy, Fiery Kochchi Chilli**).
- Instant **Fire KOT to Kitchen** action.

### 4. Kitchen & Bar Display Systems
- **Dark OLED KDS**: Battery-efficient, high-contrast `#000000` kitchen display with real-time ticket stages (`PENDING` ➔ `PREPARING` ➔ `READY` ➔ `SERVED`), elapsed timers, and prominent allergen alerts.
- **Sunset Bar BOT**: Dedicated ticket queue for cocktails, mocktails, and fresh juices.

### 5. Housekeeping Runner & Linen Turnover
- Room cleanliness management (`Clean`, `Dirty`, `Inspected`, `Maintenance`).
- Deep turnover checklist for towels, luxury toiletries, and Ceylon tea replenishment.

### 6. Billing, Split Folios & LankaQR Checkout
- Splitting folios between Master Bill (Room charges) and Extras Bill (F&B / Spa).
- **Sri Lankan Statutory 4-Stage Compounding Tax Calculation**:
  - `Base Subtotal`
  - `+ 10% Service Charge (Mandatory)`
  - `+ 1% Tourism Development Levy (TDL on Base + SC)`
  - `+ 2.5% Social Security Contribution Levy (SSCL)`
  - `+ 18% Value Added Tax (VAT on Base + SC + SSCL)`
  - Effective total ≈ **34.145%** to **34.343%**.
- **Dynamic LankaQR Generator**: EMVCo merchant-presented standard with CRC16-CCITT checksum, supporting COMBANK Q+, BOC SmartPay, Sampath WePay, and HNB SOLO.

### 7. Contactless Guest Dining & Direct Booking
- Zero-login in-room contactless QR menu for guests.
- Direct booking engine with live rate estimation and instant confirmation.

### 8. Sri Lanka ERP Modules
- **Banquets & Poruwa Weddings**: Auspicious times (*Nekath*), Dutch hall seating, and advance deposits.
- **Ayurveda Wellness Spa**: Tridosha profiling (*Vata, Pitta, Kapha*), herbal oil therapies, and therapist schedules.
- **FIFO Inventory & Recipe BOM**: Stock level tracking and low-stock reorder alerts.
- **SLTDA & IRD Statutory Tax Engine**: RAMIS CSV export generation.
- **Hospitality Payroll**: 10% Service Charge pool point distribution, 8% employee EPF, 12% employer EPF, and 3% ETF calculations.

### 9. Trilingual Localization & Ceylon Luxury Themes
- Instant trilingual switching between **English (UK/LK)**, **සිංහල (Sinhala)**, and **தமிழ் (Tamil)**.
- 8 Ceylon luxury palettes:
  - 🌿 Royal Emerald (`#0F5132`)
  - 🌊 Sapphire Coast (`#0D3B66`)
  - 🍂 Ceylon Cinnamon (`#7B3F00`)
  - 🍃 Nuwara Eliya Tea (`#1E3A1E`)
  - 🏺 Sigiriya Ochre (`#A0522D`)
  - 🌸 Lotus Sunset (`#831843`)
  - 👑 Kandy Gold (`#854D0E`)
  - 🪸 Ocean Reef (`#115E59`)
  - Plus custom brand HEX color picker!

---

## 🏗 Architecture & Cloud Connectivity

- **AWS AppSync GraphQL**: Integrated client configured for AWS Mumbai (`ap-south-1`) with offline-first resilient fallback caching.
- **Apple HIG Liquid Glass UI**: Custom specular 1px border gradient, backdrop blur filters, and continuous squircle curvature.
- **Role-Based Access Control (RBAC)**: Support for Super Admin, General Manager, Front Desk Supervisor, F&B Waiter, Executive Chef, Housekeeping Runner, and In-House Guest with 4-digit PIN authentication (Demo PIN: `4821`).

---

## 🚀 Building & Testing Locally

```bash
# Get dependencies
flutter pub get

# Run static analysis (0 warnings / 0 errors)
flutter analyze

# Run unit and widget test suite
flutter test

# Run app on connected device / emulator
flutter run
```

---

## 🤖 GitHub Actions CI/CD Workflows

Automated build and test pipelines are configured in `.github/workflows/`:

1. **`ci.yml`**: Runs on every pull request and push to `main` — validates code formatting, executes `flutter analyze`, and runs the full test suite with coverage.
2. **`build-android.yml`**: Compiles release artifacts:
   - Release APK (`app-release.apk`)
   - Release Android App Bundle (`app-release.aab`)
3. **`build-ios.yml`**: Compiles and packages the unsigned iOS archive (`CeylonHMS-Unsigned.ipa`) on macOS runners.
