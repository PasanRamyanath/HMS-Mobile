import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/l10n/translations.dart';
import '../../core/api/appsync_client.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/theme/app_theme.dart';
import '../../models/hotel_models.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

/// Web-Parity Front Desk, Rooms & Tariffs Master Hub (`FrontDeskPage.tsx` & `RoomsAndRatesPage.tsx`).
/// Implements all 6 Web Version tabs in a mobile-native workspace:
/// 1. 14-Day Tape Chart & Rack Grid (`TapeChartGrid.tsx`)
/// 2. Daily Arrivals, Departures & In-House Board + Guest CRM + Group Rooming (`FrontDeskDailyBoard.tsx`)
/// 3. Chauffeur & Driver Quarters Board (`DriverQuartersBoard.tsx` & `DriverDormManager.tsx`)
/// 4. Meal Plan Forecast (`RO/BB/HB/FB/AI`) (`MealPlanForecastCard.tsx`)
/// 5. Tourist Police B-Card Register (`PoliceBCardRegister.tsx`)
/// 6. DMC Contracts, Seasonal Tariffs, Child Policy & QR Standees (`DmcContractManager.tsx` & `RoomsAndRatesPage.tsx`)
class TapeChartScreen extends StatefulWidget {
  const TapeChartScreen({super.key});

  @override
  State<TapeChartScreen> createState() => _TapeChartScreenState();
}

class _TapeChartScreenState extends State<TapeChartScreen> {
  int _activeTab = 0;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 2));
  final int _dayCount = 14;
  int _selectedFloor = 0;

  final List<Map<String, dynamic>> _driverBeds = [
    {
      'bed': 'Bunk D-01 (AC Dorm)',
      'driver': 'Nalin Kumara',
      'phone': '+94 77 412 8890',
      'vehicle': 'WP CAA-4821 (KDH Van)',
      'guestRoom': 'Room 103 (Sophie V.)',
      'dmc': 'Aitken Spence Travels',
      'mealVoucher': true,
      'status': 'OCCUPIED',
    },
    {
      'bed': 'Bunk D-02 (AC Dorm)',
      'driver': 'Pradeep Silva',
      'phone': '+94 71 889 2310',
      'vehicle': 'WP CBE-9012 (Mercedes)',
      'guestRoom': 'Room 201 (Lord Campbell)',
      'dmc': 'Jetwing Travels',
      'mealVoucher': true,
      'status': 'OCCUPIED',
    },
    {
      'bed': 'Bunk D-03 (AC Dorm)',
      'driver': 'Vacant Bunk',
      'phone': '-',
      'vehicle': '-',
      'guestRoom': '-',
      'dmc': '-',
      'mealVoucher': false,
      'status': 'VACANT',
    },
    {
      'bed': 'Outside Allowance',
      'driver': 'Chaminda Perera',
      'phone': '+94 76 221 3344',
      'vehicle': 'SP KQ-1120 (Safari Jeep)',
      'guestRoom': 'Room 203 (H. Tanaka)',
      'dmc': 'Walkers Tours (LKR 2,500 Cash)',
      'mealVoucher': true,
      'status': 'ALLOWANCE_PAID',
    },
  ];

  static const List<String> _tabLabels = [
    '1. Tape Chart',
    '2. Daily Board & CRM',
    '3. Driver Quarters',
    '4. Meal Forecast',
    '5. Police B-Card',
    '6. DMC & Tariffs',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final client = AppSyncClient();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('tape_chart')),
        actions: [
          if (_activeTab == 0) ...[
            IconButton(
              icon: const Icon(CupertinoIcons.chevron_left, size: 17),
              tooltip: 'Previous Week',
              onPressed: () => setState(() => _startDate = _startDate.subtract(const Duration(days: 7))),
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.today, size: 17),
              tooltip: 'Today',
              onPressed: () => setState(() => _startDate = DateTime.now().subtract(const Duration(days: 2))),
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.chevron_right, size: 17),
              tooltip: 'Next Week',
              onPressed: () => setState(() => _startDate = _startDate.add(Duration(days: 7))),
            ),
          ],
          IconButton(
            icon: const Icon(CupertinoIcons.plus_circle_fill, size: 20),
            tooltip: 'New Reservation / Group Rooming',
            onPressed: () => _showNewReservationModal(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 6-Tab Sub-Module Bar (`FrontDeskPage.tsx`)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabLabels.length, (idx) {
                  final isSel = _activeTab == idx;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(_tabLabels[idx]),
                      selected: isSel,
                      onSelected: (v) {
                        if (v) setState(() => _activeTab = idx);
                      },
                    ),
                  );
                }),
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: _buildActiveTabBody(context, client, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabBody(BuildContext context, AppSyncClient client, bool isDark) {
    switch (_activeTab) {
      case 0:
        return _buildTapeChartTab(context, client, isDark);
      case 1:
        return _buildDailyBoardAndCrmTab(context, client, isDark);
      case 2:
        return _buildDriverQuartersTab(context, isDark);
      case 3:
        return _buildMealPlanForecastTab(context, client, isDark);
      case 4:
        return _buildPoliceBCardTab(context, client, isDark);
      case 5:
        return _buildDmcAndTariffsTab(context, client, isDark);
      default:
        return _buildTapeChartTab(context, client, isDark);
    }
  }

  // ===========================================================================
  // TAB 1: 14-DAY TAPE CHART
  // ===========================================================================
  Widget _buildTapeChartTab(BuildContext context, AppSyncClient client, bool isDark) {
    final theme = Theme.of(context);
    final allRooms = client.rooms;
    final rooms = _selectedFloor == 0
        ? allRooms
        : allRooms.where((r) => r.floor == _selectedFloor).toList();
    final reservations = client.reservations;

    final dates = List.generate(
      _dayCount,
      (index) => _startDate.add(Duration(days: index)),
    );

    final occupiedCount = allRooms.where((r) => r.isOccupied).length;
    final cleanCount = allRooms.where((r) => r.status == RoomCleanStatus.clean).length;
    final dirtyCount = allRooms.where((r) => r.status == RoomCleanStatus.dirty).length;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCanvas : AppTheme.lightCanvas,
            border: Border(
              bottom: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterFloorChip(0, 'All Floors (${allRooms.length})'),
                    const SizedBox(width: 6),
                    _filterFloorChip(1, 'Floor 1'),
                    const SizedBox(width: 6),
                    _filterFloorChip(2, 'Floor 2'),
                    const SizedBox(width: 10),
                    MetricBadge(label: 'Occupied: $occupiedCount', color: theme.primaryColor, showDot: true),
                    const SizedBox(width: 6),
                    MetricBadge(label: 'Clean: $cleanCount', color: const Color(0xFF16A34A), showDot: true),
                    const SizedBox(width: 6),
                    MetricBadge(label: 'Dirty: $dirtyCount', color: const Color(0xFFDC2626), showDot: true),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _legendItem('Clean', const Color(0xFF16A34A), isDark),
                    const SizedBox(width: 12),
                    _legendItem('Dirty', const Color(0xFFDC2626), isDark),
                    const SizedBox(width: 12),
                    _legendItem('Inspected', const Color(0xFF0284C7), isDark),
                    const SizedBox(width: 12),
                    _legendItem('Maintenance', const Color(0xFFD97706), isDark),
                    const SizedBox(width: 12),
                    _legendItem('In-House Stay', theme.primaryColor, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 132,
                        height: 50,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSubtleSurface : AppTheme.lightSubtleSurface,
                          border: Border.all(color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder),
                        ),
                        child: Text(
                          'Room / Category',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                          ),
                        ),
                      ),
                      ...dates.map((d) {
                        final isToday = d.day == DateTime.now().day && d.month == DateTime.now().month;
                        return Container(
                          width: 66,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppTheme.brandSurfaceTint(context)
                                : (isDark ? AppTheme.darkSubtleSurface : AppTheme.lightSubtleSurface),
                            border: Border.all(
                              color: isToday
                                  ? AppTheme.brandBorderTint(context)
                                  : (isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('E').format(d).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: isToday
                                      ? theme.primaryColor
                                      : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('dd MMM').format(d),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                                  color: isToday
                                      ? theme.primaryColor
                                      : (isDark ? Colors.white : AppTheme.lightTextPrimary),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                  ...rooms.map((room) {
                    Color statusColor;
                    switch (room.status) {
                      case RoomCleanStatus.clean:
                        statusColor = const Color(0xFF16A34A);
                        break;
                      case RoomCleanStatus.dirty:
                        statusColor = const Color(0xFFDC2626);
                        break;
                      case RoomCleanStatus.inspected:
                        statusColor = const Color(0xFF0284C7);
                        break;
                      case RoomCleanStatus.maintenance:
                        statusColor = const Color(0xFFD97706);
                        break;
                    }

                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showRoomDetailsModal(context, room, client),
                          child: Container(
                            width: 132,
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkSurface : Colors.white,
                              border: Border.all(color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Rm ${room.roomNumber}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12.5,
                                          color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  room.categoryName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ...dates.map((date) {
                          Reservation? matchingRes;
                          for (var r in reservations) {
                            if (r.roomNumber == room.roomNumber) {
                              if (!date.isBefore(DateTime(r.checkInDate.year, r.checkInDate.month, r.checkInDate.day)) &&
                                  !date.isAfter(DateTime(r.checkOutDate.year, r.checkOutDate.month, r.checkOutDate.day))) {
                                matchingRes = r;
                                break;
                              }
                            }
                          }

                          final hasBooking = matchingRes != null;
                          final isConfirmed = matchingRes?.status == 'CONFIRMED';

                          return GestureDetector(
                            onTap: () {
                              if (hasBooking) {
                                _showReservationModal(context, matchingRes!);
                              } else {
                                _showQuickBookModal(context, room, date);
                              }
                            },
                            child: Container(
                              width: 66,
                              height: 56,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkCanvas : Colors.white,
                                border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                              ),
                              alignment: Alignment.center,
                              child: hasBooking
                                  ? Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: isConfirmed ? const Color(0xFFD97706) : theme.primaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            matchingRes.guestName.split(' ').first,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            matchingRes.mealPlan.name.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        }),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TAB 2: DAILY ARRIVALS, DEPARTURES, IN-HOUSE BOARD & GUEST CRM
  // ===========================================================================
  Widget _buildDailyBoardAndCrmTab(BuildContext context, AppSyncClient client, bool isDark) {
    final theme = Theme.of(context);
    final reservations = client.reservations;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Daily Arrivals, Departures & Guest CRM',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(CupertinoIcons.person_3_fill, size: 14),
              label: const Text('Group Rooming'),
              onPressed: () => _showGroupRoomingModal(context),
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
                    MetricBadge(label: 'Room ${res.roomNumber}', color: theme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        res.guestName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                      ),
                    ),
                    MetricBadge(
                      label: res.status,
                      color: isCheckedIn ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                      showDot: true,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'ID: ${res.nicOrPassport} • Contact: ${res.guestContact} • Plan: ${res.mealPlan.name.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      icon: const Icon(CupertinoIcons.person_crop_rectangle, size: 13),
                      label: const Text('Guest CRM', style: TextStyle(fontSize: 11)),
                      onPressed: () => _showGuestCrmDrawer(context, res),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      icon: const Icon(CupertinoIcons.calendar_badge_plus, size: 13),
                      label: const Text('Modify Stay', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Stay extension / upgrade logged for ${res.guestName}')),
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      icon: Icon(
                        isCheckedIn ? CupertinoIcons.arrow_up_right_square : CupertinoIcons.checkmark_alt,
                        size: 13,
                      ),
                      label: Text(
                        isCheckedIn ? 'Check-Out' : 'Check-In Now',
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () {
                        setState(() {
                          res.status = isCheckedIn ? 'CHECKED_OUT' : 'CHECKED_IN';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${res.guestName} status updated to ${res.status}'),
                            backgroundColor: const Color(0xFF16A34A),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ===========================================================================
  // TAB 3: CHAUFFEUR & DRIVER QUARTERS BOARD (`DriverQuartersBoard.tsx`)
  // ===========================================================================
  Widget _buildDriverQuartersTab(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        LiquidGlassCard(
          padding: const EdgeInsets.all(14),
          backgroundColor: AppTheme.brandSurfaceTint(context),
          customBorder: Border.all(color: AppTheme.brandBorderTint(context)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sri Lanka Tourist Chauffeur & Driver Quarters Board',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
              SizedBox(height: 4),
              Text(
                'Manage complimentary AC driver bunk beds (D-01 to D-08), LKR 2,500 outside lodging allowances when full, and driver curry meal vouchers.',
                style: TextStyle(fontSize: 11.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ..._driverBeds.map((b) {
          final isOcc = b['status'] == 'OCCUPIED';
          return LiquidGlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        b['bed'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                    MetricBadge(
                      label: b['status'] as String,
                      color: isOcc ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                      showDot: true,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Driver: ${b['driver']} (${b['phone']}) • Vehicle: ${b['vehicle']}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  'Linked Guest: ${b['guestRoom']} • Agency: ${b['dmc']}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MetricBadge(
                      label: (b['mealVoucher'] as bool) ? 'Driver Meal Voucher Active' : 'No Voucher',
                      color: (b['mealVoucher'] as bool) ? theme.primaryColor : Colors.grey,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          b['mealVoucher'] = !(b['mealVoucher'] as bool);
                        });
                      },
                      child: const Text('Toggle Meal Pass', style: TextStyle(fontSize: 11.5)),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ===========================================================================
  // TAB 4: MEAL PLAN FORECAST (`MealPlanForecastCard.tsx`)
  // ===========================================================================
  Widget _buildMealPlanForecastTab(BuildContext context, AppSyncClient client, bool isDark) {
    final metrics = client.getDashboardMetrics();
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        LiquidGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Kitchen Meal Plan Forecast (RO / BB / HB / FB / AI)',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _mealCountTile('Breakfast', '${metrics.breakfastCount} Pax', 'BB/HB/FB/AI', const Color(0xFFD97706)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _mealCountTile('Lunch', '${metrics.lunchCount} Pax', 'FB / AI Plans', const Color(0xFF16A34A)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _mealCountTile('Dinner', '${metrics.dinnerCount} Pax', 'HB / FB / AI', const Color(0xFF4F46E5)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...client.reservations.map((res) {
          return LiquidGlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room ${res.roomNumber} — ${res.guestName}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${res.guestCount} Adults • Check-Out: ${DateFormat('dd MMM').format(res.checkOutDate)}',
                        style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                MetricBadge(
                  label: 'Plan: ${res.mealPlan.name.toUpperCase()}',
                  color: const Color(0xFF0284C7),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ===========================================================================
  // TAB 5: TOURIST POLICE B-CARD REGISTER (`PoliceBCardRegister.tsx`)
  // ===========================================================================
  Widget _buildPoliceBCardTab(BuildContext context, AppSyncClient client, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        LiquidGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Sri Lanka Tourist Police Form B-Card Register',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(CupertinoIcons.printer, size: 13),
                    label: const Text('Export B-Cards', style: TextStyle(fontSize: 11)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Statutory Tourist Police Form B-Card Register exported.')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Mandatory statutory register of foreign passports and local NICs under the Sri Lanka Tourism Development Act.',
                style: TextStyle(fontSize: 11.5, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...client.reservations.map((res) {
          final isForeign = !RegExp(r'^\d').hasMatch(res.nicOrPassport);
          return LiquidGlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        res.guestName,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                    MetricBadge(
                      label: isForeign ? 'FOREIGN PASSPORT' : 'SRI LANKAN NIC',
                      color: isForeign ? const Color(0xFF7C3AED) : const Color(0xFF0B6E4F),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Document No: ${res.nicOrPassport} • Room ${res.roomNumber}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Arrived From: ${isForeign ? "BIA Airport (UL-504)" : "Colombo"} • Next Dest: ${isForeign ? "Ella / Yala" : "Galle"}',
                  style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ===========================================================================
  // TAB 6: DMC CONTRACTS, SEASONAL TARIFFS, CHILD POLICY & QR STANDEES
  // ===========================================================================
  Widget _buildDmcAndTariffsTab(BuildContext context, AppSyncClient client, bool isDark) {
    final theme = Theme.of(context);
    final dmcs = [
      {'name': 'Aitken Spence Travels', 'code': 'DMC-AST-01', 'fitDiscount': '20% Off BAR', 'creditLimit': 2500000.0},
      {'name': 'Walkers Tours (John Keells)', 'code': 'DMC-WLK-02', 'fitDiscount': '22% Off BAR', 'creditLimit': 3000000.0},
      {'name': 'Jetwing Travels', 'code': 'DMC-JTW-03', 'fitDiscount': '18% Off BAR', 'creditLimit': 1800000.0},
    ];

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // Seasonal Bands Card (`SeasonalBandsEditor.tsx`)
        LiquidGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sri Lanka Seasonal Tariff Bands & Dual-Currency Matrix',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
              const SizedBox(height: 10),
              _seasonRow('Winter Peak (Dec 15 – Mar 31)', '1.35× Multiplier', const Color(0xFFDC2626)),
              _seasonRow('Kandy Esala Perahera / Aug Peak', '1.25× Multiplier', const Color(0xFFD97706)),
              _seasonRow('Shoulder Season (Apr / Oct–Nov)', '1.00× Base Rate', theme.primaryColor),
              _seasonRow('South-West Monsoon Green (May–Jul)', '0.80× Resident Promo', const Color(0xFF0284C7)),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Child Policy Card (`ChildPolicyCard.tsx`)
        LiquidGlassCard(
          padding: const EdgeInsets.all(16),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Statutory Child & Extra Bed Tariff Policy', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              SizedBox(height: 6),
              Text('• Infants (0–5 yrs): Stay & Buffet Meals 100% Complimentary (Baby Cot Free)'),
              Text('• Children (6–11 yrs): 50% Meal Plan Supplement • LKR 4,500 Extra Folding Bed'),
              Text('• 12+ yrs: Considered Adult for Meal Plan & Extra Bed Tariffs'),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // DMC Contracts (`DmcContractManager.tsx`)
        const Text('Contracted Destination Management Companies (DMCs)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
        const SizedBox(height: 6),
        ...dmcs.map((d) => LiquidGlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d['name'] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                        Text(
                          'Code: ${d['code']} • Credit Limit: ${CurrencyEngine.formatLkr(d['creditLimit'] as double)}',
                          style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  MetricBadge(label: d['fitDiscount'] as String, color: theme.primaryColor),
                ],
              ),
            )),
      ],
    );
  }

  Widget _seasonRow(String label, String badge, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          MetricBadge(label: badge, color: color),
        ],
      ),
    );
  }

  Widget _mealCountTile(String label, String count, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(count, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
          Text(sub, style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _filterFloorChip(int floor, String label) {
    final isSel = _selectedFloor == floor;
    return ChoiceChip(
      label: Text(label),
      selected: isSel,
      onSelected: (val) {
        if (val) setState(() => _selectedFloor = floor);
      },
    );
  }

  Widget _legendItem(String text, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  void _showGuestCrmDrawer(BuildContext context, Reservation res) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Guest CRM Profile — ${res.guestName}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                  const MetricBadge(label: 'VIP REPEAT GUEST', color: Color(0xFFD97706)),
                ],
              ),
              const Divider(height: 20),
              Text('NIC / Passport: ${res.nicOrPassport}'),
              Text('Phone / WhatsApp: ${res.guestContact}'),
              const Text('Lifetime Stays: 4 Stays (Galle Fort & Ella Cloud)'),
              const Text('Dietary & Room Preferences: High Floor, King Bed, Ceylon Cinnamon Tea, No Crustaceans'),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close CRM Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGroupRoomingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Group Tour & DMC Rooming List Import',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Batch assign rooms, meal plans (HB/FB), and chauffeur dorm beds for incoming DMC tour groups (Aitken Spence / Walkers Tours).',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(CupertinoIcons.checkmark_circle_fill, size: 16),
                  label: const Text('Auto-Assign 4 Group Rooms & 1 Driver Bunk'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('DMC Group Rooming List imported & keycards queued!'),
                        backgroundColor: Color(0xFF16A34A),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewReservationModal(BuildContext context) {
    final guestCtrl = TextEditingController(text: 'Anushka Wijeratne');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Fit / OTA / DMC Reservation', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 10),
              TextField(
                controller: guestCtrl,
                decoration: const InputDecoration(labelText: 'Guest Full Name *'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reservation created for ${guestCtrl.text}'),
                        backgroundColor: const Color(0xFF16A34A),
                      ),
                    );
                  },
                  child: const Text('Create Reservation & Send SMS Voucher'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoomDetailsModal(BuildContext context, Room room, AppSyncClient client) {
    final imgPath = WebAssets.roomImageForCategory(room.categoryName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WebHeroBannerCard(
                  assetPath: imgPath,
                  badgeText: 'Floor ${room.floor} • Max ${room.occupancyLimit} Guests',
                  rightPillText: room.status.name.toUpperCase(),
                  title: 'Room ${room.roomNumber} — ${room.categoryName}',
                  subtitle: '${CurrencyEngine.formatLkr(room.rateLkr)} / night (${CurrencyEngine.formatUsd(room.rateUsd)})',
                  height: 165,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Update Housekeeping Cleanliness Status:',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: RoomCleanStatus.values.map((s) {
                    return ChoiceChip(
                      label: Text(s.name.toUpperCase()),
                      selected: room.status == s,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            client.updateRoomCleanStatus(room.id, s);
                          });
                          Navigator.pop(ctx);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReservationModal(BuildContext context, Reservation res) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(res.guestName, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room: ${res.roomNumber}'),
            const SizedBox(height: 4),
            Text('NIC/Passport: ${res.nicOrPassport}'),
            const SizedBox(height: 4),
            Text('Contact: ${res.guestContact}'),
            const SizedBox(height: 4),
            Text('Meal Plan: ${res.mealPlan.name.toUpperCase()}'),
            const SizedBox(height: 4),
            Text('Stay: ${DateFormat('dd MMM').format(res.checkInDate)} – ${DateFormat('dd MMM').format(res.checkOutDate)}'),
            const SizedBox(height: 4),
            Text('Status: ${res.status}'),
            const SizedBox(height: 4),
            Text('Total Folio: ${CurrencyEngine.formatLkr(res.totalAmountLkr)}', style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cancellation / No-Show dialog processed for ${res.id}')),
              );
            },
            child: const Text('Cancel Stay', style: TextStyle(color: Color(0xFFDC2626))),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showQuickBookModal(BuildContext context, Room room, DateTime date) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room ${room.roomNumber} (${room.categoryName}) is available on ${DateFormat('dd MMM').format(date)}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
