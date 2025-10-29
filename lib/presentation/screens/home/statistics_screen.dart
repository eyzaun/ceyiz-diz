library;

/// Statistics Screen - Yeni Tasarım Sistemi v2.0
///
/// TASARIM KURALLARI:
/// ✅ Jakob Yasası: Standart istatistik card layout
/// ✅ Fitts Yasası: Trousseau selector 48dp height, kolay dokunma
/// ✅ Hick Yasası: Info button tek secondary action
/// ✅ Miller Yasası: 3 bölüm - Genel Bakış (4 kart), İlerleme, Kategori Dağılımı
/// ✅ Gestalt: Her bölüm görsel olarak ayrılmış, kartlar gruplanmış

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../data/models/category_model.dart';
import '../../../core/services/kac_saat_calculator.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureInitialSelection();
    });
  }

  void _ensureInitialSelection() {
    final trProv = Provider.of<TrousseauProvider>(context, listen: false);
    trProv.ensureSelection();
    
    final selectedId = trProv.selectedTrousseauId;
    if (selectedId != null) {
      final productProv = Provider.of<ProductProvider>(context, listen: false);
      productProv.loadProducts(selectedId);

      final catProv = Provider.of<CategoryProvider>(context, listen: false);
      catProv.bind(selectedId, userId: trProv.currentUserId ?? '');
    }
  }

  void _selectTrousseau(String trousseauId) {
    final trProv = Provider.of<TrousseauProvider>(context, listen: false);
    
    if (trProv.selectedTrousseauId == trousseauId) return;

    trProv.setSelectedTrousseauId(trousseauId);

    final productProv = Provider.of<ProductProvider>(context, listen: false);
    productProv.loadProducts(trousseauId);

    final catProv = Provider.of<CategoryProvider>(context, listen: false);
    catProv.bind(trousseauId, userId: trProv.currentUserId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    final pinnedTrousseaus = trousseauProvider.pinnedTrousseaus;
    final kacSaatSettings = authProvider.currentUser?.kacSaatSettings;

    // Empty state
    if (pinnedTrousseaus.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n?.statistics ?? 'Statistics')),
        body: Center(child: Text(l10n?.trousseauNotFound ?? 'Trousseau not found')),
      );
    }

    // Auto-select first if none selected
    final selectedTrousseauId = trousseauProvider.selectedTrousseauId;
    if (selectedTrousseauId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureInitialSelection();
      });
      return Scaffold(
        appBar: AppBar(title: Text(l10n?.statistics ?? 'Statistics')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final trousseau = trousseauProvider.getTrousseauById(selectedTrousseauId);
    if (trousseau == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n?.statistics ?? 'Statistics')),
        body: Center(child: Text(l10n?.trousseauNotFound ?? 'Trousseau not found')),
      );
    }

    // Calculate statistics
    final categoryStats = Map<String, int>.from(trousseau.categoryCounts);
    final double totalBudget = trousseau.totalBudget;
    final double totalSpent = trousseau.spentAmount;
    final int totalProducts = productProvider.products.length;
    final int purchasedProducts = productProvider.getPurchasedCount();
    final double remainingBudget = totalBudget - totalSpent;
    final double totalPlanned = productProvider.getTotalPlanned();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.statistics ?? 'Statistics'),
        actions: [
          // HICK YASASI: Sadece 1 secondary action
          AppIconButton(
            icon: Icons.info_outline,
            tooltip: l10n?.statisticsGuideTooltip ?? 'Statistics Guide',
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          // ═══════════════════════════════════════════════════════════════════
          // TROUSSEAU SELECTOR (eğer birden fazla varsa)
          // FITTS YASASI: 48dp height, kolay dokunma
          // ═══════════════════════════════════════════════════════════════════
          if (pinnedTrousseaus.length > 1) ...[
            _buildTrousseauSelector(context, pinnedTrousseaus, selectedTrousseauId, theme),
            AppSpacing.lg.verticalSpace,
          ],

          // ═══════════════════════════════════════════════════════════════════
          // SECTION 1: GENEL BAKIŞ (4 Kart)
          // MILLER YASASI: 4 kart 2x2 grid'de = ideal
          // GESTALT: Yakınlık - başlık + kartlar gruplanmış
          // ═══════════════════════════════════════════════════════════════════
          Text(
            trousseau.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppTypography.bold,
              fontSize: AppTypography.sizeXL,
            ),
          ),
          AppSpacing.xs.verticalSpace,
          Text(
            l10n?.overview ?? 'Overview',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: AppTypography.sizeBase,
            ),
          ),
          AppSpacing.md.verticalSpace,

          // Row 1: Toplam Bütçe + Harcanan
          Row(
            children: [
              Expanded(
                child: AppStatCard(
                  icon: Icons.account_balance_wallet,
                  title: l10n?.totalBudget ?? 'Total Budget',
                  value: '₺${totalBudget.toStringAsFixed(0)}',
                  color: theme.colorScheme.primary,
                ),
              ),
              AppSpacing.md.horizontalSpace,
              Expanded(
                child: AppStatCard(
                  icon: Icons.shopping_cart,
                  title: l10n?.spent ?? 'Spent',
                  value: '₺${totalSpent.toStringAsFixed(0)}',
                  subtitle: totalBudget > 0 
                    ? '%${((totalSpent / totalBudget) * 100).toStringAsFixed(0)} ${l10n?.percentUsed ?? 'used'}'
                    : null,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),

          AppSpacing.md.verticalSpace,

          // Row 2: Kalan Bütçe + Planlanan Toplam
          Row(
            children: [
              Expanded(
                child: AppStatCard(
                  icon: remainingBudget >= 0 ? Icons.savings : Icons.warning,
                  title: l10n?.remainingBudget ?? 'Remaining Budget',
                  value: '₺${remainingBudget.toStringAsFixed(0)}',
                  subtitle: remainingBudget >= 0 
                    ? l10n?.withinBudget ?? 'Within budget'
                    : '₺${(-remainingBudget).toStringAsFixed(0)} ${l10n?.excess ?? 'excess'}',
                  color: remainingBudget >= 0 ? theme.colorScheme.tertiary : theme.colorScheme.error,
                ),
              ),
              AppSpacing.md.horizontalSpace,
              Expanded(
                child: AppStatCard(
                  icon: Icons.calculate,
                  title: l10n?.plannedTotal ?? 'Planned Total',
                  value: '₺${totalPlanned.toStringAsFixed(0)}',
                  subtitle: totalBudget > 0 
                    ? '%${((totalPlanned / totalBudget) * 100).toStringAsFixed(0)} ${l10n?.fromBudget ?? 'from budget'}'
                    : null,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),

          AppSpacing.md.verticalSpace,

          // Row 3: Ortalama Ürün Fiyatı + En Pahalı Ürün
          Row(
            children: [
              Expanded(
                child: AppStatCard(
                  icon: Icons.attach_money,
                  title: l10n?.averagePrice ?? 'Average Price',
                  value: totalProducts > 0 
                    ? '₺${(totalPlanned / totalProducts).toStringAsFixed(0)}'
                    : '₺0',
                  subtitle: l10n?.perProduct ?? 'Per product',
                  color: Colors.orange,
                ),
              ),
              AppSpacing.md.horizontalSpace,
              Expanded(
                child: AppStatCard(
                  icon: Icons.arrow_upward,
                  title: l10n?.mostExpensive ?? 'Most Expensive',
                  value: _getMostExpensiveProduct(productProvider),
                  subtitle: _getMostExpensiveProductName(productProvider),
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),

          AppSpacing.xl.verticalSpace,

          // ═══════════════════════════════════════════════════════════════════
          // BÜTÇE SAĞLIĞI KARTI
          // ═══════════════════════════════════════════════════════════════════
          _buildBudgetHealthCard(
            context,
            totalBudget,
            totalSpent,
            totalPlanned,
            remainingBudget,
            theme,
          ),

          AppSpacing.xl.verticalSpace,

          // ═══════════════════════════════════════════════════════════════════
          // SECTION 2: İLERLEME KARTI
          // MILLER YASASI: 3 veri noktası (Toplam, Tamamlanan, Bekleyen)
          // ═══════════════════════════════════════════════════════════════════
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n?.progress ?? 'Progress',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.sizeLG,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: AppRadius.radiusXL,
                      ),
                      child: Text(
                        '${totalProducts > 0 ? ((purchasedProducts / totalProducts) * 100).toStringAsFixed(0) : 0}%',
                        style: TextStyle(
                          fontWeight: AppTypography.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                          fontSize: AppTypography.sizeBase,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.md.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _progressStat(
                      context,
                      l10n?.totalProducts ?? 'Total Products',
                      totalProducts.toString(),
                      Icons.inventory_2,
                      theme.colorScheme.primary,
                    ),
                    _progressStat(
                      context,
                      l10n?.completed ?? 'Completed',
                      purchasedProducts.toString(),
                      Icons.check_circle,
                      theme.colorScheme.tertiary,
                    ),
                    _progressStat(
                      context,
                      l10n?.pending ?? 'Pending',
                      (totalProducts - purchasedProducts).toString(),
                      Icons.pending,
                      theme.colorScheme.secondary,
                    ),
                  ],
                ),
                AppSpacing.md.verticalSpace,
                LinearProgressIndicator(
                  value: totalProducts > 0 ? purchasedProducts / totalProducts : 0,
                  minHeight: 12,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.radiusSM,
                ),
              ],
            ),
          ),

          AppSpacing.xl.verticalSpace,

          // ═══════════════════════════════════════════════════════════════════
          // TAMAMLANMA TAHMİNİ KARTI
          // ═══════════════════════════════════════════════════════════════════
          if (totalProducts > 0 && purchasedProducts > 0) ...[
            _buildCompletionEstimateCard(
              context,
              totalProducts,
              purchasedProducts,
              trousseau.createdAt,
              theme,
            ),
            AppSpacing.xl.verticalSpace,
          ],

          // ═══════════════════════════════════════════════════════════════════
          // KATEGORİ ANALİZİ - ÖNE ÇIKAN İSTATİSTİKLER
          // ═══════════════════════════════════════════════════════════════════
          if (categoryStats.isNotEmpty) ...[
            _buildCategoryInsightsCard(
              context,
              categoryStats,
              categoryProvider,
              productProvider,
              theme,
            ),
            AppSpacing.xl.verticalSpace,
          ],

          // ═══════════════════════════════════════════════════════════════════
          // KAÇ SAAT ANALİZİ (eğer aktif ise)
          // ═══════════════════════════════════════════════════════════════════
          if (kacSaatSettings?.enabled == true) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n?.kacSaatAnalysis ?? 'Work Hours Analysis',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.sizeLG,
                        ),
                      ),
                      AppIconButton(
                        icon: Icons.settings,
                        tooltip: l10n?.settings ?? 'Settings',
                        onPressed: () => context.push('/settings/kac-saat'),
                      ),
                    ],
                  ),
                  AppSpacing.md.verticalSpace,
                  _buildKacSaatAnalysis(
                    context,
                    kacSaatSettings!,
                    totalPlanned,
                    totalSpent,
                    theme,
                  ),
                ],
              ),
            ),
            AppSpacing.xl.verticalSpace,
          ],

          // ═══════════════════════════════════════════════════════════════════
          // SECTION 3: BÜTÇE ANALİZİ (eğer bütçe varsa)
          // ═══════════════════════════════════════════════════════════════════
          if (totalBudget > 0) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.budgetAnalysis ?? 'Budget Analysis',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: AppTypography.bold,
                      fontSize: AppTypography.sizeLG,
                    ),
                  ),
                  AppSpacing.md.verticalSpace,
                  _budgetBar(
                    context,
                    l10n?.spent ?? 'Spent',
                    totalSpent,
                    totalBudget,
                    theme.colorScheme.secondary,
                  ),
                  AppSpacing.md.verticalSpace,
                  _budgetBar(
                    context,
                    l10n?.planned ?? 'Planned',
                    totalPlanned,
                    totalBudget,
                    theme.colorScheme.primary,
                  ),
                  // Warning if budget exceeded
                  if (remainingBudget < 0) ...[
                    AppSpacing.md.verticalSpace,
                    AppInfoCard(
                      type: InfoCardType.error,
                      title: l10n?.budgetExceeded ?? 'Budget Exceeded!',
                      message: '₺${(-remainingBudget).toStringAsFixed(0)} ${l10n?.excessSpent ?? 'excess spent.'}',
                    ),
                  ],
                ],
              ),
            ),
            AppSpacing.xl.verticalSpace,
          ],

          // ═══════════════════════════════════════════════════════════════════
          // SECTION 4: KATEGORİ DAĞILIMI
          // MILLER YASASI: Kategoriler listelenir ama her kart 1 kategori = basit
          // ═══════════════════════════════════════════════════════════════════
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.categoryDistribution ?? 'Category Distribution',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: AppTypography.bold,
                  fontSize: AppTypography.sizeLG,
                ),
              ),
              AppTextButton(
                label: l10n?.viewAll ?? 'View All',
                icon: Icons.arrow_forward,
                onPressed: () => context.push('/trousseau/$selectedTrousseauId/products'),
              ),
            ],
          ),
          AppSpacing.md.verticalSpace,
          ..._buildCategoryBreakdown(context, categoryStats, categoryProvider, productProvider, theme),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TROUSSEAU SELECTOR
  // FITTS YASASI: 48dp height, kolay dokunma
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTrousseauSelector(BuildContext context, List<dynamic> trousseaus, String selectedTrousseauId, ThemeData theme) {
    return Container(
      height: AppDimensions.touchTargetSize,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: AppRadius.radiusMD,
      ),
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: trousseaus.length,
        separatorBuilder: (_, __) => AppSpacing.xs.horizontalSpace,
        itemBuilder: (context, index) {
          final trousseau = trousseaus[index];
          final isSelected = trousseau.id == selectedTrousseauId;

          return Material(
            color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
            borderRadius: AppRadius.radiusSM,
            child: InkWell(
              onTap: () => _selectTrousseau(trousseau.id),
              borderRadius: AppRadius.radiusSM,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (trousseau.ownerId != Provider.of<TrousseauProvider>(context, listen: false).currentUserId) ...[
                      Icon(
                        Icons.people_outline,
                        size: AppDimensions.iconSizeSmall,
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      AppSpacing.xs.horizontalSpace,
                    ],
                    Text(
                      trousseau.name,
                      style: TextStyle(
                        fontSize: AppTypography.sizeBase,
                        fontWeight: isSelected ? AppTypography.semiBold : AppTypography.regular,
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // KAÇ SAAT ANALYSIS WIDGET
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildKacSaatAnalysis(
    BuildContext context,
    KacSaatSettings settings,
    double totalPlanned,
    double totalSpent,
    ThemeData theme,
  ) {
    final calculator = settings.toCalculator();

    final l10n = AppLocalizations.of(context);
    
    if (!calculator.isValid) {
      return AppInfoCard(
        type: InfoCardType.warning,
        title: l10n?.settingsIncomplete ?? 'Settings Incomplete',
        message: l10n?.completeKacSaatSettings ?? 'Complete your settings for work hours calculation.',
      );
    }

    final plannedHours = calculator.calculateHoursForPrice(totalPlanned);
    final spentHours = calculator.calculateHoursForPrice(totalSpent);
    final plannedDays = calculator.calculateWorkingDaysForPrice(totalPlanned);
    final spentDays = calculator.calculateWorkingDaysForPrice(totalSpent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Planlanan Toplam
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.plannedTotal ?? 'Planned Total',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: AppTypography.sizeSM,
                    ),
                  ),
                  AppSpacing.xs.verticalSpace,
                  Text(
                    calculator.formatHours(plannedHours),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: AppTypography.bold,
                      color: theme.colorScheme.primary,
                      fontSize: AppTypography.sizeBase,
                    ),
                  ),
                  Text(
                    '≈ ${plannedDays.toStringAsFixed(1)} ${l10n?.workDays ?? 'work days'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: AppTypography.sizeXS,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        AppSpacing.md.verticalSpace,
        Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        AppSpacing.md.verticalSpace,

        // Harcanan Toplam
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.spent ?? 'Spent',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: AppTypography.sizeSM,
                    ),
                  ),
                  AppSpacing.xs.verticalSpace,
                  Text(
                    calculator.formatHours(spentHours),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: AppTypography.bold,
                      color: theme.colorScheme.secondary,
                      fontSize: AppTypography.sizeBase,
                    ),
                  ),
                  Text(
                    '≈ ${spentDays.toStringAsFixed(1)} ${l10n?.workDays ?? 'work days'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: AppTypography.sizeXS,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        AppSpacing.md.verticalSpace,
        Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        AppSpacing.md.verticalSpace,

        // Hesaplama Özeti
        Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: AppRadius.radiusMD,
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                size: AppDimensions.iconSizeMedium,
                color: theme.colorScheme.primary,
              ),
              AppSpacing.sm.horizontalSpace,
              Expanded(
                child: Text(
                  '${l10n?.hourlyEarnings ?? 'Your hourly earnings'}: ₺${calculator.hourlyRate.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: AppTypography.sizeSM,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUDGET BAR WIDGET
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _budgetBar(BuildContext context, String label, double amount, double total, Color color) {
    final theme = Theme.of(context);
    final percent = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: AppTypography.medium,
                fontSize: AppTypography.sizeBase,
              ),
            ),
            Text(
              '₺${amount.toStringAsFixed(0)} (${(percent * 100).toStringAsFixed(0)}%)',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: AppTypography.bold,
                color: color,
                fontSize: AppTypography.sizeBase,
              ),
            ),
          ],
        ),
        AppSpacing.sm.verticalSpace,
        LinearProgressIndicator(
          value: percent,
          minHeight: 8,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          color: color,
          borderRadius: AppRadius.radiusXS,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PROGRESS STAT WIDGET
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _progressStat(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: AppDimensions.iconSizeLarge),
        AppSpacing.xs.verticalSpace,
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: AppTypography.bold,
            color: color,
            fontSize: AppTypography.sizeXL,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontSize: AppTypography.sizeSM,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORY BREAKDOWN
  // ═══════════════════════════════════════════════════════════════════════════

  List<Widget> _buildCategoryBreakdown(
    BuildContext context,
    Map<String, int> categoryStats,
    CategoryProvider categoryProvider,
    ProductProvider productProvider,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context);
    final total = categoryStats.values.fold<int>(0, (a, b) => a + b);

    if (total == 0) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                AppSpacing.md.verticalSpace,
                Text(
                  l10n?.noCategoryDataYet ?? 'No category data yet',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    final entries = categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final allCats = categoryProvider.allCategories;

    return entries.map((e) {
      final id = e.key;
      final count = e.value;

      CategoryModel? found;
      try {
        found = allCats.firstWhere((c) => c.id == id);
      } catch (_) {
        found = null;
      }

      final category = found ?? _deriveCategory(id);
      final percent = total > 0 ? count / total : 0.0;

      final categorySpending = productProvider.products
          .where((p) => p.category == id && p.isPurchased)
          .fold<double>(0, (sum, p) => sum + p.totalPrice);

      return AppCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.15),
                    borderRadius: AppRadius.radiusMD,
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: AppDimensions.iconSizeMedium,
                  ),
                ),
                AppSpacing.md.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.sizeBase,
                        ),
                      ),
                      AppSpacing.xs.verticalSpace,
                      Text(
                        '$count ürün • ₺${categorySpending.toStringAsFixed(0)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontSize: AppTypography.sizeSM,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(percent * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: AppTypography.bold,
                    color: category.color,
                    fontSize: AppTypography.sizeMD,
                  ),
                ),
              ],
            ),
            AppSpacing.md.verticalSpace,
            LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: category.color,
              borderRadius: AppRadius.radiusXS,
            ),
          ],
        ),
      );
    }).toList();
  }

  CategoryModel _deriveCategory(String id) {
    final defaults = CategoryModel.defaultCategories;
    try {
      return defaults.firstWhere((c) => c.id == id);
    } catch (_) {
      return CategoryModel(
        id: id,
        name: id,
        displayName: _humanizeId(id),
        icon: Icons.category,
        color: CategoryModel.colorFromString(id),
        sortOrder: 1000,
        isCustom: true,
      );
    }
  }

  String _humanizeId(String id) {
    final l10n = AppLocalizations.of(context);
    final s = id.replaceAll('-', ' ').replaceAll('_', ' ');
    if (s.isEmpty) return l10n?.other ?? 'Other';
    return s[0].toUpperCase() + s.substring(1);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS - PRODUCT STATS
  // ═══════════════════════════════════════════════════════════════════════════

  String _getMostExpensiveProduct(ProductProvider productProvider) {
    final products = productProvider.products;
    if (products.isEmpty) return '₺0';

    final mostExpensive = products.reduce((a, b) => 
      a.totalPrice > b.totalPrice ? a : b
    );

    return '₺${mostExpensive.totalPrice.toStringAsFixed(0)}';
  }

  String? _getMostExpensiveProductName(ProductProvider productProvider) {
    final products = productProvider.products;
    if (products.isEmpty) return null;

    final mostExpensive = products.reduce((a, b) => 
      a.totalPrice > b.totalPrice ? a : b
    );

    // Truncate long names
    final name = mostExpensive.name;
    return name.length > 15 ? '${name.substring(0, 15)}...' : name;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPLETION ESTIMATE CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCompletionEstimateCard(
    BuildContext context,
    int totalProducts,
    int purchasedProducts,
    DateTime createdAt,
    ThemeData theme,
  ) {
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    
    // Calculate average products per day
    final avgProductsPerDay = daysSinceCreation > 0 
      ? purchasedProducts / daysSinceCreation 
      : 0.0;

    // Estimate days to completion
    final remainingProducts = totalProducts - purchasedProducts;
    final estimatedDaysToComplete = avgProductsPerDay > 0 
      ? (remainingProducts / avgProductsPerDay).ceil() 
      : 0;

    final completionDate = estimatedDaysToComplete > 0
      ? DateTime.now().add(Duration(days: estimatedDaysToComplete))
      : null;

    // Calculate progress rate
    final l10n = AppLocalizations.of(context);
    String progressRating = '';
    Color progressColor = theme.colorScheme.primary;

    if (avgProductsPerDay >= 1.0) {
      progressRating = l10n?.veryFast ?? 'Very Fast';
      progressColor = Colors.green;
    } else if (avgProductsPerDay >= 0.5) {
      progressRating = l10n?.good ?? 'Good';
      progressColor = Colors.lightGreen;
    } else if (avgProductsPerDay >= 0.2) {
      progressRating = l10n?.medium ?? 'Medium';
      progressColor = Colors.orange;
    } else {
      progressRating = l10n?.slow ?? 'Slow';
      progressColor = Colors.deepOrange;
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.completionEstimate ?? 'Completion Estimate',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: AppTypography.bold,
                  fontSize: AppTypography.sizeLG,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.2),
                  borderRadius: AppRadius.radiusXL,
                ),
                child: Text(
                  progressRating,
                  style: TextStyle(
                    fontWeight: AppTypography.bold,
                    color: progressColor,
                    fontSize: AppTypography.sizeSM,
                  ),
                ),
              ),
            ],
          ),

          AppSpacing.md.verticalSpace,

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _infoTile(
                  context,
                  Icons.calendar_today,
                  l10n?.start ?? 'Start',
                  '$daysSinceCreation ${l10n?.daysAgo ?? 'days ago'}',
                  theme,
                ),
              ),
              AppSpacing.md.horizontalSpace,
              Expanded(
                child: _infoTile(
                  context,
                  Icons.speed,
                  l10n?.speed ?? 'Speed',
                  '${avgProductsPerDay.toStringAsFixed(1)} ${l10n?.productsPerDay ?? 'products/day'}',
                  theme,
                ),
              ),
            ],
          ),

          AppSpacing.md.verticalSpace,

          Row(
            children: [
              Expanded(
                child: _infoTile(
                  context,
                  Icons.hourglass_empty,
                  l10n?.remaining ?? 'Remaining',
                  '$remainingProducts ${l10n?.products ?? 'products'}',
                  theme,
                ),
              ),
              AppSpacing.md.horizontalSpace,
              Expanded(
                child: _infoTile(
                  context,
                  Icons.event_available,
                  l10n?.estimatedCompletion ?? 'Estimated Completion',
                  completionDate != null
                    ? '~$estimatedDaysToComplete ${l10n?.days ?? 'days'}'
                    : l10n?.cannotCalculate ?? 'Cannot calculate',
                  theme,
                ),
              ),
            ],
          ),

          if (completionDate != null) ...[
            AppSpacing.md.verticalSpace,
            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: AppRadius.radiusMD,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: theme.colorScheme.primary,
                    size: AppDimensions.iconSizeMedium,
                  ),
                  AppSpacing.sm.horizontalSpace,
                  Expanded(
                    child: Text(
                      _getCompletionMessage(l10n, completionDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: AppTypography.sizeSM,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date, String locale) {
    final formatter = DateFormat.yMMMMd(locale);
    return formatter.format(date);
  }

  String _getCompletionMessage(AppLocalizations? l10n, DateTime date) {
    final locale = l10n?.localeName ?? 'tr';
    final formattedDate = _formatDate(date, locale);
    
    return l10n?.completionMessage(formattedDate) ?? 
           'At your current pace, you can complete your trousseau around ~$formattedDate.';
  }

  Widget _infoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: AppRadius.radiusMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: AppDimensions.iconSizeSmall,
                color: theme.colorScheme.primary,
              ),
              AppSpacing.xs.horizontalSpace,
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: AppTypography.sizeXS,
                ),
              ),
            ],
          ),
          AppSpacing.xs.verticalSpace,
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: AppTypography.bold,
              fontSize: AppTypography.sizeSM,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORY INSIGHTS CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCategoryInsightsCard(
    BuildContext context,
    Map<String, int> categoryStats,
    CategoryProvider categoryProvider,
    ProductProvider productProvider,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context);
    
    // Find most/least products category
    final entries = categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) return const SizedBox.shrink();

    final mostProductsEntry = entries.first;
    final leastProductsEntry = entries.last;

    final allCats = categoryProvider.allCategories;

    // Get category models
    CategoryModel? mostCat;
    CategoryModel? leastCat;

    try {
      mostCat = allCats.firstWhere((c) => c.id == mostProductsEntry.key);
    } catch (_) {
      mostCat = _deriveCategory(mostProductsEntry.key);
    }

    try {
      leastCat = allCats.firstWhere((c) => c.id == leastProductsEntry.key);
    } catch (_) {
      leastCat = _deriveCategory(leastProductsEntry.key);
    }

    // Calculate spending per category
    final mostCategorySpending = productProvider.products
        .where((p) => p.category == mostProductsEntry.key && p.isPurchased)
        .fold<double>(0, (sum, p) => sum + p.totalPrice);

    final leastCategorySpending = productProvider.products
        .where((p) => p.category == leastProductsEntry.key && p.isPurchased)
        .fold<double>(0, (sum, p) => sum + p.totalPrice);

    // Calculate average price per category
    final avgMostCategory = mostProductsEntry.value > 0
        ? mostCategorySpending / mostProductsEntry.value
        : 0.0;

    final avgLeastCategory = leastProductsEntry.value > 0
        ? leastCategorySpending / leastProductsEntry.value
        : 0.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.categoryAnalysis ?? 'Category Analysis',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: AppTypography.bold,
                  fontSize: AppTypography.sizeLG,
                ),
              ),
              Icon(
                Icons.analytics,
                color: theme.colorScheme.primary,
                size: AppDimensions.iconSizeMedium,
              ),
            ],
          ),

          AppSpacing.md.verticalSpace,

          // Most Products Category
          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: mostCat.color.withValues(alpha: 0.1),
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                color: mostCat.color.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: mostCat.color.withValues(alpha: 0.2),
                    borderRadius: AppRadius.radiusSM,
                  ),
                  child: Icon(
                    mostCat.icon,
                    color: mostCat.color,
                    size: AppDimensions.iconSizeMedium,
                  ),
                ),
                AppSpacing.md.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👑 ${l10n?.mostProducts ?? 'Most Products'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: AppTypography.sizeXS,
                        ),
                      ),
                      AppSpacing.xs.verticalSpace,
                      Text(
                        mostCat.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.sizeBase,
                        ),
                      ),
                      AppSpacing.xs.verticalSpace,
                      Text(
                        '${mostProductsEntry.value} ${l10n?.products ?? 'products'} • ${l10n?.average ?? 'Avg'}: ₺${avgMostCategory.toStringAsFixed(0)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontSize: AppTypography.sizeXS,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₺${mostCategorySpending.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: AppTypography.bold,
                    color: mostCat.color,
                    fontSize: AppTypography.sizeMD,
                  ),
                ),
              ],
            ),
          ),

          if (entries.length > 1) ...[
            AppSpacing.md.verticalSpace,

            // Least Products Category
            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: leastCat.color.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusMD,
                border: Border.all(
                  color: leastCat.color.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: leastCat.color.withValues(alpha: 0.2),
                      borderRadius: AppRadius.radiusSM,
                    ),
                    child: Icon(
                      leastCat.icon,
                      color: leastCat.color,
                      size: AppDimensions.iconSizeMedium,
                    ),
                  ),
                  AppSpacing.md.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📉 ${l10n?.leastProducts ?? 'Least Products'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: AppTypography.sizeXS,
                          ),
                        ),
                        AppSpacing.xs.verticalSpace,
                        Text(
                          leastCat.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: AppTypography.bold,
                            fontSize: AppTypography.sizeBase,
                          ),
                        ),
                        AppSpacing.xs.verticalSpace,
                        Text(
                          '${leastProductsEntry.value} ürün • Ort: ₺${avgLeastCategory.toStringAsFixed(0)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontSize: AppTypography.sizeXS,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₺${leastCategorySpending.toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: AppTypography.bold,
                      color: leastCat.color,
                      fontSize: AppTypography.sizeMD,
                    ),
                  ),
                ],
              ),
            ),
          ],

          AppSpacing.md.verticalSpace,

          // Summary
          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: AppRadius.radiusMD,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: AppDimensions.iconSizeSmall,
                ),
                AppSpacing.sm.horizontalSpace,
                Expanded(
                  child: Text(
                    l10n?.totalCategoryCount(entries.length) ?? 
                    'You have products in ${entries.length} different categories.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: AppTypography.sizeSM,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUDGET HEALTH CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBudgetHealthCard(
    BuildContext context,
    double totalBudget,
    double totalSpent,
    double totalPlanned,
    double remainingBudget,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context);
    
    // Calculate health score (0-100)
    int healthScore = 100;
    String healthStatus = l10n?.budgetHealthPerfect ?? 'Perfect';
    Color healthColor = Colors.green;
    IconData healthIcon = Icons.sentiment_very_satisfied;
    String healthMessage = l10n?.budgetHealthPerfect ?? 'You\'re managing your budget perfectly!';

    if (totalBudget > 0) {
      final spentPercent = (totalSpent / totalBudget) * 100;
      final plannedPercent = (totalPlanned / totalBudget) * 100;

      if (remainingBudget < 0) {
        // Budget exceeded
        healthScore = 0;
        healthStatus = l10n?.budgetHealthCritical ?? 'Critical';
        healthColor = theme.colorScheme.error;
        healthIcon = Icons.sentiment_very_dissatisfied;
        healthMessage = l10n?.budgetHealthCritical ?? 'You\'ve exceeded your budget! Review your spending.';
      } else if (plannedPercent > 100) {
        // Planned exceeds budget
        healthScore = 30;
        healthStatus = l10n?.budgetHealthRisky ?? 'Risky';
        healthColor = Colors.orange;
        healthIcon = Icons.sentiment_dissatisfied;
        healthMessage = l10n?.budgetHealthRisky ?? 'Planned spending exceeds budget. Make a plan.';
      } else if (spentPercent > 80) {
        // 80%+ spent
        healthScore = 50;
        healthStatus = l10n?.beCareful ?? 'Be Careful';
        healthColor = Colors.orange.shade700;
        healthIcon = Icons.sentiment_neutral;
        healthMessage = l10n?.budgetHealthBeCareful ?? 'You\'ve spent most of your budget. Proceed carefully.';
      } else if (spentPercent > 60) {
        // 60-80% spent
        healthScore = 70;
        healthStatus = l10n?.good ?? 'Good';
        healthColor = Colors.lightGreen;
        healthIcon = Icons.sentiment_satisfied;
        healthMessage = l10n?.budgetHealthGood ?? 'Going well! Keep your spending under control.';
      } else {
        // <60% spent
        healthScore = 100;
        healthStatus = l10n?.budgetHealthPerfect ?? 'Perfect';
        healthColor = Colors.green;
        healthIcon = Icons.sentiment_very_satisfied;
        healthMessage = l10n?.budgetHealthPerfect ?? 'You\'re managing your budget perfectly!';
      }
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.budgetHealth ?? 'Budget Health',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: AppTypography.bold,
                  fontSize: AppTypography.sizeLG,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: healthColor.withValues(alpha: 0.2),
                  borderRadius: AppRadius.radiusXL,
                  border: Border.all(
                    color: healthColor.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      healthIcon,
                      color: healthColor,
                      size: AppDimensions.iconSizeMedium,
                    ),
                    AppSpacing.xs.horizontalSpace,
                    Text(
                      healthStatus,
                      style: TextStyle(
                        fontWeight: AppTypography.bold,
                        color: healthColor,
                        fontSize: AppTypography.sizeBase,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.md.verticalSpace,
          
          // Health Score Progress
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.healthScore ?? 'Health Score',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: AppTypography.sizeSM,
                      ),
                    ),
                    AppSpacing.xs.verticalSpace,
                    LinearProgressIndicator(
                      value: healthScore / 100,
                      minHeight: 12,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      color: healthColor,
                      borderRadius: AppRadius.radiusSM,
                    ),
                  ],
                ),
              ),
              AppSpacing.md.horizontalSpace,
              Text(
                '$healthScore/100',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: AppTypography.bold,
                  color: healthColor,
                  fontSize: AppTypography.sizeXL,
                ),
              ),
            ],
          ),

          AppSpacing.md.verticalSpace,

          // Health Message
          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: healthColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                color: healthColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: healthColor,
                  size: AppDimensions.iconSizeMedium,
                ),
                AppSpacing.sm.horizontalSpace,
                Expanded(
                  child: Text(
                    healthMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: AppTypography.sizeSM,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INFO DIALOG
  // ═══════════════════════════════════════════════════════════════════════════

  void _showInfoDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXL,
        ),
        title: Row(
          children: [
            const Icon(Icons.info_outline, size: 28),
            const SizedBox(width: 12),
            Text(l10n?.statisticsGuide ?? 'Statistics Guide'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n?.statisticsGuide ?? 
                '📊 Overview\n\n'
                '• Total Budget: Your target budget\n'
                '• Spent: Total of purchased items\n'
                '• Remaining Budget: Amount you can spend\n'
                '• Planned Total: Cost of all items\n'
                '• Average Price: Amount per item\n'
                '• Most Expensive: Highest priced item\n\n'
                '💚 Budget Health\n\n'
                '• Perfect (100): Spent less than 60%\n'
                '• Good (70): 60-80% spending\n'
                '• Be Careful (50): Over 80% used\n'
                '• Risky (30): Planned exceeds budget\n'
                '• Critical (0): Budget exceeded!\n\n'
                '📅 Completion Estimate\n\n'
                'Estimates when you\'ll complete your trousseau based on current shopping speed.\n\n'
                '🏆 Category Analysis\n\n'
                'Categories with most/least products, average spending, and category-based statistics.',
                style: const TextStyle(height: 1.5, fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          AppTextButton(
            label: l10n?.understood ?? 'Understood',
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }
}
