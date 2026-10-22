import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/api/appsync_client.dart';
import '../../models/hotel_models.dart';

class BarBotScreen extends StatefulWidget {
  const BarBotScreen({super.key});

  @override
  State<BarBotScreen> createState() => _BarBotScreenState();
}

class _BarBotScreenState extends State<BarBotScreen> {
  @override
  Widget build(BuildContext context) {
    final client = AppSyncClient();
    final barTickets = client.kdsTickets.where((t) => t.orderType == 'Pool Bar' || t.items.any((i) => i.course == CourseType.beverage)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E), // Deep Violet Night
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1433),
        title: Row(
          children: [
            const Icon(CupertinoIcons.sparkles, color: Color(0xFFC084FC), size: 20),
            const SizedBox(width: 8),
            Text(AppTranslations.tr('bar_bot'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      body: barTickets.isEmpty
          ? const Center(
              child: Text('No active beverage tickets in the bar queue', style: TextStyle(color: Colors.white54)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: barTickets.length,
              itemBuilder: (context, index) {
                final ticket = barTickets[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1433),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC084FC).withAlpha(80)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC084FC).withAlpha(30),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ticket.ticketNumber,
                              style: const TextStyle(color: Color(0xFFE9D5FF), fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            Text(
                              ticket.tableOrRoom,
                              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: ticket.items.where((i) => i.course == CourseType.beverage).map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF9333EA).withAlpha(50),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('${item.quantity}x', style: const TextStyle(color: Color(0xFFD8B4FE), fontWeight: FontWeight.w800)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                                        if (item.nameSi.isNotEmpty) Text(item.nameSi, style: const TextStyle(color: Colors.white54, fontSize: 11)),
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
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white12))),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9333EA),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              setState(() {
                                client.updateTicketStatus(ticket.id, KdsTicketStatus.served);
                              });
                            },
                            child: const Text('Mark Drinks Served', style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
