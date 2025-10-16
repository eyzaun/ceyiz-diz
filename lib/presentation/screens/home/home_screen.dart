// Home Screen - Yeni Tasarım Sistemi v2.0
//
// TASARIM KURALLARI:
/// ✅ Jakob Yasası: Standart bottom navigation (3 tab - ideal)
/// ✅ Fitts Yasası: Bottom nav icons 28dp, 72dp height (kolay erişim)
/// ✅ Hick Yasası: Maksimum 3 ana sekme (Çeyiz, İstatistikler, Profil)
/// ✅ Miller Yasası: Profil listesi gruplara bölünmüş
/// ✅ Gestalt: İlgili menü öğeleri gruplanmış

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/design_tokens.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/app_button.dart';
import 'statistics_screen.dart';
import '../trousseau/trousseau_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _hasShownUpdateDialog = false;

  @override
  void initState() {
    super.initState();
    // Check for updates after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdateOnce();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to AuthProvider to catch update flag changes
    final authProvider = Provider.of<AuthProvider>(context);

    // If update becomes available and we haven't shown dialog yet, show it
    if (authProvider.updateAvailable && !_hasShownUpdateDialog && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForUpdateOnce();
      });
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildTrousseauTab(context),
          const StatisticsScreen(),
          _buildProfile(context),
        ],
      ),
      // ═════════════════════════════════════════════════════════════════════
      // BOTTOM NAVIGATION
      // JAKOB YASASI: Standart 3 tab layout (yaygın pattern)
      // HICK YASASI: Max 3 sekme (kolay seçim)
      // FITTS YASASI: 72dp height, 28dp icons (kolay dokunma)
      // ═════════════════════════════════════════════════════════════════════
      bottomNavigationBar: Container(
        height: AppDimensions.bottomNavHeight,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedFontSize: AppTypography.sizeSM,
          unselectedFontSize: AppTypography.sizeXS,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.inventory_2_outlined,
                size: AppDimensions.bottomNavIconSize,
              ),
              activeIcon: Icon(
                Icons.inventory_2,
                size: AppDimensions.bottomNavIconSize,
              ),
              label: 'Çeyiz',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.analytics_outlined,
                size: AppDimensions.bottomNavIconSize,
              ),
              activeIcon: Icon(
                Icons.analytics,
                size: AppDimensions.bottomNavIconSize,
              ),
              label: 'İstatistikler',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline,
                size: AppDimensions.bottomNavIconSize,
              ),
              activeIcon: Icon(
                Icons.person,
                size: AppDimensions.bottomNavIconSize,
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TROUSSEAU TAB
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTrousseauTab(BuildContext context) {
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    final pinnedTrousseaus = trousseauProvider.pinnedTrousseaus;

    // Loading state
    if (trousseauProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Empty state
    if (pinnedTrousseaus.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ),
                AppSpacing.lg.verticalSpace,
                Text(
                  'Henüz çeyiz oluşturmadınız',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: AppTypography.sizeLG,
                    fontWeight: AppTypography.semiBold,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.sm.verticalSpace,
                Text(
                  'İlk çeyizinizi oluşturarak başlayın',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.xl.verticalSpace,
                AppPrimaryButton(
                  label: 'Çeyiz Oluştur',
                  icon: Icons.add,
                  onPressed: () => context.push('/create-trousseau'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show first trousseau detail
    final id = pinnedTrousseaus.first.id;
    return TrousseauDetailScreen(trousseauId: id, key: ValueKey(id));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE TAB
  // MILLER YASASI: Liste 3 gruba bölünmüş (Çeyiz, Hesap, Sistem)
  // GESTALT: İlgili öğeler gruplanmış (Divider ile ayrılmış)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildProfile(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          // FITTS YASASI: Settings icon button 48x48 touch area
          AppIconButton(
            icon: Icons.settings,
            tooltip: 'Ayarlar',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          // ───────────────────────────────────────────────────────────────────
          // PROFILE HEADER
          // Gestalt: Yakınlık - Avatar + Name + Email gruplanmış
          // ───────────────────────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    (authProvider.currentUser?.displayName ?? 'K')
                        .substring(0, 1)
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: AppTypography.size4XL,
                      fontWeight: AppTypography.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),

                AppSpacing.md.verticalSpace,

                // Name
                Text(
                  authProvider.currentUser?.displayName ?? 'Kullanıcı',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: AppTypography.bold,
                    fontSize: AppTypography.sizeXL,
                  ),
                  textAlign: TextAlign.center,
                ),

                AppSpacing.xs.verticalSpace,

                // Email
                Text(
                  authProvider.currentUser?.email ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: AppTypography.sizeBase,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          AppSpacing.xl.verticalSpace,

          // ───────────────────────────────────────────────────────────────────
          // GROUP 1: ÇEYIZ İŞLEMLERİ
          // Miller Yasası: 2 öğe per grup
          // ───────────────────────────────────────────────────────────────────
          _buildMenuTile(
            context,
            icon: Icons.group_outlined,
            title: 'Benimle Paylaşılan Çeyizler',
            onTap: () => context.push('/shared-trousseaus'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.feedback_outlined,
            title: 'Geri Bildirim Gönder',
            subtitle: 'Görüş ve önerilerinizi bizimle paylaşın',
            onTap: () => context.push('/settings/feedback'),
          ),

          Divider(height: AppSpacing.xl, thickness: 1),

          // ───────────────────────────────────────────────────────────────────
          // GROUP 2: HESAP AYARLARI
          // Miller Yasası: 3 öğe per grup
          // ───────────────────────────────────────────────────────────────────
          _buildMenuTile(
            context,
            icon: Icons.person_outline,
            title: 'Profili Düzenle',
            onTap: () => context.push('/settings/profile'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.palette_outlined,
            title: 'Tema Ayarları',
            onTap: () => context.push('/settings/theme'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.lock_outline,
            title: 'Şifre Değiştir',
            onTap: () => context.push('/settings/change-password'),
          ),

          Divider(height: AppSpacing.xl, thickness: 1),

          // ───────────────────────────────────────────────────────────────────
          // GROUP 3: SİSTEM
          // Danger action (kırmızı)
          // ───────────────────────────────────────────────────────────────────
          _buildMenuTile(
            context,
            icon: Icons.logout,
            title: 'Çıkış Yap',
            isDanger: true,
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MENU TILE WIDGET
  // FITTS YASASI: Minimum 56dp height, full width touch area
  // GESTALT: Tutarlı layout (icon + text + chevron)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    bool isDanger = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final color = isDanger ? theme.colorScheme.error : theme.colorScheme.onSurface;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      // FITTS YASASI: Minimum height
      minVerticalPadding: AppSpacing.sm,
      leading: Icon(
        icon,
        color: color,
        size: AppDimensions.iconSizeMedium,
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: color,
          fontSize: AppTypography.sizeBase,
          fontWeight: AppTypography.medium,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: AppTypography.sizeSM,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: color.withValues(alpha: 0.5),
        size: AppDimensions.iconSizeMedium,
      ),
      onTap: onTap,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGOUT HANDLER
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXL,
        ),
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          AppTextButton(
            label: 'İptal',
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          AppDangerButton(
            label: 'Çıkış Yap',
            isOutlined: false,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UPDATE DIALOG
  // ═══════════════════════════════════════════════════════════════════════════

  void _checkForUpdateOnce() {
    if (_hasShownUpdateDialog) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.updateAvailable) {
      _hasShownUpdateDialog = true;
      _showUpdateDialog();
    }
  }

  void _showUpdateDialog() {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: !authProvider.forceUpdate,
      builder: (dialogContext) => PopScope(
        canPop: !authProvider.forceUpdate,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusXL,
          ),
          title: Row(
            children: [
              Container(
                padding: AppSpacing.paddingSM,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Icon(
                  Icons.system_update,
                  color: theme.colorScheme.primary,
                  size: AppDimensions.iconSizeLarge,
                ),
              ),
              AppSpacing.md.horizontalSpace,
              Expanded(
                child: Text(
                  authProvider.forceUpdate ? 'Güncelleme Gerekli!' : 'Yeni Versiyon Mevcut',
                  style: TextStyle(
                    fontSize: AppTypography.sizeLG,
                    fontWeight: AppTypography.bold,
                    color: authProvider.forceUpdate
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(authProvider.updateMessage, style: theme.textTheme.bodyMedium),
              AppSpacing.md.verticalSpace,
              Container(
                padding: AppSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: AppRadius.radiusMD,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.new_releases, color: theme.colorScheme.primary, size: AppDimensions.iconSizeMedium),
                    AppSpacing.sm.horizontalSpace,
                    Text(
                      'Yeni Versiyon: ${authProvider.latestVersion}',
                      style: TextStyle(
                        fontWeight: AppTypography.bold,
                        color: theme.colorScheme.primary,
                        fontSize: AppTypography.sizeBase,
                      ),
                    ),
                  ],
                ),
              ),
              if (authProvider.forceUpdate) ...[
                AppSpacing.md.verticalSpace,
                Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: AppRadius.radiusMD,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: AppDimensions.iconSizeMedium),
                      AppSpacing.sm.horizontalSpace,
                      Expanded(
                        child: Text(
                          'Bu güncelleme zorunludur. Devam etmek için güncellemeniz gerekiyor.',
                          style: TextStyle(color: theme.colorScheme.error, fontSize: AppTypography.sizeSM),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (!authProvider.forceUpdate)
              AppTextButton(
                label: 'Daha Sonra',
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            AppPrimaryButton(
              label: 'Şimdi Güncelle',
              icon: Icons.download,
              onPressed: () async {
                const url = 'https://play.google.com/store/apps/details?id=com.Loncagames.ceyizdiz';
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: const Text('Play Store açılamadı.'), backgroundColor: theme.colorScheme.error),
                    );
                  }
                }
                if (dialogContext.mounted && !authProvider.forceUpdate) {
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
