import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final double fontSize;
  final bool filled;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.fontSize = 12,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize < 12 ? 8 : 10,
        vertical: fontSize < 12 ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: filled
            ? color
            : color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: filled
            ? null
            : Border.all(
                color: color.withValues(alpha: isDark ? 0.4 : 0.28),
                width: 0.8,
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize + 1,
              color: filled ? Colors.white : color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
