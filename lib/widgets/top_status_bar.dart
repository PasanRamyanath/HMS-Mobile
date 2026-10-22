import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/l10n/translations.dart';
import '../core/auth/auth_state.dart';
import '../core/currency/currency_engine.dart';
import '../core/api/appsync_client.dart';

class TopStatusBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLanguageChanged;
  final VoidCallback onRoleChanged;

  const TopStatusBar({
    super.key,
    required this.onLanguageChanged,
    required this.onRoleChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = AuthState();
    final client = AppSyncClient();

    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A).withAlpha(220) : Colors.white.withAlpha(235),
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.white.withAlpha(20) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // CBSL Ticker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF0284C7).withAlpha(80), width: 0.8),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.money_dollar, size: 13, color: Color(0xFF0284C7)),
                  const SizedBox(width: 3),
                  Text(
                    'CBSL 1:LKR ${CurrencyEngine.usdToLkrRate.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // Cloud Status
            GestureDetector(
              onTap: () {
                client.toggleOnlineStatus();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: client.isOnline
                      ? const Color(0xFF10B981).withAlpha(25)
                      : const Color(0xFFF59E0B).withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: client.isOnline
                        ? const Color(0xFF10B981).withAlpha(80)
                        : const Color(0xFFF59E0B).withAlpha(80),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: client.isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      client.isOnline ? 'Cloud' : 'Offline',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: client.isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Trilingual Language Switcher
            GestureDetector(
              onTap: () {
                if (AppTranslations.currentLanguage == AppLanguage.en) {
                  AppTranslations.setLanguage(AppLanguage.si);
                } else if (AppTranslations.currentLanguage == AppLanguage.si) {
                  AppTranslations.setLanguage(AppLanguage.ta);
                } else {
                  AppTranslations.setLanguage(AppLanguage.en);
                }
                onLanguageChanged();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.primaryColor.withAlpha(80), width: 0.8),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.globe, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      AppTranslations.languageLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Role Switcher Pill
            GestureDetector(
              onTap: onRoleChanged,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.white.withAlpha(30) : const Color(0xFFCBD5E1),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.person_crop_circle,
                      size: 14,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      auth.currentRole.displayName.split(' ')[0],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
