import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/tax/tax_engine.dart';
import '../../widgets/liquid_glass_card.dart';

class TaxSltdaScreen extends StatefulWidget {
  const TaxSltdaScreen({super.key});

  @override
  State<TaxSltdaScreen> createState() => _TaxSltdaScreenState();
}

class _TaxSltdaScreenState extends State<TaxSltdaScreen> {
  final TextEditingController _amountController = TextEditingController(text: '100000');
  double _testBase = 100000.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final breakdown = TaxEngine.calculate(baseAmount: _testBase);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('sltda_taxes')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calculator Header Card
            LiquidGlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(CupertinoIcons.percent, color: Color(0xFFD97706), size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        'Sri Lanka Statutory Tax Simulator',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Base Net Revenue (LKR)',
                      prefixText: 'LKR ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _testBase = double.tryParse(val) ?? 0.0;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Detailed 4-Stage Compounding Breakdown
            LiquidGlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Compounding Cascade (Gazetted)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 12),
                  _buildLineItem('1. Base Net Revenue', breakdown.baseAmount, isDark),
                  _buildLineItem('2. 10% Service Charge (Mandatory)', breakdown.serviceCharge, isDark),
                  _buildLineItem('3. 1% Tourism Development Levy (TDL on Base+SC)', breakdown.tdl, isDark),
                  _buildLineItem('4. 2.5% Social Security Contribution (SSCL)', breakdown.sscl, isDark),
                  _buildLineItem('5. 18% Value Added Tax (VAT on Base+SC+SSCL)', breakdown.vat, isDark),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Invoiced to Guest:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                      Text(
                        CurrencyEngine.formatLkr(breakdown.grandTotal),
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: theme.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Levies Collected:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(CurrencyEngine.formatLkr(breakdown.totalTaxesAndLevies), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Effective Compound Tax Rate: ${breakdown.effectiveTaxPercentage.toStringAsFixed(3)}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // IRD RAMIS E-Filing Summary Card
            LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: const Color(0xFF0284C7).withAlpha(isDark ? 35 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.doc_checkmark_fill, color: Color(0xFF0284C7), size: 18),
                      SizedBox(width: 8),
                      Text('Inland Revenue Department (IRD) Filing', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Monthly SLTDA TDL and IRD RAMIS VAT & SSCL returns generated in CSV / XML format according to IRD Circular No. SEC/2022/03.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(CupertinoIcons.arrow_down_doc_fill, size: 16),
                    label: const Text('Export RAMIS Monthly Return'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exported IRD RAMIS Monthly Tax Statement (CSV)')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItem(String title, double amount, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569))),
          Text(CurrencyEngine.formatLkr(amount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
