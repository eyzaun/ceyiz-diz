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
    final currentSortType = trousseauProvider.trousseauSortType;
    final isManualSort = currentSortType == 'manual';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.trousseauManagement ?? 'Çeyiz Yönetimi'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: l10n?.sortType ?? 'Sıralama Türü',
            initialValue: currentSortType,
            onSelected: (value) async {
              await trousseauProvider.updateTrousseauSortType(value);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n?.sortTypeChanged ?? 'Sıralama türü değiştirildi'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'manual',
                child: Row(
                  children: [
                    Icon(
                      Icons.drag_handle,
                      size: 20,
                      color: currentSortType == 'manual' 
                          ? Theme.of(context).colorScheme.primary 
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.sortTypeManual ?? 'Manuel',
                      style: currentSortType == 'manual'
                          ? TextStyle(color: Theme.of(context).colorScheme.primary)
                          : null,
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'oldest_first',
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 20,
                      color: currentSortType == 'oldest_first' 
                          ? Theme.of(context).colorScheme.primary 
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.sortTypeOldestFirst ?? 'Eskiden Yeniye',
                      style: currentSortType == 'oldest_first'
                          ? TextStyle(color: Theme.of(context).colorScheme.primary)
                          : null,
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'newest_first',
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      size: 20,
                      color: currentSortType == 'newest_first' 
                          ? Theme.of(context).colorScheme.primary 
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.sortTypeNewestFirst ?? 'Yeniden Eskiye',
                      style: currentSortType == 'newest_first'
                          ? TextStyle(color: Theme.of(context).colorScheme.primary)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
              : Column(
                  children: [
                    if (!isManualSort)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                currentSortType == 'oldest_first'
                                    ? 'Çeyizler oluşturulma tarihine göre eskiden yeniye sıralanıyor'
                                    : 'Çeyizler oluşturulma tarihine göre yeniden eskiye sıralanıyor',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: isManualSort
                          ? ReorderableListView.builder(
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
                                  isManualSort,
                                );
                              },
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: allTrousseaus.length,
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
                                  isManualSort,
                                );
                              },
                            ),
                    ),
                  ],
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
    bool isManualSort,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      key: ValueKey(trousseau.id),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: isManualSort
            ? ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_handle,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : Icon(
                Icons.calendar_today,
                color: theme.colorScheme.onSurfaceVariant,
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
