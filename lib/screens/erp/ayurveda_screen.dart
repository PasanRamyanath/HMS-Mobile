import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/l10n/translations.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/api/appsync_client.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

class AyurvedaScreen extends StatelessWidget {
  const AyurvedaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final client = AppSyncClient();
    final spaBookings = client.spaBookings;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('ayurveda_spa')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tridosha Overview Card
          LiquidGlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.leaf_arrow_circlepath, color: Color(0xFF059669)),
                    const SizedBox(width: 8),
                    const Text('Ayurvedic Tridosha Harmony', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDoshaBadge('Vata', 'Air & Space', const Color(0xFF0284C7)),
                    _buildDoshaBadge('Pitta', 'Fire & Water', const Color(0xFFEA580C)),
                    _buildDoshaBadge('Kapha', 'Earth & Water', const Color(0xFF16A34A)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Spa Appointments
          const Text('Scheduled Herbal Therapy Sessions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 8),

          ...spaBookings.map((spa) {
            return LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        spa.guestName,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      MetricBadge(label: 'Room ${spa.roomNumber}', color: theme.primaryColor),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    spa.treatmentName,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: theme.primaryColor),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          spa.doshaType,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF059669)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Therapist: ${spa.therapistName}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Time: ${DateFormat('hh:mm a').format(spa.scheduledTime)} (${spa.durationMinutes} min)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        CurrencyEngine.formatLkr(spa.priceLkr),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
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

  Widget _buildDoshaBadge(String name, String element, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withAlpha(90)),
          ),
          child: Text(name, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 13)),
        ),
        const SizedBox(height: 4),
        Text(element, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
