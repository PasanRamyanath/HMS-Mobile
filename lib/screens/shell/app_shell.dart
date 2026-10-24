import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/auth/auth_state.dart';
import '../../core/l10n/translations.dart';
import '../../core/tenant/tenant_engine.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/metric_badge.dart';
import '../../widgets/top_status_bar.dart';
import '../touchpoints/touchpoints_screen.dart';
import '../dashboard/executive_dashboard_screen.dart';
import '../frontdesk/tape_chart_screen.dart';
import '../frontdesk/express_checkin_screen.dart';
import '../pos/waiter_pos_screen.dart';
import '../kds/dark_kds_screen.dart';
import '../kds/bar_bot_screen.dart';
import '../housekeeping/housekeeping_runner_screen.dart';
import '../billing/split_folio_screen.dart';
import '../guest/guest_dining_screen.dart';
import '../booking/direct_booking_screen.dart';
import '../erp/banquets_screen.dart';
import '../erp/ayurveda_screen.dart';
import '../erp/inventory_screen.dart';
import '../erp/tax_sltda_screen.dart';
import '../erp/payroll_screen.dart';
import '../channels/channel_manager_screen.dart';
import '../activities/excursions_screen.dart';
import '../staff/my_payslip_screen.dart';
import '../superadmin/saas_super_admin_screen.dart';
import '../settings/settings_screen.dart';

/// Web-Parity AdminShell & Role-Based Access Control (RBAC) Router (`AdminShell.tsx` & `RoleSimulatorBar.tsx`).
/// Enforces `AuthState().canAccessRoute(route)` on every navigation action, filters the sidebar drawer
/// according to the active user role, and provides a 1-tap Role Simulator Bar when testing restricted views.
class AppShell extends StatefulWidget {
  final VoidCallback onThemeChanged;

  const AppShell({super.key, required this.onThemeChanged});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  void _navigateToRoute(String route) {
    final auth = AuthState();

    // Enforce Role-Based Access Control (RBAC) before navigating!
    if (!auth.canAccessRoute(route)) {
      _showRbacAccessDeniedDialog(route);
      return;
    }

    Widget target;
    switch (route) {
      case '/touchpoints':
        setState(() => _currentIndex = 0);
        return;
      case '/dashboard':
        setState(() => _currentIndex = 1);
        return;
      case '/tape_chart':
        setState(() => _currentIndex = 2);
        return;
      case '/waiter_pos':
        setState(() => _currentIndex = 3);
        return;
      case '/settings':
        setState(() => _currentIndex = 4);
        return;
      case '/express_checkin':
        target = const ExpressCheckinScreen();
        break;
      case '/dark_kds':
        target = const DarkKdsScreen();
        break;
      case '/bar_bot':
        target = const BarBotScreen();
        break;
      case '/housekeeping':
        target = const HousekeepingRunnerScreen();
        break;
      case '/split_folios':
        target = const SplitFolioScreen();
        break;
      case '/guest_dining':
        target = const GuestDiningScreen();
        break;
      case '/direct_booking':
        target = const DirectBookingScreen();
        break;
      case '/banquets':
        target = const BanquetsScreen();
        break;
      case '/ayurveda':
        target = const AyurvedaScreen();
        break;
      case '/inventory':
        target = const InventoryScreen();
        break;
      case '/sltda_taxes':
        target = const TaxSltdaScreen();
        break;
      case '/payroll':
        target = const PayrollScreen();
        break;
      case '/channels':
        target = const ChannelManagerScreen();
        break;
      case '/excursions':
        target = const ExcursionsScreen();
        break;
      case '/my_payslip':
        target = const MyPayslipScreen();
        break;
      case '/super_admin':
        target = const SaasSuperAdminScreen();
        break;
      default:
        target = TouchpointsScreen(onNavigate: _navigateToRoute);
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => target));
  }

  /// Displays RBAC Permission Denied Dialog with option to switch role via Role Simulator (`RoleSimulatorBar.tsx`)
  void _showRbacAccessDeniedDialog(String route) {
    final auth = AuthState();
    final allowedRoles = AuthState.routeAllowedRoles[route] ?? UserRole.values;
    final suggestedRole = allowedRoles.first;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(CupertinoIcons.lock_shield_fill, color: Color(0xFFDC2626), size: 22),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'RBAC Role Access Restricted',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your active session role (${auth.currentRole.displayName} • ${auth.currentRole.code}) does not have permission to open "$route".',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.amberBgLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.amberBorderLight),
              ),
              child: Text(
                'Permitted Roles: ${AuthState.allowedRolesDescription(route)}',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.amberTextLight,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(CupertinoIcons.person_crop_circle_badge_checkmark, size: 15),
            label: Text('Switch to ${suggestedRole.displayName}'),
            onPressed: () {
              Navigator.pop(ctx);
              auth.switchRole(suggestedRole);
              setState(() {});
              _navigateToRoute(route);
            },
          ),
        ],
      ),
    );
  }

  void _showRoleSwitchModal() {
    final auth = AuthState();
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
                      child: Icon(CupertinoIcons.shield_lefthalf_fill, color: theme.primaryColor, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.tr('switch_role'),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                            ),
                          ),
                          Text(
                            'RoleSimulatorBar • Enforces Module & Action RBAC Permissions',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...UserRole.values.map((role) {
                  final isCurrent = auth.currentRole == role;
                  final perms = AuthState.rolePermissions[role] ?? const [];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppTheme.brandSurfaceTint(context)
                          : (isDark ? AppTheme.darkSubtleSurface : AppTheme.lightSubtleSurface),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? AppTheme.brandBorderTint(context)
                            : (isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder),
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        CupertinoIcons.person_crop_circle_badge_checkmark,
                        color: isCurrent ? theme.primaryColor : Colors.grey,
                      ),
                      title: Text(
                        '${role.displayName} (${role.code})',
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        '${role.department} • Permissions: ${perms.take(3).join(", ")}${perms.length > 3 ? "..." : ""}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10.5),
                      ),
                      trailing: isCurrent
                          ? Icon(CupertinoIcons.checkmark_circle_fill, color: theme.primaryColor, size: 18)
                          : null,
                      onTap: () {
                        auth.switchRole(role);
                        Navigator.pop(ctx);
                        setState(() {});
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

  void _onBottomTabTap(int index) {
    const tabRoutes = ['/touchpoints', '/dashboard', '/tape_chart', '/waiter_pos', '/settings'];
    final targetRoute = tabRoutes[index];
    if (!AuthState().canAccessRoute(targetRoute)) {
      _showRbacAccessDeniedDialog(targetRoute);
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Widget> pages = [
      TouchpointsScreen(onNavigate: _navigateToRoute),
      ExecutiveDashboardScreen(onNavigate: _navigateToRoute),
      const TapeChartScreen(),
      const WaiterPosScreen(),
      SettingsScreen(onThemeChanged: widget.onThemeChanged),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: TopStatusBar(
        onLanguageChanged: () {
          setState(() {});
          widget.onThemeChanged();
        },
        onRoleChanged: _showRoleSwitchModal,
        onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
        onNavigateRoute: _navigateToRoute,
      ),
      drawer: _buildWebParitySidebarDrawer(context, isDark),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 45 : 8),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onBottomTabTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          elevation: 0,
          selectedItemColor: theme.primaryColor,
          unselectedItemColor: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
          selectedFontSize: 11,
          unselectedFontSize: 10.5,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.square_grid_2x2_fill, size: 20),
              label: AppTranslations.tr('touchpoints'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.chart_bar_square_fill, size: 20),
              label: AppTranslations.tr('dashboard'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.calendar, size: 20),
              label: AppTranslations.tr('tape_chart'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.cart_fill, size: 20),
              label: AppTranslations.tr('waiter_pos'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.gear_alt_fill, size: 20),
              label: AppTranslations.tr('settings'),
            ),
          ],
        ),
      ),
    );
  }

  /// Web-Parity Slide-Over Enterprise Sidebar (`AdminShell.tsx` 3-group navigation with RBAC filtering)
  Widget _buildWebParitySidebarDrawer(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final tenant = TenantEngine().currentProperty;
    final auth = AuthState();

    return Drawer(
      backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand Header + Active Shift Session Banner
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sri Lanka Cloud HMS',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                              ),
                            ),
                            Text(
                              tenant.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: MetricBadge(
                          label: '${auth.currentRole.displayName} (${auth.currentRole.code})',
                          color: theme.primaryColor,
                          showDot: true,
                          onTap: () {
                            Navigator.pop(context);
                            _showRoleSwitchModal();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Navigation Groups matching AdminShell.tsx (Showing RBAC permission status)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                children: [
                  _drawerGroupLabel('1. FRONTLINE & GUESTS', isDark),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.square_grid_2x2_fill,
                    label: '7-Mode Workspace Portal',
                    route: '/touchpoints',
                    badge: '20',
                    isSelected: _currentIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 0);
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.chart_bar_square_fill,
                    label: 'Executive Bento Dashboard',
                    route: '/dashboard',
                    badge: 'Live',
                    isSelected: _currentIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      _onBottomTabTap(1);
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.calendar,
                    label: 'Front Desk, Tape Chart & B-Card',
                    route: '/tape_chart',
                    badge: '6 Tabs',
                    isSelected: _currentIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      _onBottomTabTap(2);
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.person_badge_plus_fill,
                    label: 'Express Check-In & Reg Card',
                    route: '/express_checkin',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/express_checkin');
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.compass_fill,
                    label: 'Direct Booking & Add-Ons',
                    route: '/direct_booking',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/direct_booking');
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.arrow_2_circlepath_circle_fill,
                    label: 'Channex OTA & Bank Promos',
                    route: '/channels',
                    badge: '5 Tabs',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/channels');
                    },
                  ),

                  const SizedBox(height: 12),
                  _drawerGroupLabel('2. DINING, EVENTS & ROOMS', isDark),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.cart_fill,
                    label: 'POS, Orders, Runner & Buffet',
                    route: '/waiter_pos',
                    badge: '5 Tabs',
                    isSelected: _currentIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      _onBottomTabTap(3);
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.flame_fill,
                    label: 'Kitchen KDS & 86 Stock Drawer',
                    route: '/dark_kds',
                    badge: '3 KOTs',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/dark_kds');
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.sparkles,
                    label: 'Sunset Bar BOT Queue',
                    route: '/bar_bot',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/bar_bot');
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.qrcode,
                    label: 'Guest Contactless QR Super-App',
                    route: '/guest_dining',
                    badge: '6 Tabs',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/guest_dining');
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.bed_double_fill,
                    label: 'Housekeeping, Laundry & Maint.',
                    route: '/housekeeping',
                    badge: '6 Tabs',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/housekeeping');
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.heart_fill,
                    label: 'Banquets, Poruwa & BEO',
                    route: '/banquets',
                    badge: '6 Tabs',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/banquets');
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.leaf_arrow_circlepath,
                    label: 'Ayurveda Spa & Panchakarma',
                    route: '/ayurveda',
                    badge: '4 Tabs',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/ayurveda');
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.car_detailed,
                    label: 'Transfers, Safaris & Gear',
                    route: '/excursions',
                    badge: '4 Tabs',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/excursions');
                    },
                  ),

                  const SizedBox(height: 12),
                  _drawerGroupLabel('3. BACK OFFICE & STATUTORY', isDark),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.doc_text_fill,
                    label: 'Folios, City Ledger & Cashier',
                    route: '/split_folios',
                    badge: '4 Tabs',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/split_folios');
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.cube_box_fill,
                    label: 'FIFO Stores, PO/GRN & Peg Audit',
                    route: '/inventory',
                    badge: '6 Tabs',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/inventory');
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.percent,
                    label: 'SLTDA, Night Audit & IRD Tax',
                    route: '/sltda_taxes',
                    badge: '5 Tabs',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/sltda_taxes');
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.money_dollar_circle_fill,
                    label: 'HR, Roster, 10% SC & EPF/ETF',
                    route: '/payroll',
                    badge: '6 Tabs',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/payroll');
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.creditcard_fill,
                    label: 'Staff My Payslip & Leave',
                    route: '/my_payslip',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/my_payslip');
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.shield_lefthalf_fill,
                    label: 'SaaS Super Admin Console',
                    route: '/super_admin',
                    badge: 'SA Only',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/super_admin');
                    },
                  ),
                  _drawerNavItem(
                    context,
                    icon: CupertinoIcons.gear_alt_fill,
                    label: 'Settings & Onboarding (6 Tabs)',
                    route: '/settings',
                    isSelected: _currentIndex == 4,
                    onTap: () {
                      Navigator.pop(context);
                      _onBottomTabTap(4);
                    },
                  ),
                ],
              ),
            ),

            // Drawer Footer: Active Shift & Theme Switcher
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSubtleSurface : AppTheme.lightSubtleSurface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.primaryColor,
                    child: const Icon(CupertinoIcons.person_fill, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          auth.currentUser?.name ?? 'Staff Session',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                        Text(
                          '${auth.currentRole.department} • On Duty',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                    icon: Icon(
                      isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_stars_fill,
                      size: 18,
                      color: isDark ? const Color(0xFFFBBF24) : theme.primaryColor,
                    ),
                    onPressed: () {
                      AppTheme.toggleThemeMode();
                      widget.onThemeChanged();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerGroupLabel(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
        ),
      ),
    );
  }

  Widget _drawerNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    String? badge,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allowed = AuthState().canAccessRoute(route);

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: isSelected ? AppTheme.brandSurfaceTint(context) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Opacity(
            opacity: allowed ? 1.0 : 0.55,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: isSelected ? Border.all(color: AppTheme.brandBorderTint(context)) : null,
              ),
              child: Row(
                children: [
                  Icon(
                    allowed ? icon : CupertinoIcons.lock_fill,
                    size: 16,
                    color: isSelected
                        ? theme.primaryColor
                        : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? theme.primaryColor
                            : (isDark ? Colors.white : AppTheme.lightTextPrimary),
                      ),
                    ),
                  ),
                  if (!allowed)
                    const Icon(CupertinoIcons.lock_shield, size: 13, color: Colors.grey)
                  else if (badge != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.primaryColor
                            : (isDark ? AppTheme.darkSubtleSurface : AppTheme.lightSubtleSurface),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
