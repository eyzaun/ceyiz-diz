import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/trousseau_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../data/models/trousseau_model.dart';

class TrousseauManagementScreen extends StatefulWidget {
  final String trousseauId;

  const TrousseauManagementScreen({super.key, required this.trousseauId});

  @override
  State<TrousseauManagementScreen> createState() => _TrousseauManagementScreenState();
}

class _TrousseauManagementScreenState extends State<TrousseauManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trousseauProvider = context.watch<TrousseauProvider>();
    
    // Get all trousseaus (own + shared) sorted by user-specific order
    final allTrousseaus = trousseauProvider.getSortedTrousseaus();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.trousseauManagement ?? 'Çeyiz Yönetimi'),
      ),
      body: trousseauProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : allTrousseaus.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      l10n?.noTrousseausYet ?? 'Henüz çeyiz eklenmemiş.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: allTrousseaus.length,
                  onReorder: (oldIndex, newIndex) async {
                    // Adjust newIndex if necessary
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }

                    // Create a new list with the reordered items
                    final reorderedList = List<TrousseauModel>.from(allTrousseaus);
                    final item = reorderedList.removeAt(oldIndex);
                    reorderedList.insert(newIndex, item);

                    // Update sort orders for all trousseaus (user-specific)
                    final Map<String, int> orderUpdates = {};
                    for (int i = 0; i < reorderedList.length; i++) {
                      orderUpdates[reorderedList[i].id] = i;
                    }

                    // Update user-specific order in Firebase
                    try {
                      await trousseauProvider.updateUserTrousseauOrders(orderUpdates);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n?.orderUpdated ?? 'Sıralama güncellendi'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n?.errorOccurred ?? 'Bir hata oluştu: $e'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                  itemBuilder: (context, index) {
                    final trousseau = allTrousseaus[index];
                    final isOwner = trousseau.ownerId == trousseauProvider.currentUserId;
                    final canEdit = trousseau.canEdit(trousseauProvider.currentUserId ?? '');

                    return _buildTrousseauTile(
                      context,
                      trousseau,
                      l10n,
                      index,
                      isOwner,
                      canEdit,
                    );
                  },
                ),
    );
  }

  Widget _buildTrousseauTile(
    BuildContext context,
    TrousseauModel trousseau,
    AppLocalizations? l10n,
    int index,
    bool isOwner,
    bool canEdit,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      key: ValueKey(trousseau.id),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: Icon(
            Icons.drag_handle,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          trousseau.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (trousseau.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                trousseau.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${trousseau.purchasedProducts}/${trousseau.totalProducts} ${l10n?.piecesLabel ?? 'ürün'}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Icon(
                  isOwner ? Icons.person : Icons.people,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  isOwner ? (l10n?.owner ?? 'Sahibi') : (l10n?.shared ?? 'Paylaşılan'),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          onSelected: (value) async {
            if (value == 'edit' && canEdit) {
              context.push('/trousseau/${trousseau.id}/edit');
            } else if (value == 'delete' && isOwner) {
              await _confirmDelete(context, trousseau, l10n);
            } else if (value == 'view') {
              context.go('/trousseau/${trousseau.id}');
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  const Icon(Icons.visibility, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n?.view ?? 'Görüntüle'),
                ],
              ),
            ),
            if (canEdit)
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n?.edit ?? 'Düzenle'),
                  ],
                ),
              ),
            if (isOwner)
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.delete ?? 'Sil',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
          ],
        ),
        onTap: () {
          context.go('/trousseau/${trousseau.id}');
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TrousseauModel trousseau,
    AppLocalizations? l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.deleteTrousseau ?? 'Çeyiz Sil'),
        content: Text(
          l10n?.deleteTrousseauConfirm ??
              '"${trousseau.name}" çeyizini silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n?.delete ?? 'Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = context.read<TrousseauProvider>();
      await provider.deleteTrousseau(trousseau.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.trousseauDeleted ?? 'Çeyiz silindi'),
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}
