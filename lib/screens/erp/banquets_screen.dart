import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/l10n/translations.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/api/appsync_client.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

class BanquetsScreen extends StatelessWidget {
  const BanquetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final client = AppSyncClient();
    final banquets = client.banquets;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('weddings_poruwa')),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: banquets.length,
        itemBuilder: (context, index) {
          final event = banquets[index];
          return LiquidGlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event.clientName,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    MetricBadge(
                      label: event.status,
                      color: const Color(0xFF10B981),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.eventType,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(CupertinoIcons.location_solid, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(event.hallName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 12),
                    const Icon(CupertinoIcons.calendar, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(DateFormat('dd MMMM yyyy').format(event.eventDate), style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withAlpha(isDark ? 40 : 25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF59E0B).withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.star_fill, size: 14, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 6),
                      Text(
                        'Auspicious Nekath: ${event.auspiciousTime}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFD97706)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Headcount: ${event.guestCount} Guests', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('Total: ${CurrencyEngine.formatLkr(event.totalAmountLkr)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Deposit Paid: ${CurrencyEngine.formatLkr(event.depositPaidLkr)}', style: const TextStyle(fontSize: 11, color: Color(0xFF10B981))),
                    Text('Balance Due: ${CurrencyEngine.formatLkr(event.balanceDueLkr)}', style: const TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
