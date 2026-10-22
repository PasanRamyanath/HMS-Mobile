import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/auth/auth_state.dart';
import '../../widgets/liquid_glass_card.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _pin = '';
  UserRole _selectedRole = UserRole.hotelAdmin;
  String? _errorMessage;

  void _onDigitPress(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
        _errorMessage = null;
      });
      if (_pin.length == 4) {
        _validatePin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _validatePin() {
    final auth = AuthState();
    final ok = auth.loginWithPin(_pin, role: _selectedRole);
    if (ok) {
      widget.onLoginSuccess();
    } else {
      setState(() {
        _errorMessage = 'Invalid Staff PIN. Try 4821 or tap Demo Quick-Fill.';
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Logo & Hotel Branding
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withAlpha(80),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(CupertinoIcons.building_2_fill, color: Colors.white, size: 34),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ceylon Heritage HMS',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              const SizedBox(height: 2),
              Text(
                'Galle Fort, Sri Lanka • Cloud SaaS',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : const Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),

              // Role Selector Pills
              LiquidGlassCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Staff Department / Role:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: UserRole.values.map((role) {
                        final isSel = _selectedRole == role;
                        return ChoiceChip(
                          label: Text(role.displayName.split(' ')[0]),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) setState(() => _selectedRole = role);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // PIN Code Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? theme.primaryColor : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                    ),
                  );
                }),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 20),

              // Numeric Keypad
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['1', '2', '3'].map((d) => _buildKeypadButton(d)).toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['4', '5', '6'].map((d) => _buildKeypadButton(d)).toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['7', '8', '9'].map((d) => _buildKeypadButton(d)).toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionKey(
                        icon: CupertinoIcons.sparkles,
                        tooltip: 'Demo 4821',
                        onTap: () {
                          setState(() {
                            _pin = '4821';
                            _validatePin();
                          });
                        },
                      ),
                      _buildKeypadButton('0'),
                      _buildActionKey(
                        icon: CupertinoIcons.delete_left_fill,
                        tooltip: 'Backspace',
                        onTap: _onDelete,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Demo Fill Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(CupertinoIcons.bolt_fill, size: 14),
                label: const Text('Quick Login with Demo PIN (4821)'),
                onPressed: () {
                  setState(() {
                    _pin = '4821';
                    _validatePin();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String digit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _onDigitPress(digit),
      child: Container(
        width: 68,
        height: 68,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 10),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          digit,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildActionKey({required IconData icon, required String tooltip, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 68,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131D2E) : const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: Theme.of(context).primaryColor),
      ),
    );
  }
}
