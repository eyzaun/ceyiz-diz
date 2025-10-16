import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/custom_dialog.dart';
import 'statistics_screen.dart';
import '../trousseau/trousseau_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _hasShownUpdateDialog = false;

  @override
  void initState() {
    super.initState();
    // After first frame, check for updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdateOnce();
    });
  }

  @override
  Widget build(BuildContext context) {
  // Listen to AuthProvider to catch update flag changes
    final authProvider = Provider.of<AuthProvider>(context);
    
    // If update becomes available and we haven't shown dialog yet, show it
    if (authProvider.updateAvailable && !_hasShownUpdateDialog && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForUpdateOnce();
      });
    }
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildTrousseauTab(context),
          const StatisticsScreen(),
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
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Çeyiz',
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

  Widget _buildTrousseauTab(BuildContext context) {
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    final pinnedTrousseaus = trousseauProvider.pinnedTrousseaus;

    // Wait until trousseaus are loaded (either loading or have data)
    if (trousseauProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (pinnedTrousseaus.isEmpty) {
      // No trousseaus yet, show empty state
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Henüz çeyiz oluşturmadınız'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.push('/create-trousseau'),
                icon: const Icon(Icons.add),
                label: const Text('Çeyiz Oluştur'),
              ),
            ],
          ),
        ),
      );
    }

    // İlk çeyizi göster (varsayılan)
    final id = pinnedTrousseaus.first.id;
    return TrousseauDetailScreen(trousseauId: id, key: ValueKey(id));
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
            leading: const Icon(Icons.group_outlined),
            title: const Text('Benimle Paylaşılan Çeyizler'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/shared-trousseaus'),
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Geri Bildirim Gönder'),
            subtitle: const Text('Görüş ve önerilerinizi bizimle paylaşın'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/feedback'),
          ),
          const Divider(),
          
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

  void _checkForUpdateOnce() {
    if (_hasShownUpdateDialog) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.updateAvailable) {
      _hasShownUpdateDialog = true;
      _showUpdateDialog();
    }
  }

  void _showUpdateDialog() {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: !authProvider.forceUpdate,
      builder: (dialogContext) => PopScope(
        canPop: !authProvider.forceUpdate,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.system_update,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  authProvider.forceUpdate 
                    ? 'Güncelleme Gerekli!' 
                    : 'Yeni Versiyon Mevcut',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: authProvider.forceUpdate 
                      ? Theme.of(context).colorScheme.error
                      : null,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authProvider.updateMessage,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.new_releases,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Yeni Versiyon: ${authProvider.latestVersion}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              if (authProvider.forceUpdate) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Theme.of(context).colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bu güncelleme zorunludur. Uygulamayı kullanmaya devam etmek için güncellemeniz gerekiyor.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (!authProvider.forceUpdate)
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                child: const Text('Daha Sonra'),
              ),
            ElevatedButton.icon(
              onPressed: () async {
                const url = 'https://play.google.com/store/apps/details?id=com.Loncagames.ceyizdiz';
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  // Show error if can't open Play Store
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Play Store açılamadı. Lütfen manuel olarak kontrol edin.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
                if (dialogContext.mounted && !authProvider.forceUpdate) {
                  Navigator.of(dialogContext).pop();
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('Şimdi Güncelle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: authProvider.forceUpdate 
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
