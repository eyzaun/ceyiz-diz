library;

/// Home Screen - Yeni Tasarım Sistemi v2.0
///
/// TASARIM KURALLARI:
/// ✅ Jakob Yasası: Standart bottom navigation (3 tab - ideal)
/// ✅ Fitts Yasası: Bottom nav icons 28dp, 72dp height (kolay erişim)
/// ✅ Hick Yasası: Maksimum 3 ana sekme (Çeyiz, İstatistikler, Profil)
/// ✅ Miller Yasası: Profil listesi gruplara bölünmüş
/// ✅ Gestalt: İlgili menü öğeleri gruplanmış

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/app_button.dart';
import 'statistics_screen.dart';
import '../trousseau/trousseau_detail_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _hasShownUpdateDialog = false;
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    // Check for updates after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdateOnce();
    });
  }

  Future<bool> _onWillPop() async {
    // Eğer çeyiz sekmesinde değilse, ilk sekmeye dön
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false; // Uygulamadan çıkma
    }

    // Çeyiz sekmesindeyse, çift tıklama kontrolü
    final now = DateTime.now();
    if (_lastBackPressTime == null || 
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      // İlk geri tuşu - uyarı göster
      _lastBackPressTime = now;
      
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.pressAgainToExit ?? 'Çıkmak için tekrar basın'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusMD,
            ),
            margin: const EdgeInsets.all(AppSpacing.md),
          ),
        );
      }
      return false; // Uygulamadan çıkma
    }
    
    // İkinci geri tuşu (2 saniye içinde) - çık
    return true;
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await _onWillPop();
        if (shouldPop) {
          // GoRouter ile çalışırken SystemNavigator.pop() kullan
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildTrousseauTab(context),
            const StatisticsScreen(),
            const SettingsScreen(),
          ],
        ),
        // ═════════════════════════════════════════════════════════════════════
        // BOTTOM NAVIGATION
        // JAKOB YASASI: Standart 3 tab layout (yaygın pattern)
        // HICK YASASI: Max 3 sekme (kolay seçim)
        // FITTS YASASI: 72dp height, 28dp icons (kolay dokunma)
        // ═════════════════════════════════════════════════════════════════════
        bottomNavigationBar: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedFontSize: AppTypography.sizeSM,
              unselectedFontSize: AppTypography.sizeXS,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onSurface,
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
                  label: l10n?.trousseau ?? 'Çeyiz',
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
                  label: l10n?.statistics ?? 'İstatistikler',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.settings_outlined,
                    size: AppDimensions.bottomNavIconSize,
                  ),
                  activeIcon: Icon(
                    Icons.settings,
                    size: AppDimensions.bottomNavIconSize,
                  ),
                  label: l10n?.settings ?? 'Ayarlar',
                ),
              ],
            );
          },
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

    // Loading state - Show loading ONLY if we haven't loaded initial data yet
    if (!trousseauProvider.hasInitialLoad) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Empty state - Only show if data has loaded AND list is empty
    if (pinnedTrousseaus.isEmpty) {
      final l10n = AppLocalizations.of(context);
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
                  l10n?.noTrousseauYet ?? 'Henüz çeyiz oluşturmadınız',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: AppTypography.sizeLG,
                    fontWeight: AppTypography.semiBold,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.sm.verticalSpace,
                Text(
                  l10n?.createFirstTrousseau ?? 'İlk çeyizinizi oluşturarak başlayın',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.xl.verticalSpace,
                AppPrimaryButton(
                  label: l10n?.createTrousseau ?? 'Çeyiz Oluştur',
                  icon: Icons.add,
                  onPressed: () => context.push('/create-trousseau'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show selected trousseau detail
    // Don't call ensureSelection here - let TrousseauDetailScreen handle it
    // This preserves the selection when switching between tabs
    final id = trousseauProvider.selectedTrousseauId ?? pinnedTrousseaus.first.id;
    return TrousseauDetailScreen(trousseauId: id, key: ValueKey(id));
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
    final l10n = AppLocalizations.of(context);

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
                  authProvider.forceUpdate 
                      ? (l10n?.updateRequired ?? 'Güncelleme Gerekli!') 
                      : (l10n?.newVersionAvailable ?? 'Yeni Versiyon Mevcut'),
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
                      '${l10n?.newVersion ?? 'Yeni Versiyon'}: ${authProvider.latestVersion}',
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
                          l10n?.forceUpdateMessage ?? 'Bu güncelleme zorunludur. Devam etmek için güncellemeniz gerekiyor.',
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
                label: l10n?.later ?? 'Daha Sonra',
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            AppPrimaryButton(
              label: l10n?.updateNow ?? 'Şimdi Güncelle',
              icon: Icons.download,
              onPressed: () async {
                const url = 'https://play.google.com/store/apps/details?id=com.Loncagames.ceyizdiz';
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (dialogContext.mounted) {
                    final dialogL10n = AppLocalizations.of(dialogContext);
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(dialogL10n?.playStoreOpenFailed ?? 'Play Store açılamadı.'),
                        backgroundColor: theme.colorScheme.error,
                      ),
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
