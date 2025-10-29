import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/common/custom_dialog.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/image_optimization_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _isUploadingPhoto = false;

  Future<void> _pickAndUploadPhoto() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);

    try {
      final ImagePicker picker = ImagePicker();
      // 🚀 OPTIMIZATION: Profil fotoğrafı için daha agresif sıkıştırma
      // 256x256 yeterli, %80 kalite (daha küçük dosya boyutu)
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 256,
        maxHeight: 256,
        imageQuality: 80,
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
          final l10n = AppLocalizations.of(context);
          throw Exception(l10n?.uploadTimeout ?? 'Yükleme süresi aşıldı. İnternet bağlantınızı kontrol edin.');
        },
      );

      final photoURL = await storageRef.getDownloadURL();

      final success = await authProvider.updateProfile(photoURL: photoURL);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.profilePhotoUpdated ?? 'Profil fotoğrafı güncellendi'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n?.profileNotUpdated ?? 'Profil güncellenemedi'}: ${authProvider.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)?.error ?? 'Hata'}: ${e.toString().replaceAll('Exception: ', '')}'),
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
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(
      text: authProvider.currentUser?.displayName ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(l10n?.editName ?? 'İsim Düzenle'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n?.name ?? 'İsim',
            hintText: l10n?.enterNewName ?? 'Yeni isminizi girin',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n?.cancel ?? 'İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(l10n?.save ?? 'Kaydet'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != authProvider.currentUser?.displayName) {
      final success = await authProvider.updateProfile(displayName: result);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.nameUpdated ?? 'İsim güncellendi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final l10n = AppLocalizations.of(context);
    
    debugPrint('🔧 [SettingsScreen] build() çağrıldı');
    debugPrint('🔧 [SettingsScreen] Locale: ${Localizations.localeOf(context)}');
    debugPrint('🔧 [SettingsScreen] l10n null mu? ${l10n == null}');
    
    // If localization is not ready, show loading
    if (l10n == null) {
      debugPrint('🔧 [SettingsScreen] l10n null! Loading gösteriliyor...');
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    debugPrint('🔧 [SettingsScreen] l10n hazır! settings key: ${l10n.settings}');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
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
                    // Profile Photo with optimization
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary,
                      ),
                      child: ClipOval(
                        child: user?.photoURL != null
                            ? CachedNetworkImage(
                                imageUrl: ImageOptimizationUtils.getSmallThumbnail(user!.photoURL!),
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                memCacheWidth: 200,
                                memCacheHeight: 200,
                                placeholder: (context, url) => Container(
                                  color: theme.colorScheme.primary,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) {
                                  final displayName = user.displayName;
                                  final initial = displayName.isNotEmpty
                                      ? displayName.substring(0, 1).toUpperCase()
                                      : 'K';
                                  return Container(
                                    color: theme.colorScheme.primary,
                                    child: Center(
                                      child: Text(
                                        initial,
                                        style: const TextStyle(
                                          fontSize: 36,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  () {
                                    final displayName = user?.displayName ?? '';
                                    return displayName.isNotEmpty 
                                        ? displayName.substring(0, 1).toUpperCase()
                                        : 'K';
                                  }(),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    if (_isUploadingPhoto)
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
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
                  user?.displayName ?? (l10n?.userDefaultName ?? 'Kullanıcı'),
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
                    l10n?.membershipSince(_formatDate(user!.createdAt)) ?? 
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
            l10n.accountSettings,
            [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.editName),
                subtitle: Text(l10n.editNameSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: _editName,
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(l10n.changePasswordButton),
                subtitle: Text(l10n.changePasswordSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/change-password'),
              ),
            ],
          ),

          // Features Settings
          _buildSection(
            context,
            l10n.features,
            [
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(l10n.kacSaatTitle),
                subtitle: Text(l10n.kacSaatSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/kac-saat'),
              ),
            ],
          ),

          // Appearance Settings
          _buildSection(
            context,
            l10n.appearance,
            [
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(l10n.themeSettings),
                subtitle: Text(l10n.themeSettingsSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/theme'),
              ),
            ],
          ),

          // App Settings
          _buildSection(
            context,
            l10n.application,
            [
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(l10n.notificationsTitle),
                subtitle: Text(l10n.notificationsSubtitle),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.notificationsStatus(value ? l10n.enabled : l10n.disabled)),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: Text(
                  context.watch<LocaleProvider>().currentLanguageName,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  debugPrint('🔧 [SettingsScreen] Dil değiştirme modal açılıyor...');
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (modalContext) {
                      final currentLocale = context.read<LocaleProvider>().locale.languageCode;
                      debugPrint('🔧 [SettingsScreen] Modal açıldı. Mevcut dil: $currentLocale');
                      
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.language),
                              title: Text(l10n.turkish),
                              trailing: currentLocale == 'tr'
                                  ? Icon(Icons.check, color: Theme.of(modalContext).primaryColor)
                                  : null,
                              onTap: () {
                                debugPrint('🔧 [SettingsScreen] Türkçe seçildi');
                                context.read<LocaleProvider>().setTurkish();
                                Navigator.pop(modalContext);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.language),
                              title: Text(l10n.english),
                              trailing: currentLocale == 'en'
                                  ? Icon(Icons.check, color: Theme.of(modalContext).primaryColor)
                                  : null,
                              onTap: () {
                                debugPrint('🔧 [SettingsScreen] İngilizce seçildi');
                                context.read<LocaleProvider>().setEnglish();
                                Navigator.pop(modalContext);
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
            l10n.sharing,
            [
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: Text(l10n.sharedWithMeTitle),
                subtitle: Text(l10n.sharedWithMeSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/shared-trousseaus'),
              ),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: Text(l10n.sendFeedback),
                subtitle: Text(l10n.sendFeedbackSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/feedback'),
              ),
            ],
          ),

          // About Section
          _buildSection(
            context,
            l10n.about,
            [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.appAbout),
                subtitle: Text('${l10n.version} 1.0.17'),
                onTap: () => _showAboutDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.privacyPolicy),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      title: Text(l10n.privacyPolicy),
                      content: Text(l10n.privacyPolicyText),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.close),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n.termsOfService),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      title: Text(l10n.termsOfService),
                      content: Text(l10n.termsOfServiceText),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.close),
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
            l10n.dangerZone,
            [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.orange),
                title: Text(
                  l10n.signOut,
                  style: const TextStyle(color: Colors.orange),
                ),
                subtitle: Text(l10n.signOutSubtitle),
                onTap: () async {
                  final confirmed = await CustomDialog.showConfirmation(
                    context: context,
                    title: l10n.signOut,
                    subtitle: l10n.signOutConfirm,
                    confirmText: l10n.signOut,
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
                title: Text(
                  l10n.deleteAccount,
                  style: const TextStyle(color: Colors.red),
                ),
                subtitle: Text(l10n.deleteAccountSubtitle),
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
    // Use intl package for locale-aware date formatting
    final locale = AppLocalizations.of(context)?.localeName ?? 'tr';
    final formatter = DateFormat.yMMMMd(locale);
    return formatter.format(date);
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
        children: [
          Text(
            l10n?.appDescription ?? 'Çeyiz Diz, hayalinizdeki çeyizi kolayca planlamanızı ve yönetmenizi sağlayan modern bir uygulamadır.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: l10n?.deleteAccount ?? 'Hesabı Sil',
        subtitle: l10n?.deleteAccountIrreversible ?? 'Bu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecektir.',
        content: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n?.deleteAccountWarning ?? 'Hesabınızı sildikten sonra tüm çeyizleriniz ve ürünleriniz kalıcı olarak silinecektir.',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n?.enterPasswordToDelete ?? 'Şifrenizi girin',
                hintText: l10n?.passwordRequiredForSecurity ?? 'Güvenlik için şifreniz gereklidir',
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.cancel ?? 'İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n?.passwordRequiredSimple ?? 'Şifre gereklidir'),
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
            child: Text(l10n?.deleteAccountButton ?? 'Hesabı Sil'),
          ),
        ],
      ),
    );
  }
}
