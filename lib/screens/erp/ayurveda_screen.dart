import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/liquid_glass_card.dart';

class AyurvedaScreen extends StatefulWidget {
  const AyurvedaScreen({super.key});

  @override
  State<AyurvedaScreen> createState() => _AyurvedaScreenState();
}

class _AyurvedaScreenState extends State<AyurvedaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDosha = 'Vata-Pitta';
  int _vataScore = 45;
  int _pittaScore = 35;
  int _kaphaScore = 20;

  final List<Map<String, dynamic>> _appointments = [
    {
      'time': '09:00 AM',
      'guest': 'Mrs. Ingrid Lindqvist (Rm 204)',
      'therapy': 'Shirodhara Warm Sesame Oil Crown Flow (75m)',
      'room': 'Lotus Pavilion 1',
      'therapist': 'Kamani Perera',
      'dosha': 'Vata-Pitta',
      'priceLkr': 24500,
      'status': 'IN THERAPY',
    },
    {
      'time': '10:30 AM',
      'guest': 'Mr. Lukas Weber (Rm 305)',
      'therapy': 'Abhyanga 4-Hand Synchronized Herbal Massage (90m)',
      'room': 'Sandalwood Suite 2',
      'therapist': 'Nimali & Ruwani',
      'dosha': 'Kapha-Vata',
      'priceLkr': 32000,
      'status': 'CONFIRMED',
    },
    {
      'time': '02:00 PM',
      'guest': 'Dr. Ananya Sharma (Rm 108)',
      'therapy': 'Sarvangadhara Pizhichil Medicated Oil Bath (60m)',
      'room': 'Ayur Sanctum 3',
      'therapist': 'Chandrika Silva',
      'dosha': 'Pitta',
      'priceLkr': 28000,
      'status': 'CONFIRMED',
    },
    {
      'time': '04:15 PM',
      'guest': 'Mr. & Mrs. Rossi (Rm 401)',
      'therapy': 'Ceylon Cinnamon & Karapincha Herbal Steam + Foot Ritual',
      'room': 'Couple Villa 1',
      'therapist': 'Saman & Kamani',
      'dosha': 'Tridosha Balance',
      'priceLkr': 38000,
      'status': 'PENDING VOUCHER',
    },
  ];

  final List<Map<String, dynamic>> _panchakarmaGuests = [
    {
      'guest': 'Mrs. Ingrid Lindqvist (Rm 204)',
      'program': '14-Day Authentic Panchakarma Detox',
      'currentDay': 6,
      'totalDays': 14,
      'phase': 'Pradhana Karma (Virechana Herbal Purgation & Shirodhara)',
      'diet': 'Warm Vata-Pacifying Kitchari, Gotukola Kanda & Coriander Tea (No Cold Drinks)',
      'vaidya': 'Vaidya Dr. D. Senanayake (BAMS)',
    },
    {
      'guest': 'Mr. Lukas Weber (Rm 305)',
      'program': '7-Day De-Stress & Spine Rejuvenation',
      'currentDay': 4,
      'totalDays': 7,
      'phase': 'Purvakarma (Snehana Internal/External Oleation & Kati Basti)',
      'diet': 'Light Kapha-Reducing Millet Hopper & Warm Cinnamon Infusion',
      'vaidya': 'Vaidya Dr. D. Senanayake (BAMS)',
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
            imagePath: WebAssets.heroAyurveda,
            badgeText: 'CEYLON AYURVEDA & PANCHAKARMA SANCTUARY',
            title: 'Vaidya Clinical & Spa Scheduler',
            subtitle:
                'Tridosha (Vata / Pitta / Kapha) pulse diagnosis, multi-day Panchakarma clinical plans, kitchen diet sync, and therapist 8% commissions.',
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
              Tab(text: '1. Spa Schedule'),
              Tab(text: '2. Vaidya Tridosha'),
              Tab(text: '3. Panchakarma Tracker'),
              Tab(text: '4. Therapist Commissions'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildScheduleTab(),
              _buildVaidyaTridoshaTab(),
              _buildPanchakarmaTab(),
              _buildCommissionsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: _appointments.map((apt) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
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
                        color: AppColors.emerald.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${apt['time']} • ${apt['room']}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.emerald,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'LKR ${apt['priceLkr']}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  apt['therapy'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${apt['guest']} • Therapist: ${apt['therapist']} • Dosha: ${apt['dosha']}',
                  style:
                      TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() => apt['status'] = 'POSTED TO FOLIO');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${apt['therapy']} posted to Room Folio (LKR ${apt['priceLkr']})'),
                            backgroundColor: AppColors.emerald,
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long_rounded, size: 15),
                      label: Text(
                        apt['status'] == 'POSTED TO FOLIO'
                            ? 'Billed to Folio'
                            : 'Post to Room Folio',
                        style: const TextStyle(fontSize: 11),
                      ),
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

  Widget _buildVaidyaTridoshaTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vaidya Nadi Pariksha (Pulse & Prakriti Assessment)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Interactive Dosha Constitution Profiler — automatically syncs herbal oil temperature & Ayurveda kitchen dietary restrictions.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Vata (Air & Ether)',
                  'Pitta (Fire & Water)',
                  'Kapha (Earth & Water)',
                  'Vata-Pitta',
                  'Tridosha Sama'
                ].map((d) {
                  final selected = _selectedDosha == d;
                  return ChoiceChip(
                    label: Text(d, style: const TextStyle(fontSize: 11)),
                    selected: selected,
                    selectedColor: AppColors.emerald.withValues(alpha: 0.2),
                    onSelected: (_) => setState(() => _selectedDosha = d),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              _doshaSlider('Vata (Movement / Nervous System)', _vataScore,
                  (v) => setState(() => _vataScore = v.round())),
              _doshaSlider('Pitta (Metabolism / Digestion)', _pittaScore,
                  (v) => setState(() => _pittaScore = v.round())),
              _doshaSlider('Kapha (Structure / Immunity)', _kaphaScore,
                  (v) => setState(() => _kaphaScore = v.round())),
              const Divider(height: 20),
              Text(
                'Prescribed Ceylon Herbal Oils & KDS Diet Alert:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• Primary Oil: Warm Mahanarayana & Bala Ashwagandha Taila\n'
                '• Kitchen KDS Tag: NO iced water, NO nightshades/chilies, serve warm Kola Kanda at 07:30 AM.',
                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _doshaSlider(
      String label, int val, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            Text('$val%',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.emerald)),
          ],
        ),
        Slider(
          value: val.toDouble(),
          min: 0,
          max: 100,
          activeColor: AppColors.emerald,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPanchakarmaTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: _panchakarmaGuests.map((pk) {
        final progress = (pk['currentDay'] as int) / (pk['totalDays'] as int);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pk['guest'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pk['program']} • Day ${pk['currentDay']} of ${pk['totalDays']}',
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emerald),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.bgElevated,
                    color: AppColors.emerald,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Clinical Phase: ${pk['phase']}',
                    style: const TextStyle(fontSize: 11.5)),
                const SizedBox(height: 4),
                Text('Ayurveda Kitchen Diet: ${pk['diet']}',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                Text('Supervising Physician: ${pk['vaidya']}',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCommissionsTab() {
    final therapists = [
      {'name': 'Kamani Perera (Senior Therapist)', 'sessions': 38, 'rev': 912000, 'comm': 72960},
      {'name': 'Nimali Fernando (Panchakarma Specialist)', 'sessions': 34, 'rev': 816000, 'comm': 65280},
      {'name': 'Chandrika Silva (Shirodhara Lead)', 'sessions': 29, 'rev': 725000, 'comm': 58000},
      {'name': 'Saman Kumara (Deep Tissue / Kati Basti)', 'sessions': 26, 'rev': 624000, 'comm': 49920},
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Therapist 8% Commission Ledger (Synced to Payroll)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ...therapists.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.bgElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t['name'] as String,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  '${t['sessions']} Therapies • Gross LKR ${t['rev']}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'LKR ${t['comm']}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.emerald,
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
}
