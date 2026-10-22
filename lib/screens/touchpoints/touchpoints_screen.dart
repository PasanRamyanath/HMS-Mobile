import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../widgets/liquid_glass_card.dart';

class TouchpointItem {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String routeName;

  const TouchpointItem({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.routeName,
  });
}

class TouchpointsScreen extends StatelessWidget {
  final Function(String route) onNavigate;

  const TouchpointsScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final touchpoints = [
      TouchpointItem(
        key: 'dashboard',
        title: AppTranslations.tr('dashboard'),
        subtitle: 'Occupancy %, ADR, RevPAR & Headcounts',
        icon: CupertinoIcons.chart_bar_square_fill,
        color: const Color(0xFF0F5132),
        routeName: '/dashboard',
      ),
      TouchpointItem(
        key: 'tape_chart',
        title: AppTranslations.tr('tape_chart'),
        subtitle: '14-Day Timeline & Room Allocation',
        icon: CupertinoIcons.calendar,
        color: const Color(0xFF0284C7),
        routeName: '/tape_chart',
      ),
      TouchpointItem(
        key: 'express_checkin',
        title: AppTranslations.tr('express_checkin'),
        subtitle: 'Guest Registration & NIC/Passport OCR',
        icon: CupertinoIcons.person_crop_circle_badge_plus,
        color: const Color(0xFF0D9488),
        routeName: '/express_checkin',
      ),
      TouchpointItem(
        key: 'waiter_pos',
        title: AppTranslations.tr('waiter_pos'),
        subtitle: 'Floor Tables, Spice Levels & KOTs',
        icon: CupertinoIcons.cart_fill,
        color: const Color(0xFFEA580C),
        routeName: '/waiter_pos',
      ),
      TouchpointItem(
        key: 'dark_kds',
        title: AppTranslations.tr('dark_kds'),
        subtitle: 'Kitchen OLED High-Contrast Order Queue',
        icon: CupertinoIcons.flame_fill,
        color: const Color(0xFFDC2626),
        routeName: '/dark_kds',
      ),
      TouchpointItem(
        key: 'bar_bot',
        title: AppTranslations.tr('bar_bot'),
        subtitle: 'Sunset Bar & Mixology Ticket Display',
        icon: CupertinoIcons.sparkles,
        color: const Color(0xFF9333EA),
        routeName: '/bar_bot',
      ),
      TouchpointItem(
        key: 'housekeeping',
        title: AppTranslations.tr('housekeeping'),
        subtitle: 'Room Cleanliness & Linen Turnover',
        icon: CupertinoIcons.sparkles,
        color: const Color(0xFF16A34A),
        routeName: '/housekeeping',
      ),
      TouchpointItem(
        key: 'split_folios',
        title: AppTranslations.tr('split_folios'),
        subtitle: 'Folio Splitting, 4-Stage Taxes & QR',
        icon: CupertinoIcons.doc_text_fill,
        color: const Color(0xFF0284C7),
        routeName: '/split_folios',
      ),
      TouchpointItem(
        key: 'guest_dining',
        title: AppTranslations.tr('guest_dining'),
        subtitle: 'Contactless QR Menu & In-Room Dining',
        icon: CupertinoIcons.qrcode,
        color: const Color(0xFFD97706),
        routeName: '/guest_dining',
      ),
      TouchpointItem(
        key: 'direct_booking',
        title: AppTranslations.tr('direct_booking'),
        subtitle: 'Direct Online Reservations & Rates',
        icon: CupertinoIcons.compass_fill,
        color: const Color(0xFF2563EB),
        routeName: '/direct_booking',
      ),
      TouchpointItem(
        key: 'weddings_poruwa',
        title: AppTranslations.tr('weddings_poruwa'),
        subtitle: 'Poruwa Ceremonies, Auspicious Nekath',
        icon: CupertinoIcons.heart_fill,
        color: const Color(0xFFBE185D),
        routeName: '/banquets',
      ),
      TouchpointItem(
        key: 'ayurveda_spa',
        title: AppTranslations.tr('ayurveda_spa'),
        subtitle: 'Tridosha Vata/Pitta/Kapha & Herbal Oils',
        icon: CupertinoIcons.leaf_arrow_circlepath,
        color: const Color(0xFF059669),
        routeName: '/ayurveda',
      ),
      TouchpointItem(
        key: 'inventory_bom',
        title: AppTranslations.tr('inventory_bom'),
        subtitle: 'FIFO Stores, Stock Transfers & BOM',
        icon: CupertinoIcons.cube_box_fill,
        color: const Color(0xFF4F46E5),
        routeName: '/inventory',
      ),
      TouchpointItem(
        key: 'sltda_taxes',
        title: AppTranslations.tr('sltda_taxes'),
        subtitle: '10% SC, 1% TDL, 2.5% SSCL, 18% VAT',
        icon: CupertinoIcons.percent,
        color: const Color(0xFFD97706),
        routeName: '/sltda_taxes',
      ),
      TouchpointItem(
        key: 'hospitality_payroll',
        title: AppTranslations.tr('hospitality_payroll'),
        subtitle: '10% SC Pool, EPF 12%/8% & ETF 3%',
        icon: CupertinoIcons.money_dollar_circle_fill,
        color: const Color(0xFF15803D),
        routeName: '/payroll',
      ),
      TouchpointItem(
        key: 'channels',
        title: 'OTA Channel Manager',
        subtitle: 'Booking.com, Agoda, Airbnb 2-Way Sync',
        icon: CupertinoIcons.arrow_2_circlepath_circle_fill,
        color: const Color(0xFF003580),
        routeName: '/channels',
      ),
      TouchpointItem(
        key: 'excursions',
        title: 'Transfers & Excursions',
        subtitle: 'Airport Drops & Mirissa Whale Watching',
        icon: CupertinoIcons.car_detailed,
        color: const Color(0xFF0284C7),
        routeName: '/excursions',
      ),
      TouchpointItem(
        key: 'my_payslip',
        title: 'Staff My Payslip',
        subtitle: '10% SC Share, EPF/ETF & Leave Passes',
        icon: CupertinoIcons.creditcard_fill,
        color: const Color(0xFF15803D),
        routeName: '/my_payslip',
      ),
      TouchpointItem(
        key: 'super_admin',
        title: 'SaaS Super Admin',
        subtitle: 'Multi-Tenant Directory & AWS Free Tier',
        icon: CupertinoIcons.shield_lefthalf_fill,
        color: const Color(0xFF9333EA),
        routeName: '/super_admin',
      ),
      TouchpointItem(
        key: 'settings',
        title: AppTranslations.tr('settings'),
        subtitle: 'Ceylon Theme Palettes & Cloud Config',
        icon: CupertinoIcons.gear_alt_fill,
        color: const Color(0xFF64748B),
        routeName: '/settings',
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ceylon Heritage HMS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unified Cloud SaaS Hospitality Operations Hub',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = touchpoints[index];
                  return LiquidGlassCard(
                    padding: const EdgeInsets.all(14),
                    margin: EdgeInsets.zero,
                    onTap: () => onNavigate(item.routeName),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: item.color.withAlpha(isDark ? 45 : 30),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: item.color.withAlpha(isDark ? 90 : 60),
                              width: 1,
                            ),
                          ),
                          child: Icon(item.icon, color: item.color, size: 22),
                        ),
                        const Spacer(),
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : const Color(0xFF64748B),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: touchpoints.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
        ],
      ),
    );
  }
}
