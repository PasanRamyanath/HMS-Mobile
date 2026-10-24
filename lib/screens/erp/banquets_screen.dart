import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/liquid_glass_card.dart';

class BanquetsScreen extends StatefulWidget {
  const BanquetsScreen({super.key});

  @override
  State<BanquetsScreen> createState() => _BanquetsScreenState();
}

class _BanquetsScreenState extends State<BanquetsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedHall = 'All Halls';
  int _livePlateCount = 248;
  final int _guaranteedPax = 250;
  int _extraPlatesOpened = 0;

  final List<Map<String, dynamic>> _events = [
    {
      'id': 'BEO-2026-0412',
      'title': 'Perera & Jayawardena Poruwa Wedding',
      'hall': 'Grand Kandyan Ballroom',
      'date': '2026-04-08',
      'pax': 250,
      'packageLkr': 9800,
      'status': 'LIVE EVENT',
      'poruwaTime': '09:42 AM (Subha Muhurtha)',
      'lampLighting': '10:35 AM',
      'kiribathTime': '10:50 AM',
      'goingAway': '03:15 PM',
      'ashtaka': 'master_k_bandara',
      'kandyanDancers': 'Booked (6 Dancers + Magul Bera)',
      'advancePaid': 1250000,
      'totalEstimate': 2850000,
    },
    {
      'id': 'BEO-2026-0415',
      'title': 'Ceylon Tea Exporters Annual AGM & Gala',
      'hall': 'Lotus Garden Pavilion',
      'date': '2026-04-12',
      'pax': 140,
      'packageLkr': 7500,
      'status': 'CONFIRMED',
      'poruwaTime': 'N/A (Corporate)',
      'lampLighting': '06:30 PM',
      'kiribathTime': 'N/A',
      'goingAway': '10:30 PM',
      'ashtaka': 'None',
      'kandyanDancers': 'Welcome Cultural Troupe (2 Pax)',
      'advancePaid': 500000,
      'totalEstimate': 1050000,
    },
    {
      'id': 'BEO-2026-0419',
      'title': 'De Silva Homecoming (2nd Day Red Saree)',
      'hall': 'Sigiriya Poolside Lawn',
      'date': '2026-04-18',
      'pax': 180,
      'packageLkr': 8900,
      'status': 'TENTATIVE (70% Paid)',
      'poruwaTime': '07:15 PM (Welcome)',
      'lampLighting': '07:30 PM',
      'kiribathTime': 'N/A',
      'goingAway': '11:45 PM',
      'ashtaka': 'None',
      'kandyanDancers': 'Fire Limbo & Oriental Band',
      'advancePaid': 1120000,
      'totalEstimate': 1602000,
    },
  ];

  final List<Map<String, dynamic>> _corkageBottles = [
    {
      'brand': 'Johnnie Walker Black Label 1L (Duty Free)',
      'handedIn': 24,
      'opened': 19,
      'empties': 18,
      'balance': 5,
      'corkageFee': 0, // Waived in Gold Package
    },
    {
      'brand': 'Rockland Old Arrack Double Distilled 750ml',
      'handedIn': 30,
      'opened': 22,
      'empties': 21,
      'balance': 8,
      'corkageFee': 1500,
    },
    {
      'brand': 'Jacob\'s Creek Shiraz Cabernet 750ml',
      'handedIn': 12,
      'opened': 10,
      'empties': 10,
      'balance': 2,
      'corkageFee': 2500,
    },
    {
      'brand': 'Lion Lager 625ml Cases (Hotel Supplied)',
      'handedIn': 48,
      'opened': 41,
      'empties': 41,
      'balance': 7,
      'corkageFee': 0,
    },
  ];

  final List<Map<String, dynamic>> _leads = [
    {
      'couple': 'Dilshan & Tharushi',
      'eventDate': '2026-08-22 (Nikini Poya Week)',
      'pax': 300,
      'stage': 'Food Tasting Scheduled',
      'depositStage': 'Stage 2 (50% Paid - LKR 1.4M)',
      'phone': '+94 77 412 8890',
    },
    {
      'couple': 'Sahan & Kavindi',
      'eventDate': '2026-11-14',
      'pax': 220,
      'stage': 'Hall Hold (14 Days)',
      'depositStage': 'Stage 1 (20% Booking Advance - LKR 450k)',
      'phone': '+94 71 902 3341',
    },
    {
      'couple': 'MAS Intimates Q2 Awards Night',
      'eventDate': '2026-05-29',
      'pax': 350,
      'stage': 'Quotation Sent',
      'depositStage': 'Pending LPO / 20% Advance',
      'phone': '+94 11 288 9900',
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

  void _showNewBeoDialog() {
    final titleCtrl = TextEditingController();
    final paxCtrl = TextEditingController(text: '200');
    final poruwaCtrl = TextEditingController(text: '09:30 AM');
    String hall = 'Grand Kandyan Ballroom';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.celebration_rounded,
                        color: AppColors.emerald, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Create Poruwa Wedding / Banquet BEO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Couple / Corporate Event Name',
                    hintText: 'e.g. Fernando & Mendis Poruwa Wedding',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: hall,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Venue / Hall'),
                  items: const [
                    DropdownMenuItem(
                        value: 'Grand Kandyan Ballroom',
                        child: Text('Grand Kandyan Ballroom (Max 350 Pax)')),
                    DropdownMenuItem(
                        value: 'Lotus Garden Pavilion',
                        child: Text('Lotus Garden Pavilion (Max 180 Pax)')),
                    DropdownMenuItem(
                        value: 'Sigiriya Poolside Lawn',
                        child: Text('Sigiriya Poolside Lawn (Max 250 Pax)')),
                  ],
                  onChanged: (v) {
                    if (v != null) setModalState(() => hall = v);
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: paxCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Guaranteed Pax'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: poruwaCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Poruwa Nekath Time'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty) return;
                      final pax = int.tryParse(paxCtrl.text) ?? 200;
                      setState(() {
                        _events.insert(0, {
                          'id': 'BEO-2026-0428',
                          'title': titleCtrl.text.trim(),
                          'hall': hall,
                          'date': '2026-05-02',
                          'pax': pax,
                          'packageLkr': 9500,
                          'status': 'CONFIRMED',
                          'poruwaTime': poruwaCtrl.text.trim(),
                          'lampLighting': '10:15 AM',
                          'kiribathTime': '10:30 AM',
                          'goingAway': '03:30 PM',
                          'ashtaka': 'Booked (Hotel Panel)',
                          'kandyanDancers': '6 Dancers + Magul Bera',
                          'advancePaid': 500000,
                          'totalEstimate': pax * 9500,
                        });
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Banquet Event Order (BEO) created & synced with Kitchen KDS'),
                          backgroundColor: AppColors.emerald,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded,
                        size: 18),
                    label: const Text('Save & Generate BEO Sheet'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: WebHeroBannerCard(
            imagePath: WebAssets.heroBanquet,
            badgeText: 'PORUWA WEDDINGS & CORPORATE BEO ENGINE',
            title: 'Ceylon Banquet & Nekath Command',
            subtitle:
                'Auspicious Poruwa Nekath timelines, duty-free corkage & empty bottle audit, live plate counters, and 20/50/30 stage deposits.',
            height: 146,
            trailing: ElevatedButton.icon(
              onPressed: _showNewBeoDialog,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('New BEO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black87,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
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
              Tab(text: '1. Calendar & Events'),
              Tab(text: '2. Poruwa Nekath & BEO'),
              Tab(text: '3. Menu & Corkage Log'),
              Tab(text: '4. Leads & Deposits'),
              Tab(text: '5. Live Plate Counter'),
              Tab(text: '6. Stewards & Profit'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCalendarEventsTab(),
              _buildPoruwaNekathTab(),
              _buildMenuAndCorkageTab(),
              _buildLeadsAndDepositsTab(),
              _buildLivePlateCounterTab(),
              _buildStewardsAndProfitTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarEventsTab() {
    final halls = [
      'All Halls',
      'Grand Kandyan Ballroom',
      'Lotus Garden Pavilion',
      'Sigiriya Poolside Lawn'
    ];
    final filtered = _selectedHall == 'All Halls'
        ? _events
        : _events.where((e) => e['hall'] == _selectedHall).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: halls.map((h) {
              final active = _selectedHall == h;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(h, style: const TextStyle(fontSize: 11)),
                  selected: active,
                  selectedColor: AppColors.emerald.withValues(alpha: 0.18),
                  onSelected: (_) => setState(() => _selectedHall = h),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        ...filtered.map((ev) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LiquidGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ev['status'] == 'LIVE EVENT'
                                ? AppColors.emerald.withValues(alpha: 0.15)
                                : AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${ev['id']} • ${ev['status']}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: ev['status'] == 'LIVE EVENT'
                                  ? AppColors.emerald
                                  : AppColors.gold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          ev['date'],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ev['title'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _chipInfo(Icons.meeting_room_outlined, ev['hall']),
                        _chipInfo(
                            Icons.groups_2_outlined, '${ev['pax']} Guaranteed'),
                        _chipInfo(Icons.payments_outlined,
                            'LKR ${ev['packageLkr']}/plate++++'),
                      ],
                    ),
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Poruwa: ${ev['poruwaTime']}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _tabController.animateTo(1),
                          icon: const Icon(Icons.schedule_rounded, size: 15),
                          label: const Text('Open BEO Sheet',
                              style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildPoruwaNekathTab() {
    final live = _events.first;
    final milestones = [
      {
        'time': '09:15 AM',
        'title': 'Groom & Bride Welcome Procession (Magul Bera)',
        'owner': 'Cultural Troupe + Banquet Captain',
        'done': true,
      },
      {
        'time': live['poruwaTime'],
        'title': 'Poruwa Ceremony & Jayamangala Gatha (Subha Muhurtha)',
        'owner': 'Ashtaka Master K. Bandara',
        'done': true,
      },
      {
        'time': live['lampLighting'],
        'title': 'Traditional Brass Oil Lamp Lighting & Registration',
        'owner': 'Marriage Registrar + Steward Lead',
        'done': true,
      },
      {
        'time': live['kiribathTime'],
        'title': 'Milk Rice (Kiribath), Kavum, Kokis & Wedding Cake Cutting',
        'owner': 'Pastry Chef + Head Waiter',
        'done': false,
      },
      {
        'time': '12:30 PM',
        'title': 'Grand Kandyan & International Buffet Opening (250 Pax)',
        'owner': 'Executive Chef + Banquet Sous Chef',
        'done': false,
      },
      {
        'time': live['goingAway'],
        'title': 'Going-Away Outfit Change & Vintage Car Departure',
        'owner': 'Bell Desk + Concierge',
        'done': false,
      },
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LIVE BEO: ${live['title']}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Auspicious Nekath Minute-by-Minute Synchronizer • Hall: ${live['hall']}',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ...milestones.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (m['done'] as bool)
                            ? AppColors.emerald.withValues(alpha: 0.08)
                            : AppColors.bgElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: (m['done'] as bool)
                              ? AppColors.emerald.withValues(alpha: 0.4)
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (m['done'] as bool)
                                ? Icons.check_circle_rounded
                                : Icons.access_time_filled_rounded,
                            color: (m['done'] as bool)
                                ? AppColors.emerald
                                : AppColors.gold,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${m['time']} — ${m['title']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Assigned: ${m['owner']}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuAndCorkageTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.liquor_rounded,
                      color: AppColors.gold, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Duty-Free Liquor & Empty Bottle Reconciliation',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Prevents banquet bar disputes: every guest-supplied bottle is tagged with serial stickers; empties are counted before sign-off.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ..._corkageBottles.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.bgElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b['brand'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 10,
                            runSpacing: 6,
                            children: [
                              _miniStat('Handed In', '${b['handedIn']}'),
                              _miniStat('Opened', '${b['opened']}'),
                              _miniStat('Empties Verified', '${b['empties']}'),
                              _miniStat('Unopened Return', '${b['balance']}'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    if ((b['balance'] as int) > 0) {
                                      b['opened'] = (b['opened'] as int) + 1;
                                      b['empties'] = (b['empties'] as int) + 1;
                                      b['balance'] = (b['balance'] as int) - 1;
                                    }
                                  });
                                },
                                icon: const Icon(Icons.add_circle_outline,
                                    size: 14),
                                label: const Text('Open +1 Bottle',
                                    style: TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gold Kandyan Buffet Menu Package (LKR 9,800++++)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Welcome Drink: King Coconut (Thambili) or Fresh Woodapple Nectar\n'
                '• Live Action Stations: Hoppers (Appa), Kottu Roti & Mongolian Wok\n'
                '• Carvery: Slow-Roasted Jaffna Spiced Leg of Lamb & Honey Glazed Chicken\n'
                '• Sri Lankan Heritage: Negombo Lagoon Crab Curry, Black Pork Curry, Cashew & Green Pea Maluwa, Tempered Jackfruit (Polos)\n'
                '• Desserts: Watalappan with Roasted Cashews, Curd & Kithul Treacle, Hot Chocolate Lava Pudding',
                style: TextStyle(fontSize: 11.5, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeadsAndDepositsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wedding & MICE Deposit Schedule (20% / 50% / 30%)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Stage 1: 20% Non-refundable Hall Block • Stage 2: 50% 30 Days Prior • Stage 3: 30% + Extra Plates before Going-Away.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ..._leads.map((l) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bgElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l['couple'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '${l['pax']} Pax',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.emerald,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Target Date: ${l['eventDate']}',
                              style: const TextStyle(fontSize: 11)),
                          Text('Pipeline: ${l['stage']}',
                              style: const TextStyle(fontSize: 11)),
                          Text('Deposit Status: ${l['depositStage']}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold)),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLivePlateCounterTab() {
    final totalServed = _livePlateCount + _extraPlatesOpened;
    final bufferLimit = (_guaranteedPax * 1.10).round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Live Buffet Plate Counter & 10% Buffer Monitor',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Guaranteed: $_guaranteedPax Plates • 10% Kitchen Buffer Cap: $bufferLimit Plates',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$totalServed',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.emerald,
                            ),
                          ),
                          const Text('Plates Released',
                              style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$_extraPlatesOpened',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold,
                            ),
                          ),
                          const Text('Billable Extra Plates',
                              style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        if (_livePlateCount < _guaranteedPax) {
                          _livePlateCount++;
                        } else {
                          _extraPlatesOpened++;
                        }
                      });
                    },
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('+1 Plate At Buffet Start'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _extraPlatesOpened += 5;
                      });
                    },
                    icon: const Icon(Icons.layers_rounded, size: 16),
                    label: const Text('Release +5 Extra Buffer Plates'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStewardsAndProfitTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Casual Banquet Stewards & Event P&L',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _profitRow('Gross Banquet Revenue (250 Pax @ 9,800)',
                  'LKR 2,450,000', true),
              _profitRow('Extra Plates & Corkage Fees', 'LKR 142,500', true),
              _profitRow(
                  'F&B Kitchen Cost of Sales (31.2%)', '- LKR 808,860', false),
              _profitRow('18 Casual Stewards Shift Allowance (@ 2,500)',
                  '- LKR 45,000', false),
              _profitRow('Poruwa Florist, Ashtaka & Kandyan Troupe Payout',
                  '- LKR 165,000', false),
              _profitRow('Hall HVAC / Generator Diesel Allocation',
                  '- LKR 68,000', false),
              const Divider(height: 20),
              _profitRow('Net Event Contribution Margin (58.2%)',
                  'LKR 1,505,640', true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chipInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.emerald),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _miniStat(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$label: $val',
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
    );
  }

  Widget _profitRow(String label, String value, bool positive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text(
            value,
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
