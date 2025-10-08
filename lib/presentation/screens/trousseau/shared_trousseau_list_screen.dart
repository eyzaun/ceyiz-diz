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
										trailing: const Icon(Icons.chevron_right),
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

