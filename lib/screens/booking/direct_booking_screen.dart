import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/l10n/translations.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/tax/tax_engine.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

/// Web-Parity 3-Step Direct Booking Engine, Curated Add-Ons, Voucher & Public Banquet Inquiry
/// (`DirectBookingEngine.tsx`, `BookingAddonsStep.tsx`, `DirectBookingCheckout.tsx`, `BookingVoucherView.tsx`, `PublicBanquetInquiry.tsx`).
class DirectBookingScreen extends StatefulWidget {
  const DirectBookingScreen({super.key});

  @override
  State<DirectBookingScreen> createState() => _DirectBookingScreenState();
}

class _DirectBookingScreenState extends State<DirectBookingScreen> {
  int _bookingStep = 0; // 0 = Room Selection, 1 = Stay Add-ons, 2 = Checkout & Voucher, 3 = Wedding Inquiry
  DateTime _checkIn = DateTime.now().add(const Duration(days: 7));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 10));
  final int _adults = 2;
  final int _children = 0;
  String _selectedCategory = 'Deluxe Ocean View';
  bool _isForeignUsd = false;
  final Set<String> _selectedAddons = {'addon-airport'};
  bool _voucherIssued = false;

  final List<Map<String, dynamic>> _roomCatalog = [
    {
      'name': 'Superior Garden Pool',
      'rateLkr': 36000.0,
      'size': '38 m² • 1 Queen Bed',
      'amenities': ['Garden View', 'Pool Access', 'Ceylon Tea Bar', 'Wi-Fi 6'],
      'photo': WebAssets.boutiqueCourtyardLogin,
    },
    {
      'name': 'Deluxe Ocean View',
      'rateLkr': 48500.0,
      'size': '46 m² • 1 King Four-Poster Bed',
      'amenities': ['Indian Ocean View', 'Private Balcony', 'Rain Shower', 'Tea Bar'],
      'photo': WebAssets.roomDeluxeOcean,
    },
    {
      'name': 'Colonial Suite Galle',
      'rateLkr': 89000.0,
      'size': '74 m² • Heritage Master Suite',
      'amenities': ['Rampart View', 'Butler Service', 'Freestanding Tub', 'Verandah'],
      'photo': WebAssets.roomHeritageSuite,
    },
    {
      'name': 'Heritage Villa Pavillion',
      'rateLkr': 115000.0,
      'size': '118 m² • Private Plunge Pool Villa',
      'amenities': ['Private Infinity Pool', 'Beachfront Deck', 'Ayurveda Bath', 'VIP Transfer'],
      'photo': WebAssets.roomBeachfrontVilla,
    },
  ];

  final List<Map<String, dynamic>> _addonsCatalog = [
    {
      'id': 'addon-airport',
      'title': 'BIA Airport Luxury Chauffeur Pickup',
      'priceLkr': 34000.0,
      'photo': WebAssets.boutiqueCourtyardLogin,
    },
    {
      'id': 'addon-whale',
      'title': 'Mirissa Blue Whale Catamaran Cruise (2 Pax)',
      'priceLkr': 28000.0,
      'photo': WebAssets.roomBeachfrontVilla,
    },
    {
      'id': 'addon-dinner',
      'title': 'Private Rampart Candlelight Seafood Dinner',
      'priceLkr': 22000.0,
      'photo': WebAssets.dishCrabHoppers,
    },
    {
      'id': 'addon-spa',
      'title': 'Ayurveda Shirodhara & Herbal Steam (Couple)',
      'priceLkr': 26000.0,
      'photo': WebAssets.spaAyurvedaPavilion,
    },
  ];

  int get _nights {
    final diff = _checkOut.difference(_checkIn).inDays;
    return diff > 0 ? diff : 1;
  }

  double get _nightlyRate {
    final found = _roomCatalog.firstWhere(
      (r) => r['name'] == _selectedCategory,
      orElse: () => _roomCatalog[1],
    );
    return (found['rateLkr'] as num).toDouble();
  }

  double get _addonsTotal => _addonsCatalog
      .where((a) => _selectedAddons.contains(a['id']))
      .fold(0.0, (s, a) => s + (a['priceLkr'] as double));

  double get _baseTotal => (_nightlyRate * _nights) + _addonsTotal;

  String _formatRate(double lkr) {
    if (_isForeignUsd) {
      return CurrencyEngine.formatUsd(CurrencyEngine.lkrToUsd(lkr));
    }
    return CurrencyEngine.formatLkr(lkr);
  }

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
      body: Column(
        children: [
          // Stepper / Mode Tabs
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
                children: [
                  ChoiceChip(
                    label: const Text('1. Rooms & Dates'),
                    selected: _bookingStep == 0,
                    onSelected: (_) => setState(() => _bookingStep = 0),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: Text('2. Stay Add-Ons (${_selectedAddons.length})'),
                    selected: _bookingStep == 1,
                    onSelected: (_) => setState(() => _bookingStep = 1),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('3. Checkout & Voucher'),
                    selected: _bookingStep == 2,
                    onSelected: (_) => setState(() => _bookingStep = 2),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('4. Wedding / Banquet Inquiry'),
                    selected: _bookingStep == 3,
                    onSelected: (_) => setState(() => _bookingStep = 3),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              child: _bookingStep == 3
                  ? _buildPublicBanquetInquiryForm(context, isDark)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const WebHeroBannerCard(
                          assetPath: WebAssets.galleFortHero,
                          badgeText: 'Best Rate Guaranteed • 0% OTA Commission',
                          rightPillText: 'Instant Voucher',
                          title: 'Galle Fort Lighthouse Villa — Direct Booking',
                          subtitle: 'Complimentary Ceylon High Tea & Late Check-Out for Direct Guests',
                          height: 165,
                        ),
                        const SizedBox(height: 14),

                        if (_bookingStep == 0) ...[
                          // Dates & Residency Selector
                          LiquidGlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Select Stay Dates & Residency Tier',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => setState(() => _isForeignUsd = !_isForeignUsd),
                                      child: MetricBadge(
                                        label: _isForeignUsd ? 'Foreign (USD)' : 'Resident (LKR)',
                                        color: theme.primaryColor,
                                        icon: CupertinoIcons.globe,
                                      ),
                                    ),
                                  ],
                                ),
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
                                Text(
                                  'Duration: $_nights Nights • $_adults Adults, $_children Children',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text('Available Luxury Rooms, Suites & Villas', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(height: 8),
                          ..._roomCatalog.map((room) {
                            final String name = room['name'] as String;
                            final double rate = (room['rateLkr'] as num).toDouble();
                            final String size = room['size'] as String;
                            final List<String> amenities = List<String>.from(room['amenities'] as List);
                            final String photo = room['photo'] as String;
                            final isSel = _selectedCategory == name;

                            return LiquidGlassCard(
                              padding: const EdgeInsets.all(12),
                              onTap: () => setState(() => _selectedCategory = name),
                              backgroundColor: isSel ? AppTheme.brandSurfaceTint(context) : null,
                              customBorder: isSel ? Border.all(color: theme.primaryColor, width: 1.8) : null,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      WebImageThumbnail(
                                        assetPath: photo,
                                        width: 74,
                                        height: 74,
                                        borderRadius: 12,
                                        fallbackIcon: CupertinoIcons.bed_double_fill,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    name,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Icon(
                                                  isSel ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                                                  color: isSel ? theme.primaryColor : Colors.grey,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(size, style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                                            const SizedBox(height: 5),
                                            Text(
                                              '${_formatRate(rate)} / night',
                                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: theme.primaryColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: amenities.map((a) => MetricBadge(label: a, color: const Color(0xFF475569))).toList(),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ] else if (_bookingStep == 1) ...[
                          // Step 2: Curated Stay Add-Ons (`BookingAddonsStep.tsx`)
                          const Text('Enhance Your Stay with Curated Experiences', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(height: 8),
                          ..._addonsCatalog.map((addon) {
                            final id = addon['id'] as String;
                            final isSel = _selectedAddons.contains(id);
                            return LiquidGlassCard(
                              padding: const EdgeInsets.all(12),
                              onTap: () {
                                setState(() {
                                  if (isSel) {
                                    _selectedAddons.remove(id);
                                  } else {
                                    _selectedAddons.add(id);
                                  }
                                });
                              },
                              backgroundColor: isSel ? AppTheme.brandSurfaceTint(context) : null,
                              child: Row(
                                children: [
                                  WebImageThumbnail(
                                    assetPath: addon['photo'] as String,
                                    width: 56,
                                    height: 56,
                                    borderRadius: 10,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(addon['title'] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                                        const SizedBox(height: 4),
                                        Text(_formatRate(addon['priceLkr'] as double), style: TextStyle(fontWeight: FontWeight.w800, color: theme.primaryColor)),
                                      ],
                                    ),
                                  ),
                                  Checkbox(
                                    value: isSel,
                                    activeColor: theme.primaryColor,
                                    onChanged: (_) {
                                      setState(() {
                                        if (isSel) {
                                          _selectedAddons.remove(id);
                                        } else {
                                          _selectedAddons.add(id);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],

                        const SizedBox(height: 14),
                        // Summary & 4-Stage Tax Confirmation Card
                        LiquidGlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Booking Price & Statutory Tax Breakdown', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                              const SizedBox(height: 10),
                              _priceRow('$_nights Nights × ${_formatRate(_nightlyRate)}', _nightlyRate * _nights, isDark),
                              if (_addonsTotal > 0)
                                _priceRow('Curated Add-Ons (${_selectedAddons.length})', _addonsTotal, isDark),
                              _priceRow('10% Mandatory Service Charge', tax.serviceCharge, isDark),
                              _priceRow('1% SLTDA Tourism Levy (TDL)', tax.tdl, isDark),
                              _priceRow('2.5% SSCL + 18% VAT Compounded', tax.sscl + tax.vat, isDark),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text('Grand Total (Incl. Taxes):', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5)),
                                  ),
                                  Text(
                                    _formatRate(tax.grandTotal),
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: theme.primaryColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  icon: const Icon(CupertinoIcons.checkmark_seal_fill, size: 17),
                                  label: Text(
                                    _bookingStep < 2 ? 'Continue to Checkout →' : 'Confirm Direct Booking',
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  onPressed: () {
                                    if (_bookingStep < 2) {
                                      setState(() => _bookingStep++);
                                    } else {
                                      setState(() => _voucherIssued = true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Reservation confirmed for $_selectedCategory! Confirmation voucher & SMS sent.'),
                                          backgroundColor: const Color(0xFF16A34A),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (_voucherIssued) ...[
                          const SizedBox(height: 12),
                          LiquidGlassCard(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: AppTheme.brandSurfaceTint(context),
                            customBorder: Border.all(color: AppTheme.brandBorderTint(context)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Official Direct Booking Confirmation Voucher (#VCH-2026-994)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text('Room: $_selectedCategory • $_nights Nights • Pre-Check-In Link Active'),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Public Banquet & Poruwa Wedding Inquiry Form (`PublicBanquetInquiry.tsx`)
  Widget _buildPublicBanquetInquiryForm(BuildContext context, bool isDark) {
    final coupleCtrl = TextEditingController(text: 'Kasun & Dilini');
    final paxCtrl = TextEditingController(text: '250');
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Public Poruwa Wedding & Corporate MICE Inquiry', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 10),
          TextField(controller: coupleCtrl, decoration: const InputDecoration(labelText: 'Bride & Groom / Corporate Client Name *')),
          const SizedBox(height: 10),
          TextField(controller: paxCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Estimated Guest Headcount (Pax) *')),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Banquet Lead added to Sales Follow-Up Queue!'),
                    backgroundColor: Color(0xFF16A34A),
                  ),
                );
              },
              child: const Text('Submit Wedding & Banquet Inquiry'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double lkrAmount, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
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
            _formatRate(lkrAmount),
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
