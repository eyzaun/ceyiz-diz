import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          // User Info Section
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    authProvider.currentUser?.displayName.substring(0, 1).toUpperCase() ?? 'K',
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.currentUser?.displayName ?? 'Kullanıcı',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.currentUser?.email ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Account Settings
          _buildSection(
            context,
            'Hesap Ayarları',
            [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profil Bilgileri'),
                subtitle: const Text('Adınızı ve diğer bilgilerinizi düzenleyin'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/profile'),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Şifre Değiştir'),
                subtitle: const Text('Hesap güvenliğiniz için şifrenizi güncelleyin'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/change-password'),
              ),
            ],
          ),
          
          // Appearance Settings
          _buildSection(
            context,
            'Görünüm',
            [
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Tema Ayarları'),
                subtitle: const Text('Uygulama temasını ve renklerini değiştirin'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/theme'),
              ),
            ],
          ),
          
          // App Settings
          _buildSection(
            context,
            'Uygulama',
            [
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Bildirimler'),
                subtitle: const Text('Bildirim tercihlerinizi yönetin'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement notification settings
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Dil'),
                subtitle: const Text('Türkçe'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implement language settings
                },
              ),
            ],
          ),
          
          // About Section
          _buildSection(
            context,
            'Hakkında',
            [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Uygulama Hakkında'),
                subtitle: const Text('Versiyon 1.0.0'),
                onTap: () => _showAboutDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Gizlilik Politikası'),
                onTap: () {
                  // TODO: Show privacy policy
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Kullanım Koşulları'),
                onTap: () {
                  // TODO: Show terms of service
                },
              ),
            ],
          ),
          
          // Danger Zone
          _buildSection(
            context,
            'Tehlikeli Bölge',
            [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.orange),
                title: const Text(
                  'Çıkış Yap',
                  style: TextStyle(color: Colors.orange),
                ),
                subtitle: const Text('Hesabınızdan çıkış yapın'),
                onTap: () async {
                  final confirmed = await CustomDialog.showConfirmation(
                    context: context,
                    title: 'Çıkış Yap',
                    subtitle: 'Çıkış yapmak istediğinizden emin misiniz?',
                    confirmText: 'Çıkış Yap',
                    confirmColor: Colors.orange,
                  );
                  
                  if (confirmed == true) {
                    await authProvider.signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  'Hesabı Sil',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: const Text('Hesabınızı kalıcı olarak silin'),
                onTap: () => _showDeleteAccountDialog(context),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Çeyiz Diz',
        applicationVersion: '1.0.0',
        applicationIcon: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.home_filled,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        children: const [
          Text(
            'Çeyiz Diz, hayalinizdeki çeyizi kolayca planlamanızı ve yönetmenizi sağlayan modern bir uygulamadır.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  void _showDeleteAccountDialog(BuildContext context) {
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Hesabı Sil',
        subtitle: 'Bu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecektir.',
        content: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hesabınızı sildikten sonra tüm çeyizleriniz ve ürünleriniz kalıcı olarak silinecektir.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifrenizi girin',
                hintText: 'Güvenlik için şifreniz gereklidir',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Şifre gereklidir'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              Navigator.of(context).pop();
              
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final success = await authProvider.deleteAccount(passwordController.text);
              
              if (success && context.mounted) {
                context.go('/login');
              } else if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(authProvider.errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );
  }
}