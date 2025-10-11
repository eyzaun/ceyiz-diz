import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/custom_dialog.dart';
// import '../../widgets/common/draggable_fab.dart';
import 'statistics_screen.dart';
import '../trousseau/trousseau_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // After first frame, ensure home tab binds to the user's own trousseau products
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureHomeTrousseauBound();
      _checkForUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
  // Keep build light; use values inside sub-widgets
    
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
          if (index == 0) {
            // Re-bind to user's own trousseau when returning to home tab
            _ensureHomeTrousseauBound();
          }
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
    final id = trousseauProvider.myTrousseauId();
    if (id == null) {
      // Henüz stream bağlanmadı veya ilk çeyiz oluşturuluyor
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // Çeyiz detay sayfasını ana tabda göster
    return TrousseauDetailScreen(trousseauId: id);
  }

  void _ensureHomeTrousseauBound() {
    final trousseauProvider = context.read<TrousseauProvider>();
    final productProvider = context.read<ProductProvider>();
    final id = trousseauProvider.myTrousseauId();
    if (id != null) {
      productProvider.loadProducts(id);
    }
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

  void _checkForUpdate() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.updateAvailable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUpdateDialog();
      });
    }
  }

  void _showUpdateDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Güncelleme Mevcut'),
        content: const Text(
          'Uygulamanın yeni bir sürümü mevcut. Daha iyi deneyim için lütfen güncelleyin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Daha Sonra'),
          ),
          ElevatedButton(
            onPressed: () async {
              const url = 'https://play.google.com/store/apps/details?id=com.Loncagames.ceyizdiz';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }
}
