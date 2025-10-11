import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feedback_provider.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedbackProvider(),
      child: const _FeedbackForm(),
    );
  }
}

class _FeedbackForm extends StatelessWidget {
  const _FeedbackForm();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FeedbackProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Geri Bildirim')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Uygulama hakkında görüş ve önerilerinizi bizimle paylaşın.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _RatingBar(
                  value: prov.rating,
                  onChanged: prov.setRating,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: prov.messageController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Geri Bildirim',
                    hintText: 'İyileştirme öneriniz, hata bildiriminiz veya genel yorumunuz...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: prov.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-posta (opsiyonel)',
                    hintText: 'İsterseniz size dönüş için e-postanızı bırakın',
                  ),
                ),
                if (prov.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(prov.errorMessage, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: prov.isSubmitting
                        ? null
                        : () async {
                            final ok = await prov.submit();
                            if (!context.mounted) return;
                            if (ok) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geri bildiriminiz için teşekkürler')));
                              Navigator.pop(context);
                            }
                          },
                    icon: const Icon(Icons.send),
                    label: prov.isSubmitting ? const Text('Gönderiliyor...') : const Text('Gönder'),
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

class _RatingBar extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;
  const _RatingBar({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return Row(
      children: List.generate(5, (i) {
        final idx = i + 1;
        final filled = (value ?? 0) >= idx;
        return IconButton(
          icon: Icon(filled ? Icons.star : Icons.star_border, color: color),
          onPressed: () => onChanged(filled ? null : idx),
        );
      }),
    );
  }
}
