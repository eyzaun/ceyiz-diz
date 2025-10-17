/// Shared Trousseau List Screen - Yeni Tasarım Sistemi v2.0
///
/// TASARIM KURALLARI:
/// ✅ Jakob Yasası: Standart list layout
/// ✅ Fitts Yasası: Card touch area 48dp+, icon buttons 48x48dp
/// ✅ Hick Yasası: 1 primary action per card (tap to open)
/// ✅ Miller Yasası: Card içinde max 4 bilgi (isim, açıklama, progress, ürün sayısı)
/// ✅ Gestalt: İlgili bilgiler card içinde gruplanmış

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_tokens.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';

class SharedTrousseauListScreen extends StatelessWidget {
  const SharedTrousseauListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<TrousseauProvider>(context);
    final list = provider.sharedTrousseaus;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Benimle Paylaşılan Çeyizler'),
        leading: AppIconButton(
          icon: Icons.arrow_back,
          onPressed: () => context.pop(),
          tooltip: 'Geri',
        ),
      ),
      body: list.isEmpty
          ? Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: const EmptyStateWidget(
                icon: Icons.share_outlined,
                title: 'Paylaşılan çeyiz yok',
                subtitle: 'Sizinle paylaşılan çeyizler burada görünecek',
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(AppSpacing.md),
              itemBuilder: (context, index) {
                final t = list[index];
                final progress = t.totalProducts > 0
                    ? t.purchasedProducts / t.totalProducts
                    : 0.0;
                final isPinned = provider.isSharedTrousseauPinned(t.id);

                // FITTS YASASI: Card ile minimum 48dp touch area
                return AppCard(
                  onTap: () => context.push('/trousseau/${t.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─────────────────────────────────────────────────────
                      // HEADER ROW: Name + Pin Button
                      // GESTALT: İlgili öğeler yakın
                      // ─────────────────────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              t.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: AppTypography.bold,
                                fontSize: AppTypography.sizeLG,
                              ),
                            ),
                          ),
                          // FITTS YASASI: 48x48dp touch area
                          AppIconButton(
                            icon: isPinned
                                ? Icons.push_pin
                                : Icons.push_pin_outlined,
                            onPressed: () async {
                              final success =
                                  await provider.togglePinSharedTrousseau(t.id);
                              if (context.mounted && !success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(provider.errorMessage),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.radiusMD,
                                    ),
                                  ),
                                );
                              }
                            },
                            tooltip: isPinned
                                ? 'Ana sayfadan kaldır'
                                : 'Ana sayfaya ekle',
                            iconColor: isPinned
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                          ),
                        ],
                      ),

                      // ─────────────────────────────────────────────────────
                      // DESCRIPTION (if exists)
                      // ─────────────────────────────────────────────────────
                      if (t.description.isNotEmpty) ...[
                        AppSpacing.sm.verticalSpace,
                        Text(
                          t.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: AppTypography.sizeBase,
                          ),
                        ),
                      ],

                      AppSpacing.md.verticalSpace,

                      // ─────────────────────────────────────────────────────
                      // PROGRESS BAR
                      // ─────────────────────────────────────────────────────
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: theme.dividerColor,
                        minHeight: 6,
                        borderRadius: AppRadius.radiusFull,
                      ),

                      AppSpacing.sm.verticalSpace,

                      // ─────────────────────────────────────────────────────
                      // PROGRESS INFO ROW
                      // MILLER YASASI: 2 bilgi (progress %, ürün sayısı)
                      // ─────────────────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progress * 100).toInt()}% tamamlandı',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: AppTypography.sizeSM,
                              fontWeight: AppTypography.medium,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            '${t.totalProducts} ürün',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: AppTypography.sizeSM,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => AppSpacing.sm.verticalSpace,
              itemCount: list.length,
            ),
    );
  }
}
