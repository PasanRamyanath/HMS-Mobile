import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/auth/auth_state.dart';
import '../../core/currency/currency_engine.dart';
import '../../widgets/liquid_glass_card.dart';

enum LoginMode {
  credentials,
  pinShift,
}

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginMode _mode = LoginMode.pinShift; // Default to fast PIN Shift unlock
  final TextEditingController _identifierController = TextEditingController(text: 'kasun@resort.lk');
  final TextEditingController _passwordController = TextEditingController(text: 'Ceylon@2026');
  String _pin = '';
  UserRole _selectedRole = UserRole.hotelAdmin;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onDigitPress(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
        _errorMessage = null;
      });
      if (_pin.length == 4) {
        _submitPin();
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

  void _submitPin() {
    final auth = AuthState();
    final ok = auth.loginWithPin(_pin, role: _selectedRole);
    if (ok) {
      widget.onLoginSuccess();
    } else {
      setState(() {
        _errorMessage = 'Invalid Staff PIN. Try 1234, 5678, 4321, 8765, 4821 or 0000.';
        _pin = '';
      });
    }
  }

  void _submitCredentials() {
    final auth = AuthState();
    final ok = auth.loginWithCredentials(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
    );
    if (ok) {
      widget.onLoginSuccess();
    } else {
      setState(() {
        _errorMessage = 'Please enter a valid staff email or phone and password.';
      });
    }
  }

  void _applyDemoPreset({required String email, required String pin, required UserRole role}) {
    setState(() {
      _identifierController.text = email;
      _passwordController.text = 'Ceylon@2026';
      _selectedRole = role;
      _pin = pin;
      _errorMessage = null;
    });

    final auth = AuthState();
    if (_mode == LoginMode.pinShift) {
      auth.loginWithPin(pin, role: role);
    } else {
      auth.loginWithCredentials(identifier: email, password: 'Ceylon@2026', role: role);
    }
    widget.onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  // Hotel Brand Crest & Logo
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.primaryColor, theme.colorScheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withAlpha(90),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(CupertinoIcons.building_2_fill, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ceylon Heritage HMS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'CBSL 1:LKR ${CurrencyEngine.usdToLkrRate.toStringAsFixed(1)}',
                          style: const TextStyle(color: Color(0xFF0284C7), fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Cloud (ap-south-1)',
                          style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Segmented Switcher: Staff Sign In vs Quick PIN Shift
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _mode = LoginMode.pinShift),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _mode == LoginMode.pinShift
                                    ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: _mode == LoginMode.pinShift
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(20),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.dial_fill,
                                    size: 15,
                                    color: _mode == LoginMode.pinShift ? theme.primaryColor : Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Quick PIN Shift',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: _mode == LoginMode.pinShift
                                          ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _mode = LoginMode.credentials),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _mode == LoginMode.credentials
                                    ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: _mode == LoginMode.credentials
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(20),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.person_crop_circle,
                                    size: 15,
                                    color: _mode == LoginMode.credentials ? theme.primaryColor : Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Staff Sign In',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: _mode == LoginMode.credentials
                                          ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mode A: Quick PIN Shift Keypad
                  if (_mode == LoginMode.pinShift) ...[
                    // 4-Digit Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final isFilled = index < _pin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
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
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Keypad
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: ['1', '2', '3'].map((d) => _buildKeypadButton(d)).toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: ['4', '5', '6'].map((d) => _buildKeypadButton(d)).toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: ['7', '8', '9'].map((d) => _buildKeypadButton(d)).toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildKeyAction(
                              icon: CupertinoIcons.sparkles,
                              onTap: () {
                                setState(() {
                                  _pin = '1234';
                                  _submitPin();
                                });
                              },
                            ),
                            _buildKeypadButton('0'),
                            _buildKeyAction(
                              icon: CupertinoIcons.delete_left_fill,
                              onTap: _onDelete,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ] else ...[
                    // Mode B: Staff Email / Mobile & Password Form
                    LiquidGlassCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _identifierController,
                            decoration: const InputDecoration(
                              labelText: 'Staff Email or +94 Mobile Phone',
                              hintText: 'e.g. kasun@resort.lk or 0771234567',
                              prefixIcon: Icon(CupertinoIcons.mail),
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(CupertinoIcons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            ),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _submitCredentials,
                              child: const Text('Sign In to Property Shift', style: TextStyle(fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Quick Demo Role Presets
                  LiquidGlassCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(CupertinoIcons.sparkles, size: 14, color: Color(0xFFD97706)),
                            SizedBox(width: 6),
                            Text('One-Tap Role Demo Presets:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildPresetChip(
                              label: 'GM / Admin (1234)',
                              color: const Color(0xFF0F5132),
                              onTap: () => _applyDemoPreset(email: 'kasun@resort.lk', pin: '1234', role: UserRole.hotelAdmin),
                            ),
                            _buildPresetChip(
                              label: 'Front Desk (5678)',
                              color: const Color(0xFF0284C7),
                              onTap: () => _applyDemoPreset(email: 'reception@resort.lk', pin: '5678', role: UserRole.frontDesk),
                            ),
                            _buildPresetChip(
                              label: 'F&B Waiter (4321)',
                              color: const Color(0xFFEA580C),
                              onTap: () => _applyDemoPreset(email: 'waiter@resort.lk', pin: '4321', role: UserRole.posCashier),
                            ),
                            _buildPresetChip(
                              label: 'Housekeeping (8765)',
                              color: const Color(0xFF16A34A),
                              onTap: () => _applyDemoPreset(email: 'hk@resort.lk', pin: '8765', role: UserRole.housekeeping),
                            ),
                            _buildPresetChip(
                              label: 'SaaS Super Admin (0000)',
                              color: const Color(0xFF9333EA),
                              onTap: () => _applyDemoPreset(email: 'admin@hms.lk', pin: '0000', role: UserRole.superAdmin),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
        width: 66,
        height: 66,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          digit,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildKeyAction({required IconData icon, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 66,
        height: 66,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131D2E) : const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _buildPresetChip({required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(80), width: 0.8),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
