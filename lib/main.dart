import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/auth/auth_state.dart';
import 'screens/shell/app_shell.dart';
import 'screens/auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system navigation & status bar transparent for edge-to-edge Apple HIG experience
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

  @override
  void initState() {
    super.initState();
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    setState(() {});
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ceylon Heritage HMS Cloud',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: _auth.isAuthenticated
          ? AppShell(onThemeChanged: _onThemeChanged)
          : LoginScreen(onLoginSuccess: () => setState(() {})),
    );
  }
}
