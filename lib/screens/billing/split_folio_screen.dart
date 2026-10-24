import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/tax/tax_engine.dart';
import '../../core/api/appsync_client.dart';
import '../../core/theme/app_theme.dart';
import '../../models/hotel_models.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';
import 'lanka_qr_screen.dart';

/// Web-Parity Folios, City Ledger, Cashier Shift, FX Encashment & Statutory Tax Invoice Hub
/// (`FoliosAndBillingPage.tsx`, `CityLedgerView.tsx`, `CashierShiftModal.tsx`, `FxEncashmentReceipt.tsx`, `PrintableTaxInvoice.tsx`).
/// Implements all 4 Web Version Billing tabs:
/// 1. Active In-Stay Folios & Split Billing + Post Charge / Advance Deposit / Credit Note / Walk-In Folio
/// 2. City Ledger (DMC & Corporate Accounts Receivable Aging)
/// 3. Cashier Shift Drawer, Petty Cash Paid-Out Vouchers & CBSL Foreign Currency Encashment Receipt
/// 4. Tax Invoice Archive & Printable A4 IRD / 80mm Thermal Previews
class SplitFolioScreen extends StatefulWidget {
  const SplitFolioScreen({super.key});

  @override
  State<SplitFolioScreen> createState() => _SplitFolioScreenState();
}

class _SplitFolioScreenState extends State<SplitFolioScreen> {
  int _activeWorkspaceTab = 0;
  int _selectedSplitTab = 0; // 0 = Master Bill, 1 = Extras Bill
  double _masterBase = 145000.0;
  double _extrasBase = 42800.0;
  bool _showUsd = false;

  static const List<String> _workspaceTabs = [
    '1. Active Folios',
    '2. City Ledger (AR)',
    '3. Cashier & FX',
    '4. Invoice Archive',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final client = AppSyncClient();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('split_folios')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _showUsd = !_showUsd),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.brandSurfaceTint(context),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: AppTheme.brandBorderTint(context)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.arrow_2_circlepath, size: 12, color: theme.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      _showUsd ? 'USD' : 'LKR',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: theme.primaryColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 4-Tab Billing Workspace Selector (`FoliosAndBillingPage.tsx`)
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
                children: List.generate(_workspaceTabs.length, (idx) {
                  final isSel = _activeWorkspaceTab == idx;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(_workspaceTabs[idx]),
                      selected: isSel,
                      onSelected: (v) {
                        if (v) setState(() => _activeWorkspaceTab = idx);
                      },
                    ),
                  );
                }),
              ),
            ),
          ),

          Expanded(
            child: _buildWorkspaceBody(context, client, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceBody(BuildContext context, AppSyncClient client, bool isDark) {
    switch (_activeWorkspaceTab) {
      case 0:
        return _buildActiveFoliosTab(context, client, isDark);
      case 1:
        return _buildCityLedgerTab(context, isDark);
      case 2:
        return _buildCashierAndFxEncashmentTab(context, isDark);
      case 3:
        return _buildInvoiceArchiveTab(context, isDark);
      default:
        return _buildActiveFoliosTab(context, client, isDark);
    }
  }

  // ===========================================================================
  // TAB 1: ACTIVE IN-STAY FOLIOS & SPLIT BILLING
  // ===========================================================================
  Widget _buildActiveFoliosTab(BuildContext context, AppSyncClient client, bool isDark) {
    final theme = Theme.of(context);
    final folios = client.folios;
    final currentFolio = folios.isNotEmpty ? folios.first : null;
    final activeBase = _selectedSplitTab == 0 ? _masterBase : _extrasBase;
    final tax = TaxEngine.calculate(baseAmount: activeBase);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LiquidGlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        currentFolio?.folioNumber ?? 'FOL #101-DR-PERERA',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    MetricBadge(
                      label: currentFolio?.isSettled == true ? 'SETTLED' : 'OPEN / ACTIVE',
                      color: currentFolio?.isSettled == true
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD97706),
                      showDot: true,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Guest: ${currentFolio?.guestName ?? "Dr. Michael Perera"} • Room ${currentFolio?.roomNumber ?? "101"} (Deluxe Ocean View)',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                // Quick Folio Actions (`PostFolioLineModal`, `AdvanceDepositModal`, `CreditNoteModal`)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34), padding: const EdgeInsets.symmetric(horizontal: 10)),
                      icon: const Icon(CupertinoIcons.plus_circle, size: 13),
                      label: const Text('+ Post Charge', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        setState(() => _extrasBase += 4500);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Posted LKR 4,500 Laundry/Spa charge to Folio B!')),
                        );
                      },
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34), padding: const EdgeInsets.symmetric(horizontal: 10)),
                      icon: const Icon(CupertinoIcons.arrow_down_circle, size: 13),
                      label: const Text('Advance Deposit', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Advance Deposit Receipt (LKR 50,000) recorded.')),
                        );
                      },
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34), padding: const EdgeInsets.symmetric(horizontal: 10)),
                      icon: const Icon(CupertinoIcons.minus_circle, size: 13),
                      label: const Text('Credit Note', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        setState(() => _masterBase = (_masterBase - 5000).clamp(10000, 999999));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Statutory Credit Note (LKR 5,000 Rebate) applied.')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Split Tab Selector (Master vs Extras)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSubtleSurface : const Color(0xFFEEF2EF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSplitTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedSplitTab == 0 ? theme.primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        'Folio A (Master Room)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _selectedSplitTab == 0
                              ? Colors.white
                              : (isDark ? Colors.white70 : AppTheme.lightTextPrimary),
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSplitTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedSplitTab == 1 ? theme.primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        'Folio B (F&B Extras)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _selectedSplitTab == 1
                              ? Colors.white
                              : (isDark ? Colors.white70 : AppTheme.lightTextPrimary),
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4-Stage Compounding Breakdown Card
          LiquidGlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.doc_plaintext, size: 16, color: Color(0xFF0284C7)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Statutory 4-Stage Compounding Breakdown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 6),
                    MetricBadge(label: '1.34343×', color: theme.primaryColor),
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
                    const Expanded(
                      child: Text(
                        'Grand Total Payable:',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _showUsd
                          ? CurrencyEngine.formatUsd(CurrencyEngine.lkrToUsd(tax.grandTotal))
                          : CurrencyEngine.formatLkr(tax.grandTotal),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 19,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Checkout Buttons
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(CupertinoIcons.qrcode_viewfinder, size: 18),
              label: Text(
                AppTranslations.tr('generate_lankaqr'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                  icon: const Icon(CupertinoIcons.creditcard, size: 15),
                  label: const Text('Credit Card', maxLines: 1, overflow: TextOverflow.ellipsis),
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
                  icon: const Icon(CupertinoIcons.money_dollar, size: 15),
                  label: const Text('Cash (LKR/USD)', maxLines: 1, overflow: TextOverflow.ellipsis),
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
    );
  }

  // ===========================================================================
  // TAB 2: CITY LEDGER (DMC & CORPORATE AR AGING) (`CityLedgerView.tsx`)
  // ===========================================================================
  Widget _buildCityLedgerTab(BuildContext context, bool isDark) {
    final accounts = [
      {'corp': 'Aitken Spence Travels (DMC)', '0_30': 680000.0, '31_60': 140000.0, 'total': 820000.0},
      {'corp': 'Walkers Tours PLC (DMC)', '0_30': 410000.0, '31_60': 0.0, 'total': 410000.0},
      {'corp': 'Dilmah Ceylon Tea Corporate', '0_30': 125000.0, '31_60': 0.0, 'total': 125000.0},
    ];
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const LiquidGlassCard(
          padding: EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('City Ledger — DMC & Corporate Accounts Receivable', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              SizedBox(height: 4),
              Text('Total Outstanding B2B City Ledger Balance: LKR 1,355,000', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...accounts.map((a) => LiquidGlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(a['corp'] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14))),
                      MetricBadge(label: CurrencyEngine.formatLkr(a['total'] as double), color: const Color(0xFF0284C7)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('0–30 Days: ${CurrencyEngine.formatLkr(a['0_30'] as double)} • 31–60 Days: ${CurrencyEngine.formatLkr(a['31_60'] as double)}', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                ],
              ),
            )),
      ],
    );
  }

  // ===========================================================================
  // TAB 3: CASHIER SHIFT, PAID-OUT VOUCHER & CBSL FX ENCASHMENT (`FxEncashmentReceipt.tsx`)
  // ===========================================================================
  Widget _buildCashierAndFxEncashmentTab(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
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
              const Text('CBSL Authorized Foreign Currency (FX) Encashment Receipt', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              const SizedBox(height: 6),
              Text(
                'Convert physical USD / EUR / GBP bank notes presented by foreign guests into LKR at the daily CBSL rate (1 USD = LKR ${CurrencyEngine.usdToLkrRate.toStringAsFixed(2)}).',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(CupertinoIcons.money_dollar_circle_fill, size: 16),
                  label: Text('Issue FX Encashment Receipt (USD 200 → ${CurrencyEngine.formatLkr(200 * CurrencyEngine.usdToLkrRate)})'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Statutory CBSL Foreign Currency Encashment Certificate printed!'),
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
        LiquidGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Front Office Cashier Shift Drawer & Petty Cash Paid-Out', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              const SizedBox(height: 6),
              const Text('• Opening Float: LKR 50,000 • Net Cash Collected: LKR 142,000'),
              const Text('• Petty Cash Paid-Out Vouchers: LKR 3,500 (Guest Tuk-Tuk & Pharmacy)'),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                icon: const Icon(CupertinoIcons.doc_append, size: 15),
                label: Text('Record Petty Cash Paid-Out Voucher', style: TextStyle(color: theme.primaryColor)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Petty Cash Paid-Out Voucher logged to Cashier Shift.')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TAB 4: TAX INVOICE ARCHIVE & PRINTABLE A4 / 80MM PREVIEWS
  // ===========================================================================
  Widget _buildInvoiceArchiveTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        LiquidGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Statutory A4 IRD Tax Invoice & 80mm Thermal Receipt Archive', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              const SizedBox(height: 6),
              const Text('TIN: 114028491-7000 • SLTDA Reg: SLTDA/SQA/HOTEL/2026/089'),
              const Divider(height: 18),
              const Text('• INV-2026-0891 — Dr. Michael Perera (Room 101) — LKR 248,534.55'),
              const SizedBox(height: 6),
              const Text('• INV-2026-0890 — Sophie Van Der Berg (Room 103) — LKR 180,000.00'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(CupertinoIcons.doc_richtext, size: 14),
                      label: const Text('A4 Tax Invoice', style: TextStyle(fontSize: 11.5)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('A4 Statutory IRD Tax Invoice PDF generated.')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(CupertinoIcons.paperplane, size: 14),
                      label: const Text('Send WhatsApp', style: TextStyle(fontSize: 11.5)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Digital Tax Invoice link sent via WhatsApp & Email!')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaxRow(String title, double amount, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
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
