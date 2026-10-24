import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/l10n/translations.dart';
import '../../core/api/appsync_client.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/theme/app_theme.dart';
import '../../models/hotel_models.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

/// Web-Parity Express Check-In, Live Sri Lankan NIC Decoder, Driver Dorm Subform & Digital Reg Card
/// (`PreCheckInForm.tsx`, `GuestIdentityField.tsx`, `DriverQuartersSubform.tsx`, `RegCardSignatureModal.tsx`, `PrintableRegCard.tsx`).
class ExpressCheckinScreen extends StatefulWidget {
  const ExpressCheckinScreen({super.key});

  @override
  State<ExpressCheckinScreen> createState() => _ExpressCheckinScreenState();
}

class _ExpressCheckinScreenState extends State<ExpressCheckinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Rohan Jayasuriya');
  final _phoneController = TextEditingController(text: '+94 77 987 6543');
  final _idController = TextEditingController(text: '199014502390');
  final _driverNameCtrl = TextEditingController(text: 'Sunil Perera');
  final _vehicleRegCtrl = TextEditingController(text: 'WP CAB-4490');
  String _selectedRoom = '104';
  MealPlan _selectedMealPlan = MealPlan.hb;
  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 3));
  bool _isCheckedIn = false;
  bool _policeBCardVerified = true;
  bool _hasChauffeurDriver = false;
  bool _signatureCaptured = true;

  bool _validateSriLankanNicOrPassport(String value) {
    if (value.trim().isEmpty) return false;
    final oldNicRegex = RegExp(r'^[0-9]{9}[vVxX]$');
    final newNicRegex = RegExp(r'^[0-9]{12}$');
    final passportRegex = RegExp(r'^[A-Za-z]{1,2}[0-9]{6,8}$');

    return oldNicRegex.hasMatch(value.trim()) ||
        newNicRegex.hasMatch(value.trim()) ||
        passportRegex.hasMatch(value.trim());
  }

  /// Decodes Sri Lankan Old (9-digit V/X) or New (12-digit) NIC into Birth Year & Gender (`GuestIdentityField.tsx`)
  String _decodeNicSummary(String raw) {
    final clean = raw.trim().toUpperCase();
    int? year;
    int? days;
    if (RegExp(r'^\d{9}[VX]$').hasMatch(clean)) {
      year = 1900 + int.parse(clean.substring(0, 2));
      days = int.parse(clean.substring(2, 5));
    } else if (RegExp(r'^\d{12}$').hasMatch(clean)) {
      year = int.parse(clean.substring(0, 4));
      days = int.parse(clean.substring(4, 7));
    } else if (RegExp(r'^[A-Z]{1,2}\d{6,8}$').hasMatch(clean)) {
      return 'Foreign Passport Verified • Visa & SLTDA Form B-Card Active';
    } else {
      return 'Enter 9-digit V/X NIC, 12-digit NIC, or Foreign Passport';
    }
    String gender = 'Male';
    if (days > 500) {
      gender = 'Female';
      days -= 500;
    }
    return 'SL NIC Decoded: Born $year • Gender: $gender • Day #$days';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _idController.dispose();
    _driverNameCtrl.dispose();
    _vehicleRegCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final client = AppSyncClient();
    final vacantRooms = client.rooms.where((r) => !r.isOccupied).toList();
    final allRooms = client.rooms;

    final selectedRoomObj = allRooms.firstWhere(
      (r) => r.roomNumber == _selectedRoom,
      orElse: () => allRooms.first,
    );

    if (vacantRooms.isNotEmpty && !vacantRooms.any((r) => r.roomNumber == _selectedRoom)) {
      _selectedRoom = vacantRooms.first.roomNumber;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('express_checkin')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected Room Photographic Preview Banner
              WebHeroBannerCard(
                assetPath: WebAssets.roomImageForCategory(selectedRoomObj.categoryName),
                badgeText: 'SLTDA Form B-Card • Police Register Ready',
                rightPillText: 'Floor ${selectedRoomObj.floor}',
                title: 'Room ${selectedRoomObj.roomNumber} — ${selectedRoomObj.categoryName}',
                subtitle:
                    '${CurrencyEngine.formatLkr(selectedRoomObj.rateLkr)} / night • Max ${selectedRoomObj.occupancyLimit} Adults',
                height: 160,
              ),
              const SizedBox(height: 14),

              LiquidGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.brandSurfaceTint(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(CupertinoIcons.person_badge_plus, color: theme.primaryColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Express Guest Registration',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                ),
                              ),
                              Text(
                                'Digital Reg Card, NIC/Passport Decoder & Driver Quarters',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Guest Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Guest Full Name *',
                        prefixIcon: Icon(CupertinoIcons.person, size: 18),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Please enter guest name' : null,
                    ),
                    const SizedBox(height: 12),

                    // NIC or Passport with Live Decoder Badge
                    TextFormField(
                      controller: _idController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Sri Lankan NIC (Old/New) or Passport *',
                        hintText: 'e.g. 199014502390 or 842150334V or N1234567',
                        prefixIcon: Icon(CupertinoIcons.doc_text, size: 18),
                      ),
                      validator: (val) {
                        if (val == null || !_validateSriLankanNicOrPassport(val)) {
                          return 'Enter valid 9-digit+V/X, 12-digit NIC, or Passport';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 6),
                    MetricBadge(
                      label: _decodeNicSummary(_idController.text),
                      color: theme.primaryColor,
                      icon: CupertinoIcons.checkmark_shield_fill,
                    ),
                    const SizedBox(height: 12),

                    // Phone Number
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Phone / WhatsApp *',
                        prefixIcon: Icon(CupertinoIcons.phone, size: 18),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Please enter contact number' : null,
                    ),
                    const SizedBox(height: 14),

                    // Room Selection (`isExpanded: true` prevents overflow)
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedRoom,
                      decoration: const InputDecoration(
                        labelText: 'Select Assigned Room *',
                        prefixIcon: Icon(CupertinoIcons.bed_double, size: 18),
                      ),
                      items: (vacantRooms.isNotEmpty ? vacantRooms : allRooms).map((r) {
                        return DropdownMenuItem(
                          value: r.roomNumber,
                          child: Text(
                            'Room ${r.roomNumber} - ${r.categoryName} (Fl. ${r.floor})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRoom = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Meal Plan
                    const Text(
                      'Meal Plan Entitlement:',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: MealPlan.values.map((plan) {
                        return ChoiceChip(
                          label: Text(plan.name.toUpperCase()),
                          selected: _selectedMealPlan == plan,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedMealPlan = plan);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Dates Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(CupertinoIcons.calendar, size: 14),
                            label: Text(
                              'In: ${DateFormat('dd MMM').format(_checkInDate)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _checkInDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 7)),
                                lastDate: DateTime.now().add(const Duration(days: 60)),
                              );
                              if (picked != null) setState(() => _checkInDate = picked);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(CupertinoIcons.calendar, size: 14),
                            label: Text(
                              'Out: ${DateFormat('dd MMM').format(_checkOutDate)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _checkOutDate,
                                firstDate: _checkInDate,
                                lastDate: DateTime.now().add(const Duration(days: 90)),
                              );
                              if (picked != null) setState(() => _checkOutDate = picked);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tourist Chauffeur / Driver Quarters Subform (`DriverQuartersSubform.tsx`)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSubtleSurface : AppTheme.lightSubtleSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: _hasChauffeurDriver,
                                  activeColor: theme.primaryColor,
                                  onChanged: (v) => setState(() => _hasChauffeurDriver = v ?? false),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Guest Arrived with Tourist Chauffeur / Driver (Assign Dorm Bed & Meal Pass)',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          if (_hasChauffeurDriver) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _driverNameCtrl,
                                    decoration: const InputDecoration(labelText: 'Driver Name'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _vehicleRegCtrl,
                                    decoration: const InputDecoration(labelText: 'Vehicle Plate'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Digital Signature & Police B-Card Consent (`RegCardSignatureModal.tsx`)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSubtleSurface : AppTheme.lightSubtleSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Checkbox(
                              value: _policeBCardVerified && _signatureCaptured,
                              activeColor: theme.primaryColor,
                              onChanged: (v) => setState(() {
                                _policeBCardVerified = v ?? true;
                                _signatureCaptured = v ?? true;
                              }),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Digital Guest Signature Captured & Logged to Tourist Police B-Card Register',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Check-In Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(CupertinoIcons.checkmark_seal_fill, size: 18),
                        label: Text(
                          AppTranslations.tr('check_in_guest'),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final firstResId = client.reservations.isNotEmpty
                                ? client.reservations.first.id
                                : 'RES-2026-001';
                            client.checkInGuest(firstResId, _selectedRoom);

                            setState(() {
                              _isCheckedIn = true;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Guest ${_nameController.text.trim()} checked into Room $_selectedRoom!',
                                ),
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

              if (_isCheckedIn) ...[
                const SizedBox(height: 14),
                LiquidGlassCard(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppTheme.brandSurfaceTint(context),
                  customBorder: Border.all(color: AppTheme.brandBorderTint(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(CupertinoIcons.checkmark_seal_fill, color: theme.primaryColor, size: 26),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Printable Registration Card Issued',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                            ),
                          ),
                          MetricBadge(label: 'Room $_selectedRoom', color: theme.primaryColor),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Keycard encoded for Room $_selectedRoom (${_selectedMealPlan.name.toUpperCase()}). Wi-Fi voucher & Contactless Guest Dining QR link sent via SMSGo.lk to ${_phoneController.text}.',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
