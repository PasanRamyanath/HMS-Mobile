import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/liquid_glass_card.dart';

class TaxSltdaScreen extends StatefulWidget {
  const TaxSltdaScreen({super.key});

  @override
  State<TaxSltdaScreen> createState() => _TaxSltdaScreenState();
}

class _TaxSltdaScreenState extends State<TaxSltdaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _baseAmount = 100000;
  final List<bool> _nightAuditSteps = [true, true, true, false, false];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sc = _baseAmount * 0.10;
    final tdl = _baseAmount * 0.01;
    final sub1 = _baseAmount + sc + tdl; // 111%
    final sscl = sub1 * 0.025; // 2.775%
    final sub2 = sub1 + sscl; // 113.775%
    final vat = sub2 * 0.18; // 20.4795%
    final grandTotal = sub2 + vat; // 134.2545%

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: WebHeroBannerCard(
            imagePath: WebAssets.heroResort,
            badgeText: 'IRD RAMIS VAT • SLTDA FORM MR-1 • NIGHT AUDIT',
            title: 'Statutory Tax, SLTDA & Night Audit',
            subtitle:
                'Sri Lanka 4-stage cascading tax engine (34.2545%), 5-step EOD Night Audit wizard, SLTDA nationality arrivals, and QuickBooks/Xero export.',
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
              Tab(text: '1. 4-Stage Tax & IRD'),
              Tab(text: '2. 5-Step Night Audit'),
              Tab(text: '3. SLTDA Form MR-1'),
              Tab(text: '4. GM Daily Flash'),
              Tab(text: '5. Accounting Export'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCascadingTaxTab(sc, tdl, sub1, sscl, sub2, vat, grandTotal),
              _buildNightAuditTab(),
              _buildSltdaMr1Tab(),
              _buildGmFlashTab(),
              _buildAccountingExportTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCascadingTaxTab(double sc, double tdl, double sub1, double sscl,
      double sub2, double vat, double grandTotal) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sri Lanka 4-Stage Cascading Tax Calculator (++++ = 34.2545%)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _baseAmount,
                min: 10000,
                max: 500000,
                divisions: 49,
                activeColor: AppColors.emerald,
                label: 'Base LKR ${_baseAmount.round()}',
                onChanged: (v) => setState(() => _baseAmount = v),
              ),
              _taxRow('Base Net Tariff (100.0000%)', _baseAmount),
              _taxRow('Stage 1a: 10% Service Charge (Labor Act Pool)', sc),
              _taxRow('Stage 1b: 1% SLTDA Tourism Dev. Levy (TDL)', tdl),
              const Divider(),
              _taxRow('Subtotal 1 (111.0000%)', sub1, bold: true),
              _taxRow('Stage 2: 2.5% SSCL on Subtotal 1 (2.7750%)', sscl),
              const Divider(),
              _taxRow('Subtotal 2 (113.7750%)', sub2, bold: true),
              _taxRow('Stage 3: 18% IRD VAT on Subtotal 2 (20.4795%)', vat),
              const Divider(),
              _taxRow('Grand Total Inclusive ++++ (134.2545%)', grandTotal,
                  bold: true, highlight: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _taxRow(String label, double val,
      {bool bold = false, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            'LKR ${val.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: highlight ? AppColors.emerald : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNightAuditTab() {
    final labels = [
      'Step 1: Verify All Restaurant KOT/BOT & Open Waiter Checks Closed',
      'Step 2: Reconcile Housekeeping vs Front Desk Room Occupancy Discrepancies',
      'Step 3: Post Nightly Room Tariff + 34.2545% Cascading Taxes to All In-House Folios',
      'Step 4: Lock CBSL Foreign Currency Exchange Rates & Cash Drawer Z-Read',
      'Step 5: Roll Property Business Date Forward & Dispatch GM Flash Email',
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '5-Step End-of-Day (EOD) Night Audit Wizard',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              ...List.generate(labels.length, (i) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _nightAuditSteps[i],
                  activeColor: AppColors.emerald,
                  title: Text(labels[i], style: const TextStyle(fontSize: 12)),
                  onChanged: (v) =>
                      setState(() => _nightAuditSteps[i] = v ?? false),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      for (var i = 0; i < _nightAuditSteps.length; i++) {
                        _nightAuditSteps[i] = true;
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Night Audit completed! All room & tax postings committed and Business Date rolled.'),
                        backgroundColor: AppColors.emerald,
                      ),
                    );
                  },
                  icon: const Icon(Icons.nightlight_round, size: 16),
                  label: const Text('Execute Complete Night Audit Roll'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSltdaMr1Tab() {
    final origins = [
      {'country': 'United Kingdom / Germany / France', 'arrivals': 142, 'bedNights': 610},
      {'country': 'India & SAARC Region', 'arrivals': 96, 'bedNights': 340},
      {'country': 'China / Japan / Australia', 'arrivals': 64, 'bedNights': 245},
      {'country': 'Sri Lankan Domestic Residents (NIC)', 'arrivals': 118, 'bedNights': 290},
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SLTDA Monthly Statistical Return (Form MR-1)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              ...origins.map((o) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.bgElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(o['country'] as String,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700))),
                          Text(
                              '${o['arrivals']} Pax • ${o['bedNights']} Nights',
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.emerald)),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGmFlashTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GM Daily Flash Report & USALI P&L Summary',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              _taxRow('Rooms Occupancy (84.4% • 38/45 Keys)', 1842000),
              _taxRow('ADR (Average Daily Rate)', 48473),
              _taxRow('RevPAR (Revenue Per Available Room)', 40933),
              _taxRow('F&B + Sunset Bar + Banquets Revenue', 1420000),
              _taxRow('Ayurveda Spa + Safari Excursions', 465000),
              const Divider(),
              _taxRow('Total Daily Gross Operating Revenue', 3727000,
                  bold: true, highlight: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountingExportTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'QuickBooks / Xero GL Journal Export & Audit Log',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                '• IRD RAMIS VAT Schedule CSV (18% Output VAT vs Input VAT)\n'
                '• QuickBooks IIF / Xero Double-Entry GL Journal Batch\n'
                '• Immutable Rebate & Folio Void Audit Trail (0 Unauthorized Voids)',
                style: TextStyle(fontSize: 11.5, height: 1.5),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'IRD RAMIS VAT CSV & QuickBooks GL Journal batch generated.'),
                      backgroundColor: AppColors.emerald,
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Export IRD RAMIS & GL Journal Batch'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
