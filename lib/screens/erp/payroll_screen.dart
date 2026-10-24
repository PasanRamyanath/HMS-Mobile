import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/liquid_glass_card.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _monthlyScRevenue = 28500000; // LKR 28.5M net F&B + Room revenue

  final List<Map<String, dynamic>> _staffRoster = [
    {
      'empNo': 'EMP-001',
      'name': 'Nuwan Wijesinghe',
      'role': 'Front Office Manager',
      'points': 14,
      'basic': 115000,
      'yearsService': 7.5,
      'poyaWorked': 1,
    },
    {
      'empNo': 'EMP-004',
      'name': 'Chef Chaminda Silva',
      'role': 'Executive Sous Chef',
      'points': 14,
      'basic': 135000,
      'yearsService': 9.2,
      'poyaWorked': 1,
    },
    {
      'empNo': 'EMP-011',
      'name': 'Kasun Perera',
      'role': 'Senior F&B Steward',
      'points': 10,
      'basic': 58000,
      'yearsService': 5.4,
      'poyaWorked': 1,
    },
    {
      'empNo': 'EMP-018',
      'name': 'Dilani Jayawardena',
      'role': 'Housekeeping Supervisor',
      'points': 10,
      'basic': 68000,
      'yearsService': 4.1,
      'poyaWorked': 0,
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
    final grossScPool = _monthlyScRevenue * 0.10;
    final breakageRetention = grossScPool * 0.10;
    final distributableScPool = grossScPool * 0.90;
    const totalPoints = 480;
    final perPointValue = distributableScPool / totalPoints;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: WebHeroBannerCard(
            imagePath: WebAssets.heroLobby,
            badgeText: '10% SERVICE CHARGE POOL • EPF/ETF • SLIPS BANK',
            title: 'Sri Lanka HR, Payroll & Statutory Hub',
            subtitle:
                '90/10 Service Charge point distribution, EPF 8%/12% Form C, ETF 3%, APIT tables, Poya 1.5x/Mercantile 2.0x OT, and 5-year Gratuity Act accrual.',
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
              Tab(text: '1. 10% SC Pool'),
              Tab(text: '2. Payroll & SLIPS'),
              Tab(text: '3. EPF Form C & ETF'),
              Tab(text: '4. Poya & Shift Roster'),
              Tab(text: '5. QR Attendance & Leave'),
              Tab(text: '6. Gratuity Act'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildScPoolTab(grossScPool, breakageRetention,
                  distributableScPool, perPointValue),
              _buildPayrollSlipsTab(perPointValue),
              _buildEpfEtfTab(),
              _buildPoyaRosterTab(),
              _buildAttendanceLeaveTab(),
              _buildGratuityTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScPoolTab(double grossPool, double breakage,
      double distributable, double perPoint) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '10% Service Charge (SC) 90/10 Statutory Pool Calculator',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              _row('Gross 10% SC Collected from Folios & POS',
                  'LKR ${grossPool.toStringAsFixed(0)}'),
              _row('Less 10% Breakage & Silverware Replacement Retention',
                  '- LKR ${breakage.toStringAsFixed(0)}'),
              _row('90% Net Staff Distributable Pool (480 Total Points)',
                  'LKR ${distributable.toStringAsFixed(0)}'),
              _row('Monetary Value Per 1.0 SC Point This Month',
                  'LKR ${perPoint.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPayrollSlipsTab(double perPoint) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        ..._staffRoster.map((s) {
          final basic = (s['basic'] as int).toDouble();
          final scShare = (s['points'] as int) * perPoint;
          final epf8 = basic * 0.08;
          final poyaBonus = (s['poyaWorked'] as int) * (basic / 26) * 1.5;
          final netPay = basic + scShare + poyaBonus - epf8;
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
                          '${s['name']} (${s['empNo']})',
                          style: const TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        'Net: LKR ${netPay.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.emerald,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${s['role']} • Basic: LKR ${basic.toStringAsFixed(0)} • SC (${s['points']} pts): LKR ${scShare.toStringAsFixed(0)} • EPF 8%: -LKR ${epf8.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'LankaPay SLIPS .DAT salary file exported for BOC / Sampath / Commercial Bank.'),
                backgroundColor: AppColors.emerald,
              ),
            );
          },
          icon: const Icon(Icons.account_balance_rounded, size: 16),
          label: const Text('Export LankaPay SLIPS Bank Transfer File'),
        ),
      ],
    );
  }

  Widget _buildEpfEtfTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Central Bank EPF Form C (20%) & ETF (3%) Return',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              _row('Employee EPF Contribution (8% of Basic + BRA)',
                  'LKR 248,400'),
              _row('Employer EPF Contribution (12% of Basic + BRA)',
                  'LKR 372,600'),
              _row('Total CBSL EPF Form C Remittance (20%)', 'LKR 621,000'),
              _row('Employer ETF Board Contribution (3%)', 'LKR 93,150'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPoyaRosterTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Full Moon Poya (1.5x) & Mercantile Holiday (2.0x) Roster',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Bak Full Moon Poya Day: Statutory 1.5x Daily Rate + Lieu Day Credit + Excise Liquor Bar Closure Enforced\n'
                '• Sinhala & Tamil New Year (Apr 13/14): Statutory 2.0x Double Pay + Avurudu Staff Bonus\n'
                '• Split-Shift Waiters: 06:30–10:30 AM & 06:00–10:30 PM with Dormitory Rest Break',
                style: TextStyle(fontSize: 11.5, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceLeaveTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Biometric / QR Time Clock & Shop and Office Leave Quotas',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Statutory Leave Entitlement: 14 Days Annual + 7 Days Casual + 7 Days Medical\n'
                '• Today\'s Live Clock-In: 44 / 46 Staff On Shift (2 Approved Poya Lieu Leaves)',
                style: TextStyle(fontSize: 11.5, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGratuityTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment of Gratuity Act No. 12 of 1983 (≥ 5 Years Service)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Accrues 0.5 Month Terminal Basic Salary per completed year of service for staff exceeding 5 years.',
                style: TextStyle(fontSize: 11),
              ),
              const SizedBox(height: 10),
              ..._staffRoster.map((s) {
                final yrs = s['yearsService'] as double;
                final eligible = yrs >= 5.0;
                final gratuity =
                    eligible ? (s['basic'] as int) * 0.5 * yrs.floor() : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _row(
                    '${s['name']} (${yrs.toStringAsFixed(1)} yrs)',
                    eligible
                        ? 'Vested: LKR ${gratuity.toStringAsFixed(0)}'
                        : 'Accruing (<5 yrs)',
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text(val,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.emerald)),
        ],
      ),
    );
  }
}
