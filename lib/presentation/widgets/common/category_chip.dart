import 'package:flutter/material.dart';
import '../../../data/models/category_model.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showCount;
  final int? count;
  final bool colorful; // when true, show tinted colors even when not selected

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
    this.showCount = false,
    this.count,
    this.colorful = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
      color: isSelected
        ? category.color.withValues(alpha: 0.15)
        : colorful
          ? category.color.withValues(alpha: 0.08)
          : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? category.color
                : colorful
                    ? category.color.withValues(alpha: 0.6)
                    : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 18,
              color: isSelected
                  ? category.color
                  : colorful
                      ? category.color
                      : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 6),
            Text(
              category.displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
        color: isSelected
          ? category.color
          : colorful
            ? category.color
            : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (showCount && count != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? category.color.withValues(alpha: 0.25)
                      : colorful
                          ? category.color.withValues(alpha: 0.15)
                          : theme.colorScheme.outline.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
              ? category.color
              : colorful
                ? category.color
                : theme.colorScheme.onSurface,
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