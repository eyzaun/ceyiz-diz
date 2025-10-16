import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../../core/utils/currency_formatter.dart';

class EditTrousseauScreen extends StatefulWidget {
  final String trousseauId;

  const EditTrousseauScreen({
    super.key,
    required this.trousseauId,
  });

  @override
  State<EditTrousseauScreen> createState() => _EditTrousseauScreenState();
}

class _EditTrousseauScreenState extends State<EditTrousseauScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final trousseau = Provider.of<TrousseauProvider>(context, listen: false)
        .getTrousseauById(widget.trousseauId);
    
    _nameController = TextEditingController(text: trousseau?.name ?? '');
    _descriptionController = TextEditingController(text: trousseau?.description ?? '');
    _budgetController = TextEditingController(
      text: trousseau != null ? CurrencyFormatter.format(trousseau.totalBudget) : '0',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _updateTrousseau() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final trousseauProvider = Provider.of<TrousseauProvider>(context, listen: false);
    final success = await trousseauProvider.updateTrousseau(
      trousseauId: widget.trousseauId,
      name: _nameController.text,
      description: _descriptionController.text,
      totalBudget: CurrencyFormatter.parse(_budgetController.text),
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Çeyiz başarıyla güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(trousseauProvider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteTrousseau() async {
    final trousseau = Provider.of<TrousseauProvider>(context, listen: false)
        .getTrousseauById(widget.trousseauId);

    if (trousseau == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çeyizi Sil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${trousseau.name}" çeyizini silmek istediğinizden emin misiniz?',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bu işlem geri alınamaz! Çeyiz içindeki tüm ürünler silinecektir.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    final trousseauProvider = Provider.of<TrousseauProvider>(context, listen: false);
    final success = await trousseauProvider.deleteTrousseau(widget.trousseauId);

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Çeyiz başarıyla silindi'),
          backgroundColor: Colors.green,
        ),
      );
      // Go back to home after deletion
      context.go('/');
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(trousseauProvider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Çeyizi Düzenle'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Çeyiz Adı',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Çeyiz adı gereklidir';
                    }
                    if (value.length < 3) {
                      return 'En az 3 karakter olmalıdır';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Toplam Bütçe (₺)',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final budget = CurrencyFormatter.parse(value);
                      if (budget == null || budget < 0) {
                        return 'Geçerli bir tutar girin';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _updateTrousseau,
                    child: const Text('Güncelle'),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                // Danger Zone
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tehlikeli Alan',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Çeyizi silmek geri alınamaz bir işlemdir. Tüm ürünler ve veriler kalıcı olarak silinecektir.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _deleteTrousseau,
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Çeyizi Sil'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.error,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}