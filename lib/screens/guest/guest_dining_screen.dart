import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/api/appsync_client.dart';
import '../../models/hotel_models.dart';
import '../../widgets/liquid_glass_card.dart';

class GuestDiningScreen extends StatefulWidget {
  const GuestDiningScreen({super.key});

  @override
  State<GuestDiningScreen> createState() => _GuestDiningScreenState();
}

class _GuestDiningScreenState extends State<GuestDiningScreen> {
  String _selectedCategory = 'All';
  final List<OrderItem> _guestCart = [];
  final String _roomNumber = '101';

  final List<OrderItem> _guestMenu = [
    OrderItem(
      id: 'G-01',
      name: 'Negombo Lagoon Crab Curry',
      nameSi: 'මීගමු කලපු කකුළු ව්‍යංජනය',
      category: 'Curries',
      priceLkr: 4800,
      course: CourseType.main,
    ),
    OrderItem(
      id: 'G-02',
      name: 'Crispy Egg Hoppers (Set of 4)',
      nameSi: 'බිත්තර ආප්ප සීනි සම්බෝල සමග',
      category: 'Specialties',
      priceLkr: 1400,
      course: CourseType.appetizer,
    ),
    OrderItem(
      id: 'G-03',
      name: 'Pol Roti with Lunu Miris & Katta Sambol',
      nameSi: 'පොල් රොටී සහ ලුණු මිරිස්',
      category: 'Specialties',
      priceLkr: 950,
      course: CourseType.appetizer,
    ),
    OrderItem(
      id: 'G-04',
      name: 'Weligama Grilled Yellowfin Tuna',
      nameSi: 'වැලිගම කෙලවල්ලා ස්ටේක්',
      category: 'Seafood',
      priceLkr: 5200,
      course: CourseType.main,
    ),
    OrderItem(
      id: 'G-05',
      name: 'Fresh King Coconut (Thambili)',
      nameSi: 'ස්වාභාවික තැඹිලි පානය',
      category: 'Beverages',
      priceLkr: 850,
      course: CourseType.beverage,
    ),
    OrderItem(
      id: 'G-06',
      name: 'Curd & Sinharaja Kithul Treacle',
      nameSi: 'මී කිරි සහ කිතුල් පැණි',
      category: 'Desserts',
      priceLkr: 1200,
      course: CourseType.dessert,
    ),
  ];

  double get _cartTotal => _guestCart.fold(0.0, (sum, i) => sum + i.subtotalLkr);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final client = AppSyncClient();

    final filteredMenu = _selectedCategory == 'All'
        ? _guestMenu
        : _guestMenu.where((m) => m.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('guest_dining')),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${_guestCart.length}'),
              isLabelVisible: _guestCart.isNotEmpty,
              child: const Icon(CupertinoIcons.bag),
            ),
            onPressed: () => _showGuestCartModal(context, client),
          ),
        ],
      ),
      body: Column(
        children: [
          // Guest In-Room Banner
          LiquidGlassCard(
            margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(CupertinoIcons.qrcode, color: Color(0xFF0F5132), size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room $_roomNumber Contactless In-Room Dining',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      const Text(
                        'Verified Guest Session | Direct Kitchen Delivery',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Categories Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Curries', 'Specialties', 'Seafood', 'Beverages', 'Desserts'].map((cat) {
                  final isSel = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Menu Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              itemCount: filteredMenu.length,
              itemBuilder: (context, index) {
                final item = filteredMenu[index];
                return LiquidGlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withAlpha(isDark ? 40 : 25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.course == CourseType.beverage ? CupertinoIcons.sparkles : CupertinoIcons.flame,
                          color: theme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            if (item.nameSi.isNotEmpty) ...[
                              Text(item.nameSi, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              CurrencyEngine.formatLkr(item.priceLkr),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        onPressed: () {
                          setState(() {
                            final idx = _guestCart.indexWhere((c) => c.id == item.id);
                            if (idx >= 0) {
                              _guestCart[idx].quantity++;
                            } else {
                              _guestCart.add(
                                OrderItem(
                                  id: item.id,
                                  name: item.name,
                                  nameSi: item.nameSi,
                                  category: item.category,
                                  priceLkr: item.priceLkr,
                                  quantity: 1,
                                ),
                              );
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added ${item.name} to cart!'), duration: const Duration(milliseconds: 700)),
                          );
                        },
                        child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Checkout Bar
          if (_guestCart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131D2E) : Colors.white,
                border: Border(top: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${_guestCart.length} items in cart', style: const TextStyle(fontSize: 12)),
                      Text(CurrencyEngine.formatLkr(_cartTotal), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => _showGuestCartModal(context, client),
                    child: const Text('View Cart & Order', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showGuestCartModal(BuildContext context, AppSyncClient client) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return LiquidGlassCard(
          margin: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('In-Room Order - Room $_roomNumber', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  IconButton(icon: const Icon(CupertinoIcons.clear), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              ..._guestCart.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text('${item.quantity}x ${item.name}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const Spacer(),
                      Text(CurrencyEngine.formatLkr(item.subtotalLkr), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total (incl. Service & Taxes):', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text(CurrencyEngine.formatLkr(_cartTotal), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF10B981))),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(CupertinoIcons.checkmark_circle_fill),
                  label: const Text('Confirm Room Service Order', style: TextStyle(fontWeight: FontWeight.w800)),
                  onPressed: () {
                    final ticket = KdsTicket(
                      id: 'KOT-${DateTime.now().millisecondsSinceEpoch % 10000}',
                      ticketNumber: 'KOT #${DateTime.now().millisecondsSinceEpoch % 1000}',
                      tableOrRoom: 'Room $_roomNumber (In-Room Guest)',
                      orderType: 'Room Service',
                      status: KdsTicketStatus.pending,
                      items: List.from(_guestCart),
                      createdTime: DateTime.now(),
                    );
                    client.fireOrder(ticket);
                    setState(() {
                      _guestCart.clear();
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Order sent directly to Executive Chef KDS for Room $_roomNumber!'), backgroundColor: const Color(0xFF10B981)),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
