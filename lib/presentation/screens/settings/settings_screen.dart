import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_dialog.dart';
import '../../../core/theme/design_tokens.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _language = 'Türkçe';
  bool _isUploadingPhoto = false;

  Future<void> _pickAndUploadPhoto() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      setState(() => _isUploadingPhoto = true);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${authProvider.currentUser!.uid}.jpg');

      // Web ve mobil için farklı upload yöntemleri
      final UploadTask uploadTask;
      if (kIsWeb) {
        // Web: putData kullan
        final bytes = await image.readAsBytes();
        uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // Mobile: putFile kullan
        final file = File(image.path);
        uploadTask = storageRef.putFile(file);
      }

      // Timeout ve progress tracking
      await uploadTask.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Yükleme süresi aşıldı. İnternet bağlantınızı kontrol edin.');
        },
      );

      final photoURL = await storageRef.getDownloadURL();

      final success = await authProvider.updateProfile(photoURL: photoURL);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil fotoğrafı güncellendi'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profil güncellenemedi: ${authProvider.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  Future<void> _editName() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final controller = TextEditingController(
      text: authProvider.currentUser?.displayName ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: const Text('İsim Düzenle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'İsim',
            hintText: 'Yeni isminizi girin',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != authProvider.currentUser?.displayName) {
      final success = await authProvider.updateProfile(displayName: result);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İsim güncellendi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          // Profile Section with Photo
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primary,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? Text(
                              user?.displayName.substring(0, 1).toUpperCase() ?? 'K',
                              style: const TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    if (_isUploadingPhoto)
                      const Positioned.fill(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.black54,
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Material(
                        color: theme.colorScheme.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  user?.displayName ?? 'Kullanıcı',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                if (user?.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Üyelik: ${_formatDate(user!.createdAt)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Account Settings
          _buildSection(
            context,
            'Hesap Ayarları',
            [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('İsmi Düzenle'),
                subtitle: const Text('Görünen adınızı değiştirin'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _editName,
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

          // Features Settings
          _buildSection(
            context,
            'Özellikler',
            [
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Kaç Saat Hesaplayıcı'),
                subtitle: const Text('Ürün fiyatlarını çalışma saatine çevir'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/kac-saat'),
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
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bildirimler ${value ? 'açık' : 'kapalı'}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Dil'),
                subtitle: Text(_language),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.language),
                              title: const Text('Türkçe'),
                              onTap: () {
                                setState(() => _language = 'Türkçe');
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.language),
                              title: const Text('English'),
                              onTap: () {
                                setState(() => _language = 'English');
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),

          // Sharing & Feedback
          _buildSection(
            context,
            'Paylaşım',
            [
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Benimle Paylaşılan Çeyizler'),
                subtitle: const Text('Paylaşılan çeyiz listelerini görüntüle'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/shared-trousseaus'),
              ),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('Geri Bildirim Gönder'),
                subtitle: const Text('Önerilerinizi bizimle paylaşın'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/feedback'),
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
                subtitle: const Text('Versiyon 1.0.17'),
                onTap: () => _showAboutDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Gizlilik Politikası'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      title: const Text('Gizlilik Politikası'),
                      content: const Text('Gizlilik politikası metni burada gösterilecektir.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Kapat'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Kullanım Koşulları'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      title: const Text('Kullanım Koşulları'),
                      content: const Text('Kullanım koşulları metni burada gösterilecektir.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Kapat'),
                        ),
                      ],
                    ),
                  );
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

          const SizedBox(height: AppSpacing.xl),
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
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(children: children),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Çeyiz Diz',
        applicationVersion: '1.0.17',
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
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Hesabınızı sildikten sonra tüm çeyizleriniz ve ürünleriniz kalıcı olarak silinecektir.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
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
