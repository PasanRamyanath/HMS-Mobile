import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/api/appsync_client.dart';
import '../../widgets/liquid_glass_card.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final client = AppSyncClient();
    final payrollList = client.payroll;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('hospitality_payroll')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Service Charge Pool Overview
          LiquidGlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('10% Service Charge Pool', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF15803D).withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('March 2026 Pool', style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.w700, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  CurrencyEngine.formatLkr(2456300),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF15803D)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Distributed 100% to staff points: LKR 42,350.00 per point share.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Individual Staff Slips
          const Text('Staff Pay Slips & Statutory EPF/ETF', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 8),

          ...payrollList.map((staff) {
            return LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(staff.staffName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      Text(staff.designation, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: theme.primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Basic + Allowances:'),
                      Text(CurrencyEngine.formatLkr(staff.basicSalaryLkr + staff.allowancesLkr), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('+ 10% Service Charge Share:', style: TextStyle(color: Color(0xFF15803D))),
                      Text(CurrencyEngine.formatLkr(staff.serviceChargeShareLkr), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('- 8% Employee EPF:', style: TextStyle(color: Colors.redAccent)),
                      Text('- ${CurrencyEngine.formatLkr(staff.deductions.epfEmployee)}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent)),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Net Take-Home Pay:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                      Text(CurrencyEngine.formatLkr(staff.deductions.netTakeHome), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: theme.primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Employer Contribution: 12% EPF (${CurrencyEngine.formatLkr(staff.deductions.epfEmployer)}) + 3% ETF (${CurrencyEngine.formatLkr(staff.deductions.etfEmployer)})',
                    style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
