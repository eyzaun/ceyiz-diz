import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/locale_provider.dart';

/// Language Selector Widget
///
/// Displays a compact language selector button that can be used
/// in any screen (onboarding, login, register, etc.) without requiring authentication.
///
/// Shows current language and opens a modal bottom sheet to change language.
class LanguageSelector extends StatelessWidget {
  /// Position of the widget (top-left, top-right, etc.)
  final Alignment alignment;

  /// Whether to show as a floating button (default) or inline widget
  final bool isFloating;

  /// Optional padding around the widget
  final EdgeInsets? padding;

  const LanguageSelector({
    super.key,
    this.alignment = Alignment.topLeft,
    this.isFloating = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final currentLocale = localeProvider.locale.languageCode;

    // Get language name and flag
    final languageInfo = _getLanguageInfo(currentLocale);

    final button = InkWell(
      onTap: () => _showLanguageModal(context),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isFloating
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.9)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Language icon
            Icon(
              Icons.language,
              size: 18,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(width: AppSpacing.xs),
            // Language code
            Text(
              languageInfo['name']!,
              style: TextStyle(
                fontSize: AppTypography.sizeSM,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 2),
            // Dropdown icon
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: theme.colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );

    if (isFloating) {
      return Align(
        alignment: alignment,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          child: button,
        ),
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: button,
    );
  }

  Map<String, String> _getLanguageInfo(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return {'name': 'TR', 'fullName': 'Türkçe'};
      case 'en':
        return {'name': 'EN', 'fullName': 'English'};
      default:
        return {'name': 'TR', 'fullName': 'Türkçe'};
    }
  }

  void _showLanguageModal(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final localeProvider = context.read<LocaleProvider>();
    final currentLocale = localeProvider.locale.languageCode;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  l10n?.language ?? 'Dil Seçimi',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Turkish option
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'TR',
                      style: TextStyle(
                        fontSize: AppTypography.sizeSM,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  l10n?.turkish ?? 'Türkçe',
                  style: TextStyle(
                    fontWeight: currentLocale == 'tr' ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: currentLocale == 'tr'
                    ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  context.read<LocaleProvider>().setTurkish();
                  Navigator.pop(modalContext);
                },
              ),

              // English option
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'EN',
                      style: TextStyle(
                        fontSize: AppTypography.sizeSM,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  l10n?.english ?? 'English',
                  style: TextStyle(
                    fontWeight: currentLocale == 'en' ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: currentLocale == 'en'
                    ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  context.read<LocaleProvider>().setEnglish();
                  Navigator.pop(modalContext);
                },
              ),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }
}
