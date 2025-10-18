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
              color: theme.colorScheme.onSurfaceVariant,
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
                  color: remainingBudget >= 0 ? theme.colorScheme.tertiary : theme.colorScheme.error,
                ),
              ),
              AppSpacing.md.horizontalSpace,
              Expanded(
                child: AppStatCard(
                  icon: Icons.calculate,
                  title: 'Planlanan Toplam',
                  value: '₺${totalPlanned.toStringAsFixed(0)}',
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
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
                      color: theme.colorScheme.onSurfaceVariant,
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
                      color: theme.colorScheme.onSurfaceVariant,
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
                      color: theme.colorScheme.onSurfaceVariant,
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
                      color: theme.colorScheme.onSurfaceVariant,
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
            color: theme.colorScheme.onSurfaceVariant,
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
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                ),
                AppSpacing.md.verticalSpace,
                Text(
                  'Henüz kategori verisi yok',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
                          color: theme.colorScheme.onSurfaceVariant,
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
  // INFO DIALOG
  // ═══════════════════════════════════════════════════════════════════════════

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXL,
        ),
        title: const Text('İstatistik Açıklaması'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Toplam Bütçe: Çeyiziniz için belirlediğiniz toplam bütçe.\n\n'
                'Harcanan: Satın aldığınız ürünlere harcadığınız toplam tutar.\n\n'
                'Kalan Bütçe: Bütçenizden kalan miktar.\n\n'
                'Planlanan Toplam: Tüm ürünlerin (alınan ve alınmayan) toplam maliyeti.\n\n'
                'İlerleme: Satın aldığınız ürünlerin yüzdesi.\n\n'
                'Kategori Dağılımı: Ürünlerinizin kategorilere göre dağılımı ve harcamaları.',
                style: TextStyle(height: 1.5),
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
