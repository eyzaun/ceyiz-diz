import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/custom_dialog.dart';

class TrousseauListScreen extends StatelessWidget {
  const TrousseauListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çeyizlerim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/trousseau/create'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => trousseauProvider.loadTrousseaus(),
        child: trousseauProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : trousseauProvider.allTrousseaus.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    title: 'Henüz çeyiz bulunmuyor',
                    subtitle: 'Yeni bir çeyiz oluşturarak başlayın',
                    action: ElevatedButton.icon(
                      onPressed: () => context.push('/trousseau/create'),
                      icon: const Icon(Icons.add),
                      label: const Text('Çeyiz Oluştur'),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: trousseauProvider.allTrousseaus.length,
                    itemBuilder: (context, index) {
                      final trousseau = trousseauProvider.allTrousseaus[index];
                      final isOwner = trousseau.ownerId == trousseauProvider.currentUserId;
                      
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
                                              if (!isOwner)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    'Paylaşılan',
                                                    style: theme.textTheme.labelSmall?.copyWith(
                                                      color: Colors.blue,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          if (trousseau.description.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              trousseau.description,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: theme.textTheme.bodySmall?.color,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      itemBuilder: (context) => <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'view',
                                          child: Row(
                                            children: [
                                              Icon(Icons.visibility, size: 20),
                                              SizedBox(width: 8),
                                              Text('Görüntüle'),
                                            ],
                                          ),
                                        ),
                                        if (trousseau.canEdit(
                                          trousseauProvider.currentUserId ?? '',
                                        )) ...[
                                          const PopupMenuItem<String>(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit, size: 20),
                                                SizedBox(width: 8),
                                                Text('Düzenle'),
                                              ],
                                            ),
                                          ),
                                        ],
                                        if (isOwner) ...[
                                          const PopupMenuItem<String>(
                                            value: 'share',
                                            child: Row(
                                              children: [
                                                Icon(Icons.share, size: 20),
                                                SizedBox(width: 8),
                                                Text('Paylaş'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuDivider(),
                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete,
                                                    size: 20, color: Colors.red),
                                                const SizedBox(width: 8),
                                                Text('Sil',
                                                    style: TextStyle(color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                      onSelected: (value) async {
                                        switch (value) {
                                          case 'view':
                                            context.push('/trousseau/${trousseau.id}');
                                            break;
                                          case 'edit':
                                            context.push('/trousseau/${trousseau.id}/edit');
                                            break;
                                          case 'share':
                                            context.push('/trousseau/${trousseau.id}/share');
                                            break;
                                          case 'delete':
                                            final confirmed = await CustomDialog.showConfirmation(
                                              context: context,
                                              title: 'Çeyizi Sil',
                                              subtitle:
                                                  'Bu çeyiz ve içindeki tüm ürünler silinecek. Bu işlem geri alınamaz.',
                                              confirmText: 'Sil',
                                              confirmColor: Colors.red,
                                            );
                                            
                                            if (confirmed == true) {
                                              await trousseauProvider.deleteTrousseau(
                                                  trousseau.id);
                                            }
                                            break;
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildStatChip(
                                      context,
                                      Icons.inventory,
                                      '${trousseau.totalProducts} ürün',
                                      theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildStatChip(
                                      context,
                                      Icons.check_circle,
                                      '${trousseau.purchasedProducts} alındı',
                                      Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildStatChip(
                                        context,
                                        Icons.account_balance_wallet,
                                        '₺${trousseau.spentAmount.toStringAsFixed(0)}',
                                        theme.colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/trousseau/create'),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Çeyiz'),
      ),
    );
  }

  Widget _buildStatChip(
      BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}