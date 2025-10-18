library;

/// Feedback Screen - Yeni Tasarım Sistemi v2.0
///
/// TASARIM KURALLARI:
/// ✅ Jakob Yasası: Standart feedback form layout
/// ✅ Fitts Yasası: Primary button 56dp, star buttons 48x48dp, inputs 56dp
/// ✅ Hick Yasası: 1 primary action (Gönder), 1 secondary (History)
/// ✅ Miller Yasası: 3 alan (Rating, Mesaj, Email) - ideal
/// ✅ Gestalt: Form alanları gruplanmış, info text ayrı

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_tokens.dart';
import '../../providers/feedback_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/app_card.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedbackProvider(),
      child: const _FeedbackForm(),
    );
  }
}

class _FeedbackForm extends StatelessWidget {
  const _FeedbackForm();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FeedbackProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geri Bildirim'),
        leading: AppIconButton(
          icon: Icons.arrow_back,
          onPressed: () => context.pop(),
          tooltip: 'Geri',
        ),
        // HICK YASASI: 1 action (History)
        // FITTS YASASI: 48x48dp
        actions: [
          AppIconButton(
            icon: Icons.history,
            onPressed: () => context.push('/settings/feedback/history'),
            tooltip: 'Geçmiş Geri Bildirimler',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: context.safePaddingHorizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppBreakpoints.maxFormWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSpacing.md.verticalSpace,

                // ─────────────────────────────────────────────────────
                // INFO CARD
                // GESTALT: Görsel olarak ayrı bilgilendirme
                // ─────────────────────────────────────────────────────
                AppInfoCard(
                  icon: Icons.feedback_outlined,
                  title: 'Uygulama hakkında görüş ve önerilerinizi bizimle paylaşın.',
                  color: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                ),

                AppSpacing.xl.verticalSpace,

                // ─────────────────────────────────────────────────────
                // FORM SECTION
                // MILLER YASASI: 3 alan (Rating, Mesaj, Email)
                // ─────────────────────────────────────────────────────
                AppFormSection(
                  title: 'Değerlendirme',
                  children: [
                    // Rating Bar
                    _RatingBar(
                      value: prov.rating,
                      onChanged: prov.setRating,
                    ),

                    // Message
                    AppTextInput(
                      label: 'Geri Bildirim',
                      hint: 'İyileştirme öneriniz, hata bildiriminiz veya genel yorumunuz...',
                      controller: prov.messageController,
                      maxLines: 6,
                      prefixIcon: const Icon(Icons.message_outlined),
                    ),

                    // Email (optional)
                    AppTextInput(
                      label: 'E-posta (opsiyonel)',
                      hint: 'İsterseniz size dönüş için e-postanızı bırakın',
                      controller: prov.emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ],
                ),

                // Error Message
                if (prov.errorMessage.isNotEmpty) ...[
                  AppSpacing.sm.verticalSpace,
                  Text(
                    prov.errorMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontSize: AppTypography.sizeSM,
                    ),
                  ),
                ],

                AppSpacing.xl2.verticalSpace,

                // ─────────────────────────────────────────────────────
                // PRIMARY ACTION
                // HICK YASASI: 1 primary action
                // FITTS YASASI: 56dp button
                // ─────────────────────────────────────────────────────
                AppButtonGroup(
                  primaryButton: AppPrimaryButton(
                    label: prov.isSubmitting ? 'Gönderiliyor...' : 'Gönder',
                    icon: Icons.send,
                    isFullWidth: true,
                    isLoading: prov.isSubmitting,
                    onPressed: prov.isSubmitting
                        ? null
                        : () async {
                            final ok = await prov.submit();
                            if (!context.mounted) return;
                            if (ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Geri bildiriminiz için teşekkürler'),
                                  backgroundColor: theme.colorScheme.tertiary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.radiusMD,
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                  ),
                  secondaryButton: AppSecondaryButton(
                    label: 'İptal',
                    onPressed: () => context.pop(),
                  ),
                ),

                AppSpacing.xl.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const _RatingBar({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uygulamamızı değerlendirin',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: AppTypography.medium,
            fontSize: AppTypography.sizeBase,
          ),
        ),
        AppSpacing.sm.verticalSpace,
        Row(
          children: List.generate(5, (i) {
            final idx = i + 1;
            final filled = (value ?? 0) >= idx;
            // FITTS YASASI: 48x48dp touch area for each star
            return AppIconButton(
              icon: filled ? Icons.star : Icons.star_border,
              iconColor: color,
              onPressed: () => onChanged(filled ? null : idx),
              tooltip: '$idx yıldız',
            );
          }),
        ),
        if (value != null) ...[
          AppSpacing.xs.verticalSpace,
          Text(
            _getRatingText(value!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: AppTypography.sizeSM,
            ),
          ),
        ],
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Çok kötü';
      case 2:
        return 'Kötü';
      case 3:
        return 'Orta';
      case 4:
        return 'İyi';
      case 5:
        return 'Mükemmel';
      default:
        return '';
    }
  }
}
