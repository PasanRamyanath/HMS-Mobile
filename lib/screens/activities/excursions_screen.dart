import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/liquid_glass_card.dart';

class ExcursionsScreen extends StatefulWidget {
  const ExcursionsScreen({super.key});

  @override
  State<ExcursionsScreen> createState() => _ExcursionsScreenState();
}

class _ExcursionsScreenState extends State<ExcursionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _flights = [
    {
      'flight': 'UL 504 (SriLankan Airlines - London Heathrow)',
      'eta': '12:45 PM',
      'terminal': 'CMB Bandaranaike T1',
      'guest': 'Mr. & Mrs. Sterling (Rm 402)',
      'vehicle': 'Toyota Prado WP CAB-8821',
      'chauffeur': 'Nimal Perera (+94 77 221 9001)',
      'pagingBoard': 'Printed • Cold Towel & King Coconut Ready',
      'status': 'LANDED - CHAUFFEUR AT ARRIVALS',
    },
    {
      'flight': 'EK 650 (Emirates - Dubai DXB)',
      'eta': '03:15 PM',
      'terminal': 'CMB Bandaranaike T1',
      'guest': 'Dr. Hiroshi Tanaka (Rm 301)',
      'vehicle': 'Mercedes V-Class WP CBI-4410',
      'chauffeur': 'Roshan Silva (+94 71 445 1290)',
      'pagingBoard': 'Printed • Highway Toll Float Issued',
      'status': 'EN ROUTE TO AIRPORT',
    },
    {
      'flight': 'QR 664 (Qatar Airways - Doha DOH)',
      'eta': '08:20 PM (Departure)',
      'terminal': 'CMB Departures',
      'guest': 'Ms. Elena Rostova (Rm 105)',
      'vehicle': 'Toyota KDH High-Roof WP NB-7712',
      'chauffeur': 'Kasun Jayawardena',
      'pagingBoard': 'Baggage Down at 04:30 PM',
      'status': 'SCHEDULED',
    },
  ];

  final List<Map<String, dynamic>> _safaris = [
    {
      'title': 'Yala Block 1 Leopard Dawn Jeep Safari (4x4 Hilux)',
      'departure': '04:45 AM',
      'wakeUpCall': '04:15 AM (Auto-logged with Front Desk)',
      'breakfastBox': '2x Packed Safari Boxes (Sandwiches, Boiled Eggs, Banana, King Coconut)',
      'guest': 'Rm 204 - Lindqvist Party (2 Pax)',
      'tracker': 'Ajith Kumara (DWC Permit #YL-992)',
      'grossLkr': 48000,
      'vendorPayout': 34000,
      'booked': true,
    },
    {
      'title': 'Mirissa Blue Whale Watching Catamaran + Breakfast',
      'departure': '05:30 AM',
      'wakeUpCall': '05:00 AM (Confirmed)',
      'breakfastBox': '2x Vegetarian Continental Boxes + Seasickness Ginger Tea',
      'guest': 'Rm 305 - Weber Party (2 Pax)',
      'tracker': 'Raja & The Whales Crew',
      'grossLkr': 42000,
      'vendorPayout': 29500,
      'booked': true,
    },
    {
      'title': 'Sigiriya Lion Rock Sunrise Climb & Polonnaruwa Cycles',
      'departure': '05:15 AM',
      'wakeUpCall': '04:45 AM',
      'breakfastBox': '4x Picnic Hampers Synced to Kitchen KDS',
      'guest': 'Rm 401 - Rossi Family (4 Pax)',
      'tracker': 'National GuideUpali (SLTDA #G-1402)',
      'grossLkr': 76000,
      'vendorPayout': 52000,
      'booked': false,
    },
  ];

  final List<Map<String, dynamic>> _gearRentals = [
    {
      'item': '9\'2" Longboard Surfboard + Leash (Weligama Reef)',
      'rate': 'LKR 4,500 / day',
      'guest': 'Rm 109 - Jack Thomson',
      'waiver': 'Digital Indemnity Waiver Signed (#WV-881)',
      'status': 'OUT WITH GUEST',
    },
    {
      'item': 'Trek Marlin 7 Mountain Bike + Helmet (Tea Trail)',
      'rate': 'LKR 3,800 / day',
      'guest': 'Rm 208 - Clara & Marc',
      'waiver': 'Digital Indemnity Waiver Signed (#WV-884)',
      'status': 'OUT WITH GUEST',
    },
    {
      'item': 'Cressi Pro Snorkeling & GoPro Hero12 Kit (Hikkaduwa)',
      'rate': 'LKR 6,000 / day',
      'guest': 'Available in Gear Locker #4',
      'waiver': 'Requires Waiver + Rm Folio Hold',
      'status': 'AVAILABLE',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: WebHeroBannerCard(
            imagePath: WebAssets.heroSafari,
            badgeText: 'CMB AIRPORT TRANSFERS & SAFARI DISPATCH',
            title: 'Excursions, Flight Board & Jeep Desk',
            subtitle:
                'Live CMB UL/EK/QR flight tracker, 04:30 AM Yala safari wake-up + KDS breakfast box sync, surfboard/bike indemnity waivers, and chauffeur splits.',
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
              Tab(text: '1. Airport Flight Board'),
              Tab(text: '2. Safaris & Wake-Up Calls'),
              Tab(text: '3. Gear Rentals & Waivers'),
              Tab(text: '4. Chauffeur Payouts & RevPOR'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFlightBoardTab(),
              _buildSafarisTab(),
              _buildGearRentalsTab(),
              _buildChauffeurPayoutsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlightBoardTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: _flights.map((f) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flight_land_rounded,
                        color: AppColors.emerald, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        f['flight'],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      f['eta'],
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Guest: ${f['guest']} • ${f['terminal']}',
                    style: const TextStyle(fontSize: 11.5)),
                Text('Fleet: ${f['vehicle']} • Chauffeur: ${f['chauffeur']}',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                Text('Paging Status: ${f['pagingBoard']}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.emerald)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSafarisTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: _safaris.map((s) {
        final booked = s['booked'] as bool;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s['title'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Guest: ${s['guest']} • Tracker: ${s['tracker']}',
                    style: const TextStyle(fontSize: 11.5)),
                const SizedBox(height: 4),
                Text(
                  'Departure: ${s['departure']} • Wake-Up Call: ${s['wakeUpCall']}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kitchen KDS Sync: ${s['breakfastBox']}',
                  style:
                      TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Folio: LKR ${s['grossLkr']} (Margin: LKR ${(s['grossLkr'] as int) - (s['vendorPayout'] as int)})',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.emerald),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => s['booked'] = !booked);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Safari wake-up call & KDS packed breakfast box synced for ${s['guest']}'),
                            backgroundColor: AppColors.emerald,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                      ),
                      child: Text(booked ? 'Dispatched ✓' : 'Dispatch Jeep',
                          style: const TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGearRentalsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: _gearRentals.map((g) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        g['item'],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      g['rate'],
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.emerald,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Assigned: ${g['guest']}',
                    style: const TextStyle(fontSize: 11.5)),
                Text('Liability: ${g['waiver']}',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChauffeurPayoutsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Third-Party Safari Jeep & Chauffeur Split Settlement',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _splitRow('Gross Excursion & Transfer Billings (MTD)',
                  'LKR 1,840,000'),
              _splitRow(
                  ' Jeep Tracker & Boat Operator Payouts (70%)', '- LKR 1,288,000'),
              _splitRow('Southern Expressway Toll & Airport Parking Floats',
                  '- LKR 42,500'),
              const Divider(height: 18),
              _splitRow('Net Hotel Experience Commission (27.7%)',
                  'LKR 509,500'),
              _splitRow('Ancillary RevPOR (Per Occupied Room)', 'LKR 14,150'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _splitRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
