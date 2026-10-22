import 'package:flutter/material.dart';
import '../../core/currency/currency_engine.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

class OtaChannel {
  final String name;
  final String iconLabel;
  final Color brandColor;
  final double commissionRate;
  bool isConnected;
  int activeBookings;
  double monthlyRevenueLkr;

  OtaChannel({
    required this.name,
    required this.iconLabel,
    required this.brandColor,
    required this.commissionRate,
    this.isConnected = true,
    required this.activeBookings,
    required this.monthlyRevenueLkr,
  });
}

class ChannelManagerScreen extends StatefulWidget {
  const ChannelManagerScreen({super.key});

  @override
  State<ChannelManagerScreen> createState() => _ChannelManagerScreenState();
}

class _ChannelManagerScreenState extends State<ChannelManagerScreen> {
  final List<OtaChannel> _channels = [
    OtaChannel(name: 'Booking.com', iconLabel: 'B.', brandColor: const Color(0xFF003580), commissionRate: 0.15, activeBookings: 8, monthlyRevenueLkr: 980000),
    OtaChannel(name: 'Agoda', iconLabel: 'agoda', brandColor: const Color(0xFF5392F9), commissionRate: 0.16, activeBookings: 5, monthlyRevenueLkr: 640000),
    OtaChannel(name: 'Airbnb', iconLabel: 'airbnb', brandColor: const Color(0xFFFF5A5F), commissionRate: 0.03, activeBookings: 3, monthlyRevenueLkr: 420000),
    OtaChannel(name: 'Direct Booking Engine', iconLabel: 'Direct', brandColor: const Color(0xFF0F5132), commissionRate: 0.0, activeBookings: 12, monthlyRevenueLkr: 1650000),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalOtaRev = _channels.fold(0.0, (sum, c) => sum + c.monthlyRevenueLkr);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('OTA Channels & Direct Web'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Channel Sync Status Card
          LiquidGlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('2-Way ARI Channel Sync', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Live Sync Active', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w700, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  CurrencyEngine.formatLkr(totalOtaRev),
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: theme.primaryColor),
                ),
                const SizedBox(height: 4),
                const Text('Monthly Combined Distribution Revenue (0% overbooking rate).', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          const Text('Connected Channels & Commission Rates', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 8),

          ..._channels.map((ch) {
            return LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: ch.brandColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ch.iconLabel,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(ch.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        ],
                      ),
                      Switch(
                        value: ch.isConnected,
                        onChanged: (val) {
                          setState(() => ch.isConnected = val);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${ch.name} ARI sync ${val ? "enabled" : "disabled"}')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Commission: ${(ch.commissionRate * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      MetricBadge(label: '${ch.activeBookings} Bookings', color: ch.brandColor),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Revenue (30 Days):', style: TextStyle(fontSize: 12)),
                      Text(CurrencyEngine.formatLkr(ch.monthlyRevenueLkr), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
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
