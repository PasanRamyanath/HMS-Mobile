import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/auth/auth_state.dart';
import 'core/tenant/tenant_engine.dart';
import 'core/api/appsync_client.dart';
import 'screens/shell/app_shell.dart';
import 'screens/auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const CeylonHmsApp());
}

class CeylonHmsApp extends StatefulWidget {
  const CeylonHmsApp({super.key});

  @override
  State<CeylonHmsApp> createState() => _CeylonHmsAppState();
}

class _CeylonHmsAppState extends State<CeylonHmsApp> {
  final AuthState _auth = AuthState();
  final TenantEngine _tenant = TenantEngine();
  final AppSyncClient _client = AppSyncClient();

  @override
  void initState() {
    super.initState();
    _auth.addListener(_onStateChanged);
    _tenant.addListener(_onStateChanged);
    _client.addListener(_onStateChanged);
    AppTheme.notifier.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onStateChanged);
    _tenant.removeListener(_onStateChanged);
    _client.removeListener(_onStateChanged);
    AppTheme.notifier.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      final isDark = AppTheme.themeMode == ThemeMode.dark;
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ceylon Heritage HMS Cloud',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: AppTheme.themeMode,
      home: _auth.isAuthenticated
          ? AppShell(onThemeChanged: _onStateChanged)
          : LoginScreen(onLoginSuccess: _onStateChanged),
    );
  }
}
