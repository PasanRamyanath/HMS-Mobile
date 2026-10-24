import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/liquid_glass_card.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _items = [
    {
      'sku': 'GAS-LP-37.5',
      'name': 'Laugfs / Litro Commercial LPG Cylinder (37.5 kg)',
      'store': 'Main Kitchen Gas Bank',
      'stock': 6,
      'par': 8,
      'unit': 'Cylinders (6 Empty Shells Held)',
      'costLkr': 16800,
      'returnable': true,
    },
    {
      'sku': 'FUEL-DSL-GEN',
      'name': 'Lanka Auto Diesel — 250kVA Cummins Generator Tank',
      'store': 'Engineering Yard Tank',
      'stock': 640,
      'par': 1000,
      'unit': 'Liters (Burn Rate: 28L/hr)',
      'costLkr': 365,
      'returnable': false,
    },
    {
      'sku': 'LIQ-ARR-dd',
      'name': 'Rockland Old Arrack Double Distilled 750ml',
      'store': 'Bonded Bar Store',
      'stock': 42,
      'par': 36,
      'unit': 'Bottles (30x 25ml Pegs/Btl)',
      'costLkr': 3950,
      'returnable': true,
    },
    {
      'sku': 'BEER-LION-625',
      'name': 'Lion Lager 625ml Crates (12 Bottles/Crate)',
      'store': 'Beverage Cold Room',
      'stock': 18,
      'par': 24,
      'unit': 'Crates (Deposit LKR 1,200/Crate)',
      'costLkr': 5400,
      'returnable': true,
    },
    {
      'sku': 'SEA-CRAB-NEG',
      'name': 'Negombo Lagoon Live Mud Crab (Export Grade XL)',
      'store': 'Cold Freezer -18°C',
      'stock': 14,
      'par': 20,
      'unit': 'kg (FEFO Expiry: 48 hrs)',
      'costLkr': 4200,
      'returnable': false,
    },
  ];

  final List<Map<String, dynamic>> _procurements = [
    {
      'doc': 'GRN-2026-0891 (3-Way Matched)',
      'po': 'PO-2026-0412',
      'supplier': 'Peliyagoda Seafood Co-op',
      'items': '18kg Lagoon Crab, 25kg Yellowfin Tuna Loins',
      'amountLkr': 148500,
      'status': 'VERIFIED & POSTED',
    },
    {
      'doc': 'PO-2026-0418 (Pending Delivery)',
      'po': 'PR-2026-0199',
      'supplier': 'Lion Brewery Ceylon PLC (Biyagama)',
      'items': '25 Crates Lion Lager + 20 Empty Crate Returns',
      'amountLkr': 135000,
      'status': 'AWAITING GRN WEIGH-IN',
    },
    {
      'doc': 'GIN-2026-1104 (Internal Issue)',
      'po': 'REQ-KITCHEN-AM',
      'supplier': 'Central Dry Store -> Main Kitchen',
      'items': '50kg Samba Rice, 15L Coconut Oil, 8kg Ceylon Cinnamon',
      'amountLkr': 46200,
      'status': 'ISSUED BY STOREKEEPER',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: WebHeroBannerCard(
            imagePath: WebAssets.dishCrab,
            badgeText: 'STORES, 3-WAY GRN & RETURNABLE CONTAINERS',
            title: 'Inventory, Bar Peg & BOM Flash Cost',
            subtitle:
                'Track 37.5kg Laugfs/Litro LPG shells, generator diesel burn, 25ml/50ml श्रीलंका excise peg reconciliation, and PR -> PO -> GRN -> GIN flows.',
            height: 142,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.emerald,
            labelColor: AppColors.emerald,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: '1. Stock & Containers'),
              Tab(text: '2. PR / PO / GRN / GIN'),
              Tab(text: '3. Bar Peg Audit'),
              Tab(text: '4. Stock-Take & Spoilage'),
              Tab(text: '5. Suppliers & AP Aging'),
              Tab(text: '6. F&B BOM & Flash Cost'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildStockAndContainersTab(),
              _buildProcurementTab(),
              _buildBarPegAuditTab(),
              _buildStockTakeTab(),
              _buildSuppliersTab(),
              _buildBomFlashCostTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockAndContainersTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: _items.map((item) {
        final low = (item['stock'] as int) < (item['par'] as int);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: low
                            ? AppColors.rose.withValues(alpha: 0.14)
                            : AppColors.emerald.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        low ? 'BELOW PAR • REORDER' : 'HEALTHY STOCK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: low ? AppColors.rose : AppColors.emerald,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item['sku'],
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item['name'],
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'On Hand: ${item['stock']} / Par ${item['par']} • ${item['unit']}',
                  style: const TextStyle(fontSize: 11.5),
                ),
                Text(
                  'Store: ${item['store']} • Unit Cost: LKR ${item['costLkr']}',
                  style:
                      TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProcurementTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: _procurements.map((p) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        p['doc'],
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.emerald,
                        ),
                      ),
                    ),
                    Text(
                      'LKR ${p['amountLkr']}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Supplier / Route: ${p['supplier']} (${p['po']})',
                    style: const TextStyle(
                        fontSize: 11.5, fontWeight: FontWeight.w700)),
                Text('Line Items: ${p['items']}',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBarPegAuditTab() {
    final spirits = [
      {
        'spirit': 'Rockland Old Arrack Double Distilled (750ml = 30x 25ml Pegs)',
        'opening': '180 Pegs (6 Btl)',
        'posSold': '44 Pegs',
        'physical': '135 Pegs',
        'variance': '-1 Peg (-25ml Spillage)',
      },
      {
        'spirit': 'Colombo No. 7 Gin (700ml = 28x 25ml Pegs)',
        'opening': '84 Pegs (3 Btl)',
        'posSold': '19 Pegs',
        'physical': '65 Pegs',
        'variance': '0 Pegs (100% Match)',
      },
      {
        'spirit': 'JW Black Label 12YO (1000ml = 40x 25ml Pegs)',
        'opening': '160 Pegs (4 Btl)',
        'posSold': '32 Pegs',
        'physical': '128 Pegs',
        'variance': '0 Pegs (100% Match)',
      },
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: spirits.map((s) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s['spirit']!,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                    'Opening: ${s['opening']} • POS Sold: ${s['posSold']} • Dipstick Closing: ${s['physical']}',
                    style: const TextStyle(fontSize: 11.5)),
                const SizedBox(height: 4),
                Text(
                  'Audit Variance: ${s['variance']}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: s['variance']!.startsWith('0')
                        ? AppColors.emerald
                        : AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStockTakeTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Monthly Physical Stock-Take & Kitchen Spoilage Log',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Buffet Trim & Staff Meal Transfer: 4.2 kg Chicken Breast re-allocated to Staff Cafeteria Ledger (LKR 5,460)\n'
                '• Cold Room FEFO Alert: 1.5 kg King Prawns flagged for Chef Today\'s Special before 24h expiry\n'
                '• Breakage Log: 3x Wine Glasses (Grand Ballroom Wedding) charged to BEO Deposit',
                style: TextStyle(fontSize: 11.5, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuppliersTab() {
    final vendors = [
      {'name': 'Peliyagoda Seafood Co-op', 'terms': '7 Days Cash/SLIPS', 'due': 'LKR 148,500', 'bucket': '0-15 Days'},
      {'name': 'Lion Brewery Ceylon PLC', 'terms': '30 Days Credit', 'due': 'LKR 270,000', 'bucket': '16-30 Days'},
      {'name': 'Dambulla Dedicated Economic Centre Veg Supply', 'terms': 'Weekly Cash', 'due': 'LKR 84,200', 'bucket': 'Current'},
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: vendors.map((v) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LiquidGlassCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v['name']!,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w800)),
                      Text('Terms: ${v['terms']} • Aging: ${v['bucket']}',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Text(v['due']!,
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBomFlashCostTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recipe Bill of Materials (BOM) & Daily F&B Flash Food Cost',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Negombo Lagoon Crab Curry (Portion Selling: LKR 6,800) -> BOM Ingredient Cost: LKR 1,980 (29.1% Food Cost)\n'
                '• Kottu Roti Roast Chicken (Portion Selling: LKR 2,900) -> BOM Ingredient Cost: LKR 740 (25.5% Food Cost)\n'
                '• Overall MTD F&B Flash Food Cost: 28.4% vs Budget Target 30.0% (Favorable by 1.6%)',
                style: TextStyle(fontSize: 11.5, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
