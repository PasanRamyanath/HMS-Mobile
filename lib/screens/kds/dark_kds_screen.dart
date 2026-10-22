import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/api/appsync_client.dart';
import '../../models/hotel_models.dart';
import '../../widgets/metric_badge.dart';

class DarkKdsScreen extends StatefulWidget {
  const DarkKdsScreen({super.key});

  @override
  State<DarkKdsScreen> createState() => _DarkKdsScreenState();
}

class _DarkKdsScreenState extends State<DarkKdsScreen> {
  String _filterStatus = 'ALL';

  @override
  Widget build(BuildContext context) {
    final client = AppSyncClient();
    final allTickets = client.kdsTickets.where((t) => t.orderType != 'Pool Bar').toList();

    final filteredTickets = _filterStatus == 'ALL'
        ? allTickets
        : allTickets.where((t) => t.status.name.toUpperCase() == _filterStatus).toList();

    return Scaffold(
      backgroundColor: Colors.black, // Dark OLED
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: Row(
          children: [
            const Icon(CupertinoIcons.flame_fill, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Text(AppTranslations.tr('dark_kds'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(50),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withAlpha(120)),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.timer, color: Colors.redAccent, size: 14),
                const SizedBox(width: 4),
                Text('${allTickets.where((t) => t.status != KdsTicketStatus.served).length} Active KOTs', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFF181818),
            child: Row(
              children: ['ALL', 'PENDING', 'PREPARING', 'READY', 'SERVED'].map((status) {
                final isSel = _filterStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSel,
                    selectedColor: Colors.orange,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                    backgroundColor: const Color(0xFF282828),
                    onSelected: (val) {
                      if (val) setState(() => _filterStatus = status);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Tickets Grid / List
          Expanded(
            child: filteredTickets.isEmpty
                ? const Center(
                    child: Text('No active kitchen orders in this queue', style: TextStyle(color: Colors.white54)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = filteredTickets[index];
                      return _buildKdsTicketCard(context, ticket, client);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKdsTicketCard(BuildContext context, KdsTicket ticket, AppSyncClient client) {
    Color headerColor;
    switch (ticket.status) {
      case KdsTicketStatus.pending:
        headerColor = Colors.red;
        break;
      case KdsTicketStatus.preparing:
        headerColor = Colors.orange;
        break;
      case KdsTicketStatus.ready:
        headerColor = const Color(0xFF10B981);
        break;
      case KdsTicketStatus.served:
        headerColor = Colors.grey;
        break;
      case KdsTicketStatus.cancelled:
        headerColor = Colors.red.shade900;
        break;
    }

    final isUrgent = ticket.elapsedMinutes > 15 && ticket.status != KdsTicketStatus.served;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent ? Colors.red : headerColor.withAlpha(120),
          width: isUrgent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: headerColor.withAlpha(35),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      ticket.ticketNumber,
                      style: TextStyle(color: headerColor, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ticket.tableOrRoom,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(CupertinoIcons.clock_fill, color: isUrgent ? Colors.red : Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${ticket.elapsedMinutes}m ago',
                      style: TextStyle(
                        color: isUrgent ? Colors.redAccent : Colors.white70,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Allergy Warning Alert
          if (ticket.hasAllergyWarning) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              color: Colors.red.withAlpha(45),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.redAccent, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'ALLERGY ALERT: ${ticket.allergyNotes ?? "Severe Food Allergy Specified"}',
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Order Items
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: ticket.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(40),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.orange.withAlpha(90)),
                        ),
                        child: Text('${item.quantity}x', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 14)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                            if (item.nameSi.isNotEmpty) ...[
                              Text(item.nameSi, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            ],
                          ],
                        ),
                      ),
                      MetricBadge(
                        label: item.spiceLevel.name.toUpperCase(),
                        color: item.spiceLevel == SpiceLevel.extraHot ? Colors.red : Colors.amber,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Action Progression Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                if (ticket.status == KdsTicketStatus.pending) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(CupertinoIcons.play_fill, size: 16),
                      label: const Text('Start Preparing', style: TextStyle(fontWeight: FontWeight.w800)),
                      onPressed: () {
                        setState(() {
                          client.updateTicketStatus(ticket.id, KdsTicketStatus.preparing);
                        });
                      },
                    ),
                  ),
                ] else if (ticket.status == KdsTicketStatus.preparing) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(CupertinoIcons.checkmark_alt, size: 18),
                      label: Text(AppTranslations.tr('mark_ready'), style: const TextStyle(fontWeight: FontWeight.w800)),
                      onPressed: () {
                        setState(() {
                          client.updateTicketStatus(ticket.id, KdsTicketStatus.ready);
                        });
                      },
                    ),
                  ),
                ] else if (ticket.status == KdsTicketStatus.ready) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(CupertinoIcons.bell_fill, size: 16),
                      label: Text(AppTranslations.tr('mark_served'), style: const TextStyle(fontWeight: FontWeight.w800)),
                      onPressed: () {
                        setState(() {
                          client.updateTicketStatus(ticket.id, KdsTicketStatus.served);
                        });
                      },
                    ),
                  ),
                ] else ...[
                  const Text('Ticket Completed & Served', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
