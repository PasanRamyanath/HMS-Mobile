import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/theme/app_theme.dart';
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

/// Web-Parity Channex 2-Way ARI OTA Channel Manager, Stop-Sell Restrictions, Commissions & Bank Promos
/// (`ChannelsAndDirectPage.tsx`, `QuickRestrictionsBar.tsx`, `OtaCommissionTable.tsx`, `BankPromoManager.tsx`, `WebhookLogDrawer.tsx`).
/// Implements all 5 Web Version tabs:
/// 1. OTAs & Channex 2-Way ARI Sync
/// 2. Stop-Sell, CTA/CTD & MinLOS Quick Restrictions
/// 3. OTA Commission Reconciliation Table
/// 4. Sri Lankan Bank Card Promotions (`Sampath 25%`, `ComBank 20%`, `HNB 15%`)
/// 5. Direct Booking Widget & Embed Code Generator
class ChannelManagerScreen extends StatefulWidget {
  const ChannelManagerScreen({super.key});

  @override
  State<ChannelManagerScreen> createState() => _ChannelManagerScreenState();
}

class _ChannelManagerScreenState extends State<ChannelManagerScreen> {
  int _activeTab = 0;
  bool _stopSellDeluxe = false;
  bool _ctaColonial = false;
  int _minLosNights = 2;

  static const List<String> _tabs = [
    '1. OTAs & ARI Sync',
    '2. Stop-Sell & MinLOS',
    '3. OTA Commissions',
    '4. SL Bank Promos',
    '5. Direct Widget',
  ];

  final List<OtaChannel> _channels = [
    OtaChannel(
      name: 'Booking.com',
      iconLabel: 'B.',
      brandColor: const Color(0xFF003580),
      commissionRate: 0.15,
      activeBookings: 8,
      monthlyRevenueLkr: 980000,
    ),
    OtaChannel(
      name: 'Agoda',
      iconLabel: 'agoda',
      brandColor: const Color(0xFF5392F9),
      commissionRate: 0.16,
      activeBookings: 5,
      monthlyRevenueLkr: 640000,
    ),
    OtaChannel(
      name: 'Airbnb',
      iconLabel: 'airbnb',
      brandColor: const Color(0xFFFF5A5F),
      commissionRate: 0.03,
      activeBookings: 3,
      monthlyRevenueLkr: 420000,
    ),
    OtaChannel(
      name: 'Direct Booking Engine',
      iconLabel: 'Direct',
      brandColor: const Color(0xFF0B6E4F),
      commissionRate: 0.0,
      activeBookings: 12,
      monthlyRevenueLkr: 1650000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('OTA Channels & Direct Web'),
        actions: [
          IconButton(
            tooltip: 'Channex ARI Webhook Logs',
            icon: const Icon(CupertinoIcons.bolt_horizontal_circle_fill, size: 19),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Channex ARI Webhook Log: 142 sync events (100% HTTP 200 OK).')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(_tabs[idx]),
                      selected: _activeTab == idx,
                      onSelected: (_) => setState(() => _activeTab = idx),
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: _buildTabContent(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final totalOtaRev = _channels.fold(0.0, (sum, c) => sum + c.monthlyRevenueLkr);

    switch (_activeTab) {
      case 0:
        return ListView(
          padding: const EdgeInsets.all(14),
          children: [
            LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: AppTheme.brandSurfaceTint(context),
              customBorder: Border.all(color: AppTheme.brandBorderTint(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Channex 2-Way ARI Channel Sync',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const MetricBadge(label: '2-Way Live', color: Color(0xFF16A34A), showDot: true),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    CurrencyEngine.formatLkr(totalOtaRev),
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 25, color: theme.primaryColor),
                  ),
                  const SizedBox(height: 4),
                  const Text('Monthly Combined Distribution Revenue • 0% Overbooking Rate.'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ..._channels.map((ch) => LiquidGlassCard(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: ch.brandColor, borderRadius: BorderRadius.circular(8)),
                            child: Text(ch.iconLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11.5)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(ch.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5))),
                          Switch(
                            value: ch.isConnected,
                            activeTrackColor: theme.primaryColor,
                            onChanged: (val) => setState(() => ch.isConnected = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
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
                          const Text('Gross Revenue (30 Days):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(CurrencyEngine.formatLkr(ch.monthlyRevenueLkr), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5)),
                        ],
                      ),
                    ],
                  ),
                )),
          ],
        );
      case 1:
        return ListView(
          padding: const EdgeInsets.all(14),
          children: [
            LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick Restrictions Bar (Stop-Sell, CTA/CTD & MinLOS)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Stop-Sell: Deluxe Ocean View on OTAs'),
                    subtitle: const Text('Keep last 2 rooms exclusive to Direct Web Engine'),
                    value: _stopSellDeluxe,
                    onChanged: (v) => setState(() => _stopSellDeluxe = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Closed to Arrival (CTA): Colonial Suite'),
                    value: _ctaColonial,
                    onChanged: (v) => setState(() => _ctaColonial = v),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Minimum Length of Stay (MinLOS):', style: TextStyle(fontWeight: FontWeight.w700)),
                      MetricBadge(label: '$_minLosNights Nights', color: theme.primaryColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      case 2:
        return ListView(
          padding: const EdgeInsets.all(14),
          children: _channels.map((ch) {
            final comm = ch.monthlyRevenueLkr * ch.commissionRate;
            final net = ch.monthlyRevenueLkr - comm;
            return LiquidGlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ch.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Gross: ${CurrencyEngine.formatLkr(ch.monthlyRevenueLkr)} • OTA Fee: ${CurrencyEngine.formatLkr(comm)}'),
                  Text('Net Payout to Hotel: ${CurrencyEngine.formatLkr(net)}', style: TextStyle(fontWeight: FontWeight.w800, color: theme.primaryColor)),
                ],
              ),
            );
          }).toList(),
        );
      case 3:
        return ListView(
          padding: const EdgeInsets.all(14),
          children: const [
            LiquidGlassCard(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sampath Bank Visa Infinite & World MasterCard — 25% Off Full Board', style: TextStyle(fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text('Promo Code: SAMPATH25 • Valid for Resident LKR Direct Bookings'),
                ],
              ),
            ),
            LiquidGlassCard(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Commercial Bank Premium Credit Cards — 20% Off Half Board', style: TextStyle(fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text('Promo Code: COMBANK20 • Valid on Weekends & Poya Holidays'),
                ],
              ),
            ),
            LiquidGlassCard(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HNB Club Elite & Amex Explorer — 15% Off Villas', style: TextStyle(fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text('Promo Code: HNB15 • Includes Complimentary High Tea'),
                ],
              ),
            ),
          ],
        );
      default:
        return ListView(
          padding: const EdgeInsets.all(14),
          children: const [
            LiquidGlassCard(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Embeddable Direct Booking Widget (`booking-widget.js`)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                  SizedBox(height: 8),
                  Text(
                    '<script src="https://cdn.srilankahms.com/booking-widget.js" data-tenant="tenant-galle-fort" data-layout="floating" async></script>',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 11.5),
                  ),
                  SizedBox(height: 8),
                  Text('Projected Annual OTA Commission Saved: LKR 2,970,000 / year', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
                ],
              ),
            ),
          ],
        );
    }
  }
}
