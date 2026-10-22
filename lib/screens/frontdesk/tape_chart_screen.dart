import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/l10n/translations.dart';
import '../../core/api/appsync_client.dart';
import '../../models/hotel_models.dart';
import '../../widgets/liquid_glass_card.dart';

class TapeChartScreen extends StatefulWidget {
  const TapeChartScreen({super.key});

  @override
  State<TapeChartScreen> createState() => _TapeChartScreenState();
}

class _TapeChartScreenState extends State<TapeChartScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 2));
  final int _dayCount = 14;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final client = AppSyncClient();
    final rooms = client.rooms;
    final reservations = client.reservations;

    final dates = List.generate(
      _dayCount,
      (index) => _startDate.add(Duration(days: index)),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('tape_chart')),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.chevron_left),
            tooltip: 'Previous Week',
            onPressed: () {
              setState(() {
                _startDate = _startDate.subtract(const Duration(days: 7));
              });
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.today),
            tooltip: 'Today',
            onPressed: () {
              setState(() {
                _startDate = DateTime.now().subtract(const Duration(days: 2));
              });
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.chevron_right),
            tooltip: 'Next Week',
            onPressed: () {
              setState(() {
                _startDate = _startDate.add(Duration(days: 7));
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tape Chart Legend
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131D2E) : Colors.white,
              border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0))),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _legendItem('Clean', const Color(0xFF10B981)),
                  const SizedBox(width: 12),
                  _legendItem('Dirty', const Color(0xFFEF4444)),
                  const SizedBox(width: 12),
                  _legendItem('Inspected', const Color(0xFF0284C7)),
                  const SizedBox(width: 12),
                  _legendItem('Maintenance', const Color(0xFFF59E0B)),
                  const SizedBox(width: 12),
                  _legendItem('Reserved / Occupied', const Color(0xFF6366F1)),
                ],
              ),
            ),
          ),

          // Timeline Grid
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Header Row
                    Row(
                      children: [
                        Container(
                          width: 110,
                          height: 48,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF090D16) : const Color(0xFFF1F5F9),
                            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                          ),
                          child: const Text('Room', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                        ...dates.map((d) {
                          final isToday = d.day == DateTime.now().day && d.month == DateTime.now().month;
                          return Container(
                            width: 64,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isToday
                                  ? theme.primaryColor.withAlpha(isDark ? 60 : 35)
                                  : (isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC)),
                              border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('E').format(d).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: isToday ? theme.primaryColor : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                                  ),
                                ),
                                Text(
                                  DateFormat('dd').format(d),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                                    color: isToday ? theme.primaryColor : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),

                    // Room Rows
                    ...rooms.map((room) {
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

                      return Row(
                        children: [
                          // Room Info Column
                          GestureDetector(
                            onTap: () => _showRoomDetailsModal(context, room, client),
                            child: Container(
                              width: 110,
                              height: 52,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF131D2E) : Colors.white,
                                border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
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
                                      const SizedBox(width: 5),
                                      Text(
                                        room.roomNumber,
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    room.categoryName.split(' ')[0],
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : const Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Days Cells
                          ...dates.map((date) {
                            // Find matching reservation
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

                            return GestureDetector(
                              onTap: () {
                                if (hasBooking) {
                                  _showReservationModal(context, matchingRes!);
                                } else {
                                  _showQuickBookModal(context, room, date);
                                }
                              },
                              child: Container(
                                width: 64,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: hasBooking
                                      ? const Color(0xFF6366F1).withAlpha(isDark ? 160 : 210)
                                      : (isDark ? const Color(0xFF0F172A) : Colors.white),
                                  border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                                ),
                                alignment: Alignment.center,
                                child: hasBooking
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2),
                                        child: Text(
                                          matchingRes.guestName.split(' ').first,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
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
      ),
    );
  }

  Widget _legendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _showRoomDetailsModal(BuildContext context, Room room, AppSyncClient client) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return LiquidGlassCard(
          margin: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Room ${room.roomNumber} - ${room.categoryName}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text('Floor ${room.floor} | Max Occupancy: ${room.occupancyLimit} Guests'),
              Text('Daily Rate: LKR ${room.rateLkr.toStringAsFixed(0)} (USD ${room.rateUsd})'),
              const SizedBox(height: 14),
              const Text('Update Cleanliness Status:', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
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
        );
      },
    );
  }

  void _showReservationModal(BuildContext context, Reservation res) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(res.guestName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room: ${res.roomNumber}'),
            Text('NIC/Passport: ${res.nicOrPassport}'),
            Text('Contact: ${res.guestContact}'),
            Text('Meal Plan: ${res.mealPlan.name.toUpperCase()}'),
            Text('Dates: ${DateFormat('dd MMM').format(res.checkInDate)} - ${DateFormat('dd MMM').format(res.checkOutDate)}'),
            Text('Status: ${res.status}'),
            Text('Total: LKR ${res.totalAmountLkr.toStringAsFixed(0)}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showQuickBookModal(BuildContext context, Room room, DateTime date) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room ${room.roomNumber} is vacant on ${DateFormat('dd MMM').format(date)}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
