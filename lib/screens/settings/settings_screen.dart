import 'package:flutter/material.dart';
import '../../core/auth/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/liquid_glass_card.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onThemeChanged;
  const SettingsScreen({super.key, this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<bool> _onboardingSteps = [true, true, true, true, false];
  double _cbslUsdRate = 298.50;
  double _cbslEurRate = 324.80;
  bool _payHereLive = true;
  bool _lankaQrDynamic = true;
  bool _smsGoEnabled = true;

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

  @override
  Widget build(BuildContext context) {
    final themeCtrl = ThemeController.instance;
    return ListenableBuilder(
      listenable: Listenable.merge([themeCtrl, AuthState.instance]),
      builder: (context, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: WebHeroBannerCard(
                imagePath: WebAssets.heroResort,
                badgeText:
                    'WEB-PARITY THEME STUDIO • 8 CEYLON PALETTES • RBAC MATRIX',
                title: 'Property Configuration & Theme Studio',
                subtitle:
                    'Switch Light/Dark/System mode, customize 8 Curated Ceylon Luxury Palettes, configure 34.2545% taxes, PayHere/LankaQR, SMSGo.lk, and Staff RBAC.',
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
                  Tab(text: '1. Appearance & Palettes'),
                  Tab(text: '2. 5-Step Onboarding'),
                  Tab(text: '3. 4-Stage Taxes'),
                  Tab(text: '4. PayHere & CBSL FX'),
                  Tab(text: '5. SMSGo.lk Templates'),
                  Tab(text: '6. Staff RBAC & SaaS'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAppearanceTab(themeCtrl),
                  _buildOnboardingTab(),
                  _buildTaxesTab(),
                  _buildPaymentsFxTab(),
                  _buildSmsTemplatesTab(),
                  _buildRbacMatrixTab(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppearanceTab(ThemeController themeCtrl) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Web-Matched Theme Mode (Light Default + Dark Switcher)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Matches hms-frontend index.css: Light Mode (#F4F7F5 Warm Stone Canvas + #FFFFFF Cards) or Dark Mode (#0B1120 Obsidian Slate).',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    avatar: const Icon(Icons.light_mode_rounded, size: 16),
                    label: const Text('Light Mode (Web Default)'),
                    selected: themeCtrl.themeMode == ThemeMode.light,
                    onSelected: (_) => themeCtrl.setThemeMode(ThemeMode.light),
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.dark_mode_rounded, size: 16),
                    label: const Text('Dark Mode (KDS / Night)'),
                    selected: themeCtrl.themeMode == ThemeMode.dark,
                    onSelected: (_) => themeCtrl.setThemeMode(ThemeMode.dark),
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.brightness_auto_rounded, size: 16),
                    label: const Text('System Auto'),
                    selected: themeCtrl.themeMode == ThemeMode.system,
                    onSelected: (_) => themeCtrl.setThemeMode(ThemeMode.system),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '8 Curated Ceylon Luxury Color Palettes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Instant live brand accent adaptation across all buttons, badges, charts, and cards.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ...ThemeController.palettes.map((p) {
                final active = themeCtrl.currentPalette.id == p.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => themeCtrl.setPalette(p.id),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: active
                            ? p.primary.withValues(alpha: 0.12)
                            : AppColors.bgElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: active ? p.primary : AppColors.glassBorder,
                          width: active ? 1.8 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: p.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: p.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  p.subtitle,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          if (active)
                            Icon(Icons.check_circle_rounded,
                                color: p.primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOnboardingTab() {
    final steps = [
      '1. SLTDA Registration Certificate & IRD VAT/TIN Verified',
      '2. Room Categories, Seasonal Tariffs & Meal Plan Supplements (RO/BB/HB/FB/AI)',
      '3. Sri Lanka 4-Stage Cascading Tax Formula (10% SC + 1% TDL + 2.5% SSCL + 18% VAT)',
      '4. Channex.io OTA Bridge (Booking.com / Agoda / Expedia) Live Mapping',
      '5. LankaPay Dynamic QR & PayHere IPG Merchant Keys Activated',
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '5-Step Property Onboarding & SLTDA Readiness Checklist',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              ...List.generate(steps.length, (i) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _onboardingSteps[i],
                  activeColor: AppColors.emerald,
                  title: Text(steps[i], style: const TextStyle(fontSize: 12)),
                  onChanged: (v) =>
                      setState(() => _onboardingSteps[i] = v ?? false),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaxesTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Sri Lanka Statutory Cascading Tax Rules (34.2545%)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
                '• Stage 1a: 10.00% Service Charge (90% Staff Pool / 10% Breakage Retention)\n'
                '• Stage 1b: 1.00% SLTDA Tourism Development Levy (TDL)\n'
                '• Stage 2: 2.50% SSCL on Subtotal 1 (= 2.7750% effective)\n'
                '• Stage 3: 18.00% IRD VAT on Subtotal 2 (= 20.4795% effective)\n'
                '• Combined Effective Tax Multiplier: 1.342545x (++++ Pricing)',
                style: TextStyle(fontSize: 11.5, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsFxTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PayHere IPG, LankaQR & CBSL Foreign Currency Rates',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('PayHere Sri Lanka Multi-Currency Gateway',
                    style: TextStyle(fontSize: 12.5)),
                value: _payHereLive,
                activeColor: AppColors.emerald,
                onChanged: (v) => setState(() => _payHereLive = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('LankaQR Central Bank Dynamic EMVCo QR',
                    style: TextStyle(fontSize: 12.5)),
                value: _lankaQrDynamic,
                activeColor: AppColors.emerald,
                onChanged: (v) => setState(() => _lankaQrDynamic = v),
              ),
              const Divider(),
              Text(
                  'CBSL Daily Buying Rate (USD -> LKR): ${_cbslUsdRate.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700)),
              Slider(
                value: _cbslUsdRate,
                min: 280,
                max: 330,
                activeColor: AppColors.emerald,
                onChanged: (v) => setState(() => _cbslUsdRate = v),
              ),
              Text(
                  'CBSL Daily Buying Rate (EUR -> LKR): ${_cbslEurRate.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700)),
              Slider(
                value: _cbslEurRate,
                min: 300,
                max: 360,
                activeColor: AppColors.emerald,
                onChanged: (v) => setState(() => _cbslEurRate = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmsTemplatesTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'SMSGo.lk / Dialog Rich Communications Gateway',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Sender ID: CEYLONHMS (Trilingual UTF-8)',
                    style: TextStyle(fontSize: 11)),
                value: _smsGoEnabled,
                activeColor: AppColors.emerald,
                onChanged: (v) => setState(() => _smsGoEnabled = v),
              ),
              const Divider(),
              const Text(
                '• Booking Confirmation (EN/SI/TA): "Ayubowan {guest_name}! Your stay at Ceylon Heritage Resort ({check_in}) is confirmed. Ref: {bk_id}"\n'
                '• Pre-Arrival Express Check-In Link: "Skip the front desk queue! Upload your NIC/Passport: https://ceylonhms.lk/checkin/{token}"\n'
                '• Folio E-Receipt & Airport Chauffeur Dispatch Alert',
                style: TextStyle(fontSize: 11.5, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRbacMatrixTab() {
    final activeRole = AuthState.instance.currentRole;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Interactive Role-Based Access Control (RBAC) Matrix',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap any role below to switch the live session and test route-level permissions across the mobile app.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ...StaffRole.values.map((role) {
                final selected = role == activeRole;
                final perms = AuthState.rolePermissions[role] ?? [];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => AuthState.instance.switchRole(role),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.emerald.withValues(alpha: 0.12)
                            : AppColors.bgElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? AppColors.emerald
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                selected
                                    ? Icons.verified_user_rounded
                                    : Icons.badge_outlined,
                                size: 18,
                                color: selected
                                    ? AppColors.emerald
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${role.label} (${role.webRoleCode})',
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                              if (selected)
                                const Text(
                                  'ACTIVE SESSION',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.emerald,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Permissions: ${perms.join(" • ")}',
                            style: TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
