import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('tr'),
    Locale('en')
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'Ceyiz Diz'**
  String get app_title;

  /// No description provided for @app_tagline.
  ///
  /// In en, this message translates to:
  /// **'Plan and manage your dream trousseau easily'**
  String get app_tagline;

  /// No description provided for @auth_login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get auth_login;

  /// No description provided for @auth_register.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get auth_register;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get auth_confirm_password;

  /// No description provided for @auth_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get auth_forgot_password;

  /// No description provided for @auth_no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get auth_no_account;

  /// No description provided for @auth_sign_up_now.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get auth_sign_up_now;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your dream trousseau easily'**
  String get login_subtitle;

  /// No description provided for @login_email_hint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get login_email_hint;

  /// No description provided for @login_password_hint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get login_password_hint;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get common_share;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @trousseau_title.
  ///
  /// In en, this message translates to:
  /// **'Trousseau'**
  String get trousseau_title;

  /// No description provided for @trousseau_list.
  ///
  /// In en, this message translates to:
  /// **'Trousseaus'**
  String get trousseau_list;

  /// No description provided for @trousseau_create.
  ///
  /// In en, this message translates to:
  /// **'Create Trousseau'**
  String get trousseau_create;

  /// No description provided for @trousseau_not_found.
  ///
  /// In en, this message translates to:
  /// **'Trousseau not found'**
  String get trousseau_not_found;

  /// No description provided for @trousseau_share_title.
  ///
  /// In en, this message translates to:
  /// **'Share Trousseau'**
  String get trousseau_share_title;

  /// No description provided for @trousseau_shared_success.
  ///
  /// In en, this message translates to:
  /// **'Trousseau shared successfully'**
  String get trousseau_shared_success;

  /// No description provided for @products_title.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products_title;

  /// No description provided for @products_add.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get products_add;

  /// No description provided for @products_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get products_edit;

  /// No description provided for @products_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get products_search_hint;

  /// No description provided for @products_empty.
  ///
  /// In en, this message translates to:
  /// **'No products added yet'**
  String get products_empty;

  /// No description provided for @products_not_found.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get products_not_found;

  /// No description provided for @products_get_started.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first product'**
  String get products_get_started;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_account_section.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get settings_account_section;

  /// No description provided for @settings_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get settings_profile;

  /// No description provided for @settings_profile_desc.
  ///
  /// In en, this message translates to:
  /// **'Edit your name and other information'**
  String get settings_profile_desc;

  /// No description provided for @settings_change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settings_change_password;

  /// No description provided for @settings_change_password_desc.
  ///
  /// In en, this message translates to:
  /// **'Update your password for account security'**
  String get settings_change_password_desc;

  /// No description provided for @settings_appearance_section.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_appearance_section;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get settings_theme;

  /// No description provided for @settings_theme_desc.
  ///
  /// In en, this message translates to:
  /// **'Change the app theme and colors'**
  String get settings_theme_desc;

  /// No description provided for @settings_app_section.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settings_app_section;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_notifications_desc.
  ///
  /// In en, this message translates to:
  /// **'Manage your notification preferences'**
  String get settings_notifications_desc;

  /// No description provided for @settings_notifications_on.
  ///
  /// In en, this message translates to:
  /// **'Notifications on'**
  String get settings_notifications_on;

  /// No description provided for @settings_notifications_off.
  ///
  /// In en, this message translates to:
  /// **'Notifications off'**
  String get settings_notifications_off;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @language_turkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get language_turkish;

  /// No description provided for @language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @settings_about_section.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about_section;

  /// No description provided for @settings_about_app.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get settings_about_app;

  /// No description provided for @settings_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacy;

  /// No description provided for @settings_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get settings_terms;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settings_version(String version);

  /// No description provided for @danger_title.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get danger_title;

  /// No description provided for @danger_sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get danger_sign_out;

  /// No description provided for @danger_sign_out_desc.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get danger_sign_out_desc;

  /// No description provided for @danger_delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get danger_delete_account;

  /// No description provided for @danger_delete_account_desc.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get danger_delete_account_desc;

  /// No description provided for @dialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dialog_confirm;

  /// No description provided for @dialog_delete_warning.
  ///
  /// In en, this message translates to:
  /// **'After deleting your account, all your trousseaus and products will be permanently deleted.'**
  String get dialog_delete_warning;

  /// No description provided for @dialog_enter_password.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get dialog_enter_password;

  /// No description provided for @dialog_password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get dialog_password_required;

  /// No description provided for @dialog_password_too_short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get dialog_password_too_short;

  /// No description provided for @dialog_invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get dialog_invalid_email;

  /// No description provided for @dialog_security_reason.
  ///
  /// In en, this message translates to:
  /// **'Your password is required for security'**
  String get dialog_security_reason;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
