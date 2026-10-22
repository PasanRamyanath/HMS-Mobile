import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/currency/currency_engine.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

class ExcursionBooking {
  final String id;
  final String excursionName;
  final String guestName;
  final String roomNumber;
  final String time;
  final String vehicleOrDriver;
  final int persons;
  final double priceLkr;
  String status;

  ExcursionBooking({
    required this.id,
    required this.excursionName,
    required this.guestName,
    required this.roomNumber,
    required this.time,
    required this.vehicleOrDriver,
    required this.persons,
    required this.priceLkr,
    this.status = 'CONFIRMED',
  });
}

class ExcursionsScreen extends StatelessWidget {
  const ExcursionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bookings = [
      ExcursionBooking(
        id: 'EXC-01',
        excursionName: 'Mirissa Blue Whale Watching Cruise',
        guestName: 'Sophie Van Der Berg',
        roomNumber: '103',
        time: '05:30 AM (Tomorrow)',
        vehicleOrDriver: 'Luxury Van #WP-CAD-8921 (Driver: Nalin)',
        persons: 2,
        priceLkr: 28000,
      ),
      ExcursionBooking(
        id: 'EXC-02',
        excursionName: 'Airport Drop - Bandaranaike BIA Express',
        guestName: 'Lord Alistair Campbell',
        roomNumber: '201',
        time: '14:00 PM (Today)',
        vehicleOrDriver: 'Mercedes E-Class (Chauffeur: Pradeep)',
        persons: 2,
        priceLkr: 38000,
      ),
      ExcursionBooking(
        id: 'EXC-03',
        excursionName: 'Galle Fort UNESCO Sunset Heritage Walk',
        guestName: 'Dr. Michael Perera',
        roomNumber: '101',
        time: '16:30 PM (Today)',
        vehicleOrDriver: 'Licensed Heritage Guide: Anura',
        persons: 4,
        priceLkr: 12000,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Airport Transfers & Excursions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          LiquidGlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(CupertinoIcons.car_detailed, color: Color(0xFF0284C7)),
                    SizedBox(width: 8),
                    Text('Travel Desk & Chauffeur Dispatch', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Automated WhatsApp driver dispatch, SLTDA-certified tourist chauffeurs, and southern expressway transit passes.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          const Text('Active Dispatch & Excursion Schedules', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 8),

          ...bookings.map((b) {
            return LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(b.excursionName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      MetricBadge(label: 'Room ${b.roomNumber}', color: theme.primaryColor),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Guest: ${b.guestName} (${b.persons} Guests)', style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.clock, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(b.time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.car_fill, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(b.vehicleOrDriver, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total (Folio Billed):', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      Text(CurrencyEngine.formatLkr(b.priceLkr), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF10B981))),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
