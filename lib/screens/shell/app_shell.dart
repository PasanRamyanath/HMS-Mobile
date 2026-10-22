import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/auth/auth_state.dart';
import '../../core/l10n/translations.dart';
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
import '../settings/settings_screen.dart';

class AppShell extends StatefulWidget {
  final VoidCallback onThemeChanged;

  const AppShell({super.key, required this.onThemeChanged});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _navigateToRoute(String route) {
    Widget target;
    switch (route) {
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
      default:
        target = TouchpointsScreen(onNavigate: _navigateToRoute);
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => target));
  }

  void _showRoleSwitchModal() {
    final auth = AuthState();
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTranslations.tr('switch_role'),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ...UserRole.values.map((role) {
                final isCurrent = auth.currentRole == role;
                return ListTile(
                  leading: Icon(
                    CupertinoIcons.person_crop_circle_badge_checkmark,
                    color: isCurrent ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                  title: Text(role.displayName, style: TextStyle(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500)),
                  subtitle: Text(role.code, style: const TextStyle(fontSize: 11)),
                  trailing: isCurrent ? Icon(CupertinoIcons.checkmark_alt, color: Theme.of(context).primaryColor) : null,
                  onTap: () {
                    auth.switchRole(role);
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Widget> pages = [
      TouchpointsScreen(onNavigate: _navigateToRoute),
      ExecutiveDashboardScreen(onNavigate: _navigateToRoute),
      const TapeChartScreen(),
      const WaiterPosScreen(),
      SettingsScreen(onThemeChanged: widget.onThemeChanged),
    ];

    return Scaffold(
      appBar: TopStatusBar(
        onLanguageChanged: () => setState(() {}),
        onRoleChanged: _showRoleSwitchModal,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white12
                  : const Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: theme.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.square_grid_2x2_fill),
              label: AppTranslations.tr('touchpoints'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.chart_bar_square_fill),
              label: AppTranslations.tr('dashboard'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.calendar),
              label: AppTranslations.tr('tape_chart'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.cart_fill),
              label: AppTranslations.tr('waiter_pos'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.gear_alt_fill),
              label: AppTranslations.tr('settings'),
            ),
          ],
        ),
      ),
    );
  }
}
