import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/custom_dialog.dart';
import '../../../core/themes/design_system.dart';

class ShareTrousseauScreen extends StatefulWidget {
  final String trousseauId;

  const ShareTrousseauScreen({
    super.key,
    required this.trousseauId,
  });

  @override
  State<ShareTrousseauScreen> createState() => _ShareTrousseauScreenState();
}

class _ShareTrousseauScreenState extends State<ShareTrousseauScreen> {
  final _emailController = TextEditingController();
  bool _canEdit = false;
  bool _isLoading = false;
  final Map<String, Future<DocumentSnapshot<Map<String, dynamic>>>> _userDocFutures = {};

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _shareTrousseau() async {
    if (_emailController.text.isEmpty) {
      final semantics = Theme.of(context).extension<AppSemanticColors>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('E-posta adresi girin'),
          backgroundColor: semantics?.warning ?? Theme.of(context).colorScheme.secondary,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final trousseauProvider = Provider.of<TrousseauProvider>(context, listen: false);
    final success = await trousseauProvider.shareTrousseau(
      trousseauId: widget.trousseauId,
      email: _emailController.text,
      canEdit: _canEdit,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      final semantics = Theme.of(context).extension<AppSemanticColors>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Çeyiz başarıyla paylaşıldı'),
          backgroundColor: semantics?.success ?? Theme.of(context).colorScheme.tertiary,
        ),
      );
      _emailController.clear();
      setState(() {
        _canEdit = false;
      });
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(trousseauProvider.errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    final trousseau = trousseauProvider.getTrousseauById(widget.trousseauId);

    if (trousseau == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Çeyiz bulunamadı'),
        ),
      );
    }

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Çeyizi Paylaş'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.share,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      trousseau.name,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bu çeyizi başkalarıyla paylaşarak birlikte yönetebilirsiniz',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-posta Adresi',
                  hintText: 'ornek@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Düzenleme Yetkisi Ver'),
                subtitle: const Text(
                  'Bu kişi çeyize ürün ekleyebilir ve düzenleyebilir',
                ),
                value: _canEdit,
                onChanged: (value) {
                  setState(() {
                    _canEdit = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _shareTrousseau,
                  child: const Text('Paylaş'),
                ),
              ),
              const SizedBox(height: 32),
              if (trousseau.sharedWith.isNotEmpty || trousseau.editors.isNotEmpty) ...[
                Text(
                  'Paylaşılan Kişiler',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ...trousseau.sharedWith.map((userId) => _buildSharedUserTile(
                      context,
                      userId,
                      false,
                      trousseau.id,
                    )),
                ...trousseau.editors.map((userId) => _buildSharedUserTile(
                      context,
                      userId,
                      true,
                      trousseau.id,
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSharedUserTile(
      BuildContext context, String userId, bool canEdit, String trousseauId) {
    final theme = Theme.of(context);
    
    _userDocFutures[userId] ??= FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _userDocFutures[userId],
      builder: (context, snapshot) {
        String titleText = userId;
        String? subtitleExtra;
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data();
          if (data != null) {
            final email = data['email'] as String?;
            final displayName = data['displayName'] as String?;
            if (email != null && email.isNotEmpty) {
              titleText = email;
              subtitleExtra = (displayName != null && displayName.isNotEmpty) ? displayName : null;
            }
          }
        }

        final permissionText = canEdit ? 'Düzenleme yetkisi var' : 'Sadece görüntüleme';
        final subtitleText = subtitleExtra != null ? '$permissionText · $subtitleExtra' : permissionText;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: Icon(Icons.person, color: theme.colorScheme.onPrimary),
          ),
          title: Text(titleText),
          subtitle: Text(subtitleText),
          trailing: IconButton(
            icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.error),
            onPressed: () async {
              final confirmed = await CustomDialog.showConfirmation(
                context: context,
                title: 'Paylaşımı Kaldır',
                subtitle: 'Bu kişinin erişimini kaldırmak istediğinizden emin misiniz?',
                confirmText: 'Kaldır',
                confirmColor: theme.colorScheme.error,
              );
              
              if (!context.mounted) return;
              if (confirmed == true) {
                final trousseauProvider =
                    Provider.of<TrousseauProvider>(context, listen: false);
                await trousseauProvider.removeShare(
                  trousseauId: trousseauId,
                  userId: userId,
                );
              }
            },
          ),
        );
      },
    );
  }
}