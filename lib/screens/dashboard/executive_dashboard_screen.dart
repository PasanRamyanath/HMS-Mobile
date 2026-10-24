import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/api/appsync_client.dart';
import '../../core/tenant/tenant_engine.dart';
import '../../core/theme/app_theme.dart';
import '../../models/hotel_models.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

/// Web-Parity Executive Performance Bento Dashboard (`src/admin/DashboardView.tsx`).
/// Matches Screen 03 of the web version:
/// - Property Header + LKR/USD toggle + Today / 7 Days / 30 Days segmented filter
/// - Underline tab bar ("Executive Bento Grid", "Live KDS & Room Feed", "SLTDA & IRD Liabilities", "Top Dishes & Revenue")
/// - 4 Bento KPI Cards (Occupancy Rate, ADR, RevPAR, Today's Gross Billing)
/// - Cumulative Revenue Trajectory Chart + Room Cleanliness Distribution Bar
/// - Today's F&B Meal Plan Headcount + Top Revenue Dishes with Web Photography
/// - SLTDA & IRD Statutory Liabilities + Active Guest In-House Roster
class ExecutiveDashboardScreen extends StatefulWidget {
  final Function(String route)? onNavigate;

  const ExecutiveDashboardScreen({super.key, this.onNavigate});

  @override
  State<ExecutiveDashboardScreen> createState() => _ExecutiveDashboardScreenState();
}

class _ExecutiveDashboardScreenState extends State<ExecutiveDashboardScreen> {
  bool _showUsd = false;
  int _selectedTabIndex = 0;
  String _selectedRange = 'Today';

  static const List<String> _tabs = [
    'Executive Bento Grid',
    'Live KDS & Room Feed',
    'SLTDA & IRD Liabilities',
    'Top Dishes & Revenue',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final client = AppSyncClient();
    final metrics = client.getDashboardMetrics();
    final reservations = client.reservations;
    final rooms = client.rooms;
    final property = TenantEngine().currentProperty;

    final cleanCount = rooms.where((r) => r.status == RoomCleanStatus.clean).length;
    final inspectedCount = rooms.where((r) => r.status == RoomCleanStatus.inspected).length;
    final dirtyCount = rooms.where((r) => r.status == RoomCleanStatus.dirty).length;
    final maintCount = rooms.where((r) => r.status == RoomCleanStatus.maintenance).length;

    const double todayGrossLkr = 985600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header & Currency / Range Controls (Wrapped in Expanded so it NEVER overflows!)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTranslations.tr('dashboard'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${property.name} • UTC+05:30',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _showUsd = !_showUsd),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTheme.brandSurfaceTint(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.brandBorderTint(context)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.arrow_2_circlepath, size: 13, color: theme.primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            _showUsd ? 'USD' : 'LKR',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Scrollable Underline Tab Bar (`DashboardView.tsx`)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_tabs.length, (idx) {
                      final isSel = _selectedTabIndex == idx;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = idx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isSel ? theme.primaryColor : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                          child: Text(
                            _tabs[idx],
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                              color: isSel
                                  ? theme.primaryColor
                                  : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextSecondary),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Time Range Selector + Quick New Reservation CTA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSubtleSurface : const Color(0xFFEEF2EF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: ['Today', '7 Days', '30 Days'].map((range) {
                          final active = _selectedRange == range;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedRange = range),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: active
                                    ? (isDark ? AppTheme.darkSurface : Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                range,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                                  color: active
                                      ? (isDark ? Colors.white : AppTheme.lightTextPrimary)
                                      : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextSecondary),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.onNavigate != null)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => widget.onNavigate!('/express_checkin'),
                      icon: const Icon(CupertinoIcons.plus, size: 13),
                      label: const Text('Check-In', style: TextStyle(fontSize: 11.5)),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // 4. Four Executive KPI Bento Cards (2x2 Grid with Expanded Titles - Zero Overflow!)
              Row(
                children: [
                  Expanded(
                    child: _buildKpiBentoCard(
                      context,
                      title: AppTranslations.tr('occupancy_rate'),
                      value: '${metrics.occupancyRate}%',
                      subtitle: '${metrics.occupiedRooms} / ${metrics.totalRooms} Rooms In-House',
                      trend: '+4.2%',
                      icon: CupertinoIcons.bed_double_fill,
                      accentColor: const Color(0xFF0B6E4F),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildKpiBentoCard(
                      context,
                      title: AppTranslations.tr('adr_metric'),
                      value: _formatMoney(metrics.adrLkr),
                      subtitle: 'RevPAR: ${_formatMoney(metrics.revparLkr)}',
                      trend: '+5.8%',
                      icon: CupertinoIcons.chart_pie_fill,
                      accentColor: const Color(0xFF0284C7),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildKpiBentoCard(
                      context,
                      title: "Today's Gross Billing",
                      value: _formatMoney(todayGrossLkr),
                      subtitle: 'Room + F&B + Ayurveda Spa',
                      trend: '+14.2%',
                      icon: CupertinoIcons.money_dollar_circle_fill,
                      accentColor: const Color(0xFFD97706),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildKpiBentoCard(
                      context,
                      title: 'Arrivals & Departures',
                      value: '${metrics.arrivingToday} In / ${metrics.departingToday} Out',
                      subtitle: '${cleanCount + inspectedCount} Clean Rooms Ready',
                      trend: 'Live',
                      icon: CupertinoIcons.person_2_square_stack_fill,
                      accentColor: const Color(0xFF7C3AED),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 5. Today's Cumulative Revenue Trajectory + Housekeeping Status Bar
              LiquidGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Today's Cumulative Revenue Trajectory",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        MetricBadge(
                          label: _formatMoney(todayGrossLkr),
                          color: theme.primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 92,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildTrajectoryBar('06:00', 0.12, theme.primaryColor, isDark),
                          _buildTrajectoryBar('09:00', 0.28, theme.primaryColor, isDark),
                          _buildTrajectoryBar('12:00', 0.46, theme.primaryColor, isDark),
                          _buildTrajectoryBar('15:00', 0.62, theme.primaryColor, isDark),
                          _buildTrajectoryBar('18:00', 0.81, theme.primaryColor, isDark),
                          _buildTrajectoryBar('21:00', 0.94, theme.primaryColor, isDark),
                          _buildTrajectoryBar('Now', 1.0, const Color(0xFF10B981), isDark),
                        ],
                      ),
                    ),
                    const Divider(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Housekeeping Room Turnaround',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                          ),
                        ),
                        Text(
                          '${rooms.length} Total Rooms',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        MetricBadge(label: 'Clean: $cleanCount', color: const Color(0xFF16A34A), showDot: true),
                        MetricBadge(label: 'Inspected: $inspectedCount', color: const Color(0xFF0284C7), showDot: true),
                        MetricBadge(label: 'Dirty: $dirtyCount', color: const Color(0xFFDC2626), showDot: true),
                        MetricBadge(label: 'Maintenance: $maintCount', color: const Color(0xFFD97706), showDot: true),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 6. Today's F&B Meal Plan Headcount Planner (Overflow-proof Expanded columns)
              LiquidGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(CupertinoIcons.person_3_fill, size: 16, color: Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Today's F&B Meal Plan Headcount",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMealHeadcountItem(
                            'Breakfast',
                            '${metrics.breakfastCount}',
                            'BB/HB/FB/AI',
                            const Color(0xFFD97706),
                            isDark,
                          ),
                        ),
                        Container(width: 1, height: 42, color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder),
                        Expanded(
                          child: _buildMealHeadcountItem(
                            'Lunch',
                            '${metrics.lunchCount}',
                            'FB / AI Plans',
                            const Color(0xFF16A34A),
                            isDark,
                          ),
                        ),
                        Container(width: 1, height: 42, color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder),
                        Expanded(
                          child: _buildMealHeadcountItem(
                            'Dinner',
                            '${metrics.dinnerCount}',
                            'HB / FB / AI',
                            const Color(0xFF4F46E5),
                            isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 7. Top Revenue Dishes & Drinks (With Web Version Photography!)
              LiquidGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Top Revenue Dishes & Signature Drinks',
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
                        Text(
                          'F&B Kitchen',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTopDishRow(
                      context,
                      imagePath: WebAssets.dishCrabHoppers,
                      name: 'Jaffna Lagoon Crab Curry',
                      outlet: 'Ocean Terrace • 54 Portions',
                      revenueLkr: 142000,
                      progress: 1.0,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildTopDishRow(
                      context,
                      imagePath: WebAssets.dishCuttlefishArrack,
                      name: 'Ceylon Arrack Old Fashioned',
                      outlet: 'Sunset Verandah Bar • 41 Glasses',
                      revenueLkr: 96400,
                      progress: 0.68,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildTopDishRow(
                      context,
                      imagePath: WebAssets.dishCrabHoppers,
                      name: 'Crispy Egg Hoppers & Seeni Sambol',
                      outlet: 'In-Room Dining • 38 Sets',
                      revenueLkr: 62700,
                      progress: 0.45,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 8. SLTDA & IRD Statutory Tax Liabilities Summary (`DashboardView.tsx`)
              LiquidGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'SLTDA & IRD Statutory Tax Liabilities',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                            ),
                          ),
                        ),
                        const MetricBadge(label: 'Due in 12d', color: Color(0xFFD97706)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildLiabilityRow('10% Mandatory Service Charge Pool', 98560, isDark),
                    _buildLiabilityRow('1% SLTDA Tourism Development Levy (TDL)', 9856, isDark),
                    _buildLiabilityRow('2.5% Social Security Contribution (SSCL)', 27104, isDark),
                    _buildLiabilityRow('18% IRD RAMIS Value Added Tax (VAT)', 201726, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 9. Active Guest In-House & Check-Ins Roster
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Active Guest In-House & Check-Ins',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${reservations.length} Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ...reservations.map((res) {
                final isCheckedIn = res.status == 'CHECKED_IN';
                return LiquidGlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.brandSurfaceTint(context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.brandBorderTint(context)),
                            ),
                            child: Text(
                              'Room ${res.roomNumber}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              res.guestName,
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
                            label: res.status,
                            color: isCheckedIn ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                            showDot: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'NIC/Pass: ${res.nicOrPassport}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7).withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              res.mealPlan.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _formatMoney(res.totalAmountLkr),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMoney(num lkrAmount) {
    if (_showUsd) {
      return CurrencyEngine.formatUsd(CurrencyEngine.lkrToUsd(lkrAmount));
    }
    return CurrencyEngine.formatLkr(lkrAmount);
  }

  Widget _buildKpiBentoCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required String trend,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 15, color: accentColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrajectoryBar(String label, double ratio, Color color, bool isDark) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: FractionallySizedBox(
                heightFactor: ratio,
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withAlpha(isDark ? 200 : 220),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealHeadcountItem(
    String title,
    String count,
    String subtext,
    Color color,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopDishRow(
    BuildContext context, {
    required String imagePath,
    required String name,
    required String outlet,
    required double revenueLkr,
    required double progress,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        WebImageThumbnail(
          assetPath: imagePath,
          width: 44,
          height: 44,
          borderRadius: 10,
          fallbackIcon: CupertinoIcons.flame_fill,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatMoney(revenueLkr),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                outlet,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                borderRadius: BorderRadius.circular(4),
                backgroundColor: isDark ? AppTheme.darkSubtleSurface : AppTheme.lightMutedSurface,
                color: theme.primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiabilityRow(String label, double amountLkr, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatMoney(amountLkr),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
