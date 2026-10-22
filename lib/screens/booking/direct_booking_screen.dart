import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/l10n/translations.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/tax/tax_engine.dart';
import '../../widgets/liquid_glass_card.dart';

class DirectBookingScreen extends StatefulWidget {
  const DirectBookingScreen({super.key});

  @override
  State<DirectBookingScreen> createState() => _DirectBookingScreenState();
}

class _DirectBookingScreenState extends State<DirectBookingScreen> {
  DateTime _checkIn = DateTime.now().add(const Duration(days: 7));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 10));
  final int _adults = 2;
  final int _children = 0;
  String _selectedCategory = 'Deluxe Ocean View';

  final Map<String, double> _categoryRates = {
    'Superior Garden Pool': 36000.0,
    'Deluxe Ocean View': 48500.0,
    'Colonial Suite Galle': 89000.0,
    'Heritage Villa Pavillion': 115000.0,
  };

  int get _nights => _checkOut.difference(_checkIn).inDays;
  double get _nightlyRate => _categoryRates[_selectedCategory] ?? 48500.0;
  double get _baseTotal => _nightlyRate * (_nights > 0 ? _nights : 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tax = TaxEngine.calculate(baseAmount: _baseTotal);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('direct_booking')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dates & Guests Selector Card
            LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Stay Dates & Occupancy', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(CupertinoIcons.calendar, size: 14),
                          label: Text('In: ${DateFormat('dd MMM').format(_checkIn)}'),
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: _checkIn,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 180)),
                            );
                            if (d != null) setState(() => _checkIn = d);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(CupertinoIcons.calendar, size: 14),
                          label: Text('Out: ${DateFormat('dd MMM').format(_checkOut)}'),
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: _checkOut,
                              firstDate: _checkIn.add(const Duration(days: 1)),
                              lastDate: DateTime.now().add(const Duration(days: 180)),
                            );
                            if (d != null) setState(() => _checkOut = d);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Duration: $_nights Nights | Adults: $_adults | Children: $_children', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Room Categories List
            const Text('Available Luxury Rooms & Suites', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 8),
            ..._categoryRates.entries.map((entry) {
              final isSel = _selectedCategory == entry.key;
              return LiquidGlassCard(
                padding: const EdgeInsets.all(14),
                onTap: () => setState(() => _selectedCategory = entry.key),
                backgroundColor: isSel ? theme.primaryColor.withAlpha(isDark ? 45 : 25) : null,
                customBorder: isSel ? Border.all(color: theme.primaryColor, width: 2) : null,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withAlpha(isDark ? 50 : 25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(CupertinoIcons.bed_double_fill, color: theme.primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('Dutch Colonial Architecture • Balcony • Wi-Fi', style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : const Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Text(
                            '${CurrencyEngine.formatLkr(entry.value)} / night (~USD ${CurrencyEngine.lkrToUsd(entry.value).toStringAsFixed(0)})',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: theme.primaryColor),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSel ? theme.primaryColor : Colors.transparent,
                        border: Border.all(
                          color: isSel ? theme.primaryColor : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: isSel
                          ? const Icon(CupertinoIcons.checkmark, size: 14, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 14),

            // Summary & Confirmation
            LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Booking Price Breakdown', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$_nights Nights x ${CurrencyEngine.formatLkr(_nightlyRate)}:'),
                      Text(CurrencyEngine.formatLkr(_baseTotal), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Statutory Taxes (SC, TDL, SSCL, VAT):', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(CurrencyEngine.formatLkr(tax.totalTaxesAndLevies), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Grand Total:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(CurrencyEngine.formatLkr(tax.grandTotal), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: theme.primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Reservation confirmed for $_selectedCategory! Confirmation SMS sent.'),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      child: const Text('Confirm Direct Booking', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
