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
import '../../../core/theme/design_tokens.dart';
import '../../../data/models/category_model.dart';
import '../../../core/services/kac_saat_calculator.dart';
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
  String? _selectedTrousseauId;

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
    final pinnedTrousseaus = trProv.pinnedTrousseaus;

    if (pinnedTrousseaus.isNotEmpty && _selectedTrousseauId == null) {
      setState(() {
        _selectedTrousseauId = pinnedTrousseaus.first.id;
      });

      final productProv = Provider.of<ProductProvider>(context, listen: false);
      productProv.loadProducts(_selectedTrousseauId!);

      final catProv = Provider.of<CategoryProvider>(context, listen: false);
      catProv.bind(_selectedTrousseauId!, userId: trProv.currentUserId ?? '');
    }
  }

  void _selectTrousseau(String trousseauId) {
    if (_selectedTrousseauId == trousseauId) return;

    setState(() {
      _selectedTrousseauId = trousseauId;
    });

    final trProv = Provider.of<TrousseauProvider>(context, listen: false);
    final productProv = Provider.of<ProductProvider>(context, listen: false);
    productProv.loadProducts(trousseauId);

    final catProv = Provider.of<CategoryProvider>(context, listen: false);
    catProv.bind(trousseauId, userId: trProv.currentUserId ?? '');
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(title: const Text('İstatistikler')),
        body: const Center(child: Text('Çeyiz bulunamadı')),
      );
    }

    // Auto-select first if none selected
    if (_selectedTrousseauId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureInitialSelection();
      });
      return Scaffold(
        appBar: AppBar(title: const Text('İstatistikler')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final trousseau = trousseauProvider.getTrousseauById(_selectedTrousseauId!);
    if (trousseau == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('İstatistikler')),
        body: const Center(child: Text('Çeyiz bulunamadı')),
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
        title: const Text('İstatistikler'),
        actions: [
          // HICK YASASI: Sadece 1 secondary action
          AppIconButton(
            icon: Icons.info_outline,
            tooltip: 'İstatistik Açıklaması',
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
            _buildTrousseauSelector(context, pinnedTrousseaus, theme),
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
            'Genel Bakış',
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
                  title: 'Toplam Bütçe',
                  value: '₺${totalBudget.toStringAsFixed(0)}',
                  color: theme.colorScheme.primary,
                ),
              ),
              AppSpacing.md.horizontalSpace,
              Expanded(
                child: AppStatCard(
                  icon: Icons.shopping_cart,
                  title: 'Harcanan',
                  value: '₺${totalSpent.toStringAsFixed(0)}',
                  subtitle: totalBudget > 0 
                    ? '%${((totalSpent / totalBudget) * 100).toStringAsFixed(0)} kullanıldı'
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
                  title: 'Kalan Bütçe',
                  value: '₺${remainingBudget.toStringAsFixed(0)}',
                  subtitle: remainingBudget >= 0 
                    ? 'Bütçe içinde'
                    : '₺${(-remainingBudget).toStringAsFixed(0)} fazla',
                  color: remainingBudget >= 0 ? theme.colorScheme.tertiary : theme.colorScheme.error,
                ),
              ),
              AppSpacing.md.horizontalSpace,
              Expanded(
                child: AppStatCard(
                  icon: Icons.calculate,
                  title: 'Planlanan Toplam',
                  value: '₺${totalPlanned.toStringAsFixed(0)}',
                  subtitle: totalBudget > 0 
                    ? '%${((totalPlanned / totalBudget) * 100).toStringAsFixed(0)} bütçeden'
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
                  title: 'Ortalama Fiyat',
                  value: totalProducts > 0 
                    ? '₺${(totalPlanned / totalProducts).toStringAsFixed(0)}'
                    : '₺0',
                  subtitle: 'Ürün başına',
                  color: Colors.orange,
                ),
              ),
              AppSpacing.md.horizontalSpace,
              Expanded(
                child: AppStatCard(
                  icon: Icons.arrow_upward,
                  title: 'En Pahalı',
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
                      'İlerleme',
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
                      'Toplam Ürün',
                      totalProducts.toString(),
                      Icons.inventory_2,
                      theme.colorScheme.primary,
                    ),
                    _progressStat(
                      context,
                      'Tamamlanan',
                      purchasedProducts.toString(),
                      Icons.check_circle,
                      theme.colorScheme.tertiary,
                    ),
                    _progressStat(
                      context,
                      'Bekleyen',
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
                        'Kaç Saat Analizi',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.sizeLG,
                        ),
                      ),
                      AppIconButton(
                        icon: Icons.settings,
                        tooltip: 'Ayarlar',
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
                    'Bütçe Analizi',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: AppTypography.bold,
                      fontSize: AppTypography.sizeLG,
                    ),
                  ),
                  AppSpacing.md.verticalSpace,
                  _budgetBar(
                    context,
                    'Harcanan',
                    totalSpent,
                    totalBudget,
                    theme.colorScheme.secondary,
                  ),
                  AppSpacing.md.verticalSpace,
                  _budgetBar(
                    context,
                    'Planlanan',
                    totalPlanned,
                    totalBudget,
                    theme.colorScheme.primary,
                  ),
                  // Warning if budget exceeded
                  if (remainingBudget < 0) ...[
                    AppSpacing.md.verticalSpace,
                    AppInfoCard(
                      type: InfoCardType.error,
                      title: 'Bütçe Aşıldı!',
                      message: '₺${(-remainingBudget).toStringAsFixed(0)} fazla harcandı.',
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
                'Kategori Dağılımı',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: AppTypography.bold,
                  fontSize: AppTypography.sizeLG,
                ),
              ),
              AppTextButton(
                label: 'Tümünü Gör',
                icon: Icons.arrow_forward,
                onPressed: () => context.push('/trousseau/$_selectedTrousseauId/products'),
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

  Widget _buildTrousseauSelector(BuildContext context, List<dynamic> trousseaus, ThemeData theme) {
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
          final isSelected = trousseau.id == _selectedTrousseauId;

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

    if (!calculator.isValid) {
      return AppInfoCard(
        type: InfoCardType.warning,
        title: 'Ayarlar Eksik',
        message: 'Kaç Saat hesaplaması için ayarlarınızı tamamlayın.',
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
                    'Planlanan Toplam',
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
                    '≈ ${plannedDays.toStringAsFixed(1)} iş günü',
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
                    'Harcanan Toplam',
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
                    '≈ ${spentDays.toStringAsFixed(1)} iş günü',
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
                  'Saatlik kazancınız: ₺${calculator.hourlyRate.toStringAsFixed(2)}',
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
                  'Henüz kategori verisi yok',
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
    final s = id.replaceAll('-', ' ').replaceAll('_', ' ');
    if (s.isEmpty) return 'Diğer';
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
    String progressRating = '';
    Color progressColor = theme.colorScheme.primary;

    if (avgProductsPerDay >= 1.0) {
      progressRating = 'Çok Hızlı';
      progressColor = Colors.green;
    } else if (avgProductsPerDay >= 0.5) {
      progressRating = 'İyi';
      progressColor = Colors.lightGreen;
    } else if (avgProductsPerDay >= 0.2) {
      progressRating = 'Orta';
      progressColor = Colors.orange;
    } else {
      progressRating = 'Yavaş';
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
                'Tamamlanma Tahmini',
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
                  'Başlangıç',
                  '$daysSinceCreation gün önce',
                  theme,
                ),
              ),
              AppSpacing.md.horizontalSpace,
              Expanded(
                child: _infoTile(
                  context,
                  Icons.speed,
                  'Hız',
                  '${avgProductsPerDay.toStringAsFixed(1)} ürün/gün',
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
                  'Kalan',
                  '$remainingProducts ürün',
                  theme,
                ),
              ),
              AppSpacing.md.horizontalSpace,
              Expanded(
                child: _infoTile(
                  context,
                  Icons.event_available,
                  'Tahmini Bitiş',
                  completionDate != null
                    ? '~$estimatedDaysToComplete gün'
                    : 'Hesaplanamadı',
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
                      'Mevcut hızınızla çeyizinizi ~${_formatDate(completionDate)} civarında tamamlayabilirsiniz.',
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

  String _formatDate(DateTime date) {
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
                'Kategori Analizi',
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
                        '👑 En Çok Ürün',
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
                        '${mostProductsEntry.value} ürün • Ort: ₺${avgMostCategory.toStringAsFixed(0)}',
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
                          '📉 En Az Ürün',
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
                    'Toplam ${entries.length} farklı kategoride ürününüz var.',
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
    // Calculate health score (0-100)
    int healthScore = 100;
    String healthStatus = 'Mükemmel';
    Color healthColor = Colors.green;
    IconData healthIcon = Icons.sentiment_very_satisfied;
    String healthMessage = 'Bütçenizi harika yönetiyorsunuz!';

    if (totalBudget > 0) {
      final spentPercent = (totalSpent / totalBudget) * 100;
      final plannedPercent = (totalPlanned / totalBudget) * 100;

      if (remainingBudget < 0) {
        // Budget exceeded
        healthScore = 0;
        healthStatus = 'Kritik';
        healthColor = theme.colorScheme.error;
        healthIcon = Icons.sentiment_very_dissatisfied;
        healthMessage = 'Bütçenizi aştınız! Harcamalarınızı gözden geçirin.';
      } else if (plannedPercent > 100) {
        // Planned exceeds budget
        healthScore = 30;
        healthStatus = 'Riskli';
        healthColor = Colors.orange;
        healthIcon = Icons.sentiment_dissatisfied;
        healthMessage = 'Planlanan harcamalar bütçeyi aşıyor. Plan yapın.';
      } else if (spentPercent > 80) {
        // 80%+ spent
        healthScore = 50;
        healthStatus = 'Dikkatli Olun';
        healthColor = Colors.orange.shade700;
        healthIcon = Icons.sentiment_neutral;
        healthMessage = 'Bütçenizin çoğunu harcadınız. Kontrollü ilerleyin.';
      } else if (spentPercent > 60) {
        // 60-80% spent
        healthScore = 70;
        healthStatus = 'İyi';
        healthColor = Colors.lightGreen;
        healthIcon = Icons.sentiment_satisfied;
        healthMessage = 'İyi gidiyorsunuz! Harcamalarınızı kontrol altında tutun.';
      } else {
        // <60% spent
        healthScore = 100;
        healthStatus = 'Mükemmel';
        healthColor = Colors.green;
        healthIcon = Icons.sentiment_very_satisfied;
        healthMessage = 'Bütçenizi harika yönetiyorsunuz!';
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
                'Bütçe Sağlığı',
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
                      'Sağlık Skoru',
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
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXL,
        ),
        title: const Row(
          children: [
            Icon(Icons.info_outline, size: 28),
            SizedBox(width: 12),
            Text('İstatistik Rehberi'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '📊 Genel Bakış\n\n'
                '• Toplam Bütçe: Belirlediğiniz hedef bütçe\n'
                '• Harcanan: Satın aldığınız ürünlerin toplamı\n'
                '• Kalan Bütçe: Harcayabileceğiniz miktar\n'
                '• Planlanan Toplam: Tüm ürünlerin maliyeti\n'
                '• Ortalama Fiyat: Ürün başına düşen tutar\n'
                '• En Pahalı: Listedeki en yüksek fiyatlı ürün\n\n'
                '💚 Bütçe Sağlığı\n\n'
                '• Mükemmel (100): %60\'tan az harcadınız\n'
                '• İyi (70): %60-80 arası harcama\n'
                '• Dikkatli (50): %80\'den fazla kullanıldı\n'
                '• Riskli (30): Planlanan bütçeyi aşıyor\n'
                '• Kritik (0): Bütçe aşıldı!\n\n'
                '📅 Tamamlanma Tahmini\n\n'
                'Mevcut alışveriş hızınıza göre çeyizinizi ne zaman tamamlayacağınızı tahmin eder.\n\n'
                '🏆 Kategori Analizi\n\n'
                'En çok/az ürüne sahip kategoriler, ortalama harcamalar ve kategori bazlı istatistikler.',
                style: TextStyle(height: 1.5, fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          AppTextButton(
            label: 'Anladım',
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }
}
