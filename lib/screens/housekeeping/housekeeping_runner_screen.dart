import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/api/appsync_client.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/theme/app_theme.dart';
import '../../models/hotel_models.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

/// Web-Parity Master Housekeeping, Laundry, Engineering & Sustainability Hub
/// (`HousekeepingAdminPage.tsx` & `HousekeepingMobileView.tsx`).
/// Implements all 6 Web Version tabs in a mobile-first workspace:
/// 1. Room Turnaround & Attendant Assignments + Discrepancy Alert + Supervisor Inspect + Minibar Log
/// 2. Evening Turndown Service & Guest Amenity Queue (`TurndownServiceView.tsx` & `HkAmenityQueue.tsx`)
/// 3. Guest & Hotel Linen Laundry Pipeline (`LaundryTrackerView.tsx` & `LinenInventoryCard.tsx`)
/// 4. Engineering & Preventive Maintenance Tickets (`MaintenanceTicketBoard.tsx`)
/// 5. Lost & Found Register + Pool Towel Tracker (`LostAndFoundView.tsx` & `PoolTowelTracker.tsx`)
/// 6. CEB/Generator Utilities, Deep Clean & Eco-Refills (`UtilityMeterCard.tsx`, `DeepCleanSchedule.tsx`, `AmenityUsageCard.tsx`)
class HousekeepingRunnerScreen extends StatefulWidget {
  const HousekeepingRunnerScreen({super.key});

  @override
  State<HousekeepingRunnerScreen> createState() => _HousekeepingRunnerScreenState();
}

class _HousekeepingRunnerScreenState extends State<HousekeepingRunnerScreen> {
  int _activeTab = 0;
  String _filter = 'ALL';
  bool _discrepancyResolved = false;

  static const List<String> _tabs = [
    '1. Room Runner',
    '2. Turndown & Amenities',
    '3. Laundry & Linen',
    '4. Maintenance',
    '5. Lost/Found & Towels',
    '6. Utilities & Eco',
  ];

  final List<Map<String, dynamic>> _maintenanceTickets = [
    {
      'id': 'MNT-401',
      'room': 'Room 202',
      'issue': 'Daikin Inverter AC Compressor Low Cooling',
      'priority': 'URGENT',
      'technician': 'Roshan (HVAC)',
      'status': 'IN_PROGRESS',
    },
    {
      'id': 'MNT-402',
      'room': 'Pool Deck',
      'issue': 'Infinity Edge Salt-Chlorinator Pump Calibration',
      'priority': 'NORMAL',
      'technician': 'Chamara (Plumbing)',
      'status': 'OPEN',
    },
    {
      'id': 'MNT-403',
      'room': 'Room 104',
      'issue': 'Brass Rain-Shower Mixer Valve Seal Replacement',
      'priority': 'LOW',
      'technician': 'Chamara (Plumbing)',
      'status': 'RESOLVED',
    },
  ];

  final List<Map<String, dynamic>> _turndownQueue = [
    {'room': 'Room 101', 'guest': 'Dr. Michael Perera', 'req': 'Ceylon Citronella Coil & 2 Extra King Pillows', 'done': false},
    {'room': 'Room 103', 'guest': 'Sophie Van Der Berg', 'req': 'EveningTurndown + Herbal Jasmine Mist + Ice Bucket', 'done': true},
    {'room': 'Room 201', 'guest': 'Lord Alistair Campbell', 'req': 'Four-Poster Mosquito Net Draping & Camomile Tea', 'done': false},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final client = AppSyncClient();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('housekeeping')),
        actions: [
          IconButton(
            tooltip: 'Printable HK Floor Sheet',
            icon: const Icon(CupertinoIcons.printer, size: 18),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Daily Attendant Floor Assignment Clipboard Sheet printed.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 6-Tab Housekeeping Sub-Module Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              border: Border(
                bottom: BorderSide(color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (idx) {
                  final isSel = _activeTab == idx;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(_tabs[idx]),
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

          Expanded(
            child: _buildActiveTab(context, client, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTab(BuildContext context, AppSyncClient client, bool isDark) {
    switch (_activeTab) {
      case 0:
        return _buildRoomRunnerTab(context, client, isDark);
      case 1:
        return _buildTurndownAndAmenitiesTab(context, isDark);
      case 2:
        return _buildLaundryAndLinenTab(context, isDark);
      case 3:
        return _buildMaintenanceTab(context, isDark);
      case 4:
        return _buildLostFoundAndTowelsTab(context, isDark);
      case 5:
        return _buildUtilitiesAndEcoTab(context, isDark);
      default:
        return _buildRoomRunnerTab(context, client, isDark);
    }
  }

  // ===========================================================================
  // TAB 1: ROOM RUNNER, DISCREPANCY BAR, SUPERVISOR INSPECT & MINIBAR LOG
  // ===========================================================================
  Widget _buildRoomRunnerTab(BuildContext context, AppSyncClient client, bool isDark) {
    final rooms = client.rooms;
    final filtered = _filter == 'ALL'
        ? rooms
        : rooms.where((r) => r.status.name.toUpperCase() == _filter).toList();

    final cleanCount = rooms.where((r) => r.status == RoomCleanStatus.clean).length;
    final dirtyCount = rooms.where((r) => r.status == RoomCleanStatus.dirty).length;
    final inspectedCount = rooms.where((r) => r.status == RoomCleanStatus.inspected).length;

    return Column(
      children: [
        // Discrepancy Alert Banner (`DiscrepancyAlertBar.tsx`)
        if (!_discrepancyResolved)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFFDC2626).withAlpha(isDark ? 45 : 20),
            child: Row(
              children: [
                const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Color(0xFFDC2626), size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Discrepancy Alert: Room 102 marked Vacant at Front Desk but luggage spotted by Attendant.',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _discrepancyResolved = true),
                  child: const Text('Resolve', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),

        // Filter Chips
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                MetricBadge(label: 'Clean: $cleanCount', color: const Color(0xFF16A34A), showDot: true),
                const SizedBox(width: 6),
                MetricBadge(label: 'Inspected: $inspectedCount', color: const Color(0xFF0284C7), showDot: true),
                const SizedBox(width: 6),
                MetricBadge(label: 'Dirty: $dirtyCount', color: const Color(0xFFDC2626), showDot: true),
                const SizedBox(width: 10),
                ...['ALL', 'DIRTY', 'CLEAN', 'INSPECTED', 'MAINTENANCE'].map((f) {
                  final isSel = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setState(() => _filter = f);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final room = filtered[index];
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

              final imgPath = WebAssets.roomImageForCategory(room.categoryName);

              return LiquidGlassCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        WebImageThumbnail(
                          assetPath: imgPath,
                          width: 48,
                          height: 48,
                          borderRadius: 10,
                          fallbackIcon: CupertinoIcons.bed_double_fill,
                          fallbackColor: statusColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor.withAlpha(isDark ? 40 : 22),
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(color: statusColor.withAlpha(90)),
                                    ),
                                    child: Text(
                                      'Room ${room.roomNumber}',
                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: statusColor),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      room.categoryName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
                                        color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                room.isOccupied
                                    ? 'Occupied by: ${room.currentGuestName ?? "In-House Guest"} • Floor ${room.floor}'
                                    : 'Vacant — Ready for Turnover • Floor ${room.floor}',
                                maxLines: 1,
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
                        MetricBadge(
                          label: room.status.name.toUpperCase(),
                          color: statusColor,
                          showDot: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatusButton('Mark Clean', RoomCleanStatus.clean, const Color(0xFF16A34A), room, client),
                        const SizedBox(width: 6),
                        _buildStatusButton('Mark Inspected', RoomCleanStatus.inspected, const Color(0xFF0284C7), room, client),
                        const SizedBox(width: 6),
                        _buildStatusButton('Mark Dirty', RoomCleanStatus.dirty, const Color(0xFFDC2626), room, client),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            style: TextButton.styleFrom(minimumSize: const Size(0, 32), padding: EdgeInsets.zero),
                            icon: const Icon(CupertinoIcons.checkmark_shield, size: 13),
                            label: const Text('Supervisor Inspect Checklist', style: TextStyle(fontSize: 11)),
                            onPressed: () => _showSupervisorInspectModal(context, room, client),
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            style: TextButton.styleFrom(minimumSize: const Size(0, 32), padding: EdgeInsets.zero),
                            icon: const Icon(CupertinoIcons.cube_box, size: 13),
                            label: const Text('Log Minibar Items', style: TextStyle(fontSize: 11)),
                            onPressed: () => _showMinibarLoggerModal(context, room),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TAB 2: EVENING TURNDOWN & AMENITY QUEUE
  // ===========================================================================
  Widget _buildTurndownAndAmenitiesTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const LiquidGlassCard(
          padding: EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Evening Turndown Service & Guest Amenity Queue', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              SizedBox(height: 4),
              Text('18:00–21:00 SLST tropical mosquito net draping, citronella coils, and express pillow/towel requests.', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ..._turndownQueue.map((item) {
          final isDone = item['done'] as bool;
          return LiquidGlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item['room']} — ${item['guest']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 3),
                      Text(item['req'] as String, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDone ? const Color(0xFF16A34A) : Theme.of(context).primaryColor,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () => setState(() => item['done'] = !isDone),
                  child: Text(isDone ? 'Completed ✓' : 'Complete'),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ===========================================================================
  // TAB 3: LAUNDRY PIPELINE & LINEN PAR INVENTORY
  // ===========================================================================
  Widget _buildLaundryAndLinenTab(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        LiquidGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('600GSM Egyptian Cotton Linen Par-Stock Inventory', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              const SizedBox(height: 10),
              _linenRow('King Fitted Sheets (300TC)', '54 Clean • 18 In-Wash • 4 Damaged', theme.primaryColor),
              _linenRow('Bath Towels (600GSM White)', '120 Clean • 32 In-Wash • 2 Stained', const Color(0xFF16A34A)),
              _linenRow('Striped Pool & Beach Towels', '85 Clean • 24 Issued at Pool', const Color(0xFF0284C7)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        LiquidGlassCard(
          padding: const EdgeInsets.all(16),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Active Guest Valet Laundry Jobs', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              SizedBox(height: 8),
              Text('• BAG #LND-88 (Room 101): 3 Linen Shirts, 2 Trousers — Stage: STEAM PRESSING (Express 4-Hr)'),
              SizedBox(height: 6),
              Text('• BAG #LND-89 (Room 201): 2 Silk Evening Dresses — Stage: DELICATE DRYING'),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TAB 4: ENGINEERING & PREVENTIVE MAINTENANCE TICKETS
  // ===========================================================================
  Widget _buildMaintenanceTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text('Engineering & Preventive Maintenance Board', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 34), padding: const EdgeInsets.symmetric(horizontal: 10)),
              icon: const Icon(CupertinoIcons.plus, size: 13),
              label: const Text('New Ticket', style: TextStyle(fontSize: 11.5)),
              onPressed: () {
                setState(() {
                  _maintenanceTickets.insert(0, {
                    'id': 'MNT-${400 + _maintenanceTickets.length + 1}',
                    'room': 'Room 102',
                    'issue': 'Balcony Sliding Door Lock Lubrication',
                    'priority': 'NORMAL',
                    'technician': 'Roshan (Engineering)',
                    'status': 'OPEN',
                  });
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._maintenanceTickets.map((t) => LiquidGlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MetricBadge(
                        label: '${t['id']} • ${t['room']}',
                        color: t['priority'] == 'URGENT' ? const Color(0xFFDC2626) : const Color(0xFF0284C7),
                      ),
                      const Spacer(),
                      MetricBadge(label: t['status'] as String, color: const Color(0xFFD97706)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(t['issue'] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                  const SizedBox(height: 3),
                  Text('Assigned Technician: ${t['technician']}', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                ],
              ),
            )),
      ],
    );
  }

  // ===========================================================================
  // TAB 5: LOST & FOUND REGISTER + POOL TOWEL TRACKER
  // ===========================================================================
  Widget _buildLostFoundAndTowelsTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const LiquidGlassCard(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lost & Found Custody Register', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              SizedBox(height: 8),
              Text('• LF-201 (Room 104 Checkout): Apple AirPods Pro 2 Case — Locked in HK Safe #2 (Guest Notified via WhatsApp)'),
              SizedBox(height: 6),
              Text('• LF-202 (Ocean Terrace): Ray-Ban Polarized Sunglasses — Claimed & Signed by Room 201'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const LiquidGlassCard(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Infinity Pool & Beach Towel Tracker', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              SizedBox(height: 8),
              Text('• Room 101: 2 Towels Issued (09:30 AM) — Status: Returned ✓'),
              SizedBox(height: 6),
              Text('• Room 103: 2 Towels Issued (11:15 AM) — Status: Active at Cabana 2'),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TAB 6: CEB/GENERATOR UTILITIES, DEEP CLEAN & ECO-REFILLS
  // ===========================================================================
  Widget _buildUtilitiesAndEcoTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const LiquidGlassCard(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CEB Grid Electricity, Diesel Generator & NWSDB Water Meters', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              SizedBox(height: 8),
              Text('• CEB Peak/Off-Peak Today: 412 kWh • Rooftop Solar Offset: 148 kWh (36%)'),
              Text('• Cummins 150kVA Standby Generator: 0.5 hrs Run Today • Diesel Tank: 78% (620L)'),
              Text('• NWSDB Sump & Overhead Water Storage: 94% Capacity (28,000 Liters)'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const LiquidGlassCard(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sustainability & Ceramic Eco-Dispenser Impact', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              SizedBox(height: 8),
              Text('• Single-Use Plastic Mini-Bottles Avoided This Month: 1,420 Bottles'),
              Text('• Monsoon Deep-Clean & Anti-Mold Dehumidification: Completed for Ground Floor Villas'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _linenRow(String name, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700))),
          MetricBadge(label: status, color: color),
        ],
      ),
    );
  }

  void _showSupervisorInspectModal(BuildContext context, Room room, AppSyncClient client) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Supervisor 12-Point Inspection — Room ${room.roomNumber}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const Divider(height: 18),
              const Text('✓ Crisp 300TC Linen & Four-Poster Canopy Checked'),
              const Text('✓ Ceylon Artisan Tea Bar & Ceramic Dispensers Refilled'),
              const Text('✓ AC Filter, Rain Shower Pressure & Safe Unlocked'),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      client.updateRoomCleanStatus(room.id, RoomCleanStatus.inspected);
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Approve & Release Room to Front Desk'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMinibarLoggerModal(BuildContext context, Room room) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Minibar Consumption Logger — Room ${room.roomNumber}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const Divider(height: 18),
              Text('• 2x Lion Lager Can 330ml (${CurrencyEngine.formatLkr(1900)})'),
              Text('• 1x Ceylon Roasted Cashews 100g (${CurrencyEngine.formatLkr(1450)})'),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Minibar charges (LKR 3,350) posted directly to Room ${room.roomNumber} Folio!'),
                        backgroundColor: const Color(0xFF16A34A),
                      ),
                    );
                  },
                  child: const Text('Post LKR 3,350 to Guest Room Folio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(
    String label,
    RoomCleanStatus targetStatus,
    Color color,
    Room room,
    AppSyncClient client,
  ) {
    final isCurrent = room.status == targetStatus;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          backgroundColor: isCurrent ? color.withAlpha(28) : null,
          side: BorderSide(color: isCurrent ? color : Colors.grey.withAlpha(80)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        onPressed: () {
          setState(() {
            client.updateRoomCleanStatus(room.id, targetStatus);
          });
        },
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isCurrent ? color : null,
          ),
        ),
      ),
    );
  }
}
