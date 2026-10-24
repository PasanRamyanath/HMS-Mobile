import 'package:flutter/material.dart';
import '../../core/auth/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/liquid_glass_card.dart';

class MyPayslipScreen extends StatefulWidget {
  const MyPayslipScreen({super.key});

  @override
  State<MyPayslipScreen> createState() => _MyPayslipScreenState();
}

class _MyPayslipScreenState extends State<MyPayslipScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedMonth = 'April 2026';
  String _leaveType = 'Annual Leave (14 Days Quota)';
  final _reasonCtrl = TextEditingController();

  final List<Map<String, String>> _leaveHistory = [
    {
      'dates': '2026-04-01 (Bak Full Moon Poya Lieu Day)',
      'type': 'Statutory Poya Lieu Day',
      'status': 'APPROVED BY HR',
    },
    {
      'dates': '2026-03-14 to 2026-03-15 (2 Days)',
      'type': 'Casual Leave',
      'status': 'APPROVED BY HOD',
    },
  ];

  final List<Map<String, String>> _mySchedule = [
    {
      'day': 'Today • Wed Apr 08',
      'shift': 'Morning Shift (07:00 AM – 04:00 PM)',
      'station': 'Main Lobby / Front Office Desk',
      'meal': 'Staff Cafeteria Lunch Token #441',
    },
    {
      'day': 'Tomorrow • Thu Apr 09',
      'shift': 'Morning Shift (07:00 AM – 04:00 PM)',
      'station': 'VIP Express Check-In Pavilion',
      'meal': 'Staff Cafeteria Lunch Token #489',
    },
    {
      'day': 'Fri Apr 10 (Poya Prep)',
      'shift': 'Split Shift (06:30–10:30 AM & 06:00–10:00 PM)',
      'station': 'Grand Ballroom Poruwa Reception',
      'meal': 'Dormitory Rest Bed #B4 Assigned',
    },
    {
      'day': 'Sat Apr 11',
      'shift': 'Weekly Off Day (Rest)',
      'station': 'Off Duty',
      'meal': 'N/A',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = AuthState.instance.currentSession;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: WebHeroBannerCard(
            imagePath: WebAssets.heroLobby,
            badgeText: 'STAFF SELF-SERVICE PORTAL • EPF/ETF & SC SHARE',
            title: '${session.staffName} — Staff Wallet',
            subtitle:
                'Role: ${session.role.label} • Shift PIN: ${session.pinCode} • View 10% Service Charge points, EPF 8%/12% balances, leave passes, and split-shift roster.',
            height: 140,
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
            indicatorColor: AppColors.emerald,
            labelColor: AppColors.emerald,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: '1. Monthly Payslip'),
              Tab(text: '2. Leave Pass'),
              Tab(text: '3. Shift Roster'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPayslipTab(session),
              _buildLeaveRequestTab(),
              _buildShiftRosterTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPayslipTab(UserSession session) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Official Statutory Payslip',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  DropdownButton<String>(
                    value: _selectedMonth,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(
                          value: 'April 2026', child: Text('April 2026')),
                      DropdownMenuItem(
                          value: 'March 2026', child: Text('March 2026')),
                      DropdownMenuItem(
                          value: 'February 2026', child: Text('February 2026')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedMonth = v);
                    },
                  ),
                ],
              ),
              const Divider(),
              _line('Basic Salary + Budgetary Relief Allowance (BRA)',
                  'LKR 85,000.00', true),
              _line('10% Service Charge Share (12 Points @ LKR 5,343.75)',
                  'LKR 64,125.00', true),
              _line('Bak Full Moon Poya Day Overtime (1.5x Rate)',
                  'LKR 4,903.85', true),
              _line('Attendance & Grooming Incentive', 'LKR 5,000.00', true),
              const Divider(),
              _line('Gross Monthly Earnings', 'LKR 159,028.85', true,
                  bold: true),
              const SizedBox(height: 6),
              _line('Employee EPF 8% Deduction (Central Bank Fund)',
                  '- LKR 6,800.00', false),
              _line('IRD APIT (Pay-As-You-Earn Tax Above LKR 100k)',
                  '- LKR 3,541.73', false),
              _line('Staff Welfare Society & Festival Advance',
                  '- LKR 2,000.00', false),
              const Divider(),
              _line('Net Take-Home Salary (Credited via LankaPay SLIPS)',
                  'LKR 146,687.12', true,
                  bold: true),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Employer Statutory Contributions (Not Deducted from Pay):\n'
                  '• Employer EPF 12%: LKR 10,200.00  • Employer ETF 3%: LKR 2,550.00',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveRequestTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Submit Digital Leave Pass / Poya Lieu Request',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _leaveType,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Leave Category'),
                items: const [
                  DropdownMenuItem(
                      value: 'Annual Leave (14 Days Quota)',
                      child: Text('Annual Leave (10 / 14 Days Remaining)')),
                  DropdownMenuItem(
                      value: 'Casual Leave (7 Days Quota)',
                      child: Text('Casual Leave (5 / 7 Days Remaining)')),
                  DropdownMenuItem(
                      value: 'Poya / Mercantile Lieu Day',
                      child: Text('Poya / Mercantile Lieu Day (2 Accrued)')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _leaveType = v);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dates & Reason for HOD Approval',
                  hintText: 'e.g. 2026-04-20 (1 Day) — Family Avurudu visit',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _leaveHistory.insert(0, {
                        'dates': _reasonCtrl.text.trim().isEmpty
                            ? '2026-04-20 (1 Day)'
                            : _reasonCtrl.text.trim(),
                        'type': _leaveType,
                        'status': 'PENDING HOD APPROVAL',
                      });
                      _reasonCtrl.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Leave request dispatched to Department Head.'),
                        backgroundColor: AppColors.emerald,
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Submit Leave Application'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._leaveHistory.map((l) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: LiquidGlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l['dates']!,
                              style: const TextStyle(
                                  fontSize: 12.5, fontWeight: FontWeight.w800)),
                          Text(l['type']!,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Text(
                      l['status']!,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.emerald),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildShiftRosterTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: _mySchedule.map((s) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['day']!,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.emerald)),
                const SizedBox(height: 4),
                Text(s['shift']!,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700)),
                Text('Station: ${s['station']} • ${s['meal']}',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _line(String label, String val, bool positive, {bool bold = false}) {
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
            val,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: positive ? AppColors.emerald : AppColors.rose,
            ),
          ),
        ],
      ),
    );
  }
}
