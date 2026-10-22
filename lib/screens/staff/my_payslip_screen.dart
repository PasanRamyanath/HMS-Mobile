import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/auth/auth_state.dart';
import '../../core/tax/tax_engine.dart';
import '../../widgets/liquid_glass_card.dart';

class MyPayslipScreen extends StatelessWidget {
  const MyPayslipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = AuthState();
    final role = auth.currentRole;

    const double basicSalary = 75000.0;
    const double attendanceAllowance = 15000.0;
    const double serviceChargeShare = 42350.0; // 10% SC pool point
    final deductions = TaxEngine.calculatePayroll(
      grossSalary: basicSalary + attendanceAllowance,
      serviceChargeShare: serviceChargeShare,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Mobile Payslip & EPF/ETF'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Staff Profile Card
          LiquidGlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withAlpha(isDark ? 40 : 25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(CupertinoIcons.person_fill, color: theme.primaryColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auth.currentUser?.name ?? 'Staff Member', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(role.displayName, style: TextStyle(fontSize: 12, color: theme.primaryColor, fontWeight: FontWeight.w600)),
                      const Text('EMP #CEY-8421 | Galle Fort Property', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Net Take-Home Hero Card
          LiquidGlassCard(
            padding: const EdgeInsets.all(20),
            backgroundColor: const Color(0xFF15803D).withAlpha(isDark ? 40 : 25),
            child: Column(
              children: [
                const Text('March 2026 Net Take-Home Pay', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF15803D))),
                const SizedBox(height: 8),
                Text(
                  CurrencyEngine.formatLkr(deductions.netTakeHome),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 30, color: Color(0xFF15803D), letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                const Text('Credited via SLIPS / CEFT to Commercial Bank Account', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Breakdown
          LiquidGlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Earnings & Allowances', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 8),
                _row('Basic Monthly Salary', basicSalary, isDark),
                _row('Attendance & Transport Allowance', attendanceAllowance, isDark),
                _row('10% Hotel Service Charge Pool Share', serviceChargeShare, isDark, highlight: true),
                const Divider(height: 20),
                const Text('Statutory Deductions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 8),
                _row('8% Employee EPF Contribution', -deductions.epfEmployee, isDark, isNegative: true),
                const Divider(height: 20),
                const Text('Statutory Employer Contributions (Non-Deducted)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 8),
                _row('12% Employer EPF Contribution', deductions.epfEmployer, isDark),
                _row('3% Employer ETF Contribution', deductions.etfEmployer, isDark),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Quick Leave Request Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              icon: const Icon(CupertinoIcons.calendar_badge_plus, size: 16),
              label: const Text('Submit Annual / Casual Leave Request'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Leave request form opened for GM approval.')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String title, double amount, bool isDark, {bool highlight = false, bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569))),
          Text(
            isNegative ? '- ${CurrencyEngine.formatLkr(amount.abs())}' : CurrencyEngine.formatLkr(amount),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: highlight ? const Color(0xFF15803D) : (isNegative ? Colors.redAccent : null),
            ),
          ),
        ],
      ),
    );
  }
}
