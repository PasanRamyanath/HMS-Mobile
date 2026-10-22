import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/api/appsync_client.dart';
import '../../widgets/liquid_glass_card.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;

  const SettingsScreen({super.key, required this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _hexController = TextEditingController(text: '#0F5132');
  final TextEditingController _endpointController = TextEditingController(text: AppSyncClient().graphqlEndpoint);

  @override
  void dispose() {
    _hexController.dispose();
    _endpointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final client = AppSyncClient();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('settings')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ceylon Luxury Theme Presets
            LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(CupertinoIcons.paintbrush_fill, color: Color(0xFF0F5132)),
                      const SizedBox(width: 8),
                      const Text(
                        'Ceylon Luxury Theme Presets',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppTheme.presets.map((preset) {
                      final isSelected = AppTheme.activePreset.id == preset.id;
                      return ChoiceChip(
                        avatar: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(color: preset.primaryColor, shape: BoxShape.circle),
                        ),
                        label: Text(preset.name),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              AppTheme.setPreset(preset.id);
                              _hexController.text = '#${preset.primaryColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
                            });
                            widget.onThemeChanged();
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Custom HEX Color Picker
                  const Text('Custom Brand HEX Color:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _hexController,
                          decoration: const InputDecoration(
                            hintText: '#0F5132',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          final text = _hexController.text.replaceAll('#', '').trim();
                          if (text.length == 6) {
                            final val = int.tryParse('0xFF$text');
                            if (val != null) {
                              AppTheme.setCustomColor(Color(val));
                              widget.onThemeChanged();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Theme set to #${text.toUpperCase()}')),
                              );
                            }
                          }
                        },
                        child: const Text('Apply HEX'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Trilingual Language Engine
            LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.globe, color: Color(0xFF0284C7)),
                      SizedBox(width: 8),
                      Text('System Language / භාෂාව / மொழி', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildLangButton('English (UK/LK)', AppLanguage.en),
                      const SizedBox(width: 8),
                      _buildLangButton('සිංහල (Sinhala)', AppLanguage.si),
                      const SizedBox(width: 8),
                      _buildLangButton('தமிழ் (Tamil)', AppLanguage.ta),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // CBSL FX Central Bank Engine
            LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.money_dollar_circle_fill, color: Color(0xFF0D9488)),
                      SizedBox(width: 8),
                      Text('Central Bank of Sri Lanka (CBSL) FX', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current CBSL Mid-Rate: 1 USD = LKR ${CurrencyEngine.usdToLkrRate.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text('Automated real-time statutory sync for multi-currency folios and LankaQR settlements.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // AWS Cloud Backend Diagnostics
            LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.cloud_fill, color: Color(0xFFEA580C)),
                      SizedBox(width: 8),
                      Text('AWS AppSync GraphQL Endpoint', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _endpointController,
                    decoration: const InputDecoration(
                      labelText: 'AppSync GraphQL URL (ap-south-1)',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      client.setEndpoint(_endpointController.text.trim());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('AppSync GraphQL Endpoint updated!')),
                      );
                    },
                    child: const Text('Update Endpoint'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(String label, AppLanguage lang) {
    final isSelected = AppTranslations.currentLanguage == lang;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          backgroundColor: isSelected ? Theme.of(context).primaryColor.withAlpha(30) : null,
          side: BorderSide(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withAlpha(80),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          setState(() {
            AppTranslations.setLanguage(lang);
          });
          widget.onThemeChanged();
        },
        child: Text(
          label.split(' ')[0],
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
        ),
      ),
    );
  }
}
