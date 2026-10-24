import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/api/appsync_client.dart';
import '../../core/theme/app_theme.dart';
import '../../models/hotel_models.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

/// Web-Parity Sunset Bar BOT Queue, Liquor Peg Audit & Bottle Gate-Pass (`BarBotView.tsx` & `BarPegAuditView.tsx`).
class BarBotScreen extends StatefulWidget {
  const BarBotScreen({super.key});

  @override
  State<BarBotScreen> createState() => _BarBotScreenState();
}

class _BarBotScreenState extends State<BarBotScreen> {
  String _selectedCategory = 'ALL';
  bool _loungeDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = _loungeDarkMode || theme.brightness == Brightness.dark;
    final client = AppSyncClient();
    final barTickets = client.kdsTickets
        .where((t) =>
            t.orderType == 'Pool Bar' ||
            t.items.any((i) => i.course == CourseType.beverage))
        .toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1120) : AppTheme.lightCanvas,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        foregroundColor: isDark ? Colors.white : AppTheme.lightTextPrimary,
        title: Row(
          children: [
            Icon(CupertinoIcons.sparkles, color: theme.primaryColor, size: 19),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppTranslations.tr('bar_bot'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '25ml/50ml Bar Peg Audit',
            icon: const Icon(CupertinoIcons.chart_bar_alt_fill, size: 18),
            onPressed: () => _showBarPegAuditSheet(context),
          ),
          GestureDetector(
            onTap: () => setState(() => _loungeDarkMode = !_loungeDarkMode),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : AppTheme.lightSubtleSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : AppTheme.lightBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_stars_fill,
                    size: 13,
                    color: isDark ? const Color(0xFFFBBF24) : theme.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isDark ? 'Web Light' : 'Lounge Dark',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111827) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : AppTheme.lightBorder,
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['ALL', 'COCKTAILS', 'BEERS & WINES', 'FRESH JUICES', 'CEYLON TEA'].map((cat) {
                  final isSel = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      selectedColor: theme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSel
                            ? Colors.white
                            : (isDark ? Colors.white70 : AppTheme.lightTextPrimary),
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                      backgroundColor: isDark ? const Color(0xFF1E293B) : AppTheme.lightSubtleSurface,
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Expanded(
            child: barTickets.isEmpty
                ? Center(
                    child: Text(
                      'No active beverage tickets in the bar queue',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: barTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = barTickets[index];
                      return LiquidGlassCard(
                        padding: EdgeInsets.zero,
                        margin: const EdgeInsets.only(bottom: 14),
                        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.brandSurfaceTint(context),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    ticket.ticketNumber,
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      ticket.tableOrRoom,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  MetricBadge(
                                    label: ticket.status.name.toUpperCase(),
                                    color: ticket.status == KdsTicketStatus.served
                                        ? Colors.grey
                                        : theme.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                children: ticket.items
                                    .where((i) => i.course == CourseType.beverage || ticket.orderType == 'Pool Bar')
                                    .map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      children: [
                                        const WebImageThumbnail(
                                          assetPath: WebAssets.dishCuttlefishArrack,
                                          width: 42,
                                          height: 42,
                                          borderRadius: 10,
                                          fallbackIcon: CupertinoIcons.sparkles,
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: theme.primaryColor.withAlpha(25),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${item.quantity}x',
                                            style: TextStyle(
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13.5,
                                                ),
                                              ),
                                              if (item.nameSi.isNotEmpty)
                                                Text(
                                                  item.nameSi,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Glassware: Chilled Coupe • Garnish: Dehydrated Lime',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B).withAlpha(100) : AppTheme.lightSubtleSurface,
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                                border: Border(
                                  top: BorderSide(
                                    color: isDark ? Colors.white12 : AppTheme.lightBorder,
                                  ),
                                ),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(CupertinoIcons.checkmark_circle_fill, size: 16),
                                  label: Text(
                                    ticket.status == KdsTicketStatus.served
                                        ? 'Drinks Dispatched & Served'
                                        : 'Mark Drinks Served',
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  onPressed: ticket.status == KdsTicketStatus.served
                                      ? null
                                      : () {
                                          setState(() {
                                            client.updateTicketStatus(ticket.id, KdsTicketStatus.served);
                                          });
                                        },
                                ),
                              ),
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

  void _showBarPegAuditSheet(BuildContext context) {
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
                'Sri Lanka Bar 25ml / 50ml Peg & Liquor Variance Audit',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const Divider(height: 18),
              const Text('• Rockland Old Arrack (750ml = 30 pegs): POS Sold 18 pegs • Dipstick 12 pegs (0% Variance)'),
              const SizedBox(height: 4),
              const Text('• Ceylon Colombo No.7 Gin (700ml = 28 pegs): POS Sold 14 pegs • Dipstick 13.5 pegs (-0.5 peg)'),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Confirm Bar Shift Peg Audit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
