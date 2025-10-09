import 'package:flutter/material.dart';

/// A unified pill-style filter chip with optional count badge.
///
/// Consistent paddings, radius, borders, and colors aligned with the
/// Design System. Prefer using this over raw FilterChip to keep styling
/// cohesive across the app.
class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;
  final Color? color; // base color for selected/outline states
  final IconData? leadingIcon; // optional leading icon (e.g., category icon)
  final bool neutralWhenUnselected; // grey style when not selected
  final bool dense; // smaller paddings

  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.color,
    this.leadingIcon,
    this.neutralWhenUnselected = true,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = color ?? theme.colorScheme.primary;
    final onBase = theme.colorScheme.onPrimary;

    final Color bg;
    final Color border;
    final Color labelColor;

    if (selected) {
      bg = base;
      border = base;
      labelColor = onBase;
    } else {
      if (neutralWhenUnselected) {
        bg = theme.colorScheme.surfaceContainerHighest;
        border = theme.colorScheme.outline;
        labelColor = base; // hint of the category/filter color
      } else {
        bg = Colors.transparent;
        border = base.withValues(alpha: 0.6);
        labelColor = base;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? 12 : 14,
          vertical: dense ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: border, width: selected ? 2 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null && !selected) ...[
              Icon(leadingIcon, size: 16, color: labelColor),
              const SizedBox(width: 6),
            ],
            if (selected) ...[
              Icon(Icons.check, size: 16, color: onBase),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.25)
                      : (neutralWhenUnselected
                          ? theme.colorScheme.outline.withValues(alpha: 0.35)
                          : base.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected ? onBase : labelColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
