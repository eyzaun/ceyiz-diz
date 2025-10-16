import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../../data/models/category_model.dart';
import '../../../core/themes/design_system.dart';
import '../../widgets/common/responsive_container.dart';
import 'package:go_router/go_router.dart';

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

      // Load products and bind categories for selected trousseau
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

    // Load products and bind categories for new trousseau
    final trProv = Provider.of<TrousseauProvider>(context, listen: false);
    final productProv = Provider.of<ProductProvider>(context, listen: false);
    productProv.loadProducts(trousseauId);

    final catProv = Provider.of<CategoryProvider>(context, listen: false);
    catProv.bind(trousseauId, userId: trProv.currentUserId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    final pinnedTrousseaus = trousseauProvider.pinnedTrousseaus;

    // Ensure we have a selection
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
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'İstatistik Açıklaması',
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Trousseau Selector
          if (pinnedTrousseaus.length > 1) ...[
            ResponsiveContainer(
              padding: EdgeInsets.zero,
              child: _buildTrousseauSelector(context, pinnedTrousseaus, theme),
            ),
            const SizedBox(height: 16),
          ],

          // Overview Cards
          ResponsiveContainer(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trousseau.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Genel Bakış',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        context,
                        'Toplam Bütçe',
                        '₺${totalBudget.toStringAsFixed(0)}',
                        theme.extension<AppStatsColors>()?.budget ?? theme.colorScheme.primary,
                        Icons.account_balance_wallet,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _metricCard(
                        context,
                        'Harcanan',
                        '₺${totalSpent.toStringAsFixed(0)}',
                        theme.extension<AppStatsColors>()?.spent ?? theme.colorScheme.secondary,
                        Icons.shopping_cart,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        context,
                        'Kalan Bütçe',
                        '₺${remainingBudget.toStringAsFixed(0)}',
                        remainingBudget >= 0
                            ? (theme.extension<AppStatsColors>()?.completed ?? theme.colorScheme.tertiary)
                            : theme.colorScheme.error,
                        remainingBudget >= 0 ? Icons.savings : Icons.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _metricCard(
                        context,
                        'Planlanan Toplam',
                        '₺${totalPlanned.toStringAsFixed(0)}',
                        theme.extension<AppStatsColors>()?.total ?? theme.colorScheme.tertiary,
                        Icons.calculate,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Progress Card
          ResponsiveContainer(
            padding: EdgeInsets.zero,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'İlerleme',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${totalProducts > 0 ? ((purchasedProducts / totalProducts) * 100).toStringAsFixed(0) : 0}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: totalProducts > 0 ? purchasedProducts / totalProducts : 0,
                      minHeight: 12,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Budget Analysis
          if (totalBudget > 0) ...[
            ResponsiveContainer(
              padding: EdgeInsets.zero,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bütçe Analizi',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _budgetBar(
                        context,
                        'Harcanan',
                        totalSpent,
                        totalBudget,
                        theme.colorScheme.secondary,
                      ),
                      const SizedBox(height: 12),
                      _budgetBar(
                        context,
                        'Planlanan',
                        totalPlanned,
                        totalBudget,
                        theme.colorScheme.primary,
                      ),
                      if (remainingBudget < 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Bütçe aşıldı! ₺${(-remainingBudget).toStringAsFixed(0)} fazla harcandı.',
                                  style: TextStyle(
                                    color: theme.colorScheme.onErrorContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Category Breakdown
          ResponsiveContainer(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kategori Dağılımı',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => context.push('/trousseau/$_selectedTrousseauId/products'),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Tümünü Gör'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._buildCategoryBreakdown(context, categoryStats, categoryProvider, productProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrousseauSelector(BuildContext context, List<dynamic> trousseaus, ThemeData theme) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: trousseaus.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final trousseau = trousseaus[index];
          final isSelected = trousseau.id == _selectedTrousseauId;

          return Material(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => _selectTrousseau(trousseau.id),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (trousseau.ownerId != Provider.of<TrousseauProvider>(context, listen: false).currentUserId) ...[
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      trousseau.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _budgetBar(
    BuildContext context,
    String label,
    double amount,
    double total,
    Color color,
  ) {
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
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '₺${amount.toStringAsFixed(0)} (${(percent * 100).toStringAsFixed(0)}%)',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percent,
          minHeight: 8,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _progressStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCategoryBreakdown(
    BuildContext context,
    Map<String, int> categoryStats,
    CategoryProvider categoryProvider,
    ProductProvider productProvider,
  ) {
    final theme = Theme.of(context);
    final total = categoryStats.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
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

      // Calculate spending for this category
      final categorySpending = productProvider.products
          .where((p) => p.category == id && p.isPurchased)
          .fold<double>(0, (sum, p) => sum + p.totalPrice);

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(category.icon, color: category.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$count ürün • ₺${categorySpending.toStringAsFixed(0)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(percent * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: category.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: category.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  CategoryModel _deriveCategory(String id) {
    final defaults = CategoryModel.defaultCategories;
    try {
      final def = defaults.firstWhere((c) => c.id == id);
      return def;
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

  Widget _metricCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bool dark = theme.brightness == Brightness.dark;

    final Color backgroundColor = color.withValues(
      alpha: dark ? DesignTokens.statsBgAlphaDark : DesignTokens.statsBgAlphaLight,
    );
    final Color borderColor = color.withValues(alpha: DesignTokens.statsBorderAlpha);
    final Color textColor = cs.onSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: theme.textTheme.bodySmall?.copyWith(color: textColor)),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }
}
