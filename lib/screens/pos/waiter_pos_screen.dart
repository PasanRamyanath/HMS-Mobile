import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/api/appsync_client.dart';
import '../../models/hotel_models.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

class WaiterPosScreen extends StatefulWidget {
  const WaiterPosScreen({super.key});

  @override
  State<WaiterPosScreen> createState() => _WaiterPosScreenState();
}

class _WaiterPosScreenState extends State<WaiterPosScreen> {
  String _selectedOutlet = 'Ocean Terrace';
  String _selectedTable = 'Table 4';
  final List<OrderItem> _cart = [];
  SpiceLevel _currentSpice = SpiceLevel.hot;
  final CourseType _currentCourse = CourseType.main;
  bool _allergyWarning = false;
  final TextEditingController _allergyController = TextEditingController();

  final List<OrderItem> _menuCatalog = [
    OrderItem(
      id: 'POS-01',
      name: 'Negombo Lagoon Crab Curry',
      nameSi: 'මීගමු කලපු කකුළු ව්‍යංජනය',
      category: 'Sri Lankan Curries',
      priceLkr: 4800,
      course: CourseType.main,
    ),
    OrderItem(
      id: 'POS-02',
      name: 'Black Pepper Jaffna Mutton',
      nameSi: 'යාපනයේ කළු ගම්මිරිස් එළුමස්',
      category: 'Sri Lankan Curries',
      priceLkr: 3900,
      course: CourseType.main,
    ),
    OrderItem(
      id: 'POS-03',
      name: 'Crispy Egg Hoppers with Seeni Sambol',
      nameSi: 'බිත්තර ආප්ප සීනි සම්බෝල සමග',
      category: 'Specialties',
      priceLkr: 1400,
      course: CourseType.appetizer,
    ),
    OrderItem(
      id: 'POS-04',
      name: 'Weligama Yellowfin Tuna Steak',
      nameSi: 'වැලිගම කෙලවල්ලා ස්ටේක්',
      category: 'Seafood Grills',
      priceLkr: 5200,
      course: CourseType.main,
    ),
    OrderItem(
      id: 'POS-05',
      name: 'Sinharaja Curd & Kithul Treacle',
      nameSi: 'මී කිරි සහ කිතුල් පැණි',
      category: 'Desserts',
      priceLkr: 1200,
      course: CourseType.dessert,
    ),
    OrderItem(
      id: 'POS-06',
      name: 'Arrack Sour Galle Fort Cocktail',
      nameSi: 'ගාලු කොටුව අරක් සවර්',
      category: 'Signature Mixology',
      priceLkr: 2400,
      course: CourseType.beverage,
    ),
    OrderItem(
      id: 'POS-07',
      name: 'King Coconut Thambili Cooler',
      nameSi: 'තැඹිලි පානය',
      category: 'Fresh Beverages',
      priceLkr: 850,
      course: CourseType.beverage,
    ),
  ];

  @override
  void dispose() {
    _allergyController.dispose();
    super.dispose();
  }

  void _addToCart(OrderItem item) {
    setState(() {
      final existingIndex = _cart.indexWhere((c) => c.id == item.id && c.spiceLevel == _currentSpice);
      if (existingIndex >= 0) {
        _cart[existingIndex].quantity++;
      } else {
        _cart.add(
          OrderItem(
            id: item.id,
            name: item.name,
            nameSi: item.nameSi,
            category: item.category,
            priceLkr: item.priceLkr,
            quantity: 1,
            spiceLevel: _currentSpice,
            course: _currentCourse,
            specialInstructions: _allergyWarning ? _allergyController.text : null,
          ),
        );
      }
    });
  }

  double get _cartTotalLkr => _cart.fold(0.0, (sum, item) => sum + item.subtotalLkr);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final client = AppSyncClient();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('waiter_pos')),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${_cart.length}'),
              isLabelVisible: _cart.isNotEmpty,
              child: const Icon(CupertinoIcons.cart),
            ),
            onPressed: () => _showCartModal(context, client),
          ),
        ],
      ),
      body: Column(
        children: [
          // Table & Dining Area Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131D2E) : Colors.white,
              border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _selectedOutlet,
                  underline: const SizedBox(),
                  items: ['Ocean Terrace', 'Main Dutch Hall', 'Sunset Pool Bar'].map((outlet) {
                    return DropdownMenuItem(value: outlet, child: Text(outlet, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedOutlet = val);
                  },
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedTable,
                  underline: const SizedBox(),
                  items: ['Table 1', 'Table 2', 'Table 3', 'Table 4', 'Table 5', 'Pool Cabana 1', 'Pool Cabana 2'].map((tbl) {
                    return DropdownMenuItem(value: tbl, child: Text(tbl, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: theme.primaryColor)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedTable = val);
                  },
                ),
              ],
            ),
          ),

          // Customizer Bar (Spice Level & Course)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('Spice:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  ...SpiceLevel.values.map((s) {
                    final isSel = _currentSpice == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: MetricBadge(
                        label: s.name.toUpperCase(),
                        color: s == SpiceLevel.extraHot ? Colors.red : (s == SpiceLevel.hot ? Colors.orange : Colors.green),
                        isSelected: isSel,
                        onTap: () => setState(() => _currentSpice = s),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Menu Catalog List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemCount: _menuCatalog.length,
              itemBuilder: (context, index) {
                final item = _menuCatalog[index];
                return LiquidGlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withAlpha(isDark ? 40 : 25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item.course == CourseType.beverage ? CupertinoIcons.sparkles : CupertinoIcons.flame,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            if (item.nameSi.isNotEmpty) ...[
                              Text(
                                item.nameSi,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                            const SizedBox(height: 3),
                            Text(
                              CurrencyEngine.formatLkr(item.priceLkr),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.plus_circle_fill, size: 28),
                        color: theme.primaryColor,
                        onPressed: () => _addToCart(item),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Quick Bar
          if (_cart.isNotEmpty)
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
                      Text('${_cart.length} items in KOT', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      Text(CurrencyEngine.formatLkr(_cartTotalLkr), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    icon: const Icon(CupertinoIcons.paperplane_fill, size: 16),
                    label: Text(AppTranslations.tr('fire_kot')),
                    onPressed: () => _fireKotOrder(context, client),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _fireKotOrder(BuildContext context, AppSyncClient client) {
    if (_cart.isEmpty) return;

    final newTicket = KdsTicket(
      id: 'KOT-${DateTime.now().millisecondsSinceEpoch % 10000}',
      ticketNumber: 'KOT #${DateTime.now().millisecondsSinceEpoch % 1000}',
      tableOrRoom: '$_selectedTable ($_selectedOutlet)',
      orderType: 'Dine-in',
      status: KdsTicketStatus.pending,
      items: List.from(_cart),
      createdTime: DateTime.now(),
      hasAllergyWarning: _allergyWarning,
      allergyNotes: _allergyWarning ? _allergyController.text : null,
    );

    client.fireOrder(newTicket);

    setState(() {
      _cart.clear();
      _allergyWarning = false;
      _allergyController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newTicket.ticketNumber} fired to Dark KDS & Bar BOT!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _showCartModal(BuildContext context, AppSyncClient client) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return LiquidGlassCard(
              margin: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Active KOT - $_selectedTable', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      IconButton(icon: const Icon(CupertinoIcons.clear), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(),
                  ..._cart.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${item.quantity}x ${item.name}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Text('Spice: ${item.spiceLevel.name.toUpperCase()}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Text(CurrencyEngine.formatLkr(item.subtotalLkr), style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      Text(CurrencyEngine.formatLkr(_cartTotalLkr), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _fireKotOrder(context, client);
                      },
                      child: Text(AppTranslations.tr('fire_kot')),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
