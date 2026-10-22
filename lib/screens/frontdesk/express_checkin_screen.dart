import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/l10n/translations.dart';
import '../../core/api/appsync_client.dart';
import '../../models/hotel_models.dart';
import '../../widgets/liquid_glass_card.dart';

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
  String _selectedRoom = '104';
  MealPlan _selectedMealPlan = MealPlan.hb;
  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 3));
  bool _isCheckedIn = false;

  bool _validateSriLankanNicOrPassport(String value) {
    if (value.trim().isEmpty) return false;
    // Old NIC: 9 digits followed by V or X
    final oldNicRegex = RegExp(r'^[0-9]{9}[vVxX]$');
    // New NIC: 12 digits
    final newNicRegex = RegExp(r'^[0-9]{12}$');
    // Passport: 1-2 letters followed by 6-8 digits
    final passportRegex = RegExp(r'^[A-Za-z]{1,2}[0-9]{6,8}$');

    return oldNicRegex.hasMatch(value.trim()) ||
        newNicRegex.hasMatch(value.trim()) ||
        passportRegex.hasMatch(value.trim());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final client = AppSyncClient();
    final vacantRooms = client.rooms.where((r) => !r.isOccupied).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('express_checkin')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LiquidGlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withAlpha(isDark ? 40 : 25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(CupertinoIcons.person_badge_plus, color: theme.primaryColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Express Guest Registration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                        prefixIcon: Icon(CupertinoIcons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Please enter guest name' : null,
                    ),
                    const SizedBox(height: 12),

                    // NIC or Passport
                    TextFormField(
                      controller: _idController,
                      decoration: const InputDecoration(
                        labelText: 'Sri Lankan NIC (Old/New) or Passport *',
                        hintText: 'e.g. 199014502390 or 842150334V or N1234567',
                        prefixIcon: Icon(CupertinoIcons.doc_text),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      validator: (val) {
                        if (val == null || !_validateSriLankanNicOrPassport(val)) {
                          return 'Enter valid 9-digit+V/X, 12-digit NIC, or Passport';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Phone Number
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Phone / WhatsApp *',
                        prefixIcon: Icon(CupertinoIcons.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Please enter contact number' : null,
                    ),
                    const SizedBox(height: 14),

                    // Room Selection
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRoom,
                      decoration: const InputDecoration(
                        labelText: 'Select Assigned Room *',
                        prefixIcon: Icon(CupertinoIcons.bed_double),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      items: vacantRooms.map((r) {
                        return DropdownMenuItem(
                          value: r.roomNumber,
                          child: Text('Room ${r.roomNumber} - ${r.categoryName} (Floor ${r.floor})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRoom = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Meal Plan
                    const Text('Meal Plan Entitlement:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
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

                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(CupertinoIcons.calendar, size: 14),
                            label: Text('In: ${DateFormat('dd MMM').format(_checkInDate)}'),
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
                            label: Text('Out: ${DateFormat('dd MMM').format(_checkOutDate)}'),
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
                    const SizedBox(height: 20),

                    // Check-In Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final newRes = Reservation(
                              id: 'RES-${DateTime.now().millisecondsSinceEpoch % 100000}',
                              guestName: _nameController.text.trim(),
                              guestContact: _phoneController.text.trim(),
                              nicOrPassport: _idController.text.trim(),
                              roomNumber: _selectedRoom,
                              checkInDate: _checkInDate,
                              checkOutDate: _checkOutDate,
                              mealPlan: _selectedMealPlan,
                              status: 'CHECKED_IN',
                              totalAmountLkr: 145000,
                              paidAmountLkr: 50000,
                            );

                            client.checkInGuest(newRes.id, _selectedRoom);

                            setState(() {
                              _isCheckedIn = true;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Guest ${newRes.guestName} successfully checked into Room $_selectedRoom!'),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          }
                        },
                        child: Text(
                          AppTranslations.tr('check_in_guest'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_isCheckedIn) ...[
                const SizedBox(height: 14),
                LiquidGlassCard(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: const Color(0xFF10B981).withAlpha(isDark ? 40 : 25),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.checkmark_seal_fill, color: Color(0xFF10B981), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Registration Card Issued',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                            Text(
                              'Keycard encoded for Room $_selectedRoom. Wi-Fi voucher & Guest Dining QR link SMS sent to ${_phoneController.text}.',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
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
