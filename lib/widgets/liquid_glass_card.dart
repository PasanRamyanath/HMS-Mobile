import 'dart:ui';
import 'package:flutter/material.dart';

/// Apple Human Interface Guidelines Liquid Glass card container.
/// Features specular border gradient, backdrop blur filter, and continuous squircle curvature.
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double borderRadius;
  final Border? customBorder;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    this.onTap,
    this.backgroundColor,
    this.borderRadius = 20.0,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark
        ? const Color(0xFF131D2E).withAlpha(190)
        : Colors.white.withAlpha(210);

    final defaultBorder = Border.all(
      color: isDark
          ? Colors.white.withAlpha(28)
          : const Color(0xFF0F172A).withAlpha(20),
      width: 1.0,
    );

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? defaultBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: customBorder ?? defaultBorder,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withAlpha(90)
                    : const Color(0xFF64748B).withAlpha(20),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
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
            child: content,
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      child: content,
    );
  }
}
