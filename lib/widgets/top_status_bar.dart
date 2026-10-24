import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/l10n/translations.dart';
import '../core/auth/auth_state.dart';
import '../core/currency/currency_engine.dart';
import '../core/tax/tax_engine.dart';
import '../core/tenant/tenant_engine.dart';
import '../core/api/appsync_client.dart';
import '../core/theme/app_theme.dart';
import 'metric_badge.dart';

/// Web-Parity Two-Tier Responsive Operations Bar (`BaseLandingPortal.tsx`, `AdminShell.tsx`, `CommandPalette.tsx`, `HelpDrawer.tsx`).
/// Includes:
/// - Row 1: Drawer button + Flexible Property Switcher + Spotlight Search (`⌘K`) + Help/NIC Decoder (`?`) + Light/Dark Toggle + Language + Logout
/// - Row 2: Scrollable Telemetry Strip (`CBSL 1:LKR`, `Cloud`, Active RBAC Role Badge, Occupancy, 4-Stage Tax)
class TopStatusBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLanguageChanged;
  final VoidCallback onRoleChanged;
  final VoidCallback? onOpenDrawer;
  final Function(String route)? onNavigateRoute;

  const TopStatusBar({
    super.key,
    required this.onLanguageChanged,
    required this.onRoleChanged,
    this.onOpenDrawer,
    this.onNavigateRoute,
  });

  @override
  Size get preferredSize => const Size.fromHeight(88.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = AuthState();
    final client = AppSyncClient();
    final tenant = TenantEngine();
    final metrics = client.getDashboardMetrics();

    return SafeArea(
      bottom: false,
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 40 : 6),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ROW 1: Drawer + Property Selector + Spotlight Search + Help + Theme + Language + Logout
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onOpenDrawer ?? () => _showPropertySwitchModal(context, onRoleChanged),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          onOpenDrawer != null ? CupertinoIcons.sidebar_left : Icons.eco_rounded,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),

                    // Multi-Tenant Property Switcher (Wrapped in Expanded so it NEVER overflows!)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showPropertySwitchModal(context, onRoleChanged),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkSubtleSurface : AppTheme.lightSubtleSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.building_2_fill,
                                size: 13,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      tenant.currentProperty.name.split(' - ').first,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                        height: 1.1,
                                      ),
                                    ),
                                    Text(
                                      '${tenant.currentProperty.city} • ${tenant.currentProperty.subscriptionPlan}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                CupertinoIcons.chevron_down,
                                size: 10,
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),

                    // Spotlight Command Palette (⌘K Search) Button (`CommandPalette.tsx`)
                    GestureDetector(
                      onTap: () => _showSpotlightCommandPalette(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSubtleSurface : AppTheme.lightSubtleSurface,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.search,
                              size: 13,
                              color: isDark ? Colors.white70 : AppTheme.lightTextSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '⌘K',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white70 : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),

                    // Help & Statutory NIC/Tax Diagnostics Drawer Button (`HelpDrawer.tsx`)
                    GestureDetector(
                      onTap: () => _showHelpDiagnosticsSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSubtleSurface : AppTheme.lightSubtleSurface,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.question_circle,
                          size: 14,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),

                    // 1-Tap Light / Dark Theme Mode Toggle Button
                    GestureDetector(
                      onTap: () {
                        AppTheme.toggleThemeMode();
                        onLanguageChanged();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFFDE68A),
                          ),
                        ),
                        child: Icon(
                          isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_stars_fill,
                          size: 14,
                          color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),

                    // Trilingual Language Switcher (EN · සිං · த)
                    GestureDetector(
                      onTap: () {
                        if (AppTranslations.currentLanguage == AppLanguage.en) {
                          AppTranslations.setLanguage(AppLanguage.si);
                        } else if (AppTranslations.currentLanguage == AppLanguage.si) {
                          AppTranslations.setLanguage(AppLanguage.ta);
                        } else {
                          AppTranslations.setLanguage(AppLanguage.en);
                        }
                        onLanguageChanged();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.brandSurfaceTint(context),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: AppTheme.brandBorderTint(context)),
                        ),
                        child: Text(
                          AppTranslations.languageLabel,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),

                    // Quick Sign Out / Lock Shift Button
                    GestureDetector(
                      onTap: () => auth.logout(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF3F1D28) : AppTheme.roseBgLight,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: isDark ? const Color(0xFF881337) : AppTheme.roseBorderLight,
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.square_arrow_right,
                          size: 14,
                          color: isDark ? const Color(0xFFFB7185) : AppTheme.roseError,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ROW 2: Horizontally Scrollable Telemetry & RBAC Role Strip (Zero Overflow!)
            Container(
              height: 36,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCanvas : AppTheme.lightCanvas,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppTheme.darkBorder : const Color(0xFFEEF2EF),
                    width: 1,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // 1. CBSL FX Ticker Pill (Preserves exact text 'CBSL 1:LKR ...' for tests)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0284C7).withAlpha(35) : AppTheme.skyBgLight,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: isDark ? const Color(0xFF0284C7).withAlpha(90) : AppTheme.skyBorderLight,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.money_dollar_circle, size: 12, color: Color(0xFF0284C7)),
                          const SizedBox(width: 4),
                          Text(
                            'CBSL 1:LKR ${CurrencyEngine.usdToLkrRate.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // 2. Cloud Sync Status Pill (Preserves exact text 'Cloud' / 'Offline')
                    GestureDetector(
                      onTap: () => client.toggleOnlineStatus(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: client.isOnline
                              ? (isDark ? const Color(0xFF10B981).withAlpha(35) : AppTheme.emeraldBgLight)
                              : (isDark ? const Color(0xFFF59E0B).withAlpha(35) : AppTheme.amberBgLight),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: client.isOnline
                                ? (isDark ? const Color(0xFF10B981).withAlpha(90) : AppTheme.emeraldBorderLight)
                                : (isDark ? const Color(0xFFF59E0B).withAlpha(90) : AppTheme.amberBorderLight),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: client.isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              client.isOnline ? 'Cloud' : 'Offline',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: client.isOnline
                                    ? (isDark ? const Color(0xFF34D399) : AppTheme.emeraldTextLight)
                                    : (isDark ? const Color(0xFFFBBF24) : AppTheme.amberTextLight),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // 3. Active RBAC Role Simulator Pill (`RoleSimulatorBar.tsx`)
                    GestureDetector(
                      onTap: onRoleChanged,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.brandSurfaceTint(context),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: AppTheme.brandBorderTint(context)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.shield_lefthalf_fill,
                              size: 11,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'RBAC: ${auth.currentRole.displayName}',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(
                              CupertinoIcons.chevron_down,
                              size: 10,
                              color: theme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // 4. Live Occupancy Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSubtleSurface : Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
                        ),
                      ),
                      child: Text(
                        'Occ ${metrics.occupancyRate}% (${metrics.occupiedRooms}/${metrics.totalRooms})',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Spotlight Command Palette (`CommandPalette.tsx` in `hms-frontend`)
  void _showSpotlightCommandPalette(BuildContext context) {
    final client = AppSyncClient();
    final auth = AuthState();
    final TextEditingController searchCtrl = TextEditingController();

    final List<Map<String, String>> allCommands = [
      ...client.rooms.map((r) => {
            'title': 'Room ${r.roomNumber} — ${r.categoryName}',
            'sub': 'Floor ${r.floor} • ${r.status.name.toUpperCase()} • ${r.isOccupied ? "Occupied (${r.currentGuestName})" : "Vacant"}',
            'badge': r.status.name.toUpperCase(),
            'route': '/tape_chart',
          }),
      ...client.reservations.map((res) => {
            'title': '${res.id} — ${res.guestName}',
            'sub': 'Room ${res.roomNumber} • ${res.mealPlan.name.toUpperCase()} • ${res.status}',
            'badge': res.status,
            'route': '/tape_chart',
          }),
      {'title': 'Executive Bento Dashboard', 'sub': 'RevPAR, ADR, Occupancy & Tax Liability', 'badge': 'MODULE', 'route': '/dashboard'},
      {'title': '14-Day Front Desk Tape Chart', 'sub': 'Room Rack, Arrivals, Driver Quarters & Police B-Card', 'badge': 'MODULE', 'route': '/tape_chart'},
      {'title': 'Express Check-In & Police B-Card', 'sub': 'NIC/Passport OCR & Digital Signature Reg Card', 'badge': 'MODULE', 'route': '/express_checkin'},
      {'title': 'Terrace Bar Waiter POS & All Orders', 'sub': 'Table Floor Map, Split Bill, Runner & Buffet Host', 'badge': 'MODULE', 'route': '/waiter_pos'},
      {'title': 'Kitchen KDS 3-Column Kanban', 'sub': 'Chef Order Queue, 86 Stock Drawer & Thermal KOT', 'badge': 'MODULE', 'route': '/dark_kds'},
      {'title': 'Sunset Bar BOT Queue', 'sub': 'Mixology Queue, Glassware & Bar Peg Audit', 'badge': 'MODULE', 'route': '/bar_bot'},
      {'title': 'Housekeeping, Laundry & Engineering', 'sub': 'Room Turnaround, Linen Par, Maintenance & Lost/Found', 'badge': 'MODULE', 'route': '/housekeeping'},
      {'title': 'Folios, City Ledger & LankaQR', 'sub': 'Split Folios, DMC AR, FX Encashment & IRD Tax Invoice', 'badge': 'MODULE', 'route': '/split_folios'},
      {'title': 'Guest Contactless QR Super-App', 'sub': 'In-Room Dining, Housekeeping, Laundry, Minibar & Spa', 'badge': 'MODULE', 'route': '/guest_dining'},
      {'title': 'Direct Booking Engine', 'sub': '0% Commission Booking, Add-Ons & Wedding Inquiry', 'badge': 'MODULE', 'route': '/direct_booking'},
      {'title': 'Banquets, Poruwa Nekath & BEO', 'sub': 'Wedding Packages, Live Plate Counter & Liquor Log', 'badge': 'MODULE', 'route': '/banquets'},
      {'title': 'Ayurveda Spa & Panchakarma', 'sub': 'Tridosha Assessment, Vaidya Schedule & Commissions', 'badge': 'MODULE', 'route': '/ayurveda'},
      {'title': 'FIFO Stores, Procurement & BOM', 'sub': 'PR/PO/GRN/GIN Vouchers, Bar Peg Audit & Suppliers', 'badge': 'MODULE', 'route': '/inventory'},
      {'title': 'SLTDA, Night Audit & IRD Tax Returns', 'sub': '5-Step Night Audit, Form MR-1, TDL & QuickBooks Export', 'badge': 'MODULE', 'route': '/sltda_taxes'},
      {'title': 'HR, Shift Roster, 10% SC & EPF/ETF', 'sub': 'SC Pool Points, Payroll Run, Form C & Gratuity Act', 'badge': 'MODULE', 'route': '/payroll'},
      {'title': 'Channex OTA Channel Manager', 'sub': '2-Way ARI Sync, Stop-Sell, Commissions & Bank Promos', 'badge': 'MODULE', 'route': '/channels'},
      {'title': 'Airport Transfers, Safaris & Gear', 'sub': 'BIA Flight Board, Wake-Up Calls & Liability Waivers', 'badge': 'MODULE', 'route': '/excursions'},
      {'title': 'SaaS Multi-Tenant Super Admin', 'sub': '4 Tenants, AWS Free Tier Meters & Backups', 'badge': 'SUPER_ADMIN', 'route': '/super_admin'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final q = searchCtrl.text.trim().toLowerCase();
            final results = q.isEmpty
                ? allCommands
                : allCommands
                    .where((c) =>
                        c['title']!.toLowerCase().contains(q) ||
                        c['sub']!.toLowerCase().contains(q))
                    .toList();

            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.78,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(CupertinoIcons.search, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Spotlight Quick Jump (⌘K)',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.clear),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: searchCtrl,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search rooms (101), guests (Perera), folios, KOTs, or modules...',
                        prefixIcon: Icon(CupertinoIcons.search, size: 18),
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, idx) {
                          final item = results[idx];
                          final route = item['route']!;
                          final allowed = auth.canAccessRoute(route);
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            leading: Icon(
                              allowed ? CupertinoIcons.arrow_right_circle_fill : CupertinoIcons.lock_fill,
                              color: allowed ? Theme.of(context).primaryColor : Colors.grey,
                              size: 18,
                            ),
                            title: Text(
                              item['title']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            subtitle: Text(
                              item['sub']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: MetricBadge(
                              label: allowed ? item['badge']! : 'LOCKED',
                              color: allowed ? Theme.of(context).primaryColor : Colors.grey,
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              if (onNavigateRoute != null) {
                                onNavigateRoute!(route);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Interactive Trilingual Help & Statutory Diagnostics Drawer (`HelpDrawer.tsx` in `hms-frontend`)
  void _showHelpDiagnosticsSheet(BuildContext context) {
    final TextEditingController nicCtrl = TextEditingController(text: '198421503342');
    final TextEditingController taxBaseCtrl = TextEditingController(text: '100000');

    Map<String, String> decodeSriLankanNic(String raw) {
      final clean = raw.trim().toUpperCase();
      int? year;
      int? days;
      String format = 'INVALID';

      if (RegExp(r'^\d{9}[VX]$').hasMatch(clean)) {
        format = 'OLD_9_DIGIT';
        year = 1900 + int.parse(clean.substring(0, 2));
        days = int.parse(clean.substring(2, 5));
      } else if (RegExp(r'^\d{12}$').hasMatch(clean)) {
        format = 'NEW_12_DIGIT';
        year = int.parse(clean.substring(0, 4));
        days = int.parse(clean.substring(4, 7));
      } else {
        return {'valid': 'false', 'format': 'INVALID', 'info': 'Enter 9 digits + V/X or 12 digits'};
      }

      String gender = 'MALE';
      if (days > 500) {
        gender = 'FEMALE';
        days -= 500;
      }
      if (days < 1 || days > 366) {
        return {'valid': 'false', 'format': format, 'info': 'Day-of-year ($days) out of range 1..366'};
      }
      return {
        'valid': 'true',
        'format': format,
        'info': 'Birth Year: $year • Gender: $gender • Day of Year: $days',
      };
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        int activeTopic = 0;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final nicResult = decodeSriLankanNic(nicCtrl.text);
            final baseAmt = double.tryParse(taxBaseCtrl.text) ?? 100000.0;
            final taxRes = TaxEngine.calculate(baseAmount: baseAmt);

            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.78,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Statutory Help & Diagnostics Drawer',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.clear),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('1. 4-Stage Tax Math'),
                            selected: activeTopic == 0,
                            onSelected: (_) => setModalState(() => activeTopic = 0),
                          ),
                          const SizedBox(width: 6),
                          ChoiceChip(
                            label: const Text('2. SL NIC Decoder'),
                            selected: activeTopic == 1,
                            onSelected: (_) => setModalState(() => activeTopic = 1),
                          ),
                          const SizedBox(width: 6),
                          ChoiceChip(
                            label: const Text('3. QR Diagnostics'),
                            selected: activeTopic == 2,
                            onSelected: (_) => setModalState(() => activeTopic = 2),
                          ),
                          const SizedBox(width: 6),
                          ChoiceChip(
                            label: const Text('4. RBAC Matrix'),
                            selected: activeTopic == 3,
                            onSelected: (_) => setModalState(() => activeTopic = 3),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: activeTopic == 0
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sri Lanka 4-Stage Compounding Tax Cascade (1.34343×)',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: taxBaseCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Test Base Room/F&B Tariff (LKR)',
                                    ),
                                    onChanged: (_) => setModalState(() {}),
                                  ),
                                  const SizedBox(height: 10),
                                  Text('Stage 1 — Base Amount: ${CurrencyEngine.formatLkr(taxRes.baseAmount)}'),
                                  Text('Stage 2 — +10% Service Charge: ${CurrencyEngine.formatLkr(taxRes.serviceCharge)}'),
                                  Text('Stage 3 — +1% SLTDA TDL (on Base+SC): ${CurrencyEngine.formatLkr(taxRes.tdl)}'),
                                  Text('Stage 4 — +2.5% SSCL (on Base+SC): ${CurrencyEngine.formatLkr(taxRes.sscl)}'),
                                  Text('Stage 5 — +18% VAT (on Base+SC+SSCL): ${CurrencyEngine.formatLkr(taxRes.vat)}'),
                                  const Divider(),
                                  Text(
                                    'Grand Total: ${CurrencyEngine.formatLkr(taxRes.grandTotal)} (${taxRes.effectiveTaxPercentage.toStringAsFixed(2)}%)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              )
                            : activeTopic == 1
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Sri Lankan Old (9-Digit V/X) & New (12-Digit) NIC Decoder',
                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: nicCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'Enter NIC Number',
                                          hintText: 'e.g. 198421503342 or 842150334V',
                                        ),
                                        onChanged: (_) => setModalState(() {}),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: nicResult['valid'] == 'true'
                                              ? AppTheme.emeraldBgLight
                                              : AppTheme.roseBgLight,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Format: ${nicResult['format']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              nicResult['info']!,
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : activeTopic == 2
                                    ? const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Contactless Guest QR & HMAC Session Diagnostics',
                                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            '• Every room standee QR encodes ?t=<hmac_sha256> bound to the active check-in folio.\n'
                                            '• When a guest checks out at Front Desk, the room QR token automatically rotates so previous guests cannot post fraudulent room charges.\n'
                                            '• High-value orders (> LKR 15,000) require the guest to verify the last 4 digits of their NIC/Passport or Room PIN.',
                                            style: TextStyle(fontSize: 12.5, height: 1.45),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Role-Based Access Control (RBAC) Permission Matrix',
                                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                          ),
                                          const SizedBox(height: 8),
                                          ...UserRole.values.map((r) => Padding(
                                                padding: const EdgeInsets.only(bottom: 8),
                                                child: Text(
                                                  '• ${r.displayName} (${r.code}): ${(AuthState.rolePermissions[r] ?? []).join(", ")}',
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                              )),
                                        ],
                                      ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPropertySwitchModal(BuildContext context, VoidCallback onRefresh) {
    final tenantEngine = TenantEngine();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.brandSurfaceTint(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(CupertinoIcons.building_2_fill, color: theme.primaryColor, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Switch Hotel Property (Multi-Tenant)',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                            ),
                          ),
                          Text(
                            'Select an active SLTDA-registered hotel across Sri Lanka',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...TenantEngine.registeredProperties.map((prop) {
                  final isCurrent = tenantEngine.activeTenantId == prop.tenantId;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppTheme.brandSurfaceTint(context)
                          : (isDark ? AppTheme.darkSubtleSurface : AppTheme.lightSubtleSurface),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCurrent
                            ? AppTheme.brandBorderTint(context)
                            : (isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCurrent ? theme.primaryColor : Colors.grey.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          CupertinoIcons.bed_double_fill,
                          size: 18,
                          color: isCurrent ? Colors.white : Colors.grey,
                        ),
                      ),
                      title: Text(
                        prop.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        '${prop.city} (${prop.province}) • ${prop.totalRooms} Rooms • ${prop.sltdaRegistrationNumber}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: isCurrent
                          ? Icon(CupertinoIcons.checkmark_circle_fill, color: theme.primaryColor, size: 20)
                          : null,
                      onTap: () {
                        tenantEngine.switchProperty(prop.tenantId);
                        Navigator.pop(ctx);
                        onRefresh();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
