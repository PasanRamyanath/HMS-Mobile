import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/auth/auth_state.dart';
import '../../core/l10n/translations.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

class TouchpointItem {
  final String key;
  final String title;
  final String subtitle;
  final String category;
  final String tag;
  final IconData icon;
  final Color color;
  final String routeName;
  final String? imageAsset;

  const TouchpointItem({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.tag,
    required this.icon,
    required this.color,
    required this.routeName,
    this.imageAsset,
  });
}

/// Web-Parity Base Landing Portal, 7-Mode Workspace Switcher & Staff Mobile Hub (`BaseLandingPortal.tsx` + `StaffMobileHub.tsx`).
/// Shows active RBAC role permissions, filters or highlights permitted modules,
/// and provides quick staff shift shortcuts (Driver Meal Voucher Redeem, Outlet Shift Z-Read, Chef 86 Stock).
class TouchpointsScreen extends StatefulWidget {
  final Function(String route) onNavigate;

  const TouchpointsScreen({super.key, required this.onNavigate});

  @override
  State<TouchpointsScreen> createState() => _TouchpointsScreenState();
}

class _TouchpointsScreenState extends State<TouchpointsScreen> {
  String _selectedCategory = 'ALL';
  bool _onlyMyRoleModules = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = AuthState();

    final touchpoints = [
      TouchpointItem(
        key: 'dashboard',
        title: AppTranslations.tr('dashboard'),
        subtitle: '4 Tabs: Bento KPIs, Live KDS Feed, IRD Liabilities & Top Dishes',
        category: 'FRONTLINE',
        tag: '4 Tabs',
        icon: CupertinoIcons.chart_bar_square_fill,
        color: const Color(0xFF0B6E4F),
        routeName: '/dashboard',
        imageAsset: WebAssets.galleFortHero,
      ),
      TouchpointItem(
        key: 'tape_chart',
        title: AppTranslations.tr('tape_chart'),
        subtitle: '6 Tabs: Tape Chart, Daily Board, Driver Beds, Meal Forecast, Police B-Card & DMC',
        category: 'FRONTLINE',
        tag: '6 Tabs',
        icon: CupertinoIcons.calendar,
        color: const Color(0xFF0284C7),
        routeName: '/tape_chart',
        imageAsset: WebAssets.roomDeluxeOcean,
      ),
      TouchpointItem(
        key: 'express_checkin',
        title: AppTranslations.tr('express_checkin'),
        subtitle: 'NIC Birth/Gender Decoder, Digital Signature Pad & Printable Reg Card',
        category: 'FRONTLINE',
        tag: 'B-Card OCR',
        icon: CupertinoIcons.person_crop_circle_badge_plus,
        color: const Color(0xFF0D9488),
        routeName: '/express_checkin',
        imageAsset: WebAssets.boutiqueCourtyardLogin,
      ),
      TouchpointItem(
        key: 'waiter_pos',
        title: AppTranslations.tr('waiter_pos'),
        subtitle: '5 Tabs: Table POS, All Orders, Order Runner, Buffet Host & Menus/86 Board',
        category: 'DINING',
        tag: '5 Tabs',
        icon: CupertinoIcons.cart_fill,
        color: const Color(0xFFEA580C),
        routeName: '/waiter_pos',
        imageAsset: WebAssets.dishCrabHoppers,
      ),
      TouchpointItem(
        key: 'dark_kds',
        title: AppTranslations.tr('dark_kds'),
        subtitle: '3-Column Kanban, 1-Tap 86 Out-of-Stock Drawer & 80mm KOT Slip',
        category: 'DINING',
        tag: 'Kanban KDS',
        icon: CupertinoIcons.flame_fill,
        color: const Color(0xFFDC2626),
        routeName: '/dark_kds',
        imageAsset: WebAssets.dishCrabHoppers,
      ),
      TouchpointItem(
        key: 'bar_bot',
        title: AppTranslations.tr('bar_bot'),
        subtitle: 'Beverage BOT Queue, Glassware Specs & Liquor Peg Audit',
        category: 'DINING',
        tag: 'Pool Bar',
        icon: CupertinoIcons.sparkles,
        color: const Color(0xFF7C3AED),
        routeName: '/bar_bot',
        imageAsset: WebAssets.dishCuttlefishArrack,
      ),
      TouchpointItem(
        key: 'housekeeping',
        title: AppTranslations.tr('housekeeping'),
        subtitle: '6 Tabs: Room Runner, Turndown, Laundry, Maintenance, Lost/Found & Utilities',
        category: 'FRONTLINE',
        tag: '6 Tabs',
        icon: CupertinoIcons.bed_double_fill,
        color: const Color(0xFF16A34A),
        routeName: '/housekeeping',
        imageAsset: WebAssets.roomThumbDeluxe,
      ),
      TouchpointItem(
        key: 'split_folios',
        title: AppTranslations.tr('split_folios'),
        subtitle: '4 Tabs: Split Folios, City Ledger AR, Cashier Shift/FX & Tax Invoice Archive',
        category: 'BACKOFFICE',
        tag: '4 Tabs',
        icon: CupertinoIcons.doc_text_fill,
        color: const Color(0xFF0284C7),
        routeName: '/split_folios',
      ),
      TouchpointItem(
        key: 'guest_dining',
        title: AppTranslations.tr('guest_dining'),
        subtitle: '6 Tabs: Dining, Express HK, Laundry, Minibar, Safari Box & Live Folio Pay',
        category: 'DINING',
        tag: '6 Tabs',
        icon: CupertinoIcons.qrcode,
        color: const Color(0xFFD97706),
        routeName: '/guest_dining',
        imageAsset: WebAssets.dishCuttlefishArrack,
      ),
      TouchpointItem(
        key: 'direct_booking',
        title: AppTranslations.tr('direct_booking'),
        subtitle: '3-Step Booking Engine, Stay Add-Ons, Voucher & Wedding Inquiry',
        category: 'FRONTLINE',
        tag: '0% Comm.',
        icon: CupertinoIcons.compass_fill,
        color: const Color(0xFF2563EB),
        routeName: '/direct_booking',
        imageAsset: WebAssets.roomBeachfrontVilla,
      ),
      TouchpointItem(
        key: 'weddings_poruwa',
        title: AppTranslations.tr('weddings_poruwa'),
        subtitle: '6 Tabs: Calendar, Poruwa Nekath BEO, Menu/Corkage, Leads, Plate Counter & Stewards',
        category: 'DINING',
        tag: '6 Tabs',
        icon: CupertinoIcons.heart_fill,
        color: const Color(0xFFBE185D),
        routeName: '/banquets',
        imageAsset: WebAssets.roomHeritageSuite,
      ),
      TouchpointItem(
        key: 'ayurveda_spa',
        title: AppTranslations.tr('ayurveda_spa'),
        subtitle: '4 Tabs: Spa Schedule, Vaidya Tridosha Quiz, Panchakarma & Commissions',
        category: 'DINING',
        tag: '4 Tabs',
        icon: CupertinoIcons.leaf_arrow_circlepath,
        color: const Color(0xFF059669),
        routeName: '/ayurveda',
        imageAsset: WebAssets.spaAyurvedaPavilion,
      ),
      TouchpointItem(
        key: 'inventory_bom',
        title: AppTranslations.tr('inventory_bom'),
        subtitle: '6 Tabs: Stock Registry, PR/PO/GRN/GIN, Bar Peg Audit, Stock-Take & Suppliers',
        category: 'BACKOFFICE',
        tag: '6 Tabs',
        icon: CupertinoIcons.cube_box_fill,
        color: const Color(0xFF4F46E5),
        routeName: '/inventory',
      ),
      TouchpointItem(
        key: 'sltda_taxes',
        title: AppTranslations.tr('sltda_taxes'),
        subtitle: '5 Tabs: 4-Stage Tax, 5-Step Night Audit, SLTDA MR-1/TDL, Flash & Accounting Export',
        category: 'BACKOFFICE',
        tag: '5 Tabs',
        icon: CupertinoIcons.percent,
        color: const Color(0xFFD97706),
        routeName: '/sltda_taxes',
      ),
      TouchpointItem(
        key: 'hospitality_payroll',
        title: AppTranslations.tr('hospitality_payroll'),
        subtitle: '6 Tabs: 10% SC Pool, Payroll Run, EPF/ETF Form C, Shift Roster, Attendance & Gratuity',
        category: 'BACKOFFICE',
        tag: '6 Tabs',
        icon: CupertinoIcons.money_dollar_circle_fill,
        color: const Color(0xFF15803D),
        routeName: '/payroll',
      ),
      TouchpointItem(
        key: 'channels',
        title: 'OTA Channel Manager',
        subtitle: '5 Tabs: Channex ARI Matrix, Stop-Sell/MinLOS, Commissions, Bank Promos & Widget',
        category: 'FRONTLINE',
        tag: '5 Tabs',
        icon: CupertinoIcons.arrow_2_circlepath_circle_fill,
        color: const Color(0xFF003580),
        routeName: '/channels',
      ),
      TouchpointItem(
        key: 'excursions',
        title: 'Transfers, Safaris & Gear',
        subtitle: '4 Tabs: Airport Flight Board, Excursions/Wake-Up, Gear Rentals & Waivers',
        category: 'DINING',
        tag: '4 Tabs',
        icon: CupertinoIcons.car_detailed,
        color: const Color(0xFF0284C7),
        routeName: '/excursions',
        imageAsset: WebAssets.galleFortHero,
      ),
      TouchpointItem(
        key: 'my_payslip',
        title: 'Staff My Payslip & Roster',
        subtitle: '3 Tabs: Monthly Payslip, Leave Pass Request & My Weekly Shift Schedule',
        category: 'BACKOFFICE',
        tag: 'Self-Service',
        icon: CupertinoIcons.creditcard_fill,
        color: const Color(0xFF15803D),
        routeName: '/my_payslip',
      ),
      TouchpointItem(
        key: 'super_admin',
        title: 'SaaS Super Admin',
        subtitle: '4 Tabs: Tenant Directory, AWS Free Tier, Chain Rollup & Backups/Invoices',
        category: 'BACKOFFICE',
        tag: 'SUPER_ADMIN',
        icon: CupertinoIcons.shield_lefthalf_fill,
        color: const Color(0xFF9333EA),
        routeName: '/super_admin',
      ),
      TouchpointItem(
        key: 'settings',
        title: AppTranslations.tr('settings'),
        subtitle: '6 Tabs: Appearance, Onboarding Profile, Taxes, Payments, SMSGo & Staff RBAC',
        category: 'BACKOFFICE',
        tag: '6 Tabs',
        icon: CupertinoIcons.gear_alt_fill,
        color: const Color(0xFF64748B),
        routeName: '/settings',
      ),
    ];

    final filtered = touchpoints.where((t) {
      if (_selectedCategory != 'ALL' && t.category != _selectedCategory) return false;
      if (_onlyMyRoleModules && !auth.canAccessRoute(t.routeName)) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active RBAC Session Banner (`RoleSimulatorBar.tsx`)
            LiquidGlassCard(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              backgroundColor: AppTheme.brandSurfaceTint(context),
              customBorder: Border.all(color: AppTheme.brandBorderTint(context)),
              child: Row(
                children: [
                  Icon(CupertinoIcons.shield_lefthalf_fill, color: theme.primaryColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active RBAC Role: ${auth.currentRole.displayName} (${auth.currentRole.code})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            color: theme.primaryColor,
                          ),
                        ),
                        Text(
                          'Department: ${auth.currentRole.department} • Shift Active',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  FilterChip(
                    label: Text(
                      _onlyMyRoleModules ? 'Role Only' : 'Show All',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                    ),
                    selected: _onlyMyRoleModules,
                    onSelected: (val) => setState(() => _onlyMyRoleModules = val),
                  ),
                ],
              ),
            ),

            // 1. Web Version Hero Section (`BaseLandingPortal.tsx`)
            Text(
              'One calm platform for every team in your hotel.',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
                height: 1.15,
                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Switch seamlessly between Hotel PMS Admin, Waiter POS, Kitchen KDS, Bar BOT, Staff Operations Hub, Guest QR Super-App, and Direct Booking.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Quick Action Buttons (`Wrap` so buttons NEVER overflow horizontally)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => widget.onNavigate('/dashboard'),
                  icon: const Icon(CupertinoIcons.chart_bar_square_fill, size: 15),
                  label: const Text('Open Hotel PMS Admin'),
                ),
                OutlinedButton.icon(
                  onPressed: () => widget.onNavigate('/direct_booking'),
                  icon: const Icon(CupertinoIcons.compass, size: 15),
                  label: const Text('Public Booking Engine'),
                ),
                OutlinedButton.icon(
                  onPressed: () => widget.onNavigate('/guest_dining'),
                  icon: const Icon(CupertinoIcons.qrcode, size: 15),
                  label: const Text('Room 101 QR Super-App'),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Galle Fort Lighthouse Villa Hero Photography Card (`galle-fort-villa-hero.jpg`)
            const WebHeroBannerCard(
              assetPath: WebAssets.galleFortHero,
              badgeText: 'UNESCO World Heritage Luxury Boutique Hotel',
              rightPillText: '24 Rooms In-House',
              title: 'Galle Fort Lighthouse Villa • Ramparts & Ocean View',
              subtitle: 'Infinity Pool, Ayurveda Pavilion, Dutch Verandah & Sunset Bar',
              height: 180,
            ),
            const SizedBox(height: 14),

            // 4-Metric Telemetry Strip (`BaseLandingPortal.tsx` 2x2 Responsive Grid)
            LiquidGlassCard(
              padding: const EdgeInsets.all(14),
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTelemetryMetric(
                          label: 'Occupancy',
                          value: '86% (24/28)',
                          valueColor: theme.primaryColor,
                          isDark: isDark,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTelemetryMetric(
                          label: "Today's Billing",
                          value: 'LKR 985.6k',
                          valueColor: isDark ? Colors.white : AppTheme.lightTextPrimary,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTelemetryMetric(
                          label: '4-Stage IRD Tax',
                          value: '1.34343×',
                          valueColor: isDark ? Colors.white : AppTheme.lightTextPrimary,
                          isDark: isDark,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTelemetryMetric(
                          label: 'Channex OTA',
                          value: '2-Way Live',
                          valueColor: theme.primaryColor,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 4 Core Workspace Launcher Cards (`BaseLandingPortal.tsx`)
            Text(
              '7-MODE ROLE WORKSPACE LAUNCHERS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
            ),
            const SizedBox(height: 8),
            _buildWorkspaceLauncherCard(
              context,
              badgeText: '1. Hotel PMS Admin',
              badgeColor: const Color(0xFF0B6E4F),
              rightTag: '14 Modules',
              title: 'PMS, Folios & Statutory Tax',
              description: 'Tape chart, Police B-Card, Driver Beds, Form MR-1 SLTDA, EPF/ETF & Stores.',
              actionLabel: 'Launch PMS Dashboard →',
              highlighted: true,
              onTap: () => widget.onNavigate('/dashboard'),
            ),
            _buildWorkspaceLauncherCard(
              context,
              badgeText: '2. Waiter POS & Hub',
              badgeColor: const Color(0xFFD97706),
              rightTag: '5 Sub-Modules',
              title: 'Terrace Bar POS, Runner & Buffet Host',
              description: 'Dine-in, room charge, split bill, Z-Read register & driver meal vouchers.',
              actionLabel: 'Launch Waiter POS →',
              onTap: () => widget.onNavigate('/waiter_pos'),
            ),
            _buildWorkspaceLauncherCard(
              context,
              badgeText: '3. Kitchen KDS & Bar BOT',
              badgeColor: const Color(0xFF0284C7),
              rightTag: '3 Active Tickets',
              title: 'Live KDS Kanban & Beverage BOT',
              description: '3-column Kanban boards with KOT/BOT print, 86 stock drawer & glassware specs.',
              actionLabel: 'Launch Kitchen KDS →',
              onTap: () => widget.onNavigate('/dark_kds'),
            ),
            _buildWorkspaceLauncherCard(
              context,
              badgeText: '4. Guest QR & Booking',
              badgeColor: const Color(0xFF475569),
              rightTag: 'Room 101',
              title: 'Guest QR Super-App & Direct Web',
              description: 'In-room dining, express housekeeping, laundry, minibar, safari box & direct booking.',
              actionLabel: 'Open Guest Super-App →',
              onTap: () => widget.onNavigate('/guest_dining'),
            ),
            const SizedBox(height: 18),

            // Category Filter Bar for All 20 Operational Modules
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'All Operational Modules (${filtered.length})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('ALL', 'All Modules (20)', isDark),
                  const SizedBox(width: 6),
                  _buildFilterChip('FRONTLINE', 'Frontline & Rooms', isDark),
                  const SizedBox(width: 6),
                  _buildFilterChip('DINING', 'Dining, KDS & Spa', isDark),
                  const SizedBox(width: 6),
                  _buildFilterChip('BACKOFFICE', 'Back Office & Statutory', isDark),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Overflow-Safe Responsive Module List/Bento Cards
            ...filtered.map((item) => _buildModuleBentoCard(context, item, isDark, auth)),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryMetric({
    required String label,
    required String value,
    required Color valueColor,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkspaceLauncherCard(
    BuildContext context, {
    required String badgeText,
    required Color badgeColor,
    required String rightTag,
    required String title,
    required String description,
    required String actionLabel,
    bool highlighted = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LiquidGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 10),
      backgroundColor: highlighted ? AppTheme.brandSurfaceTint(context) : null,
      customBorder: highlighted
          ? Border.all(color: AppTheme.brandBorderTint(context), width: 1.2)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: MetricBadge(
                  label: badgeText,
                  color: badgeColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                rightTag,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            actionLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String id, String label, bool isDark) {
    final isSelected = _selectedCategory == id;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedCategory = id);
      },
    );
  }

  Widget _buildModuleBentoCard(
    BuildContext context,
    TouchpointItem item,
    bool isDark,
    AuthState auth,
  ) {
    final allowed = auth.canAccessRoute(item.routeName);
    return LiquidGlassCard(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      onTap: () => widget.onNavigate(item.routeName),
      child: Opacity(
        opacity: allowed ? 1.0 : 0.65,
        child: Row(
          children: [
            if (item.imageAsset != null)
              WebImageThumbnail(
                assetPath: item.imageAsset!,
                width: 52,
                height: 52,
                borderRadius: 12,
                fallbackIcon: item.icon,
                fallbackColor: item.color,
              )
            else
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: item.color.withAlpha(isDark ? 45 : 22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: item.color.withAlpha(80)),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      MetricBadge(
                        label: allowed ? item.tag : 'RBAC LOCKED',
                        color: allowed ? item.color : Colors.grey,
                        icon: allowed ? null : CupertinoIcons.lock_fill,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              allowed ? CupertinoIcons.chevron_right : CupertinoIcons.lock_shield,
              size: 15,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ],
        ),
      ),
    );
  }
}
