// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get app_title => 'Çeyiz Diz';

  @override
  String get app_tagline => 'Hayalinizdeki çeyizi kolayca planlayın ve yönetin';

  @override
  String get auth_login => 'Giriş Yap';

  @override
  String get auth_register => 'Kayıt Ol';

  @override
  String get auth_email => 'E-posta';

  @override
  String get auth_password => 'Şifre';

  @override
  String get auth_confirm_password => 'Şifre Tekrarı';

  @override
  String get auth_forgot_password => 'Şifremi Unuttum';

  @override
  String get auth_no_account => 'Hesabınız yok mu?';

  @override
  String get auth_sign_up_now => 'Kayıt Olun';

  @override
  String get login_subtitle => 'Hayalinizdeki çeyizi kolayca yönetin';

  @override
  String get login_email_hint => 'ornek@email.com';

  @override
  String get login_password_hint => 'En az 6 karakter';

  @override
  String get common_save => 'Kaydet';

  @override
  String get common_cancel => 'İptal';

  @override
  String get common_delete => 'Sil';

  @override
  String get common_share => 'Paylaş';

  @override
  String get common_close => 'Kapat';

  @override
  String get trousseau_title => 'Çeyiz';

  @override
  String get trousseau_list => 'Çeyizler';

  @override
  String get trousseau_create => 'Çeyiz Oluştur';

  @override
  String get trousseau_not_found => 'Çeyiz bulunamadı';

  @override
  String get trousseau_share_title => 'Çeyizi Paylaş';

  @override
  String get trousseau_shared_success => 'Çeyiz başarıyla paylaşıldı';

  @override
  String get products_title => 'Ürünler';

  @override
  String get products_add => 'Ürün Ekle';

  @override
  String get products_edit => 'Ürünü Düzenle';

  @override
  String get products_search_hint => 'Ürün ara...';

  @override
  String get products_empty => 'Henüz ürün eklenmemiş';

  @override
  String get products_not_found => 'Ürün bulunamadı';

  @override
  String get products_get_started => 'İlk ürününüzü ekleyerek başlayın';

  @override
  String get settings_title => 'Ayarlar';

  @override
  String get settings_account_section => 'Hesap Ayarları';

  @override
  String get settings_profile => 'Profil Bilgileri';

  @override
  String get settings_profile_desc =>
      'Adınızı ve diğer bilgilerinizi düzenleyin';

  @override
  String get settings_change_password => 'Şifre Değiştir';

  @override
  String get settings_change_password_desc =>
      'Hesap güvenliğiniz için şifrenizi güncelleyin';

  @override
  String get settings_appearance_section => 'Görünüm';

  @override
  String get settings_theme => 'Tema Ayarları';

  @override
  String get settings_theme_desc =>
      'Uygulama temasını ve renklerini değiştirin';

  @override
  String get settings_app_section => 'Uygulama';

  @override
  String get settings_notifications => 'Bildirimler';

  @override
  String get settings_notifications_desc => 'Bildirim tercihlerinizi yönetin';

  @override
  String get settings_notifications_on => 'Bildirimler açık';

  @override
  String get settings_notifications_off => 'Bildirimler kapalı';

  @override
  String get settings_language => 'Dil';

  @override
  String get language_turkish => 'Türkçe';

  @override
  String get language_english => 'English';

  @override
  String get settings_about_section => 'Hakkında';

  @override
  String get settings_about_app => 'Uygulama Hakkında';

  @override
  String get settings_privacy => 'Gizlilik Politikası';

  @override
  String get settings_terms => 'Kullanım Koşulları';

  @override
  String settings_version(String version) {
    return 'Versiyon $version';
  }

  @override
  String get danger_title => 'Tehlikeli Bölge';

  @override
  String get danger_sign_out => 'Çıkış Yap';

  @override
  String get danger_sign_out_desc => 'Hesabınızdan çıkış yapın';

  @override
  String get danger_delete_account => 'Hesabı Sil';

  @override
  String get danger_delete_account_desc => 'Hesabınızı kalıcı olarak silin';

  @override
  String get dialog_confirm => 'Onayla';

  @override
  String get dialog_delete_warning =>
      'Hesabınızı sildikten sonra tüm çeyizleriniz ve ürünleriniz kalıcı olarak silinecektir.';

  @override
  String get dialog_enter_password => 'Şifrenizi girin';

  @override
  String get dialog_password_required => 'Şifre gereklidir';

  @override
  String get dialog_password_too_short => 'Şifre en az 6 karakter olmalıdır';

  @override
  String get dialog_invalid_email => 'Geçerli bir e-posta adresi girin';

  @override
  String get dialog_security_reason => 'Güvenlik için şifreniz gereklidir';
}
