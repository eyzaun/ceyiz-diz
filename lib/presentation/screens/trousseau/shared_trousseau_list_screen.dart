import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/empty_state_widget.dart';

class SharedTrousseauListScreen extends StatelessWidget {
	const SharedTrousseauListScreen({super.key});

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		final provider = Provider.of<TrousseauProvider>(context);
		final list = provider.sharedTrousseaus;

		return Scaffold(
			appBar: AppBar(
				title: const Text('Benimle Paylaşılan Çeyizler'),
			),
			body: list.isEmpty
					? const EmptyStateWidget(
							icon: Icons.share_outlined,
							title: 'Paylaşılan çeyiz yok',
							subtitle: 'Sizinle paylaşılan çeyizler burada görünecek',
						)
					: ListView.separated(
							padding: const EdgeInsets.all(16),
							itemBuilder: (context, index) {
								final t = list[index];
								final progress = t.totalProducts > 0
										? t.purchasedProducts / t.totalProducts
										: 0.0;
								return Card(
									child: ListTile(
										contentPadding: const EdgeInsets.all(16),
										title: Text(t.name, style: theme.textTheme.titleMedium),
										subtitle: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												if (t.description.isNotEmpty) ...[
													const SizedBox(height: 6),
													Text(
														t.description,
														maxLines: 2,
														overflow: TextOverflow.ellipsis,
													),
												],
												const SizedBox(height: 8),
												LinearProgressIndicator(
													value: progress,
													backgroundColor: theme.dividerColor,
													minHeight: 6,
												),
												const SizedBox(height: 8),
												Row(
													mainAxisAlignment: MainAxisAlignment.spaceBetween,
													children: [
														Text('${(progress * 100).toInt()}% tamamlandı'),
														Text('${t.totalProducts} ürün'),
													],
												),
											],
										),
										trailing: Row(
											mainAxisSize: MainAxisSize.min,
											children: [
												// Pin/Unpin butonu
												IconButton(
													icon: Icon(
														provider.isSharedTrousseauPinned(t.id)
																? Icons.push_pin
																: Icons.push_pin_outlined,
														color: provider.isSharedTrousseauPinned(t.id)
																? theme.colorScheme.primary
																: null,
													),
													tooltip: provider.isSharedTrousseauPinned(t.id)
															? 'Ana sayfadan kaldır'
															: 'Ana sayfaya ekle',
													onPressed: () async {
														final success = await provider.togglePinSharedTrousseau(t.id);
														if (context.mounted && !success) {
															ScaffoldMessenger.of(context).showSnackBar(
																SnackBar(content: Text(provider.errorMessage)),
															);
														}
													},
												),
												const Icon(Icons.chevron_right),
											],
										),
										onTap: () => context.push('/trousseau/${t.id}'),
									),
								);
							},
							separatorBuilder: (_, __) => const SizedBox(height: 8),
							itemCount: list.length,
						),
		);
	}
}

