import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import 'onboarding_data.dart';

/// Tekrar Kullanılabilir Onboarding Sayfa Widget'ı
/// Material 3 Design ve Proje Design Tokens ile uyumlu
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageData pageData;

  const OnboardingPageWidget({
    super.key,
    required this.pageData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xl),

          // ═══════════════════════════════════════════════════════════════
          // ICON WITH GRADIENT BACKGROUND
          // GESTALT: Görsel olarak dikkat çekici, ayrı bir element
          // ═══════════════════════════════════════════════════════════════
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  pageData.iconColor.withValues(alpha: 0.2),
                  pageData.iconColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              pageData.icon,
              size: 56,
              color: pageData.iconColor,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ═══════════════════════════════════════════════════════════════
          // TITLE
          // TYPOGRAPHY: displaySmall (32sp, bold)
          // ═══════════════════════════════════════════════════════════════
          Text(
            pageData.title,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: AppTypography.bold,
              color: colorScheme.onSurface,
              fontFamily: AppTypography.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.sm),

          // ═══════════════════════════════════════════════════════════════
          // SUBTITLE
          // TYPOGRAPHY: titleMedium (16sp, medium)
          // ═══════════════════════════════════════════════════════════════
          Text(
            pageData.subtitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: pageData.iconColor,
              fontWeight: FontWeight.w500,
              fontFamily: AppTypography.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.lg),

          // ═══════════════════════════════════════════════════════════════
          // DESCRIPTION
          // TYPOGRAPHY: bodyLarge (16sp, regular)
          // ═══════════════════════════════════════════════════════════════
          Text(
            pageData.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.6,
              fontFamily: AppTypography.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xl),

          // ═══════════════════════════════════════════════════════════════
          // FEATURES LIST
          // GESTALT: İlgili bilgiler gruplanmış, card içinde
          // MILLER YASASI: Max 5 feature (optimal bilgi miktarı)
          // ═══════════════════════════════════════════════════════════════
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: pageData.iconColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: pageData.features.map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: AppTypography.sizeSM,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                            height: 1.5,
                            fontFamily: AppTypography.fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
