import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/api/appsync_client.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

class ExecutiveDashboardScreen extends StatefulWidget {
  final Function(String route)? onNavigate;

  const ExecutiveDashboardScreen({super.key, this.onNavigate});

  @override
  State<ExecutiveDashboardScreen> createState() => _ExecutiveDashboardScreenState();
}

class _ExecutiveDashboardScreenState extends State<ExecutiveDashboardScreen> {
  bool _showUsd = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final client = AppSyncClient();
    final metrics = client.getDashboardMetrics();
    final reservations = client.reservations;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Currency Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTranslations.tr('dashboard'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ceylon Heritage Resort & Spa - Galle Fort',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showUsd = !_showUsd;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withAlpha(isDark ? 45 : 25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.primaryColor.withAlpha(isDark ? 100 : 80),
                          width: 1,
                        ),
                      ),
                      child: Row(
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
              const SizedBox(height: 16),

              // KPI Row 1: Occupancy & Available Rooms
              Row(
                children: [
                  Expanded(
                    child: LiquidGlassCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppTranslations.tr('occupancy_rate'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                ),
                              ),
                              const Icon(CupertinoIcons.bed_double_fill, size: 16, color: Color(0xFF10B981)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${metrics.occupancyRate}%',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${metrics.occupiedRooms} / ${metrics.totalRooms} Rooms Occupied',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LiquidGlassCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppTranslations.tr('adr_metric'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                ),
                              ),
                              const Icon(CupertinoIcons.chart_pie_fill, size: 16, color: Color(0xFF0284C7)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _showUsd
                                ? CurrencyEngine.formatUsd(CurrencyEngine.lkrToUsd(metrics.adrLkr))
                                : CurrencyEngine.formatLkr(metrics.adrLkr),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'RevPAR: ${_showUsd ? CurrencyEngine.formatUsd(CurrencyEngine.lkrToUsd(metrics.revparLkr)) : CurrencyEngine.formatLkr(metrics.revparLkr)}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Headcount Forecast Planner
              LiquidGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(CupertinoIcons.person_3_fill, size: 16, color: Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        Text(
                          'Today\'s F&B Meal Plan Headcount',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMealHeadcountItem('Breakfast', '${metrics.breakfastCount}', 'BB/HB/FB/AI', const Color(0xFFF59E0B), isDark),
                        Container(width: 1, height: 40, color: isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
                        _buildMealHeadcountItem('Lunch', '${metrics.lunchCount}', 'FB / AI Packages', const Color(0xFF10B981), isDark),
                        Container(width: 1, height: 40, color: isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
                        _buildMealHeadcountItem('Dinner', '${metrics.dinnerCount}', 'HB / FB / AI Plated', const Color(0xFF6366F1), isDark),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // In-House Guest Operations
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Guest In-House & Check-Ins',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '${reservations.length} Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Reservations List
              ...reservations.map((res) {
                final isCheckedIn = res.status == 'CHECKED_IN';
                return LiquidGlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withAlpha(isDark ? 50 : 25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Room ${res.roomNumber}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                res.guestName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          MetricBadge(
                            label: res.status,
                            color: isCheckedIn ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'NIC/Pass: ${res.nicOrPassport}',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : const Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              res.mealPlan.name.toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF3B82F6)),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _showUsd
                                ? CurrencyEngine.formatUsd(CurrencyEngine.lkrToUsd(res.totalAmountLkr))
                                : CurrencyEngine.formatLkr(res.totalAmountLkr),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealHeadcountItem(String title, String count, String subtext, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtext,
          style: TextStyle(
            fontSize: 9,
            color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
