// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Ceyiz Diz';

  @override
  String get app_tagline => 'Plan and manage your dream trousseau easily';

  @override
  String get auth_login => 'Log In';

  @override
  String get auth_register => 'Sign Up';

  @override
  String get auth_email => 'Email';

  @override
  String get auth_password => 'Password';

  @override
  String get auth_confirm_password => 'Confirm Password';

  @override
  String get auth_forgot_password => 'Forgot Password';

  @override
  String get auth_no_account => 'Don\'t have an account?';

  @override
  String get auth_sign_up_now => 'Sign Up';

  @override
  String get login_subtitle => 'Manage your dream trousseau easily';

  @override
  String get login_email_hint => 'name@example.com';

  @override
  String get login_password_hint => 'At least 6 characters';

  @override
  String get common_save => 'Save';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_share => 'Share';

  @override
  String get common_close => 'Close';

  @override
  String get trousseau_title => 'Trousseau';

  @override
  String get trousseau_list => 'Trousseaus';

  @override
  String get trousseau_create => 'Create Trousseau';

  @override
  String get trousseau_not_found => 'Trousseau not found';

  @override
  String get trousseau_share_title => 'Share Trousseau';

  @override
  String get trousseau_shared_success => 'Trousseau shared successfully';

  @override
  String get products_title => 'Products';

  @override
  String get products_add => 'Add Product';

  @override
  String get products_edit => 'Edit Product';

  @override
  String get products_search_hint => 'Search products...';

  @override
  String get products_empty => 'No products added yet';

  @override
  String get products_not_found => 'No products found';

  @override
  String get products_get_started => 'Start by adding your first product';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_account_section => 'Account Settings';

  @override
  String get settings_profile => 'Profile Information';

  @override
  String get settings_profile_desc => 'Edit your name and other information';

  @override
  String get settings_change_password => 'Change Password';

  @override
  String get settings_change_password_desc =>
      'Update your password for account security';

  @override
  String get settings_appearance_section => 'Appearance';

  @override
  String get settings_theme => 'Theme Settings';

  @override
  String get settings_theme_desc => 'Change the app theme and colors';

  @override
  String get settings_app_section => 'App';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_notifications_desc =>
      'Manage your notification preferences';

  @override
  String get settings_notifications_on => 'Notifications on';

  @override
  String get settings_notifications_off => 'Notifications off';

  @override
  String get settings_language => 'Language';

  @override
  String get language_turkish => 'Türkçe';

  @override
  String get language_english => 'English';

  @override
  String get settings_about_section => 'About';

  @override
  String get settings_about_app => 'About App';

  @override
  String get settings_privacy => 'Privacy Policy';

  @override
  String get settings_terms => 'Terms of Use';

  @override
  String settings_version(String version) {
    return 'Version $version';
  }

  @override
  String get danger_title => 'Danger Zone';

  @override
  String get danger_sign_out => 'Sign Out';

  @override
  String get danger_sign_out_desc => 'Sign out of your account';

  @override
  String get danger_delete_account => 'Delete Account';

  @override
  String get danger_delete_account_desc => 'Permanently delete your account';

  @override
  String get dialog_confirm => 'Confirm';

  @override
  String get dialog_delete_warning =>
      'After deleting your account, all your trousseaus and products will be permanently deleted.';

  @override
  String get dialog_enter_password => 'Enter your password';

  @override
  String get dialog_password_required => 'Password is required';

  @override
  String get dialog_password_too_short =>
      'Password must be at least 6 characters';

  @override
  String get dialog_invalid_email => 'Enter a valid email address';

  @override
  String get dialog_security_reason => 'Your password is required for security';
}
