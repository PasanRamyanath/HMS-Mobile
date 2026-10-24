import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/api/appsync_client.dart';
import '../../core/theme/app_theme.dart';
import '../../models/hotel_models.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

/// Web-Parity POS, All Orders Ledger, Order Runner, Buffet Host & Menus/86 Board Hub
/// (`PosTerminalView.tsx`, `AllOrdersView.tsx`, `RunnerDeliveryView.tsx`, `BuffetCheckInView.tsx`, `MenusAndCatalogPage.tsx`).
/// Implements all 5 Web Version F&B modules in a mobile-first tabbed workspace:
/// 1. Terrace POS Terminal (Floor Map, Dish Modifiers, Room Charge Lookup, Split Bill, Z-Read, Driver Meal Pass)
/// 2. All Orders Master Ledger (Live/Historical POS & QR orders, Void Order Modal, 80mm Receipt Reprint)
/// 3. Order Runner Delivery Tray (`RunnerDeliveryView.tsx`)
/// 4. Buffet Host Meal-Plan Check-In (`BuffetCheckInView.tsx`)
/// 5. Menus, 86'd Out-of-Stock Board, Happy Hour & Menu Engineering (`MenusAndCatalogPage.tsx`)
class WaiterPosScreen extends StatefulWidget {
  const WaiterPosScreen({super.key});

  @override
  State<WaiterPosScreen> createState() => _WaiterPosScreenState();
}

class _WaiterPosScreenState extends State<WaiterPosScreen> {
  int _activeSubModule = 0;
  String _selectedOutlet = 'Ocean Terrace';
  String _selectedTable = 'Table 4';
  String _selectedCategory = 'All';
  final List<OrderItem> _cart = [];
  SpiceLevel _currentSpice = SpiceLevel.hot;
  final CourseType _currentCourse = CourseType.main;
  final Set<String> _eightySixedItemIds = {'POS-02'}; // 86'd Out-of-Stock IDs
  final Set<String> _buffetCheckedInRooms = {'101'};

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

  static const List<String> _subModuleTabs = [
    '1. Waiter POS',
    '2. All Orders',
    '3. Order Runner',
    '4. Buffet Host',
    '5. Menus & 86 Board',
  ];

  void _addToCart(OrderItem item) {
    if (_eightySixedItemIds.contains(item.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} is currently 86\'d (Out of Stock)!'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }
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
            tooltip: 'Driver Meal Voucher Scanner',
            icon: const Icon(CupertinoIcons.ticket, size: 19),
            onPressed: () => _showDriverMealVoucherModal(context),
          ),
          IconButton(
            tooltip: 'Outlet Shift Z-Read Closing',
            icon: const Icon(CupertinoIcons.doc_chart, size: 19),
            onPressed: () => _showPosZReadModal(context),
          ),
          IconButton(
            tooltip: 'Active KOT Cart',
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
          // 5-Tab F&B Sub-Module Selector
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
                children: List.generate(_subModuleTabs.length, (idx) {
                  final isSel = _activeSubModule == idx;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(_subModuleTabs[idx]),
                      selected: isSel,
                      onSelected: (v) {
                        if (v) setState(() => _activeSubModule = idx);
                      },
                    ),
                  );
                }),
              ),
            ),
          ),

          Expanded(
            child: _buildSubModuleView(context, client, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSubModuleView(BuildContext context, AppSyncClient client, bool isDark) {
    switch (_activeSubModule) {
      case 0:
        return _buildWaiterPosTerminal(context, client, isDark);
      case 1:
        return _buildAllOrdersMasterLedger(context, client, isDark);
      case 2:
        return _buildOrderRunnerView(context, client, isDark);
      case 3:
        return _buildBuffetHostCheckInView(context, client, isDark);
      case 4:
        return _buildMenusAnd86BoardView(context, isDark);
      default:
        return _buildWaiterPosTerminal(context, client, isDark);
    }
  }

  // ===========================================================================
  // SUB-MODULE 1: WAITER POS TERMINAL
  // ===========================================================================
  Widget _buildWaiterPosTerminal(BuildContext context, AppSyncClient client, bool isDark) {
    final theme = Theme.of(context);
    final categories = ['All', 'Sri Lankan Curries', 'Specialties', 'Seafood Grills', 'Signature Mixology', 'Desserts'];
    final filteredMenu = _selectedCategory == 'All'
        ? _menuCatalog
        : _menuCatalog.where((i) => i.category == _selectedCategory).toList();

    return Column(
      children: [
        // Outlet & Table Floor Map Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
            border: Border(
              bottom: BorderSide(color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSubtleSurface : AppTheme.lightSubtleSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedOutlet,
                    underline: const SizedBox(),
                    items: ['Ocean Terrace', 'Main Dutch Hall', 'Sunset Pool Bar'].map((outlet) {
                      return DropdownMenuItem(
                        value: outlet,
                        child: Text(
                          outlet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedOutlet = val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.brandSurfaceTint(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.brandBorderTint(context)),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedTable,
                    underline: const SizedBox(),
                    items: [
                      'Table 1',
                      'Table 2',
                      'Table 3',
                      'Table 4',
                      'Table 5',
                      'Pool Cabana 1',
                      'Pool Cabana 2',
                    ].map((tbl) {
                      return DropdownMenuItem(
                        value: tbl,
                        child: Text(
                          tbl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: theme.primaryColor),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTable = val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Category Pills & Spice Level Customizer Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCanvas : AppTheme.lightCanvas,
            border: Border(
              bottom: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            ),
          ),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSel,
                        onSelected: (v) {
                          if (v) setState(() => _selectedCategory = cat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      'Spice:',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    ...SpiceLevel.values.map((s) {
                      final isSel = _currentSpice == s;
                      final color = s == SpiceLevel.extraHot
                          ? const Color(0xFFDC2626)
                          : (s == SpiceLevel.hot ? const Color(0xFFEA580C) : const Color(0xFF16A34A));
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: MetricBadge(
                          label: s.name.toUpperCase(),
                          color: color,
                          isSelected: isSel,
                          onTap: () => setState(() => _currentSpice = s),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Menu Catalog List with Web Photography
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            itemCount: filteredMenu.length,
            itemBuilder: (context, index) {
              final item = filteredMenu[index];
              final isBev = item.course == CourseType.beverage;
              final imgPath = WebAssets.dishImageForItem(item.name, isBeverage: isBev);
              final is86d = _eightySixedItemIds.contains(item.id);
              final inCartQty = _cart.where((c) => c.id == item.id).fold<int>(0, (sum, c) => sum + c.quantity);

              return LiquidGlassCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    WebImageThumbnail(
                      assetPath: imgPath,
                      width: 60,
                      height: 60,
                      borderRadius: 12,
                      fallbackIcon: isBev ? CupertinoIcons.sparkles : CupertinoIcons.flame_fill,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              decoration: is86d ? TextDecoration.lineThrough : null,
                              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                            ),
                          ),
                          if (item.nameSi.isNotEmpty)
                            Text(
                              item.nameSi,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextSecondary,
                              ),
                            ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                CurrencyEngine.formatLkr(item.priceLkr),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: theme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: MetricBadge(
                                  label: is86d ? '86 SOLD OUT' : item.category,
                                  color: is86d
                                      ? const Color(0xFFDC2626)
                                      : (isBev ? const Color(0xFF7C3AED) : const Color(0xFF0B6E4F)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            is86d ? CupertinoIcons.nosign : CupertinoIcons.plus_circle_fill,
                            size: 28,
                            color: is86d ? Colors.grey : theme.primaryColor,
                          ),
                          onPressed: () => _addToCart(item),
                        ),
                        if (inCartQty > 0)
                          Text(
                            '${inCartQty}x in KOT',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: theme.primaryColor),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom KOT Fire & Split Bill Bar
        if (_cart.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              border: Border(
                top: BorderSide(color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_cart.length} items • $_selectedTable',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        CurrencyEngine.formatLkr(_cartTotalLkr),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onPressed: () => _showSplitBillModal(context),
                  child: const Text('Split Bill', style: TextStyle(fontSize: 11.5)),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: ElevatedButton.icon(
                    icon: const Icon(CupertinoIcons.paperplane_fill, size: 14),
                    label: Text(
                      AppTranslations.tr('fire_kot'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () => _fireKotOrder(context, client),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // SUB-MODULE 2: ALL ORDERS MASTER LEDGER (`AllOrdersView.tsx`)
  // ===========================================================================
  Widget _buildAllOrdersMasterLedger(BuildContext context, AppSyncClient client, bool isDark) {
    final theme = Theme.of(context);
    final tickets = client.kdsTickets;
    final totalNetRev = tickets.fold<double>(0, (s, t) => s + t.totalLkr);

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        LiquidGlassCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('All Orders Master POS & KDS Ledger', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  Text('Total Active & Completed Tickets: ${tickets.length}', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                ],
              ),
              MetricBadge(label: CurrencyEngine.formatLkr(totalNetRev), color: theme.primaryColor),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...tickets.map((t) => LiquidGlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(t.ticketNumber, style: TextStyle(fontWeight: FontWeight.w900, color: theme.primaryColor)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.tableOrRoom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      MetricBadge(label: t.status.name.toUpperCase(), color: const Color(0xFF0284C7)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.items.map((i) => '${i.quantity}x ${i.name}').join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(CurrencyEngine.formatLkr(t.totalLkr), style: const TextStyle(fontWeight: FontWeight.w900)),
                      Wrap(
                        spacing: 6,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 32), padding: const EdgeInsets.symmetric(horizontal: 8)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('80mm Thermal Receipt reprinted for ${t.ticketNumber}')),
                              );
                            },
                            child: const Text('80mm Print', style: TextStyle(fontSize: 11)),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 32),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              foregroundColor: const Color(0xFFDC2626),
                            ),
                            onPressed: () {
                              setState(() {
                                client.updateTicketStatus(t.id, KdsTicketStatus.cancelled);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${t.ticketNumber} voided with Manager PIN audit log')),
                              );
                            },
                            child: const Text('Void', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ===========================================================================
  // SUB-MODULE 3: ORDER RUNNER DELIVERY TRAY (`RunnerDeliveryView.tsx`)
  // ===========================================================================
  Widget _buildOrderRunnerView(BuildContext context, AppSyncClient client, bool isDark) {
    final readyTickets = client.kdsTickets.where((t) => t.status != KdsTicketStatus.served).toList();
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const LiquidGlassCard(
          padding: EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order Runner Tray & Room Service Dispatch', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              SizedBox(height: 4),
              Text('Pick up plated kitchen KOTs and bar BOTs and confirm guest table/room delivery.', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...readyTickets.map((t) => LiquidGlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${t.ticketNumber} → ${t.tableOrRoom}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ),
                      MetricBadge(label: '${t.elapsedMinutes}m Elapsed', color: const Color(0xFFD97706)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...t.items.map((i) => Text('• ${i.quantity}x ${i.name}', style: const TextStyle(fontSize: 12.5))),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(CupertinoIcons.checkmark_circle_fill, size: 16),
                      label: const Text('Confirm Tray Delivered to Guest'),
                      onPressed: () {
                        setState(() {
                          client.updateTicketStatus(t.id, KdsTicketStatus.served);
                        });
                      },
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ===========================================================================
  // SUB-MODULE 4: BUFFET HOST MEAL-PLAN CHECK-IN (`BuffetCheckInView.tsx`)
  // ===========================================================================
  Widget _buildBuffetHostCheckInView(BuildContext context, AppSyncClient client, bool isDark) {
    final reservations = client.reservations;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const LiquidGlassCard(
          padding: EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Buffet Host Meal-Plan Verification & Pax Check-In', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              SizedBox(height: 4),
              Text('Verify in-house guest meal plan entitlements (BB/HB/FB/AI Included vs RO Walk-in Chargeable).', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...reservations.map((res) {
          final isCheckedInBuffet = _buffetCheckedInRooms.contains(res.roomNumber);
          final isFreeOnPlan = res.mealPlan != MealPlan.ro;
          return LiquidGlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room ${res.roomNumber} — ${res.guestName}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Plan: ${res.mealPlan.name.toUpperCase()} (${res.guestCount} Pax) • ${isFreeOnPlan ? "BUFFET INCLUDED" : "WALK-IN SURCHARGE LKR 4,500"}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isFreeOnPlan ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCheckedInBuffet ? const Color(0xFF16A34A) : Theme.of(context).primaryColor,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      if (isCheckedInBuffet) {
                        _buffetCheckedInRooms.remove(res.roomNumber);
                      } else {
                        _buffetCheckedInRooms.add(res.roomNumber);
                      }
                    });
                  },
                  child: Text(isCheckedInBuffet ? 'Checked In ✓' : 'Check In Pax'),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ===========================================================================
  // SUB-MODULE 5: MENUS, 86'D BOARD, HAPPY HOUR & MENU ENGINEERING
  // ===========================================================================
  Widget _buildMenusAnd86BoardView(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        LiquidGlassCard(
          padding: const EdgeInsets.all(14),
          backgroundColor: AppTheme.brandSurfaceTint(context),
          customBorder: Border.all(color: AppTheme.brandBorderTint(context)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1-Tap "86 Item" Out-of-Stock & Menu Engineering', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    SizedBox(height: 2),
                    Text('Happy Hour (17:00–19:00): 25% Off Signature Arrack Cocktails Active', style: TextStyle(fontSize: 11.5)),
                  ],
                ),
              ),
              MetricBadge(label: '${_eightySixedItemIds.length} 86\'d', color: const Color(0xFFDC2626)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ..._menuCatalog.map((item) {
          final is86d = _eightySixedItemIds.contains(item.id);
          return LiquidGlassCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          decoration: is86d ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      Text(
                        '${CurrencyEngine.formatLkr(item.priceLkr)} • Matrix: ★ STAR (High Margin / High Popularity)',
                        style: TextStyle(fontSize: 11, color: theme.primaryColor, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: !is86d,
                  activeTrackColor: const Color(0xFF16A34A),
                  onChanged: (avail) {
                    setState(() {
                      if (avail) {
                        _eightySixedItemIds.remove(item.id);
                      } else {
                        _eightySixedItemIds.add(item.id);
                      }
                    });
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showDriverMealVoucherModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chauffeur / Tour Guide Meal Voucher Redemption', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 6),
              const Text('Scan or redeem complimentary Driver Rice & Curry Meal Pass linked to in-house DMC rooms.'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(CupertinoIcons.qrcode_viewfinder, size: 16),
                  label: const Text('Redeem Driver Meal Voucher (Bunk D-01 • Room 103)'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Driver Meal Voucher redeemed & posted to Staff/Chauffeur Meal Cost Center!'),
                        backgroundColor: Color(0xFF16A34A),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPosZReadModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Outlet Shift X-Read / Z-Read Financial Closing', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const Divider(height: 20),
              const Text('• Room Charge Postings: LKR 184,500'),
              const Text('• LankaQR CEFT Settlements: LKR 68,200'),
              const Text('• Visa / MasterCard Terminal: LKR 94,000'),
              const Text('• Cash in Drawer (Expected): LKR 42,300'),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(CupertinoIcons.printer, size: 16),
                  label: const Text('Print 80mm Z-Read & Close Outlet Shift'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Outlet Z-Read printed & posted to Night Audit!')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSplitBillModal(BuildContext context) {
    final half = _cartTotalLkr / 2.0;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Split Bill — $_selectedTable', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Total Bill: ${CurrencyEngine.formatLkr(_cartTotalLkr)}'),
              Text('2-Way Equal Split: ${CurrencyEngine.formatLkr(half)} per guest'),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Split checks generated for Seat 1 & Seat 2!')),
                    );
                  },
                  child: const Text('Generate Split Guest Checks'),
                ),
              ),
            ],
          ),
        ),
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
    );

    client.fireOrder(newTicket);

    setState(() {
      _cart.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newTicket.ticketNumber} fired to Kitchen KDS & Bar BOT!'),
        backgroundColor: const Color(0xFF16A34A),
      ),
    );
  }

  void _showCartModal(BuildContext context, AppSyncClient client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Active KOT — $_selectedTable ($_selectedOutlet)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.clear),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                if (_cart.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('No items in active KOT')),
                  )
                else
                  ..._cart.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.quantity}x ${item.name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                Text(
                                  'Spice: ${item.spiceLevel.name.toUpperCase()}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            CurrencyEngine.formatLkr(item.subtotalLkr),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    Text(
                      CurrencyEngine.formatLkr(_cartTotalLkr),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    icon: const Icon(CupertinoIcons.paperplane_fill, size: 15),
                    label: Text(AppTranslations.tr('fire_kot')),
                    onPressed: _cart.isEmpty
                        ? null
                        : () {
                            Navigator.pop(ctx);
                            _fireKotOrder(context, client);
                          },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
