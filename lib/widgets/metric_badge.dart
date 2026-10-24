import 'package:flutter/material.dart';

/// Web-Parity Semantic Status & Metric Pill (`StatusBadge.tsx` in `hms-frontend`).
/// Constrained with `Flexible` and `TextOverflow.ellipsis` so it never overflows mobile rows.
class MetricBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showDot;

  const MetricBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.onTap,
    this.isSelected = false,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor = isSelected
        ? color
        : (isDark ? color.withAlpha(42) : color.withAlpha(24));

    final Color borderColor = isSelected
        ? color
        : (isDark ? color.withAlpha(95) : color.withAlpha(75));

    final Color textColor = isSelected
        ? Colors.white
        : (isDark
            ? Color.lerp(color, Colors.white, 0.25) ?? color
            : Color.lerp(color, Colors.black, 0.18) ?? color);

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ] else if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: textColor,
            ),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: badge,
      );
    }
    return badge;
  }
}
