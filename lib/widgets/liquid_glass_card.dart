import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Web-Parity Universal Surface Card (`GlassCard.tsx` + `.admin-card` in `apple-hig-theme.css`).
/// In Light Mode: Crisp white (`#FFFFFF`), `1px solid #E2E8F0` border, subtle shadow.
/// In Dark Mode: Slate 900 (`#111827`), `1px solid #1E293B` border, deep shadow.
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double borderRadius;
  final Border? customBorder;
  final bool isInner;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    this.onTap,
    this.backgroundColor,
    this.borderRadius = 16.0,
    this.customBorder,
    this.isInner = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isInner
        ? (isDark ? AppTheme.darkSubtleSurface : AppTheme.lightSubtleSurface)
        : (isDark ? AppTheme.darkSurface : AppTheme.lightSurface);

    final defaultBorder = Border.all(
      color: isDark
          ? (isInner ? AppTheme.darkBorderStrong : const Color(0xFF1E293B))
          : (isInner ? const Color(0xFFE2E8F0) : const Color(0xFFE2E8F0)),
      width: 1.0,
    );

    final cardContainer = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: customBorder ?? defaultBorder,
        boxShadow: isInner
            ? null
            : [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withAlpha(65)
                      : const Color(0xFF0F172A).withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius),
            onTap: onTap,
            child: cardContainer,
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      child: cardContainer,
    );
  }
}

/// Web-Parity Thumbnail Image Widget with graceful fallback so missing assets in tests never crash.
class WebImageThumbnail extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final double borderRadius;
  final IconData fallbackIcon;
  final Color? fallbackColor;
  final BoxFit fit;

  const WebImageThumbnail({
    super.key,
    required this.assetPath,
    this.width = 64,
    this.height = 64,
    this.borderRadius = 12,
    this.fallbackIcon = CupertinoIcons.photo,
    this.fallbackColor,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tint = fallbackColor ?? theme.primaryColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, err, stack) {
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    tint.withAlpha(isDark ? 65 : 35),
                    tint.withAlpha(isDark ? 35 : 15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: tint.withAlpha(70)),
              ),
              child: Icon(fallbackIcon, color: tint, size: width * 0.42),
            );
          },
        ),
      ),
    );
  }
}

/// Web-Parity Photographic Hero Card (`BaseLandingPortal.tsx` & `LoginView.tsx` & `GuestQrApp.tsx`)
class WebHeroBannerCard extends StatelessWidget {
  final String assetPath;
  final String badgeText;
  final String title;
  final String subtitle;
  final String? rightPillText;
  final double height;
  final Widget? bottomOverlay;

  const WebHeroBannerCard({
    super.key,
    required this.assetPath,
    required this.badgeText,
    required this.title,
    required this.subtitle,
    this.rightPillText,
    this.height = 195,
    this.bottomOverlay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 80 : 18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor,
                        const Color(0xFF0F172A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withAlpha(70),
                    Colors.black.withAlpha(185),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5).withAlpha(240),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0B6E4F),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  badgeText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF0B6E4F),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (rightPillText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(135),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            rightPillText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  bottomOverlay ??
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF111827).withAlpha(235)
                              : Colors.white.withAlpha(242),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? AppTheme.darkBorderStrong : AppTheme.lightBorder,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
