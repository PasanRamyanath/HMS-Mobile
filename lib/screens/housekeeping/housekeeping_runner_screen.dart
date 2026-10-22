import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/api/appsync_client.dart';
import '../../models/hotel_models.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

class HousekeepingRunnerScreen extends StatefulWidget {
  const HousekeepingRunnerScreen({super.key});

  @override
  State<HousekeepingRunnerScreen> createState() => _HousekeepingRunnerScreenState();
}

class _HousekeepingRunnerScreenState extends State<HousekeepingRunnerScreen> {
  String _filter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final client = AppSyncClient();
    final rooms = client.rooms;

    final filtered = _filter == 'ALL'
        ? rooms
        : rooms.where((r) => r.status.name.toUpperCase() == _filter).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('housekeeping')),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: isDark ? const Color(0xFF131D2E) : Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['ALL', 'DIRTY', 'CLEAN', 'INSPECTED', 'MAINTENANCE'].map((f) {
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
                }).toList(),
              ),
            ),
          ),

          // Room Cleanliness List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final room = filtered[index];
                Color statusColor;
                switch (room.status) {
                  case RoomCleanStatus.clean:
                    statusColor = const Color(0xFF10B981);
                    break;
                  case RoomCleanStatus.dirty:
                    statusColor = const Color(0xFFEF4444);
                    break;
                  case RoomCleanStatus.inspected:
                    statusColor = const Color(0xFF0284C7);
                    break;
                  case RoomCleanStatus.maintenance:
                    statusColor = const Color(0xFFF59E0B);
                    break;
                }

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
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: statusColor.withAlpha(isDark ? 40 : 25),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: statusColor.withAlpha(90)),
                                ),
                                child: Text(
                                  'Room ${room.roomNumber}',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: statusColor),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                room.categoryName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          MetricBadge(
                            label: room.status.name.toUpperCase(),
                            color: statusColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        room.isOccupied
                            ? 'Occupied by: ${room.currentGuestName ?? "In-House Guest"}'
                            : 'Vacant - Ready for Turnover',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Quick Toggle Row
                      Row(
                        children: [
                          _buildStatusButton('Mark Clean', RoomCleanStatus.clean, const Color(0xFF10B981), room, client),
                          const SizedBox(width: 8),
                          _buildStatusButton('Mark Inspected', RoomCleanStatus.inspected, const Color(0xFF0284C7), room, client),
                          const SizedBox(width: 8),
                          _buildStatusButton('Mark Dirty', RoomCleanStatus.dirty, const Color(0xFFEF4444), room, client),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String label, RoomCleanStatus targetStatus, Color color, Room room, AppSyncClient client) {
    final isCurrent = room.status == targetStatus;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          backgroundColor: isCurrent ? color.withAlpha(35) : null,
          side: BorderSide(color: isCurrent ? color : Colors.grey.withAlpha(80)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
