library;

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
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/design_tokens.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';

class SharedTrousseauListScreen extends StatefulWidget {
  const SharedTrousseauListScreen({super.key});

  @override
  State<SharedTrousseauListScreen> createState() => _SharedTrousseauListScreenState();
}

class _SharedTrousseauListScreenState extends State<SharedTrousseauListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benimle Paylaşılanlar'),
        leading: AppIconButton(
          icon: Icons.arrow_back,
          onPressed: () => context.pop(),
          tooltip: 'Geri',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Paylaşılanlar', icon: Icon(Icons.folder_shared)),
            Tab(text: 'Davetler', icon: Icon(Icons.mail_outline)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSharedTrousseausTab(context),
          _buildInvitationsTab(context),
        ],
      ),
    );
  }

  Widget _buildSharedTrousseausTab(BuildContext context) {
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

  Widget _buildInvitationsTab(BuildContext context) {
    final theme = Theme.of(context);
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    final currentUserId = trousseauProvider.currentUserId;

    if (currentUserId == null) {
      return Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: const EmptyStateWidget(
          icon: Icons.person_outline,
          title: 'Giriş yapmalısınız',
          subtitle: 'Davetleri görmek için giriş yapın',
        ),
      );
    }

    final invitationsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('trousseauInvitations')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: invitationsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Hata oluştu',
              subtitle: snapshot.error.toString(),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: const EmptyStateWidget(
              icon: Icons.mail_outline,
              title: 'Yeni davet yok',
              subtitle: 'Size gönderilen davetler burada görünecek',
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(AppSpacing.md),
          itemCount: docs.length,
          separatorBuilder: (_, __) => AppSpacing.sm.verticalSpace,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final trousseauId = data['trousseauId'] as String? ?? '';
            final trousseauName = data['trousseauName'] as String? ?? 'Çeyiz';
            final ownerEmail = data['ownerEmail'] as String? ?? '';
            final canEdit = data['canEdit'] == true;

            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    trousseauName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: AppTypography.bold,
                      fontSize: AppTypography.sizeLG,
                    ),
                  ),
                  AppSpacing.sm.verticalSpace,
                  
                  // Owner info
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: AppDimensions.iconSizeSmall,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      AppSpacing.xs.horizontalSpace,
                      Expanded(
                        child: Text(
                          ownerEmail,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: AppTypography.sizeBase,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.xs.verticalSpace,
                  
                  // Permission info
                  Row(
                    children: [
                      Icon(
                        canEdit ? Icons.edit_outlined : Icons.visibility_outlined,
                        size: AppDimensions.iconSizeSmall,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      AppSpacing.xs.horizontalSpace,
                      Text(
                        canEdit ? 'Düzenleme izni' : 'Sadece görüntüleme',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: AppTypography.sizeSM,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  
                  AppSpacing.md.verticalSpace,
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppTextButton(
                        label: 'Reddet',
                        onPressed: () async {
                          final success = await trousseauProvider.declineShare(
                            invitationDocPath: doc.reference.path,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Davet reddedildi'
                                    : trousseauProvider.errorMessage,
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.radiusMD,
                              ),
                            ),
                          );
                        },
                      ),
                      AppSpacing.sm.horizontalSpace,
                      AppPrimaryButton(
                        label: 'Kabul Et',
                        onPressed: () async {
                          final success = await trousseauProvider.acceptShare(
                            invitationDocPath: doc.reference.path,
                            trousseauId: trousseauId,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Davet kabul edildi! Paylaşılanlar sekmesinde görünecek.'
                                    : trousseauProvider.errorMessage,
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.radiusMD,
                              ),
                            ),
                          );
                          if (success) {
                            // Switch to shared trousseaus tab
                            _tabController.animateTo(0);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
