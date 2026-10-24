import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/auth/auth_state.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

enum LoginMode {
  credentials,
  pinShift,
}

/// Web-Parity Split Showcase, Role-Based Sign-In, 2-Step Property Registration & Password Reset View
/// (`LoginView.tsx`, `RegisterStep1.tsx`, `RegisterStep2.tsx`, `ResetPasswordView.tsx`).
class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginMode _mode = LoginMode.pinShift;
  final TextEditingController _identifierController =
      TextEditingController(text: 'kasun.perera@gallefortvilla.lk');
  final TextEditingController _passwordController =
      TextEditingController(text: 'Ceylon@2026');
  String _pin = '';
  UserRole _selectedRole = UserRole.hotelAdmin;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _usePasskey = true;

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

  void _onClear() {
    setState(() {
      _pin = '';
      _errorMessage = null;
    });
  }

  void _submitPin() {
    final auth = AuthState();
    final ok = auth.loginWithPin(_pin, role: _selectedRole);
    if (ok) {
      widget.onLoginSuccess();
    } else {
      setState(() {
        _errorMessage =
            'Invalid Staff PIN. Try 1234, 5678, 4321, 8765, 4821, 1111 or 0000.';
        _pin = '';
      });
    }
  }

  void _submitCredentials() {
    final auth = AuthState();
    final ok = auth.loginWithCredentials(
      identifier: _identifierController.text.trim(),
      password: _usePasskey
          ? 'PASSKEY_AUTHENTICATED_TOKEN'
          : _passwordController.text.trim(),
      role: _selectedRole,
    );
    if (ok) {
      widget.onLoginSuccess();
    } else {
      setState(() {
        _errorMessage =
            'Please enter a valid staff email or +94 phone and password.';
      });
    }
  }

  void _applyDemoPreset({
    required String email,
    required String pin,
    required UserRole role,
  }) {
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
      auth.loginWithCredentials(
          identifier: email, password: 'Ceylon@2026', role: role);
    }
    widget.onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeRolePerms = AuthState.rolePermissions[_selectedRole] ?? const [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Bar: Brand Identity + Light/Dark Theme Switcher
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withAlpha(60),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.eco_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ceylon Heritage HMS',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                                color: isDark
                                    ? Colors.white
                                    : AppTheme.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'Hospitality Operations & RBAC Portal',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppTheme.darkTextMuted
                                    : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          AppTheme.toggleThemeMode();
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkSubtleSurface
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.darkBorderStrong
                                  : AppTheme.lightBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isDark
                                    ? CupertinoIcons.sun_max_fill
                                    : CupertinoIcons.moon_stars_fill,
                                size: 14,
                                color: isDark
                                    ? const Color(0xFFFBBF24)
                                    : theme.primaryColor,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isDark ? 'Light Theme' : 'Dark Theme',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : AppTheme.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Web Version Photographic Villa Hero Banner (`boutique-courtyard-login.jpg`)
                  const WebHeroBannerCard(
                    assetPath: WebAssets.boutiqueCourtyardLogin,
                    badgeText: 'Secure Cognito RBAC Shift Access • UTC+05:30',
                    rightPillText: 'Cloud (ap-south-1)',
                    title: 'Galle Fort Lighthouse Villa',
                    subtitle:
                        'Unified front desk, 4-stage IRD/SLTDA tax compliance, KDS/BOT & QR dining',
                    height: 160,
                  ),
                  const SizedBox(height: 10),

                  // Telemetry Pills Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0284C7).withAlpha(35)
                              : AppTheme.skyBgLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF0284C7).withAlpha(90)
                                : AppTheme.skyBorderLight,
                          ),
                        ),
                        child: Text(
                          'CBSL 1:LKR ${CurrencyEngine.usdToLkrRate.toStringAsFixed(1)}',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFF0369A1),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.brandSurfaceTint(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.brandBorderTint(context)),
                        ),
                        child: Text(
                          'Role: ${_selectedRole.code}',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Main Sign-In Card (`LoginView.tsx`)
                  LiquidGlassCard(
                    padding: const EdgeInsets.all(16),
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2-Tab Segmented Switcher: Quick PIN Shift vs Staff Sign In
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkSubtleSurface
                                : const Color(0xFFEEF2EF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.darkBorderStrong
                                  : AppTheme.lightBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _mode = LoginMode.pinShift;
                                    _errorMessage = null;
                                  }),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 9),
                                    decoration: BoxDecoration(
                                      color: _mode == LoginMode.pinShift
                                          ? (isDark
                                              ? AppTheme.darkSurface
                                              : Colors.white)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.dial_fill,
                                          size: 14,
                                          color: _mode == LoginMode.pinShift
                                              ? theme.primaryColor
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 5),
                                        Flexible(
                                          child: Text(
                                            'Quick PIN Shift',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                              color: _mode == LoginMode.pinShift
                                                  ? (isDark
                                                      ? Colors.white
                                                      : AppTheme
                                                          .lightTextPrimary)
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _mode = LoginMode.credentials;
                                    _errorMessage = null;
                                  }),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 9),
                                    decoration: BoxDecoration(
                                      color: _mode == LoginMode.credentials
                                          ? (isDark
                                              ? AppTheme.darkSurface
                                              : Colors.white)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.person_crop_circle,
                                          size: 14,
                                          color: _mode == LoginMode.credentials
                                              ? theme.primaryColor
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 5),
                                        Flexible(
                                          child: Text(
                                            'Staff Sign In',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                              color: _mode ==
                                                      LoginMode.credentials
                                                  ? (isDark
                                                      ? Colors.white
                                                      : AppTheme
                                                          .lightTextPrimary)
                                                  : Colors.grey,
                                            ),
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
                        const SizedBox(height: 12),

                        // Role-Based Login Access Selector (RBAC)
                        DropdownButtonFormField<UserRole>(
                          isExpanded: true,
                          initialValue: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Select RBAC Departmental Role',
                            prefixIcon: Icon(CupertinoIcons.shield_lefthalf_fill, size: 17),
                          ),
                          items: UserRole.values.map((r) {
                            return DropdownMenuItem(
                              value: r,
                              child: Text(
                                '${r.displayName} (${r.code})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedRole = val);
                          },
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Role Permissions: ${activeRolePerms.join(", ")}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (_errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF3F1D28)
                                  : AppTheme.roseBgLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF881337)
                                    : AppTheme.roseBorderLight,
                              ),
                            ),
                            child: Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFFB7185)
                                    : AppTheme.roseTextLight,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],

                        // Mode A: Quick PIN Shift Keypad
                        if (_mode == LoginMode.pinShift) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkSubtleSurface
                                  : AppTheme.lightSubtleSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? AppTheme.darkBorderStrong
                                    : AppTheme.lightBorder,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'OPERATIONAL SHIFT PIN (4 DIGITS)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: isDark
                                        ? AppTheme.darkTextMuted
                                        : AppTheme.lightTextMuted,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(4, (index) {
                                    final isFilled = index < _pin.length;
                                    return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isFilled
                                            ? theme.primaryColor
                                            : (isDark
                                                ? Colors.white24
                                                : const Color(0xFFCBD5E1)),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: [
                              _buildKeypadRow(['1', '2', '3'], isDark),
                              const SizedBox(height: 8),
                              _buildKeypadRow(['4', '5', '6'], isDark),
                              const SizedBox(height: 8),
                              _buildKeypadRow(['7', '8', '9'], isDark),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildKeyActionBtn(
                                      label: 'Clear',
                                      icon: CupertinoIcons.clear,
                                      isDark: isDark,
                                      onTap: _onClear,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildKeypadDigitBtn('0', isDark),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildKeyActionBtn(
                                      label: 'Delete',
                                      icon: CupertinoIcons.delete_left,
                                      isDark: isDark,
                                      onTap: _onDelete,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton.icon(
                              icon: const Icon(CupertinoIcons.lock_open_fill,
                                  size: 16),
                              label: const Text('Unlock Staff Shift →',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800)),
                              onPressed: () {
                                if (_pin.isEmpty) {
                                  _pin = '1234';
                                }
                                _submitPin();
                              },
                            ),
                          ),
                        ] else ...[
                          // Mode B: Staff Email / Mobile & Password Form (`LoginView.tsx`)
                          TextField(
                            controller: _identifierController,
                            decoration: const InputDecoration(
                              labelText: 'Staff Email or +94 Mobile Phone',
                              hintText: 'kasun.perera@gallefortvilla.lk',
                              prefixIcon: Icon(CupertinoIcons.mail, size: 18),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon:
                                  const Icon(CupertinoIcons.lock, size: 18),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? CupertinoIcons.eye
                                      : CupertinoIcons.eye_slash,
                                  size: 18,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _showResetPasswordModal(context),
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkSubtleSurface
                                  : AppTheme.lightSubtleSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? AppTheme.darkBorderStrong
                                    : AppTheme.lightBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: _usePasskey,
                                    activeColor: theme.primaryColor,
                                    onChanged: (val) => setState(
                                        () => _usePasskey = val ?? false),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Sign in with Passkey / Biometrics',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                MetricBadge(
                                  label: 'TouchID Ready',
                                  color: theme.primaryColor,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _submitCredentials,
                              child: const Text('Sign In to Hotel PMS →',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Role Demo Presets Box (All 7 Roles with RBAC!)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.brandSurfaceTint(context),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppTheme.brandBorderTint(context)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(CupertinoIcons.shield_lefthalf_fill,
                                      size: 14, color: theme.primaryColor),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'One-Tap Role Demo Presets (RBAC):',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '7 Roles',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildPresetChip(
                              label: 'GM / Admin (1234)',
                              color: const Color(0xFF0B6E4F),
                              isDark: isDark,
                              onTap: () => _applyDemoPreset(
                                email: 'kasun@resort.lk',
                                pin: '1234',
                                role: UserRole.hotelAdmin,
                              ),
                            ),
                            _buildPresetChip(
                              label: 'Front Desk (5678)',
                              color: const Color(0xFF0284C7),
                              isDark: isDark,
                              onTap: () => _applyDemoPreset(
                                email: 'reception@resort.lk',
                                pin: '5678',
                                role: UserRole.frontDesk,
                              ),
                            ),
                            _buildPresetChip(
                              label: 'F&B Waiter (4321)',
                              color: const Color(0xFFEA580C),
                              isDark: isDark,
                              onTap: () => _applyDemoPreset(
                                email: 'waiter@resort.lk',
                                pin: '4321',
                                role: UserRole.posCashier,
                              ),
                            ),
                            _buildPresetChip(
                              label: 'Chef KDS (4821)',
                              color: const Color(0xFFD97706),
                              isDark: isDark,
                              onTap: () => _applyDemoPreset(
                                email: 'chef@resort.lk',
                                pin: '4821',
                                role: UserRole.kitchenKds,
                              ),
                            ),
                            _buildPresetChip(
                              label: 'Housekeeping (8765)',
                              color: const Color(0xFF16A34A),
                              isDark: isDark,
                              onTap: () => _applyDemoPreset(
                                email: 'hk@resort.lk',
                                pin: '8765',
                                role: UserRole.housekeeping,
                              ),
                            ),
                            _buildPresetChip(
                              label: 'Guest QR (1111)',
                              color: const Color(0xFF0D9488),
                              isDark: isDark,
                              onTap: () => _applyDemoPreset(
                                email: 'guest@resort.lk',
                                pin: '1111',
                                role: UserRole.guest,
                              ),
                            ),
                            _buildPresetChip(
                              label: 'SaaS Super Admin (0000)',
                              color: const Color(0xFF7C3AED),
                              isDark: isDark,
                              onTap: () => _applyDemoPreset(
                                email: 'admin@hms.lk',
                                pin: '0000',
                                role: UserRole.superAdmin,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Footer: Register New Hotel Property (`RegisterStep1.tsx` & `RegisterStep2.tsx`)
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'New hotelier or property manager? ',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showRegisterPropertyWizard(context),
                        child: Text(
                          'Register Hotel Property →',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Password Reset Modal (`ResetPasswordView.tsx`)
  void _showResetPasswordModal(BuildContext context) {
    final emailCtrl = TextEditingController(text: _identifierController.text);
    final otpCtrl = TextEditingController(text: '482910');
    final newPassCtrl = TextEditingController();
    bool otpSent = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reset Staff / Admin Password (Cognito OTP)',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Staff Email or +94 Mobile Number',
                      ),
                    ),
                    if (otpSent) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: otpCtrl,
                        decoration: const InputDecoration(
                          labelText: '6-Digit SMS / Email Verification Code',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: newPassCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!otpSent) {
                            setModalState(() => otpSent = true);
                          } else {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password reset confirmed via AWS Cognito!'),
                                backgroundColor: Color(0xFF16A34A),
                              ),
                            );
                          }
                        },
                        child: Text(otpSent ? 'Confirm New Password' : 'Send Verification OTP'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 2-Step Self-Service Hotel Property Registration Wizard (`RegisterStep1.tsx` & `RegisterStep2.tsx`)
  void _showRegisterPropertyWizard(BuildContext context) {
    int step = 1;
    final orgCtrl = TextEditingController(text: 'Mirissa Ocean Retreat Villa');
    final emailCtrl = TextEditingController(text: 'gm@mirissaretreat.lk');
    final phoneCtrl = TextEditingController(text: '+94 77 450 8899');
    final sltdaCtrl = TextEditingController(text: 'SLTDA/SQA/VILLA/2026/310');
    final tinCtrl = TextEditingController(text: '114892031-7000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          step == 1
                              ? 'Step 1 of 2: Property Owner Identity'
                              : 'Step 2 of 2: SLTDA & 4-Stage Tax Profile',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        MetricBadge(label: 'Step $step/2', color: Theme.of(context).primaryColor),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (step == 1) ...[
                      TextField(
                        controller: orgCtrl,
                        decoration: const InputDecoration(labelText: 'Hotel / Resort Property Name *'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(labelText: 'GM / Owner Email *'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(labelText: 'Sri Lanka +94 Mobile (SMSGo OTP) *'),
                      ),
                    ] else ...[
                      TextField(
                        controller: sltdaCtrl,
                        decoration: const InputDecoration(labelText: 'SLTDA License Number *'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: tinCtrl,
                        decoration: const InputDecoration(labelText: 'IRD RAMIS VAT/SSCL TIN *'),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '4-Stage Tax Rule (10% SC + 1% TDL + 2.5% SSCL + 18% VAT = 1.34343×) pre-configured.',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        if (step == 2) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setModalState(() => step = 1),
                              child: const Text('← Back'),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (step == 1) {
                                setModalState(() => step = 2);
                              } else {
                                Navigator.pop(ctx);
                                AuthState().loginWithCredentials(
                                  identifier: emailCtrl.text,
                                  password: 'Registered@2026',
                                  role: UserRole.hotelAdmin,
                                );
                                widget.onLoginSuccess();
                              }
                            },
                            child: Text(step == 1 ? 'Next: Tax & SLTDA →' : 'Complete Onboarding →'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildKeypadRow(List<String> digits, bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildKeypadDigitBtn(digits[0], isDark)),
        const SizedBox(width: 8),
        Expanded(child: _buildKeypadDigitBtn(digits[1], isDark)),
        const SizedBox(width: 8),
        Expanded(child: _buildKeypadDigitBtn(digits[2], isDark)),
      ],
    );
  }

  Widget _buildKeypadDigitBtn(String digit, bool isDark) {
    return Material(
      color: isDark ? AppTheme.darkSubtleSurface : AppTheme.lightSubtleSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onDigitPress(digit),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
            ),
          ),
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyActionBtn({
    required String label,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark ? AppTheme.darkSubtleSurface : AppTheme.lightSubtleSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: color.withAlpha(95), width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDark
                ? Color.lerp(color, Colors.white, 0.25)
                : color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
