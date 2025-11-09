library;

/// Sort Bottom Sheet - Sıralama Seçenekleri
///
/// GESTALT PRENSİPLERİ:
/// - BENZERLİK: Tüm seçenekler aynı stilde
/// - YAKINLIK: İlgili seçenekler gruplanmış
/// - ORTAK ALAN: Bottom sheet içinde tutarlı padding

import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/enums/sort_option.dart';

class SortBottomSheet extends StatelessWidget {
  final ProductSortOption? currentSort;
  final Function(ProductSortOption) onSortSelected;

  const SortBottomSheet({
    super.key,
    this.currentSort,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            AppSpacing.md.verticalSpace,

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Icon(
                    Icons.sort,
                    color: theme.colorScheme.primary,
                    size: AppDimensions.iconSizeMedium,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n?.sortBy ?? 'Sırala',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: AppTypography.bold,
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.md.verticalSpace,

            // Sort Options
            _buildSortOption(
              context,
              icon: Icons.access_time,
              title: l10n?.sortDateOldToNew ?? 'Tarih (Eskiden Yeniye)',
              option: ProductSortOption.dateOldToNew,
              isSelected: currentSort == ProductSortOption.dateOldToNew,
            ),
            _buildSortOption(
              context,
              icon: Icons.schedule,
              title: l10n?.sortDateNewToOld ?? 'Tarih (Yeniden Eskiye)',
              option: ProductSortOption.dateNewToOld,
              isSelected: currentSort == ProductSortOption.dateNewToOld,
            ),
            Divider(
              height: AppSpacing.md,
              indent: AppSpacing.lg,
              endIndent: AppSpacing.lg,
            ),
            _buildSortOption(
              context,
              icon: Icons.check_circle,
              title: l10n?.sortPurchasedFirst ?? 'Alınanlar Önce',
              option: ProductSortOption.purchasedFirst,
              isSelected: currentSort == ProductSortOption.purchasedFirst,
            ),
            _buildSortOption(
              context,
              icon: Icons.radio_button_unchecked,
              title: l10n?.sortNotPurchasedFirst ?? 'Alınmayanlar Önce',
              option: ProductSortOption.notPurchasedFirst,
              isSelected: currentSort == ProductSortOption.notPurchasedFirst,
            ),
            Divider(
              height: AppSpacing.md,
              indent: AppSpacing.lg,
              endIndent: AppSpacing.lg,
            ),
            _buildSortOption(
              context,
              icon: Icons.arrow_downward,
              title: l10n?.sortPriceHighToLow ?? 'Fiyat (Yüksek → Düşük)',
              option: ProductSortOption.priceHighToLow,
              isSelected: currentSort == ProductSortOption.priceHighToLow,
            ),
            _buildSortOption(
              context,
              icon: Icons.arrow_upward,
              title: l10n?.sortPriceLowToHigh ?? 'Fiyat (Düşük → Yüksek)',
              option: ProductSortOption.priceLowToHigh,
              isSelected: currentSort == ProductSortOption.priceLowToHigh,
            ),
            Divider(
              height: AppSpacing.md,
              indent: AppSpacing.lg,
              endIndent: AppSpacing.lg,
            ),
            _buildSortOption(
              context,
              icon: Icons.sort_by_alpha,
              title: l10n?.sortNameAZ ?? 'İsim (A → Z)',
              option: ProductSortOption.nameAZ,
              isSelected: currentSort == ProductSortOption.nameAZ,
            ),
            _buildSortOption(
              context,
              icon: Icons.sort_by_alpha,
              title: l10n?.sortNameZA ?? 'İsim (Z → A)',
              option: ProductSortOption.nameZA,
              isSelected: currentSort == ProductSortOption.nameZA,
            ),

            AppSpacing.md.verticalSpace,
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required ProductSortOption option,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onSortSelected(option);
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: AppDimensions.iconSizeMedium,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected
                        ? AppTypography.semiBold
                        : AppTypography.regular,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: theme.colorScheme.primary,
                  size: AppDimensions.iconSizeMedium,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
