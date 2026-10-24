import 'package:flutter/material.dart';
import '../../core/auth/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/liquid_glass_card.dart';

class SaasSuperAdminScreen extends StatefulWidget {
  const SaasSuperAdminScreen({super.key});

  @override
  State<SaasSuperAdminScreen> createState() => _SaasSuperAdminScreenState();
}

class _SaasSuperAdminScreenState extends State<SaasSuperAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _tenants = [
    {
      'id': 'TEN-CMB-001',
      'name': 'Ceylon Heritage Grand Resort & Spa (Galle Face)',
      'tier': 'Enterprise Plus (Unlimited Keys)',
      'rooms': 45,
      'occupancy': '84.4%',
      'mrrLkr': 145000,
      'status': 'ACTIVE',
      'sltdaNo': 'SLTDA/HM/2026/0091',
    },
    {
      'id': 'TEN-KDY-002',
      'name': 'Kandyan Cloud Retreat & Ayurveda Sanctuary',
      'tier': 'Boutique Pro (Up to 35 Keys)',
      'rooms': 28,
      'occupancy': '78.5%',
      'mrrLkr': 79000,
      'status': 'ACTIVE',
      'sltdaNo': 'SLTDA/BT/2026/0144',
    },
    {
      'id': 'TEN-YLA-003',
      'name': 'Yala Wild Leopard Tented Safari Camp',
      'tier': 'Boutique Pro (Up to 35 Keys)',
      'rooms': 18,
      'occupancy': '91.0%',
      'mrrLkr': 79000,
      'status': 'ACTIVE',
      'sltdaNo': 'SLTDA/EC/2026/0312',
    },
    {
      'id': 'TEN-ELL-004',
      'name': 'Nine Arch Tea Estate Bungalow (Ella)',
      'tier': 'Villa Starter (Up to 12 Keys)',
      'rooms': 10,
      'occupancy': '70.0%',
      'mrrLkr': 39000,
      'status': 'TRIAL (11 Days Left)',
      'sltdaNo': 'SLTDA/VL/2026/0510',
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

  void _showProvisionTenantModal() {
    final nameCtrl = TextEditingController();
    final sltdaCtrl = TextEditingController(text: 'SLTDA/HM/2026/0800');
    String tier = 'Enterprise Plus (Unlimited Keys)';

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
                const Text(
                  'Provision New Sri Lankan Resort Tenant',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Property / Resort Name',
                    hintText: 'e.g. Bentota Cinnamon Beach Resort',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: sltdaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'SLTDA Registration Number',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: tier,
                  isExpanded: true,
                  decoration:
                      const InputDecoration(labelText: 'SaaS Subscription Tier'),
                  items: const [
                    DropdownMenuItem(
                        value: 'Villa Starter (Up to 12 Keys)',
                        child: Text('Villa Starter — LKR 39,000/mo')),
                    DropdownMenuItem(
                        value: 'Boutique Pro (Up to 35 Keys)',
                        child: Text('Boutique Pro — LKR 79,000/mo')),
                    DropdownMenuItem(
                        value: 'Enterprise Plus (Unlimited Keys)',
                        child: Text('Enterprise Plus — LKR 145,000/mo')),
                  ],
                  onChanged: (v) {
                    if (v != null) setModalState(() => tier = v);
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty) return;
                      setState(() {
                        _tenants.insert(0, {
                          'id': 'TEN-NEW-005',
                          'name': nameCtrl.text.trim(),
                          'tier': tier,
                          'rooms': 32,
                          'occupancy': '0.0% (Onboarding)',
                          'mrrLkr': 145000,
                          'status': 'ACTIVE',
                          'sltdaNo': sltdaCtrl.text.trim(),
                        });
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'New hotel tenant isolated schema & Cognito user pool provisioned!'),
                          backgroundColor: AppColors.emerald,
                        ),
                      );
                    },
                    icon: const Icon(Icons.cloud_done_rounded, size: 16),
                    label: const Text('Deploy Isolated Tenant Instance'),
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
    final role = AuthState.instance.currentRole;
    final hasAccess =
        role == StaffRole.superAdmin || role == StaffRole.hotelAdmin;

    if (!hasAccess) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LiquidGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_person_rounded,
                    size: 48, color: AppColors.rose),
                const SizedBox(height: 12),
                const Text(
                  'RBAC Guard: Super Admin Clearance Required',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Your active role (${role.label}) does not have SUPER_ADMIN privileges to manage multi-tenant cloud infrastructure.',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    AuthState.instance.switchRole(StaffRole.superAdmin);
                    setState(() {});
                  },
                  icon: const Icon(Icons.verified_user_rounded, size: 16),
                  label: const Text('Elevate to SaaS Super Admin (9999)'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: WebHeroBannerCard(
            imagePath: WebAssets.heroSuite,
            badgeText: 'MULTI-TENANT CLOUD CONTROL PLANE • AWS AP-SOUTH-1',
            title: 'SaaS Super Admin & Chain Rollup',
            subtitle:
                'Provision Sri Lankan hotel tenants, inspect AWS Free Tier guardrails (RDS/Lambda/Cognito/S3), and monitor island-wide portfolio RevPAR.',
            height: 144,
            trailing: ElevatedButton.icon(
              onPressed: _showProvisionTenantModal,
              icon: const Icon(Icons.add_business_rounded, size: 16),
              label: const Text('New Tenant'),
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
              Tab(text: '1. Tenant Directory'),
              Tab(text: '2. AWS Free Tier Meters'),
              Tab(text: '3. Group Chain Rollup'),
              Tab(text: '4. Backups & Billing'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTenantsTab(),
              _buildAwsMetersTab(),
              _buildChainRollupTab(),
              _buildBackupsBillingTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTenantsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: _tenants.map((t) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${t['id']} • ${t['sltdaNo']}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.emerald,
                      ),
                    ),
                    Text(
                      'MRR: LKR ${t['mrrLkr']}/mo',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  t['name'],
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${t['tier']} • ${t['rooms']} Keys • Live Occ: ${t['occupancy']}',
                  style:
                      TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAwsMetersTab() {
    final meters = [
      {'service': 'Amazon RDS PostgreSQL (db.t4g.micro 20GB)', 'usage': '12.4 GB / 20 GB (62%)', 'pct': 0.62},
      {'service': 'AWS Lambda Invocations (1M Free/mo)', 'usage': '412,800 / 1,000,000 (41%)', 'pct': 0.41},
      {'service': 'Amazon Cognito MAUs (50,000 Free Tier)', 'usage': '1,840 / 50,000 (3.7%)', 'pct': 0.04},
      {'service': 'Amazon S3 Folio & B-Card Vault (5GB)', 'usage': '2.1 GB / 5.0 GB (42%)', 'pct': 0.42},
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: meters.map((m) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m['service'] as String,
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(m['usage'] as String,
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: m['pct'] as double,
                    minHeight: 7,
                    color: AppColors.emerald,
                    backgroundColor: AppColors.bgElevated,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChainRollupTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Island-Wide Portfolio Consolidated Performance (4 Properties)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
                '• Total Active Inventory: 101 Keys across Colombo, Kandy, Yala & Ella\n'
                '• Portfolio Weighted Occupancy: 82.6%\n'
                '• Consolidated Group MTD Revenue: LKR 84.6M\n'
                '• Platform SaaS Recurring Billing (ARR): LKR 4.10M / yr',
                style: TextStyle(fontSize: 11.5, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackupsBillingTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Point-in-Time RDS Snapshots & Tenant SaaS Invoices',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Latest Automated Encrypted Snapshot: Today 03:00 AM SLST (ap-south-1 Mumbai)\n'
                '• RPO / RTO SLA: 5-Minute Point-in-Time Recovery • 99.98% Uptime',
                style: TextStyle(fontSize: 11.5, height: 1.5),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Manual encrypted PostgreSQL snapshot triggered across all 4 tenant schemas.'),
                      backgroundColor: AppColors.emerald,
                    ),
                  );
                },
                icon: const Icon(Icons.backup_rounded, size: 16),
                label: const Text('Trigger Instant Multi-Tenant Snapshot'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
