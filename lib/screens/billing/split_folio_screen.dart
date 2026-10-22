import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/tax/tax_engine.dart';
import '../../core/api/appsync_client.dart';
import '../../models/hotel_models.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';
import 'lanka_qr_screen.dart';

class SplitFolioScreen extends StatefulWidget {
  const SplitFolioScreen({super.key});

  @override
  State<SplitFolioScreen> createState() => _SplitFolioScreenState();
}

class _SplitFolioScreenState extends State<SplitFolioScreen> {
  int _selectedSplitTab = 0; // 0 = Master Bill, 1 = Extras Bill
  final double _masterBase = 145000.0;
  final double _extrasBase = 42800.0;
  bool _showUsd = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final client = AppSyncClient();
    final folios = client.folios;
    final currentFolio = folios.isNotEmpty ? folios.first : null;

    final activeBase = _selectedSplitTab == 0 ? _masterBase : _extrasBase;
    final tax = TaxEngine.calculate(baseAmount: activeBase);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('split_folios')),
        actions: [
          IconButton(
            icon: Icon(_showUsd ? CupertinoIcons.money_dollar : CupertinoIcons.money_rubl),
            onPressed: () => setState(() => _showUsd = !_showUsd),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guest & Folio Info Header
            LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentFolio?.folioNumber ?? 'FOL #101-DR-PERERA',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      MetricBadge(
                        label: currentFolio?.isSettled == true ? 'SETTLED' : 'OPEN / ACTIVE',
                        color: currentFolio?.isSettled == true ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Guest: ${currentFolio?.guestName ?? "Dr. Michael Perera"} | Room: ${currentFolio?.roomNumber ?? "101"}',
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF475569)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Split Tab Selector (Master vs Extras)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSplitTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedSplitTab == 0 ? theme.primaryColor : (isDark ? const Color(0xFF131D2E) : Colors.white),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _selectedSplitTab == 0 ? theme.primaryColor : const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        'Folio A (Master Room)',
                        style: TextStyle(
                          color: _selectedSplitTab == 0 ? Colors.white : (isDark ? Colors.white : Colors.black),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSplitTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedSplitTab == 1 ? theme.primaryColor : (isDark ? const Color(0xFF131D2E) : Colors.white),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _selectedSplitTab == 1 ? theme.primaryColor : const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        'Folio B (F&B Extras)',
                        style: TextStyle(
                          color: _selectedSplitTab == 1 ? Colors.white : (isDark ? Colors.white : Colors.black),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Sri Lankan Statutory 4-Stage Compounding Tax Breakdown Card
            LiquidGlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(CupertinoIcons.doc_plaintext, size: 16, color: Color(0xFF0284C7)),
                      const SizedBox(width: 8),
                      const Text(
                        'Statutory 4-Stage Compounding Breakdown',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildTaxRow('Base Subtotal', activeBase, isDark),
                  _buildTaxRow('+ 10% Service Charge (Mandatory)', tax.serviceCharge, isDark),
                  _buildTaxRow('+ 1% Tourism Development Levy (TDL)', tax.tdl, isDark),
                  _buildTaxRow('+ 2.5% Social Security Levy (SSCL)', tax.sscl, isDark),
                  _buildTaxRow('+ 18% Value Added Tax (VAT)', tax.vat, isDark),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grand Total Payable:',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      Text(
                        _showUsd
                            ? CurrencyEngine.formatUsd(CurrencyEngine.lkrToUsd(tax.grandTotal))
                            : CurrencyEngine.formatLkr(tax.grandTotal),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Effective Statutory Levy: ~${tax.effectiveTaxPercentage.toStringAsFixed(2)}% compounding rate',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Checkout Buttons
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(CupertinoIcons.qrcode_viewfinder),
                label: Text(
                  AppTranslations.tr('generate_lankaqr'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LankaQrScreen(
                        amountLkr: tax.grandTotal,
                        folioReference: currentFolio?.folioNumber ?? 'FOL-101',
                        guestName: currentFolio?.guestName ?? 'Dr. Michael Perera',
                        onPaymentConfirmed: () {
                          if (currentFolio != null) {
                            client.recordPayment(
                              currentFolio.id,
                              FolioPayment(
                                id: 'PAY-${DateTime.now().millisecondsSinceEpoch % 1000}',
                                timestamp: DateTime.now(),
                                method: 'LankaQR',
                                amountLkr: tax.grandTotal,
                                referenceId: 'LANKAQR-CEFT-${DateTime.now().millisecondsSinceEpoch % 10000}',
                              ),
                            );
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(CupertinoIcons.creditcard, size: 16),
                    label: const Text('Credit Card'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Payment gateway terminal triggered for EMV chip & PIN.')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(CupertinoIcons.money_dollar, size: 16),
                    label: const Text('Cash (LKR/USD)'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cash drawer receipt printed.')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxRow(String title, double amount, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569))),
          Text(
            _showUsd
                ? CurrencyEngine.formatUsd(CurrencyEngine.lkrToUsd(amount))
                : CurrencyEngine.formatLkr(amount),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
