library;

/// Update Available Dialog
///
/// Yeni versiyon uyarısı gösterir ve kullanıcıya güncelleme seçeneği sunar.

import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/services/version_service.dart';

class UpdateAvailableDialog extends StatelessWidget {
  final VersionCheckResult result;

  const UpdateAvailableDialog({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      icon: Icon(
        Icons.system_update,
        size: 48,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        result.forceUpdate ? 'Güncelleme Gerekli' : 'Yeni Versiyon Mevcut',
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: AppTypography.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            result.updateMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          AppSpacing.md.verticalSpace,
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mevcut Versiyon',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      result.currentVersion,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppTypography.semiBold,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward,
                  color: theme.colorScheme.primary,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Yeni Versiyon',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      result.latestVersion,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppTypography.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (result.forceUpdate) ...[
            AppSpacing.md.verticalSpace,
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  AppSpacing.xs.horizontalSpace,
                  Expanded(
                    child: Text(
                      'Bu güncelleme zorunludur',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: AppTypography.semiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!result.forceUpdate)
          TextButton(
            onPressed: () {
              // Skip this version
              VersionService.skipVersion(result.latestVersion);
              Navigator.of(context).pop();
            },
            child: const Text('Daha Sonra'),
          ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Force reload
            VersionService.forceReload();
          },
          child: const Text('Güncelle'),
        ),
      ],
      actionsAlignment: MainAxisAlignment.end,
    );
  }

  /// Dialog'u göster
  static Future<void> show(BuildContext context, VersionCheckResult result) {
    return showDialog(
      context: context,
      barrierDismissible: !result.forceUpdate,
      builder: (context) => UpdateAvailableDialog(result: result),
    );
  }
}
