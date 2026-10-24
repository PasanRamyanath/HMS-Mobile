import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/api/appsync_client.dart';
import '../../core/theme/app_theme.dart';
import '../../models/hotel_models.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

/// Web-Parity Kitchen Display System (KDS) Kanban Board, 1-Tap 86 Stock Toggle Drawer & 80mm KOT Slip
/// (`KdsKanbanView.tsx`, `KdsStockToggleDrawer.tsx`, `PrintableKotSlip.tsx`).
class DarkKdsScreen extends StatefulWidget {
  const DarkKdsScreen({super.key});

  @override
  State<DarkKdsScreen> createState() => _DarkKdsScreenState();
}

class _DarkKdsScreenState extends State<DarkKdsScreen> {
  String _filterStatus = 'ALL';
  bool _forceOledDark = false;
  bool _audioChimeActive = true;
  final Set<String> _completedItemKeys = {};
  final Map<String, bool> _stockAvailability = {
    'Negombo Lagoon Crab Curry': true,
    'Crispy Egg Hoppers with Seeni Sambol': true,
    'Weligama Yellowfin Tuna Steak': true,
    'Black Pepper Jaffna Mutton': false, // 86'd
    'Curd & Kithul Treacle': true,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = _forceOledDark || theme.brightness == Brightness.dark;
    final client = AppSyncClient();
    final allTickets = client.kdsTickets.where((t) => t.orderType != 'Pool Bar').toList();

    final filteredTickets = _filterStatus == 'ALL'
        ? allTickets
        : allTickets.where((t) => t.status.name.toUpperCase() == _filterStatus).toList();

    final activeCount = allTickets.where((t) => t.status != KdsTicketStatus.served).length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1120) : AppTheme.lightCanvas,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        foregroundColor: isDark ? Colors.white : AppTheme.lightTextPrimary,
        title: Row(
          children: [
            const Icon(CupertinoIcons.flame_fill, color: Color(0xFFEA580C), size: 19),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppTranslations.tr('dark_kds'),
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
          // Chef 1-Tap 86 Stock Drawer Button (`KdsStockToggleDrawer.tsx`)
          IconButton(
            tooltip: 'Chef 1-Tap 86 Stock Drawer',
            icon: const Icon(Icons.inventory_2_outlined, size: 18),
            onPressed: () => _show86StockDrawer(context),
          ),
          // Audio Bell Toggle
          IconButton(
            tooltip: _audioChimeActive ? 'Harmonic Chime On' : 'Muted',
            icon: Icon(
              _audioChimeActive ? CupertinoIcons.speaker_2_fill : CupertinoIcons.speaker_slash_fill,
              size: 18,
            ),
            onPressed: () => setState(() => _audioChimeActive = !_audioChimeActive),
          ),
          // 1-Tap Web Light / OLED Dark Toggle
          GestureDetector(
            onTap: () => setState(() => _forceOledDark = !_forceOledDark),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              margin: const EdgeInsets.only(right: 10),
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
                    isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
                    size: 13,
                    color: isDark ? const Color(0xFFFBBF24) : AppTheme.lightTextSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isDark ? 'Light' : 'OLED',
                    style: TextStyle(
                      fontSize: 10.5,
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
          // Horizontally Scrollable Status Filter Tabs + Telemetry
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
                children: [
                  MetricBadge(
                    label: '$activeCount Active KOTs • Wake-Lock ON',
                    color: const Color(0xFFDC2626),
                    showDot: true,
                  ),
                  const SizedBox(width: 8),
                  ...['ALL', 'PENDING', 'PREPARING', 'READY', 'SERVED'].map((status) {
                    final isSel = _filterStatus == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(status),
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
                          if (val) setState(() => _filterStatus = status);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Tickets List
          Expanded(
            child: filteredTickets.isEmpty
                ? Center(
                    child: Text(
                      'No active kitchen orders in this queue',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: filteredTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = filteredTickets[index];
                      return _buildKdsTicketCard(context, ticket, client, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _show86StockDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chef 1-Tap "86 Item" Quick Stock Toggle Drawer',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Instantly mark dishes Sold Out (86\'d) across Waiter POS & Guest QR menus.',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
                const Divider(height: 18),
                ..._stockAvailability.entries.map((entry) => SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        entry.key,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration: entry.value ? null : TextDecoration.lineThrough,
                        ),
                      ),
                      subtitle: Text(entry.value ? 'AVAILABLE' : '86\'D — SOLD OUT'),
                      value: entry.value,
                      onChanged: (v) {
                        setModalState(() => _stockAvailability[entry.key] = v);
                        setState(() {});
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKdsTicketCard(
    BuildContext context,
    KdsTicket ticket,
    AppSyncClient client,
    bool isDark,
  ) {
    Color statusColor;
    String statusLabel;
    switch (ticket.status) {
      case KdsTicketStatus.pending:
        statusColor = const Color(0xFF0284C7);
        statusLabel = 'NEW ORDER';
        break;
      case KdsTicketStatus.preparing:
        statusColor = const Color(0xFFD97706);
        statusLabel = 'COOKING';
        break;
      case KdsTicketStatus.ready:
        statusColor = const Color(0xFF16A34A);
        statusLabel = 'READY TO DELIVER';
        break;
      case KdsTicketStatus.served:
        statusColor = const Color(0xFF64748B);
        statusLabel = 'SERVED';
        break;
      case KdsTicketStatus.cancelled:
        statusColor = const Color(0xFFDC2626);
        statusLabel = 'CANCELLED';
        break;
    }

    final isUrgent = ticket.elapsedMinutes > 15 && ticket.status != KdsTicketStatus.served;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent
              ? const Color(0xFFDC2626)
              : (isDark ? statusColor.withAlpha(110) : AppTheme.lightBorder),
          width: isUrgent ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(isDark ? 35 : 22),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Text(
                  ticket.ticketNumber,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 15),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isDark ? Colors.white24 : AppTheme.lightBorder),
                    ),
                    child: Text(
                      ticket.tableOrRoom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  tooltip: 'Print 80mm KOT Slip',
                  icon: Icon(CupertinoIcons.printer, size: 15, color: statusColor),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('80mm Thermal KOT Slip printed for ${ticket.ticketNumber}')),
                    );
                  },
                ),
                const SizedBox(width: 4),
                MetricBadge(
                  label: '${ticket.elapsedMinutes}m • $statusLabel',
                  color: isUrgent ? const Color(0xFFDC2626) : statusColor,
                ),
              ],
            ),
          ),

          if (ticket.hasAllergyWarning)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              color: const Color(0xFFDC2626).withAlpha(isDark ? 45 : 20),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Color(0xFFDC2626), size: 15),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'ALLERGY ALERT: ${ticket.allergyNotes ?? "Severe Food Allergy Specified"}',
                      style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w800, fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            ),

          // Tap-to-Complete Order Items (`KdsTicketCard.tsx`)
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: ticket.items.map((item) {
                final itemKey = '${ticket.id}-${item.id}';
                final isDone = _completedItemKeys.contains(itemKey);
                final imgPath = WebAssets.dishImageForItem(
                  item.name,
                  isBeverage: item.course == CourseType.beverage,
                );
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isDone) {
                        _completedItemKeys.remove(itemKey);
                      } else {
                        _completedItemKeys.add(itemKey);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Icon(
                          isDone ? CupertinoIcons.checkmark_square_fill : CupertinoIcons.square,
                          size: 18,
                          color: isDone ? const Color(0xFF16A34A) : statusColor,
                        ),
                        const SizedBox(width: 8),
                        WebImageThumbnail(
                          assetPath: imgPath,
                          width: 36,
                          height: 36,
                          borderRadius: 8,
                          fallbackIcon: CupertinoIcons.flame_fill,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item.quantity}x',
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 12.5),
                          ),
                        ),
                        const SizedBox(width: 8),
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
                                  fontSize: 13,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              if (item.nameSi.isNotEmpty)
                                Text(
                                  item.nameSi,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
                                    fontSize: 10.5,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        MetricBadge(
                          label: item.spiceLevel.name.toUpperCase(),
                          color: item.spiceLevel == SpiceLevel.extraHot
                              ? const Color(0xFFDC2626)
                              : const Color(0xFFD97706),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Action Progression Buttons + Recall Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B).withAlpha(110) : AppTheme.lightSubtleSurface,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
              border: Border(top: BorderSide(color: isDark ? Colors.white12 : AppTheme.lightBorder)),
            ),
            child: Row(
              children: [
                if (ticket.status != KdsTicketStatus.pending) ...[
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () {
                      setState(() {
                        client.updateTicketStatus(ticket.id, KdsTicketStatus.preparing);
                      });
                    },
                    child: const Text('Recall', style: TextStyle(fontSize: 11.5)),
                  ),
                  const SizedBox(width: 8),
                ],
                if (ticket.status == KdsTicketStatus.pending)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(CupertinoIcons.play_fill, size: 15),
                      label: const Text('Start Preparing', style: TextStyle(fontWeight: FontWeight.w800)),
                      onPressed: () {
                        setState(() {
                          client.updateTicketStatus(ticket.id, KdsTicketStatus.preparing);
                        });
                      },
                    ),
                  )
                else if (ticket.status == KdsTicketStatus.preparing)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(CupertinoIcons.checkmark_alt, size: 17),
                      label: Text(
                        AppTranslations.tr('mark_ready'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      onPressed: () {
                        setState(() {
                          client.updateTicketStatus(ticket.id, KdsTicketStatus.ready);
                        });
                      },
                    ),
                  )
                else if (ticket.status == KdsTicketStatus.ready)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(CupertinoIcons.bell_fill, size: 15),
                      label: Text(
                        AppTranslations.tr('mark_served'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      onPressed: () {
                        setState(() {
                          client.updateTicketStatus(ticket.id, KdsTicketStatus.served);
                        });
                      },
                    ),
                  )
                else
                  Expanded(
                    child: Text(
                      'Ticket Completed & Served',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
