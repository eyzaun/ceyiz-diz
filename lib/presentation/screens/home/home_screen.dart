import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/custom_dialog.dart';
import '../../widgets/common/draggable_fab.dart';
import '../../../data/models/category_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
  // Keep build light; use values inside sub-widgets
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(context),
          _buildStatistics(context),
          _buildProfile(context),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Özet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'İstatistikler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    final allTrousseaus = trousseauProvider.allTrousseaus;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Hoş Geldin, ${authProvider.currentUser?.displayName ?? 'Kullanıcı'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: allTrousseaus.isEmpty
          ? Stack(
              children: [
                EmptyStateWidget(
                  icon: Icons.home_work_outlined,
                  title: 'Henüz çeyiz oluşturmadınız',
                  subtitle: 'Hayalinizdeki çeyizi planlamaya başlayın',
                  action: ElevatedButton.icon(
                    onPressed: () => context.push('/trousseau/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('İlk Çeyizi Oluştur'),
                  ),
                ),
                Positioned.fill(
                  child: DraggableFAB(
                    heroTag: 'fab-home-create',
                    tooltip: 'Yeni Çeyiz',
                    icon: Icons.add,
                    onPressed: () => context.push('/trousseau/create'),
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () => trousseauProvider.loadTrousseaus(),
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverToBoxAdapter(
                          child: _buildSummaryCards(context),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Son Çeyizler',
                                style: theme.textTheme.headlineSmall,
                              ),
                              TextButton.icon(
                                onPressed: () => context.push('/trousseau/create'),
                                icon: const Icon(Icons.add),
                                label: const Text('Yeni Çeyiz'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final trousseau = allTrousseaus[index];
                              return _buildTrousseauCard(context, trousseau);
                            },
                            childCount: allTrousseaus.length > 3 ? 3 : allTrousseaus.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Draggable FAB for quick create
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: false,
                    child: DraggableFAB(
                      heroTag: 'fab-home-create',
                      tooltip: 'Yeni Çeyiz',
                      icon: Icons.add,
                      onPressed: () => context.push('/trousseau/create'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
  final theme = Theme.of(context);
  final trousseauProvider = Provider.of<TrousseauProvider>(context);
    final allTrousseaus = trousseauProvider.allTrousseaus;
    
    double totalBudget = 0;
    double totalSpent = 0;
    int totalProducts = 0;
    int purchasedProducts = 0;
    
    for (var trousseau in allTrousseaus) {
      totalBudget += trousseau.totalBudget;
      totalSpent += trousseau.spentAmount;
      totalProducts += trousseau.totalProducts;
      purchasedProducts += trousseau.purchasedProducts;
    }
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Toplam Bütçe',
                '₺${totalBudget.toStringAsFixed(0)}',
                Icons.account_balance_wallet,
                theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Harcanan',
                '₺${totalSpent.toStringAsFixed(0)}',
                Icons.shopping_cart,
                theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Toplam Ürün',
                totalProducts.toString(),
                Icons.inventory,
                theme.colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Tamamlanan',
                '$purchasedProducts/$totalProducts',
                Icons.check_circle,
                theme.colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // Map role color to appropriate container/onContainer for readability
    final bool isPrimary = color.value == cs.primary.value;
    final bool isSecondary = color.value == cs.secondary.value;
    final bool isTertiary = color.value == cs.tertiary.value;

    final Color backgroundColor = isPrimary
        ? cs.primaryContainer
        : isSecondary
            ? cs.secondaryContainer
            : isTertiary
                ? cs.tertiaryContainer
                : color.withValues(alpha: 0.12);

    final Color borderColor = isPrimary
        ? cs.primary
        : isSecondary
            ? cs.secondary
            : isTertiary
                ? cs.tertiary
                : color.withValues(alpha: 0.35);

    final Color titleColor = isPrimary
        ? cs.onPrimaryContainer
        : isSecondary
            ? cs.onSecondaryContainer
            : isTertiary
                ? cs.onTertiaryContainer
                : cs.onSurface.withValues(alpha: 0.9);

    final Color valueColor = isPrimary
        ? cs.onPrimaryContainer
        : isSecondary
            ? cs.onSecondaryContainer
            : isTertiary
                ? cs.onTertiaryContainer
                : cs.onSurface;

    final Color iconColor = isPrimary
        ? cs.primary
        : isSecondary
            ? cs.secondary
            : isTertiary
                ? cs.tertiary
                : color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrousseauCard(BuildContext context, trousseau) {
    final theme = Theme.of(context);
    final progress = trousseau.totalProducts > 0
        ? trousseau.purchasedProducts / trousseau.totalProducts
        : 0.0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/trousseau/${trousseau.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trousseau.name,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${trousseau.totalProducts} ürün',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (trousseau.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  trousseau.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.dividerColor,
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toInt()}% Tamamlandı',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '₺${trousseau.spentAmount.toStringAsFixed(0)} / ₺${trousseau.totalBudget.toStringAsFixed(0)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    final theme = Theme.of(context);
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    final allTrousseaus = trousseauProvider.allTrousseaus;
    
  Map<String, int> categoryStats = {};
    
    for (var trousseau in allTrousseaus) {
      trousseau.categoryCounts.forEach((category, count) {
        categoryStats[category] = (categoryStats[category] ?? 0) + count;
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler'),
      ),
      body: allTrousseaus.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.bar_chart,
              title: 'İstatistik bulunmuyor',
              subtitle: 'Çeyiz oluşturduktan sonra istatistiklerinizi görebilirsiniz',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Kategori Dağılımı',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ...CategoryModel.defaultCategories.map((category) {
                  final count = categoryStats[category.id] ?? 0;
                  final total = categoryStats.values.fold(0, (a, b) => a + b);
                  final percentage = total > 0 ? (count / total * 100) : 0.0;
                  
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
                                value: percentage / 100,
                                backgroundColor: theme.dividerColor,
                                color: category.color,
                                minHeight: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildProfile(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              (authProvider.currentUser?.displayName ?? 'K').substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 36, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            authProvider.currentUser?.displayName ?? 'Kullanıcı',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          Text(
            authProvider.currentUser?.email ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profili Düzenle'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Tema Ayarları'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/theme'),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Şifre Değiştir'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/change-password'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirmed = await CustomDialog.showConfirmation(
                context: context,
                title: 'Çıkış Yap',
                subtitle: 'Çıkış yapmak istediğinizden emin misiniz?',
                confirmText: 'Çıkış Yap',
                confirmColor: Colors.red,
              );
              
              if (confirmed == true) {
                await authProvider.signOut();
              }
            },
          ),
        ],
      ),
    );
  }
}
