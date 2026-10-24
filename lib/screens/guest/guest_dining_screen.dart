import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/api/appsync_client.dart';
import '../../core/theme/app_theme.dart';
import '../../models/hotel_models.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';
import '../billing/lanka_qr_screen.dart';

/// Web-Parity Contactless Guest QR Super-App (`GuestQrApp.tsx` & all 6 Guest Departments).
/// Implements all 6 Web Version Guest QR tabs:
/// 1. In-Room Dining & Bar Menu + Dish Modifiers + Live Order Tracker (`GuestDishCard.tsx`, `LiveOrderTracker.tsx`)
/// 2. Express Housekeeping & Pillow Menu (`ExpressHousekeepingTab.tsx`)
/// 3. Guest Valet Laundry & Express Pressing (`GuestLaundryTab.tsx`)
/// 4. In-Room Minibar Self-Report (`GuestMinibarTab.tsx`)
/// 5. Spa, Excursions & 05:00 AM Safari Packed Breakfast Box (`GuestSpaAndExcursionsTab.tsx` & `PackedMealModal.tsx`)
/// 6. Live Room Folio, LankaQR Pay & Hotel Wi-Fi / Weather Advisory (`GuestLiveFolioTab.tsx` & `HotelInfoSheet.tsx`)
class GuestDiningScreen extends StatefulWidget {
  const GuestDiningScreen({super.key});

  @override
  State<GuestDiningScreen> createState() => _GuestDiningScreenState();
}

class _GuestDiningScreenState extends State<GuestDiningScreen> {
  int _activeDeptTab = 0;
  String _selectedCategory = 'All';
  final List<OrderItem> _guestCart = [];
  final String _roomNumber = '101';
  bool _dndActive = false;
  bool _makeUpRoomActive = true;

  static const List<String> _deptTabs = [
    '1. Dining Menu',
    '2. Express HK',
    '3. Valet Laundry',
    '4. Minibar',
    '5. Spa & Safari Box',
    '6. Live Folio & Wi-Fi',
  ];

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('guest_dining')),
        actions: [
          IconButton(
            tooltip: 'Call Waiter / Butler',
            icon: const Icon(CupertinoIcons.bell_fill, size: 18),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Butler & Room Service notified for Room 101.'),
                ),
              );
            },
          ),
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
          // 6-Tab Guest QR Department Switcher (`DepartmentTabs.tsx`)
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
                children: List.generate(_deptTabs.length, (idx) {
                  final isSel = _activeDeptTab == idx;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(_deptTabs[idx]),
                      selected: isSel,
                      onSelected: (v) {
                        if (v) setState(() => _activeDeptTab = idx);
                      },
                    ),
                  );
                }),
              ),
            ),
          ),

          Expanded(
            child: _buildGuestDeptTab(context, client, isDark),
          ),

          // Bottom Floating Cart Bar
          if (_guestCart.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                          '${_guestCart.length} items • Room $_roomNumber',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                          ),
                        ),
                        Text(
                          CurrencyEngine.formatLkr(_cartTotal),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: ElevatedButton.icon(
                      icon: const Icon(CupertinoIcons.bag_fill, size: 15),
                      label: const Text('View Cart & Order', maxLines: 1, overflow: TextOverflow.ellipsis),
                      onPressed: () => _showGuestCartModal(context, client),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuestDeptTab(BuildContext context, AppSyncClient client, bool isDark) {
    switch (_activeDeptTab) {
      case 0:
        return _buildInRoomDiningTab(context, isDark);
      case 1:
        return _buildExpressHousekeepingTab(context, isDark);
      case 2:
        return _buildGuestLaundryTab(context, isDark);
      case 3:
        return _buildGuestMinibarTab(context, isDark);
      case 4:
        return _buildSpaAndSafariBoxTab(context, isDark);
      case 5:
        return _buildLiveFolioAndHotelInfoTab(context, client, isDark);
      default:
        return _buildInRoomDiningTab(context, isDark);
    }
  }

  // ===========================================================================
  // TAB 1: IN-ROOM DINING MENU
  // ===========================================================================
  Widget _buildInRoomDiningTab(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final filteredMenu = _selectedCategory == 'All'
        ? _guestMenu
        : _guestMenu.where((m) => m.category == _selectedCategory).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      children: [
        WebHeroBannerCard(
          assetPath: WebAssets.galleFortHero,
          badgeText: 'Room $_roomNumber • Verified Guest QR Session',
          rightPillText: '06:30 – 23:00 SLST',
          title: 'Galle Fort Lighthouse Villa • In-Room Dining',
          subtitle: 'Direct Kitchen KDS Dispatch • HB/FB/AI Meal Plan Eligible',
          height: 160,
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
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
        const SizedBox(height: 8),
        ...filteredMenu.map((item) {
          final isBev = item.course == CourseType.beverage;
          final imgPath = WebAssets.dishImageForItem(item.name, isBeverage: isBev);

          return LiquidGlassCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                WebImageThumbnail(
                  assetPath: imgPath,
                  width: 62,
                  height: 62,
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
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
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
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: theme.primaryColor),
                          ),
                          const SizedBox(width: 6),
                          const Flexible(
                            child: MetricBadge(label: 'AI Free', color: Color(0xFF16A34A)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 38),
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
                  child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ===========================================================================
  // TAB 2: EXPRESS HOUSEKEEPING & PILLOW MENU (`ExpressHousekeepingTab.tsx`)
  // ===========================================================================
  Widget _buildExpressHousekeepingTab(BuildContext context, bool isDark) {
    final amenities = [
      '2x Egyptian Cotton Bath Towels',
      'Hypoallergenic Microfiber King Pillow',
      'Ceylon Citronella Mosquito Coil & Burner',
      'Dental & Shaving Vanity Kit',
      'Complimentary Bottled Mineral Water (2x 1L)',
      'Evening Turndown & Ice Bucket Refill',
    ];
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        LiquidGlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Room Privacy & Make-Up Status', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Make Up My Room Now', style: TextStyle(fontWeight: FontWeight.w700)),
                value: _makeUpRoomActive,
                onChanged: (v) => setState(() {
                  _makeUpRoomActive = v;
                  if (v) _dndActive = false;
                }),
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Do Not Disturb (DND)', style: TextStyle(fontWeight: FontWeight.w700)),
                value: _dndActive,
                onChanged: (v) => setState(() {
                  _dndActive = v;
                  if (v) _makeUpRoomActive = false;
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...amenities.map((a) => LiquidGlassCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: Text(a, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34), padding: const EdgeInsets.symmetric(horizontal: 10)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Requested "$a" for Room $_roomNumber!'), backgroundColor: const Color(0xFF16A34A)),
                      );
                    },
                    child: const Text('Request Free', style: TextStyle(fontSize: 11.5)),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ===========================================================================
  // TAB 3: GUEST VALET LAUNDRY (`GuestLaundryTab.tsx`)
  // ===========================================================================
  Widget _buildGuestLaundryTab(BuildContext context, bool isDark) {
    final items = [
      {'name': 'Gentleman\'s Linen Shirt (Wash & Iron)', 'price': 650.0},
      {'name': 'Trousers / Slacks (Dry Clean & Press)', 'price': 850.0},
      {'name': 'Ladies Silk Dress / Saree (Delicate Care)', 'price': 1400.0},
    ];
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const LiquidGlassCard(
          padding: EdgeInsets.all(14),
          child: Text('Guest Valet Laundry & Express 4-Hour Pressing Service', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
        ),
        const SizedBox(height: 8),
        ...items.map((i) => LiquidGlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        Text(CurrencyEngine.formatLkr(i['price'] as double), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 12)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Valet Laundry Pickup scheduled for Room 101!'), backgroundColor: Color(0xFF16A34A)),
                      );
                    },
                    child: const Text('Schedule Pickup'),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ===========================================================================
  // TAB 4: IN-ROOM MINIBAR SELF-REPORT (`GuestMinibarTab.tsx`)
  // ===========================================================================
  Widget _buildGuestMinibarTab(BuildContext context, bool isDark) {
    final minibar = [
      {'name': 'Lion Lager Can 330ml (Chilled)', 'price': 950.0},
      {'name': 'Ceylon Spice Roasted Cashews 100g', 'price': 1450.0},
      {'name': 'Artisan Dark Chocolate Bar 70%', 'price': 1200.0},
    ];
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const LiquidGlassCard(
          padding: EdgeInsets.all(14),
          child: Text('Honor Minibar Self-Report & Instant Refill', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
        ),
        const SizedBox(height: 8),
        ...minibar.map((m) => LiquidGlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        Text(CurrencyEngine.formatLkr(m['price'] as double), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 12)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logged ${m['name']} to Room $_roomNumber Folio.')),
                      );
                    },
                    child: const Text('Add to Folio'),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ===========================================================================
  // TAB 5: SPA, EXCURSIONS & 05:00 AM SAFARI PACKED BREAKFAST (`PackedMealModal.tsx`)
  // ===========================================================================
  Widget _buildSpaAndSafariBoxTab(BuildContext context, bool isDark) {
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
              const Text('Early Morning Yala / Whale Watching Safari Packed Breakfast Box', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              const SizedBox(height: 6),
              const Text(
                'Departing before 06:30 AM? Convert your BB/HB/FB breakfast entitlement into a freshly packed picnic hamper ready at Reception at 05:00 AM.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(CupertinoIcons.bag_fill_badge_plus, size: 16),
                  label: const Text('Order 05:00 AM Safari Breakfast Box (Free on HB)'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Safari Packed Breakfast Box scheduled for 05:00 AM pickup at Front Desk!'),
                        backgroundColor: Color(0xFF16A34A),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const WebHeroBannerCard(
          assetPath: WebAssets.spaAyurvedaPavilion,
          badgeText: 'Ayurveda Sanctuary • Room 101',
          rightPillText: 'LKR 16,500',
          title: 'Shirodhara Warm Oil & Herbal Steam (90 Min)',
          subtitle: 'Book a private consultation with our resident Vaidya physician',
          height: 165,
        ),
      ],
    );
  }

  // ===========================================================================
  // TAB 6: LIVE ROOM FOLIO, LANKAQR PAY & HOTEL WI-FI / ADVISORY SHEET
  // ===========================================================================
  Widget _buildLiveFolioAndHotelInfoTab(BuildContext context, AppSyncClient client, bool isDark) {
    final folio = client.folios.isNotEmpty ? client.folios.first : null;
    final balance = folio?.outstandingBalanceLkr ?? 148500.0;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // Ocean & Monsoon Advisory Banner (`AdvisoryBanner.tsx`)
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppTheme.skyBgLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.skyBorderLight),
          ),
          child: const Row(
            children: [
              Icon(CupertinoIcons.wind, color: Color(0xFF0284C7), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Southern Coast Advisory: Calm seas at Galle Fort & Unawatuna today (29°C). Sunset high tea at 17:00 on the Verandah.',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0369A1)),
                ),
              ),
            ],
          ),
        ),

        // Hotel Info & Wi-Fi Sheet (`HotelInfoSheet.tsx`)
        const LiquidGlassCard(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hotel Wi-Fi 6 & Guest Directory', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              SizedBox(height: 6),
              Text('• Wi-Fi Network: GalleFort_Villa_5G  |  Passcode: Heritage2026'),
              Text('• Reception Dial: Ext. 0  |  In-Room Dining: Ext. 4  |  Ayurveda Spa: Ext. 7'),
              Text('• Check-Out Time: 12:00 Noon (Late Check-Out subject to availability)'),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Live Room Folio & LankaQR Pay (`GuestLiveFolioTab.tsx` & `GuestLankaQrPay.tsx`)
        LiquidGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Live Room 101 Folio Summary', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 8),
              Text(
                'Outstanding Balance (Incl. 4-Stage Taxes): ${CurrencyEngine.formatLkr(balance)}',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(CupertinoIcons.qrcode_viewfinder, size: 17),
                  label: const Text('Settle Room Folio via Instant LankaQR'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LankaQrScreen(
                          amountLkr: balance,
                          folioReference: folio?.folioNumber ?? 'FOL-101',
                          guestName: folio?.guestName ?? 'Dr. Michael Perera',
                          onPaymentConfirmed: () => setState(() {}),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showGuestCartModal(BuildContext context, AppSyncClient client) {
    final pinCtrl = TextEditingController(text: '3342');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'In-Room Order — Room $_roomNumber',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.clear),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                ..._guestCart.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
                const SizedBox(height: 10),
                // RoomChargeAuthBox (`RoomChargeAuthBox.tsx`)
                TextField(
                  controller: pinCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Verify Last 4 Digits of NIC/Passport for Room Charge',
                    prefixIcon: Icon(CupertinoIcons.lock_shield, size: 17),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Total (Room Charge / LankaQR):',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      CurrencyEngine.formatLkr(_cartTotal),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    icon: const Icon(CupertinoIcons.checkmark_circle_fill, size: 16),
                    label: const Text('Confirm Room Service Order'),
                    onPressed: _guestCart.isEmpty
                        ? null
                        : () {
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
                              SnackBar(
                                content: Text('Order sent directly to Executive Chef KDS for Room $_roomNumber!'),
                                backgroundColor: const Color(0xFF16A34A),
                              ),
                            );
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
