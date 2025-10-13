import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../providers/category_provider.dart';
import '../../../data/models/category_model.dart';
import '../../../core/themes/design_system.dart';
import '../../widgets/common/responsive_container.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    // Defer provider access to first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureCategoryBinding();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureCategoryBinding();
  }

  void _ensureCategoryBinding() {
    final trProv = Provider.of<TrousseauProvider>(context, listen: false);
    final catProv = Provider.of<CategoryProvider>(context, listen: false);
    
    // Don't bind if CategoryProvider is already bound to a valid trousseau
    // This prevents StatisticsScreen from interfering when user switches between trousseaux
    if (catProv.currentTrousseauId != null) return;
    
    // Only bind if no trousseau is currently bound
    final myId = trProv.myTrousseauId();
    if (myId == null) return;
    
    catProv.bind(myId, userId: trProv.currentUserId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    // Show ONLY the current user's own (single) trousseau statistics
    final myTrousseau = trousseauProvider.trousseaus.isNotEmpty
        ? trousseauProvider.trousseaus.first
        : null;

    if (myTrousseau == null) {
      return const Center(child: Text('İstatistik bulunmuyor'));
    }

    final categoryStats = Map<String, int>.from(myTrousseau.categoryCounts);
    final double totalBudget = myTrousseau.totalBudget;
    final double totalSpent = myTrousseau.spentAmount;
    final int totalProducts = myTrousseau.totalProducts;
    final int purchasedProducts = myTrousseau.purchasedProducts;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ResponsiveContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
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
                'Toplam Ürün',
                totalProducts.toString(),
                theme.extension<AppStatsColors>()?.total ?? theme.colorScheme.tertiary,
                Icons.inventory,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                context,
                'Tamamlanan',
                '$purchasedProducts/$totalProducts',
                theme.extension<AppStatsColors>()?.completed ?? theme.colorScheme.primary,
                Icons.check_circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Kategori Dağılımı', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        ..._buildCategoryBreakdown(context, categoryStats, categoryProvider),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCategoryBreakdown(
    BuildContext context,
    Map<String, int> categoryStats,
    CategoryProvider categoryProvider,
  ) {
    final theme = Theme.of(context);
    final total = categoryStats.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return [const Text('Kategori verisi yok')];

    final entries = categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final allCats = categoryProvider.allCategories;

    return entries.map((e) {
      final id = e.key;
      final count = e.value;

      // Prefer dynamic/custom categories; fall back to defaults; finally derive
      CategoryModel? found;
      try {
        found = allCats.firstWhere((c) => c.id == id);
      } catch (_) {
        found = null;
      }

      final category = found ?? _deriveCategory(id);
      final percent = total > 0 ? count / total : 0.0;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(category.icon, color: category.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(category.displayName),
                      Text('$count ürün'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    backgroundColor: theme.dividerColor,
                    color: category.color,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  CategoryModel _deriveCategory(String id) {
    // If id matches a known default, use it; else create a derived custom-looking category
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
}
