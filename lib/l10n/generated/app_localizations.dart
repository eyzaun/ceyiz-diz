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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @googleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get googleSignIn;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get displayName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email sent! Check your inbox.'**
  String get emailSent;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email address cannot be empty'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full Name cannot be empty'**
  String get nameRequired;

  /// No description provided for @passwordsNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsNotMatch;

  /// No description provided for @emailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get emailVerification;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email Not Verified'**
  String get emailNotVerified;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Your email address has been verified! You can login.'**
  String get emailVerified;

  /// No description provided for @verificationEmailResent.
  ///
  /// In en, this message translates to:
  /// **'Verification email resent'**
  String get verificationEmailResent;

  /// No description provided for @emailNotVerifiedYet.
  ///
  /// In en, this message translates to:
  /// **'Email not verified yet. Please check your inbox.'**
  String get emailNotVerifiedYet;

  /// No description provided for @resetPasswordEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get resetPasswordEmailSent;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login page'**
  String get backToLogin;

  /// No description provided for @backToLoginPage.
  ///
  /// In en, this message translates to:
  /// **'Back to Login Page'**
  String get backToLoginPage;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @trousseaus.
  ///
  /// In en, this message translates to:
  /// **'Trousseaus'**
  String get trousseaus;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @tapBackAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Tap back again to exit'**
  String get tapBackAgainToExit;

  /// No description provided for @cantOpenPlayStore.
  ///
  /// In en, this message translates to:
  /// **'Can\'t open Play Store'**
  String get cantOpenPlayStore;

  /// No description provided for @trousseau.
  ///
  /// In en, this message translates to:
  /// **'Trousseau'**
  String get trousseau;

  /// No description provided for @createTrousseau.
  ///
  /// In en, this message translates to:
  /// **'Create Trousseau'**
  String get createTrousseau;

  /// No description provided for @editTrousseau.
  ///
  /// In en, this message translates to:
  /// **'Edit Trousseau'**
  String get editTrousseau;

  /// No description provided for @trousseauName.
  ///
  /// In en, this message translates to:
  /// **'Trousseau Name'**
  String get trousseauName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @targetBudget.
  ///
  /// In en, this message translates to:
  /// **'Target Budget'**
  String get targetBudget;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// No description provided for @unpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// No description provided for @pinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinned;

  /// No description provided for @noPinnedTrousseaus.
  ///
  /// In en, this message translates to:
  /// **'No pinned trousseaus yet'**
  String get noPinnedTrousseaus;

  /// No description provided for @createFirstTrousseau.
  ///
  /// In en, this message translates to:
  /// **'Create your first trousseau'**
  String get createFirstTrousseau;

  /// No description provided for @createNewTrousseau.
  ///
  /// In en, this message translates to:
  /// **'Create New Trousseau'**
  String get createNewTrousseau;

  /// No description provided for @trousseauCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Trousseau created successfully'**
  String get trousseauCreatedSuccessfully;

  /// No description provided for @trousseauUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Trousseau updated successfully'**
  String get trousseauUpdatedSuccessfully;

  /// No description provided for @trousseauDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Trousseau deleted successfully'**
  String get trousseauDeletedSuccessfully;

  /// No description provided for @deleteTrousseau.
  ///
  /// In en, this message translates to:
  /// **'Delete Trousseau'**
  String get deleteTrousseau;

  /// No description provided for @trousseauNotFound.
  ///
  /// In en, this message translates to:
  /// **'Trousseau not found'**
  String get trousseauNotFound;

  /// No description provided for @shareTrousseau.
  ///
  /// In en, this message translates to:
  /// **'Share Trousseau'**
  String get shareTrousseau;

  /// No description provided for @sharedWith.
  ///
  /// In en, this message translates to:
  /// **'Shared With'**
  String get sharedWith;

  /// No description provided for @sharedTrousseaus.
  ///
  /// In en, this message translates to:
  /// **'Shared With Me'**
  String get sharedTrousseaus;

  /// No description provided for @sharedWithMeTitle.
  ///
  /// In en, this message translates to:
  /// **'Shared with Me'**
  String get sharedWithMeTitle;

  /// No description provided for @sharedWithMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View shared trousseau lists'**
  String get sharedWithMeSubtitle;

  /// No description provided for @sharedTrousseausSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View shared trousseau lists'**
  String get sharedTrousseausSubtitle;

  /// No description provided for @trousseauSharedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Trousseau shared successfully'**
  String get trousseauSharedSuccessfully;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get enterEmail;

  /// No description provided for @giveEditPermission.
  ///
  /// In en, this message translates to:
  /// **'Give Edit Permission'**
  String get giveEditPermission;

  /// No description provided for @invitations.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get invitations;

  /// No description provided for @acceptInvitation.
  ///
  /// In en, this message translates to:
  /// **'Accept Invitation'**
  String get acceptInvitation;

  /// No description provided for @declineInvitation.
  ///
  /// In en, this message translates to:
  /// **'Decline Invitation'**
  String get declineInvitation;

  /// No description provided for @invitationSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent'**
  String get invitationSent;

  /// No description provided for @invitationAccepted.
  ///
  /// In en, this message translates to:
  /// **'Invitation accepted'**
  String get invitationAccepted;

  /// No description provided for @invitationDeclined.
  ///
  /// In en, this message translates to:
  /// **'Invitation declined'**
  String get invitationDeclined;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @viewOnly.
  ///
  /// In en, this message translates to:
  /// **'View Only'**
  String get viewOnly;

  /// No description provided for @canEdit.
  ///
  /// In en, this message translates to:
  /// **'Can Edit'**
  String get canEdit;

  /// No description provided for @fullAccess.
  ///
  /// In en, this message translates to:
  /// **'Full Access'**
  String get fullAccess;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @leaveTrousseau.
  ///
  /// In en, this message translates to:
  /// **'Leave Trousseau'**
  String get leaveTrousseau;

  /// No description provided for @leaveTrousseauConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this trousseau? Your access will be revoked.'**
  String get leaveTrousseauConfirm;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get links;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @purchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchased;

  /// No description provided for @notPurchased.
  ///
  /// In en, this message translates to:
  /// **'Not Purchased'**
  String get notPurchased;

  /// No description provided for @markAsPurchased.
  ///
  /// In en, this message translates to:
  /// **'Mark as Purchased'**
  String get markAsPurchased;

  /// No description provided for @productPurchased.
  ///
  /// In en, this message translates to:
  /// **'Product Purchased'**
  String get productPurchased;

  /// No description provided for @isProductPurchased.
  ///
  /// In en, this message translates to:
  /// **'Is this product purchased?'**
  String get isProductPurchased;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProducts;

  /// No description provided for @addFirstProduct.
  ///
  /// In en, this message translates to:
  /// **'Add your first product'**
  String get addFirstProduct;

  /// No description provided for @productAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product added successfully'**
  String get productAddedSuccessfully;

  /// No description provided for @productUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get productUpdatedSuccessfully;

  /// No description provided for @productDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeletedSuccessfully;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String productDeleted(String name);

  /// No description provided for @whichTrousseauToAdd.
  ///
  /// In en, this message translates to:
  /// **'Which trousseau to add to?'**
  String get whichTrousseauToAdd;

  /// No description provided for @openProductLink1.
  ///
  /// In en, this message translates to:
  /// **'Open Product Link 1'**
  String get openProductLink1;

  /// No description provided for @openProductLink2.
  ///
  /// In en, this message translates to:
  /// **'Open Product Link 2'**
  String get openProductLink2;

  /// No description provided for @openProductLink3.
  ///
  /// In en, this message translates to:
  /// **'Open Product Link 3'**
  String get openProductLink3;

  /// No description provided for @cantOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Can\'t open link'**
  String get cantOpenLink;

  /// No description provided for @invalidLink.
  ///
  /// In en, this message translates to:
  /// **'Invalid link'**
  String get invalidLink;

  /// No description provided for @furniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get furniture;

  /// No description provided for @textile.
  ///
  /// In en, this message translates to:
  /// **'Textile'**
  String get textile;

  /// No description provided for @kitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get kitchen;

  /// No description provided for @bathroom.
  ///
  /// In en, this message translates to:
  /// **'Bathroom'**
  String get bathroom;

  /// No description provided for @decoration.
  ///
  /// In en, this message translates to:
  /// **'Decoration'**
  String get decoration;

  /// No description provided for @electronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get electronics;

  /// No description provided for @clothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get clothing;

  /// No description provided for @accessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get accessories;

  /// No description provided for @jewelry.
  ///
  /// In en, this message translates to:
  /// **'Jewelry'**
  String get jewelry;

  /// No description provided for @shoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get shoes;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @customCategories.
  ///
  /// In en, this message translates to:
  /// **'Custom Categories'**
  String get customCategories;

  /// No description provided for @defaultCategories.
  ///
  /// In en, this message translates to:
  /// **'Default Categories'**
  String get defaultCategories;

  /// No description provided for @categoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Category Management'**
  String get categoryManagement;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add new category...'**
  String get addNewCategory;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategory;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the \"{name}\" category? Products will not be deleted; category view may be Other.'**
  String deleteCategoryConfirm(String name);

  /// No description provided for @selectIconAndColor.
  ///
  /// In en, this message translates to:
  /// **'Select Icon and Color'**
  String get selectIconAndColor;

  /// No description provided for @changeIconAndColor.
  ///
  /// In en, this message translates to:
  /// **'Change Icon and Color'**
  String get changeIconAndColor;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @totalBudget.
  ///
  /// In en, this message translates to:
  /// **'Total Budget'**
  String get totalBudget;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @totalProducts.
  ///
  /// In en, this message translates to:
  /// **'Total Products'**
  String get totalProducts;

  /// No description provided for @purchasedProducts.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchasedProducts;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @categoryDistribution.
  ///
  /// In en, this message translates to:
  /// **'Category Distribution'**
  String get categoryDistribution;

  /// No description provided for @statisticsGuide.
  ///
  /// In en, this message translates to:
  /// **'Statistics Guide'**
  String get statisticsGuide;

  /// No description provided for @exportToExcel.
  ///
  /// In en, this message translates to:
  /// **'Export to Excel'**
  String get exportToExcel;

  /// No description provided for @excelCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Excel file created successfully'**
  String get excelCreatedSuccessfully;

  /// No description provided for @shareAsExcel.
  ///
  /// In en, this message translates to:
  /// **'Share as Excel'**
  String get shareAsExcel;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSettings.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get themeSettings;

  /// No description provided for @themeSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change app theme and colors'**
  String get themeSettingsSubtitle;

  /// No description provided for @defaultTheme.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultTheme;

  /// No description provided for @monochrome.
  ///
  /// In en, this message translates to:
  /// **'Monochrome'**
  String get monochrome;

  /// No description provided for @purpleOcean.
  ///
  /// In en, this message translates to:
  /// **'Purple Ocean'**
  String get purpleOcean;

  /// No description provided for @forestGreen.
  ///
  /// In en, this message translates to:
  /// **'Forest Green'**
  String get forestGreen;

  /// No description provided for @sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunset;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @membership.
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get membership;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editName;

  /// No description provided for @editNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change your display name'**
  String get editNameSubtitle;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enterNewName.
  ///
  /// In en, this message translates to:
  /// **'Enter your new name'**
  String get enterNewName;

  /// No description provided for @nameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated'**
  String get nameUpdated;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated'**
  String get profilePhotoUpdated;

  /// No description provided for @profileNotUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile not updated'**
  String get profileNotUpdated;

  /// No description provided for @profileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Profile update failed'**
  String get profileUpdateError;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your password for account security'**
  String get changePasswordSubtitle;

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordButton;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @passwordRequiredSimple.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequiredSimple;

  /// No description provided for @uploadTimeout.
  ///
  /// In en, this message translates to:
  /// **'Upload timeout. Please check your internet connection.'**
  String get uploadTimeout;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Trousseau Diz is a modern app that allows you to easily plan and manage your dream trousseau.'**
  String get appDescription;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @kacSaatTitle.
  ///
  /// In en, this message translates to:
  /// **'Hours Calculator'**
  String get kacSaatTitle;

  /// No description provided for @kacSaatCalculator.
  ///
  /// In en, this message translates to:
  /// **'Work Hours Calculator'**
  String get kacSaatCalculator;

  /// No description provided for @kacSaatSettings.
  ///
  /// In en, this message translates to:
  /// **'Work Hours Settings'**
  String get kacSaatSettings;

  /// No description provided for @kacSaatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Convert product prices to work hours'**
  String get kacSaatSubtitle;

  /// No description provided for @useKacSaatFeature.
  ///
  /// In en, this message translates to:
  /// **'Use Work Hours Feature'**
  String get useKacSaatFeature;

  /// No description provided for @showWorkHoursForProducts.
  ///
  /// In en, this message translates to:
  /// **'Show work hours next to product prices'**
  String get showWorkHoursForProducts;

  /// No description provided for @kacSaatFeatureClosed.
  ///
  /// In en, this message translates to:
  /// **'Work Hours feature disabled'**
  String get kacSaatFeatureClosed;

  /// No description provided for @productHours.
  ///
  /// In en, this message translates to:
  /// **'This product equals {hours} hours of your work'**
  String productHours(String hours);

  /// No description provided for @monthlySalary.
  ///
  /// In en, this message translates to:
  /// **'Monthly Salary'**
  String get monthlySalary;

  /// No description provided for @dailyHours.
  ///
  /// In en, this message translates to:
  /// **'Daily Working Hours'**
  String get dailyHours;

  /// No description provided for @workingDays.
  ///
  /// In en, this message translates to:
  /// **'Working Days'**
  String get workingDays;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @hasPremium.
  ///
  /// In en, this message translates to:
  /// **'Has Premium'**
  String get hasPremium;

  /// No description provided for @iHavePremium.
  ///
  /// In en, this message translates to:
  /// **'I have a premium'**
  String get iHavePremium;

  /// No description provided for @quarterlyPremium.
  ///
  /// In en, this message translates to:
  /// **'Quarterly Premium'**
  String get quarterlyPremium;

  /// No description provided for @yearlyPremium.
  ///
  /// In en, this message translates to:
  /// **'Yearly Premium'**
  String get yearlyPremium;

  /// No description provided for @quarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get quarterly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @hourlyWage.
  ///
  /// In en, this message translates to:
  /// **'Hourly Wage'**
  String get hourlyWage;

  /// No description provided for @selectAtLeastOneDay.
  ///
  /// In en, this message translates to:
  /// **'You must select at least one day'**
  String get selectAtLeastOneDay;

  /// No description provided for @selectPremiumFrequency.
  ///
  /// In en, this message translates to:
  /// **'If you have a premium, you must select the premium frequency'**
  String get selectPremiumFrequency;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @application.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get application;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your notification preferences'**
  String get notificationsSubtitle;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationsDisabled;

  /// No description provided for @notificationsStatus.
  ///
  /// In en, this message translates to:
  /// **'Notifications {status}'**
  String notificationsStatus(String status);

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'disabled'**
  String get disabled;

  /// No description provided for @sharingAndFeedback.
  ///
  /// In en, this message translates to:
  /// **'Sharing & Feedback'**
  String get sharingAndFeedback;

  /// No description provided for @sharing.
  ///
  /// In en, this message translates to:
  /// **'Sharing'**
  String get sharing;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @sendFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your suggestions with us'**
  String get sendFeedbackSubtitle;

  /// No description provided for @feedbackHistory.
  ///
  /// In en, this message translates to:
  /// **'Feedback History'**
  String get feedbackHistory;

  /// No description provided for @myFeedbacks.
  ///
  /// In en, this message translates to:
  /// **'My Feedbacks'**
  String get myFeedbacks;

  /// No description provided for @thankYouForFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback'**
  String get thankYouForFeedback;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @appAbout.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get appAbout;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy text will be shown here.'**
  String get privacyPolicyContent;

  /// No description provided for @privacyPolicyText.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY POLICY\n\nLast Updated: October 31, 2025\n\nAt Çeyiz Diz, we value your privacy. This privacy policy explains what information is collected when using the application, how it is used, and how it is protected.\n\nINFORMATION COLLECTED\n\n1. Account Information:\n• Email address: For account creation and authentication\n• Username: For profile display\n• Profile photo: Optional, for profile customization\n\n2. Trousseau Data:\n• Trousseau lists: Name and description of your created lists\n• Product information: Name, category, price, quantity, notes of added products\n• Product photos: Product images you upload\n• Product links: Web links associated with products\n• Budget information: Budget and expense data you set\n\n3. Technical Information:\n• Device information: Operating system, device model, app version\n• Usage statistics: Anonymous usage data\n• Error reports: Automatic error logs to detect issues\n\nUSE OF INFORMATION\n\nCollected information is used for:\n• Service Provision: To provide trousseau management features\n• Data Synchronization: To sync your data across devices\n• Account Security: To protect your account and prevent unauthorized access\n• App Improvement: To enhance user experience and fix bugs\n• Statistics: To provide personalized statistics and analysis\n\nDATA STORAGE AND SECURITY\n\nFirebase Infrastructure:\n• Your data is securely stored on Google Firebase cloud services\n• All data is transmitted over encrypted connections (SSL/TLS)\n• Uses Firebase Cloud Firestore and Firebase Storage\n• Protected by Google\'s security standards and infrastructure\n\nData Security:\n• Your data is protected by user authentication\n• Only data belonging to your account is shown to you\n• Passwords are securely hashed and stored\n• No payment information is stored (app is free)\n\nDATA SHARING\n\nWE DO NOT SHARE YOUR DATA WITH THIRD PARTIES.\n\n• Your trousseau lists, products, and photos remain only in your account\n• Other users cannot see your data\n• Your data is not used for advertising or marketing purposes\n• Your data is not shared unless legally required\n\nTHIRD PARTY SERVICES\n\nGoogle Firebase:\n• Authentication: Account creation and login\n• Database: Data storage with Cloud Firestore\n• Storage: Photo storage with Firebase Storage\n• Privacy: https://firebase.google.com/support/privacy\n\nGoogle Sign-In (Optional):\n• Quick login with your Google account\n• Only basic profile information (name, email, profile photo) is obtained\n• Privacy: https://policies.google.com/privacy\n\nUSER RIGHTS\n\nAccess to Your Data:\n• You can view all your data within the app\n• You can export your trousseau lists in Excel format\n\nData Editing:\n• You can update or delete your data at any time\n• You can change your profile information\n\nAccount Deletion:\n• You can delete your account via Settings > Delete Account\n• When account is deleted, all your data is permanently deleted:\n  - Trousseau lists\n  - Products and photos\n  - Budget information\n  - Profile information\n• THIS ACTION CANNOT BE UNDONE\n\nCHILDREN\'S PRIVACY\n\n• Çeyiz Diz is for users aged 13 and above\n• We do not knowingly collect data from children under 13\n• If you are a parent or guardian and believe your child has provided us with information, please contact us\n\nCOOKIES AND TRACKING TECHNOLOGIES\n\n• The app uses cookies for basic functionality\n• Local storage is used to store session information\n• No ad tracking or third-party analytics tools are used\n\nDATA RETENTION PERIOD\n\n• Your data is stored as long as your account is active\n• When you delete your account, your data is permanently deleted within 30 days\n• Records required for legal obligations may be kept for the specified period\n\nINTERNATIONAL DATA TRANSFER\n\n• Your data is stored on Google Firebase\'s global infrastructure\n• Firebase processes data under the EU-US Privacy Shield framework\n• All data transfers are made through encrypted and secure connections\n\nLEGAL RIGHTS (GDPR COMPLIANCE)\n\nUnder the General Data Protection Regulation (GDPR), you have the right to:\n• Learn what purposes your data is processed for\n• Request access to and correction of your data\n• Request deletion or destruction of your data\n• Learn about third parties your data is transferred to\n• Learn about decisions made by automated systems based on your data\n\nCONTACT\n\nFor questions about our privacy policy:\n• App: You can reach us from Settings > Support section\n\nPRIVACY POLICY CHANGES\n\n• We may update this privacy policy from time to time\n• Changes will be published on this page\n• In-app notifications may be sent for significant changes\n• The last update date is always indicated at the top\n\nImportant Note: This privacy policy applies to the Çeyiz Diz mobile application. By using the app, you accept this policy.'**
  String get privacyPolicyText;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsOfServiceContent.
  ///
  /// In en, this message translates to:
  /// **'Terms of service text will be shown here.'**
  String get termsOfServiceContent;

  /// No description provided for @termsOfServiceText.
  ///
  /// In en, this message translates to:
  /// **'TERMS OF SERVICE\n\nLast Updated: October 31, 2025\n\nBy using the Çeyiz Diz application, you agree to the following terms of service. Please read these terms carefully.\n\n1. SERVICE DEFINITION\n\nÇeyiz Diz is a free mobile application that helps users manage their trousseau preparation process digitally.\n\nOffered Features:\n• Create and manage trousseau lists\n• Add, edit, and delete products\n• Categorize and filter products\n• Budget tracking and statistics\n• Upload product photos\n• Add product links\n• Excel export\n• Data synchronization (cloud backup)\n\nAccount Requirements:\n• You need to create an account to use the app\n• You can register with email/password or Google account\n• Suitable for users aged 13 and above\n• A user can only have one account\n\n2. TERMS OF USE\n\nPermitted Use:\n• Personal trousseau planning and tracking\n• Family organization\n• Budget management\n• Shopping list preparation\n\nProhibited Uses:\n• Commercial purposes or profit making\n• Disrupting or damaging the app\'s functionality\n• Unauthorized access to other users\' data\n• Creating fake accounts or impersonation\n• Spreading spam, malware, or viruses\n• Sharing illegal content\n• Reverse engineering the app\'s source code\n• Using automated bots or scraping tools\n\nContent Responsibility:\n• You are responsible for all content you upload (photos, text, links)\n• You must not upload content that infringes copyright\n• You cannot share inappropriate, offensive, or illegal content\n• Product photos are for personal use only\n\n3. ACCOUNT SECURITY\n\nAccount Responsibility:\n• You are responsible for keeping your account information (email, password) secure\n• You are responsible for all activities in your account\n• We recommend changing your password regularly\n• Contact us immediately if you suspect your account has been compromised\n\nAccount Suspension/Closure:\nWe reserve the right to suspend or close your account in the following cases:\n• Violation of terms of service\n• Detection of illegal activity\n• Attempt to harm other users\n• Threatening the app\'s security\n\n4. INTELLECTUAL PROPERTY RIGHTS\n\nApplication Rights:\n• All rights to the Çeyiz Diz application are reserved\n• App design, logo, and content are protected by copyright\n• You cannot copy the app\'s source code\n• You cannot use the app name and logo without permission\n\nUser Content:\n• Copyright of uploaded content belongs to you\n• You grant us the right to store and process content you upload\n• You can delete your content at any time\n• Your content is deleted when you delete your account\n\n5. PRIVACY AND DATA PROTECTION\n\n• Your personal data is protected under our Privacy Policy\n• Your data is stored on Google Firebase secure servers\n• We do not share your data with third parties\n• We operate in compliance with GDPR\n\nPlease review the Privacy Policy page for detailed information.\n\n6. SERVICE INTERRUPTIONS\n\nMaintenance and Updates:\n• We may perform regular maintenance and updates on the app\n• Temporary interruptions may occur during updates\n• Prior notification is given for critical updates\n\nNo Service Guarantee:\n• We provide the app \"as is\"\n• We do not guarantee uninterrupted or error-free operation\n• We accept no responsibility for data loss\n• Users are advised to take regular backups\n\n7. LIABILITY LIMITATIONS\n\nApplication Liability:\nWe are not responsible for:\n• Incorrect product information or price calculations\n• User-caused data loss\n• Issues arising from third-party links (product links)\n• Internet connection or device problems\n• Interruptions caused by Firebase infrastructure\n\nThird Party Links:\n• Product links shared in the app are added by users\n• We are not responsible for the content of linked websites\n• You are responsible for your purchases on e-commerce sites\n• Product prices and stock status may change\n\nFinancial Liability:\n• Çeyiz Diz is a free application\n• We do not process any payments\n• Budget calculations are estimates, not exact\n• We are not responsible for your financial decisions\n\n8. PRICING\n\n• ÇEYİZ DİZ IS COMPLETELY FREE\n• There are no in-app purchases\n• There are no premium features or subscription plans\n• Users will be informed if paid features are added in the future\n\n9. CHANGES TO TERMS OF SERVICE\n\nRight to Update:\n• We may update these terms of service at any time\n• Significant changes will be announced via in-app notification\n• Updates will be published on this page\n• The last update date is always indicated\n\nAcceptance and Approval:\n• If you continue using the app after updates, you accept the new terms\n• If you do not accept the terms, you should stop using the app\n• You can delete your account at any time\n\n10. SERVICE TERMINATION\n\nBy User:\n• You can delete your account at any time\n• Use Settings > Delete Account option\n• All your data is permanently deleted after account deletion\n• This action cannot be undone\n\nBy Company:\nWe may terminate your account in the following cases:\n• Serious violation of terms of service\n• Not logging into your account for a long time (12+ months)\n• Detection of illegal activity\n• Abuse of the application\n\nMass Service Termination:\n• We may decide to shut down the application\n• At least 90 days notice will be given\n• Users will be given time to export their data\n• Data loss will be prevented as much as possible\n\n11. COMMUNICATION AND SUPPORT\n\nSupport Channels:\n• In-App: Settings > Support\n• Feedback: Feedback form in the app\n\nResponse Times:\n• Technical support requests: Within 48 hours\n• Account issues: Within 24 hours\n• General questions: Within 72 hours\n\n12. DISPUTE RESOLUTION\n\nApplicable Law:\n• These terms of service are subject to the laws of the Republic of Turkey\n• Disputes will be resolved in Turkish courts\n• Istanbul courts and enforcement offices have jurisdiction\n\nDispute Resolution:\n• Amicable resolution is preferred first\n• Formal complaint process may be applied\n• Right to resort to legal means is reserved\n\n13. MISCELLANEOUS PROVISIONS\n\n• Severability: If any of these terms is deemed invalid, the others remain in effect\n• Waiver: Non-exercise of a right does not mean waiver of that right\n• Assignment: You cannot transfer your rights under this agreement to another party\n• Entire Agreement: These terms of service and privacy policy constitute the entire agreement\n\nIMPORTANT REMINDERS\n\nMain Points You Accept:\n• You will use the app for personal use\n• Your account security is your responsibility\n• Content you upload must be appropriate and legal\n• We recommend backing up your data\n• Violating the terms of service may result in account closure\n\nThings You Cannot Do:\n• Commercial use\n• Copyright infringement\n• Harming other users\n• Threatening the app\'s security\n• Sharing spam or harmful content\n\nFinal Note: By accepting these terms of service, you commit to using the Çeyiz Diz application in accordance with legal and ethical rules. You are deemed to have accepted these terms when you start using the app.\n\nEffective Date: October 31, 2025'**
  String get termsOfServiceText;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @logoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out from your account'**
  String get logoutSubtitle;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out from your account'**
  String get signOutSubtitle;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountButton;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get deleteAccountSubtitle2;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'You need to login'**
  String get loginRequired;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Get Started!'**
  String get getStarted;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Çeyiz Diz!'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trousseau preparation made easy'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your trousseau preparation digitally, track your budget, and share with your loved ones. Everything is now at your fingertips!'**
  String get welcomeDescription;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteConfirm;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New Item'**
  String get newItem;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @operationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Operation cancelled'**
  String get operationCancelled;

  /// No description provided for @primaryButton.
  ///
  /// In en, this message translates to:
  /// **'Primary Button'**
  String get primaryButton;

  /// No description provided for @secondaryButton.
  ///
  /// In en, this message translates to:
  /// **'Secondary Button'**
  String get secondaryButton;

  /// No description provided for @checkbox.
  ///
  /// In en, this message translates to:
  /// **'Checkbox'**
  String get checkbox;

  /// No description provided for @pressAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press again to exit'**
  String get pressAgainToExit;

  /// No description provided for @noTrousseauYet.
  ///
  /// In en, this message translates to:
  /// **'No trousseau created yet'**
  String get noTrousseauYet;

  /// No description provided for @updateRequired.
  ///
  /// In en, this message translates to:
  /// **'Update Required!'**
  String get updateRequired;

  /// No description provided for @newVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'New Version Available'**
  String get newVersionAvailable;

  /// No description provided for @newVersion.
  ///
  /// In en, this message translates to:
  /// **'New Version'**
  String get newVersion;

  /// No description provided for @forceUpdateMessage.
  ///
  /// In en, this message translates to:
  /// **'This update is mandatory. You need to update to continue.'**
  String get forceUpdateMessage;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @playStoreOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open Play Store.'**
  String get playStoreOpenFailed;

  /// No description provided for @emailVerificationMessage.
  ///
  /// In en, this message translates to:
  /// **'You need to verify your email address to log into your account. Click the link sent to your email address.'**
  String get emailVerificationMessage;

  /// No description provided for @goToVerification.
  ///
  /// In en, this message translates to:
  /// **'Go to Verification Page'**
  String get goToVerification;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordHint;

  /// No description provided for @nameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Must be at least 3 characters'**
  String get nameMinLength;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first and last name (e.g. John Doe)'**
  String get enterFullName;

  /// No description provided for @passwordUpperCase.
  ///
  /// In en, this message translates to:
  /// **'Must contain at least 1 uppercase letter (A-Z)'**
  String get passwordUpperCase;

  /// No description provided for @passwordLowerCase.
  ///
  /// In en, this message translates to:
  /// **'Must contain at least 1 lowercase letter (a-z)'**
  String get passwordLowerCase;

  /// No description provided for @passwordDigit.
  ///
  /// In en, this message translates to:
  /// **'Must contain at least 1 digit (0-9)'**
  String get passwordDigit;

  /// No description provided for @confirmPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get confirmPasswordMismatch;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @securityRequirements.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters, 1 uppercase, 1 lowercase and 1 digit'**
  String get securityRequirements;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @registerWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get registerWithGoogle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your new account'**
  String get createAccountSubtitle;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry! Enter your email address and we\'ll send you a password reset link.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Sent!'**
  String get emailSentTitle;

  /// No description provided for @emailSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a password reset link to {email}. Please check your email.'**
  String emailSentMessage(String email);

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get passwordResetEmailSent;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyYourEmail;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification email to {email}.'**
  String verificationEmailSent(String email);

  /// No description provided for @clickLinkToVerify.
  ///
  /// In en, this message translates to:
  /// **'Please click the link in your email to verify your account.'**
  String get clickLinkToVerify;

  /// No description provided for @checkVerification.
  ///
  /// In en, this message translates to:
  /// **'Check Verification'**
  String get checkVerification;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendVerificationEmail;

  /// No description provided for @resendInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Resend in ({seconds} seconds)'**
  String resendInSeconds(int seconds);

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @verificationTip1.
  ///
  /// In en, this message translates to:
  /// **'• Check your spam folder if you can\'t find the email'**
  String get verificationTip1;

  /// No description provided for @verificationTip2.
  ///
  /// In en, this message translates to:
  /// **'• Use the \"Resend\" button if the email doesn\'t arrive within a few minutes'**
  String get verificationTip2;

  /// No description provided for @verificationTip3.
  ///
  /// In en, this message translates to:
  /// **'• You will be automatically redirected to the login page once verification is complete'**
  String get verificationTip3;

  /// No description provided for @trousseauInfo.
  ///
  /// In en, this message translates to:
  /// **'Trousseau Information'**
  String get trousseauInfo;

  /// No description provided for @trousseauNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Trousseau name is required'**
  String get trousseauNameRequired;

  /// No description provided for @minThreeCharacters.
  ///
  /// In en, this message translates to:
  /// **'Must be at least 3 characters'**
  String get minThreeCharacters;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add notes about your trousseau (Optional)'**
  String get descriptionHint;

  /// No description provided for @budgetOptional.
  ///
  /// In en, this message translates to:
  /// **'Budget (Optional)'**
  String get budgetOptional;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @shareViaEmail.
  ///
  /// In en, this message translates to:
  /// **'Share via Email'**
  String get shareViaEmail;

  /// No description provided for @shareSuccess.
  ///
  /// In en, this message translates to:
  /// **'Shared successfully'**
  String get shareSuccess;

  /// No description provided for @noSharedTrousseaus.
  ///
  /// In en, this message translates to:
  /// **'No shared trousseaus'**
  String get noSharedTrousseaus;

  /// No description provided for @priceOptional.
  ///
  /// In en, this message translates to:
  /// **'Price (Optional)'**
  String get priceOptional;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Organize Your Trousseau'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Easily track all your trousseau items in one place'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Budget Planning'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Set budgets and track your spending'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Share with Family'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Share your trousseau list with family members'**
  String get onboardingDesc3;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @leaveSharing.
  ///
  /// In en, this message translates to:
  /// **'Leave Sharing'**
  String get leaveSharing;

  /// No description provided for @leaveShareConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this trousseau? Your access will be removed.'**
  String get leaveShareConfirm;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @leftSharing.
  ///
  /// In en, this message translates to:
  /// **'Left sharing'**
  String get leftSharing;

  /// No description provided for @searchProduct.
  ///
  /// In en, this message translates to:
  /// **'Search product...'**
  String get searchProduct;

  /// No description provided for @noProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProductsYet;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @tryDifferentFilters.
  ///
  /// In en, this message translates to:
  /// **'You can try different filters'**
  String get tryDifferentFilters;

  /// No description provided for @deleteProductConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {productName}?'**
  String deleteProductConfirm(String productName);

  /// No description provided for @excelExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Excel file created successfully'**
  String get excelExportSuccess;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @deleteTrousseauWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone! All products in this trousseau will be deleted.'**
  String get deleteTrousseauWarning;

  /// No description provided for @deleteTrousseauConfirm.
  ///
  /// In en, this message translates to:
  /// **'Deleting a trousseau is irreversible. All products and data will be permanently deleted.'**
  String get deleteTrousseauConfirm;

  /// No description provided for @enterPasswordToDelete.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPasswordToDelete;

  /// No description provided for @passwordRequiredForSecurity.
  ///
  /// In en, this message translates to:
  /// **'Your password is required for security'**
  String get passwordRequiredForSecurity;

  /// No description provided for @deleteAccountIrreversible.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data will be permanently deleted.'**
  String get deleteAccountIrreversible;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'After deleting your account, all your trousseaus and products will be permanently deleted.'**
  String get deleteAccountWarning;

  /// No description provided for @trousseauDeleted.
  ///
  /// In en, this message translates to:
  /// **'Trousseau deleted'**
  String get trousseauDeleted;

  /// No description provided for @giveEditPermissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This person can add and edit products in the trousseau'**
  String get giveEditPermissionSubtitle;

  /// No description provided for @sharedPeople.
  ///
  /// In en, this message translates to:
  /// **'Shared With'**
  String get sharedPeople;

  /// No description provided for @removeSharing.
  ///
  /// In en, this message translates to:
  /// **'Remove Sharing'**
  String get removeSharing;

  /// No description provided for @removeSharingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this person\'s access?'**
  String get removeSharingConfirm;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @sharedWithMe.
  ///
  /// In en, this message translates to:
  /// **'Shared With Me'**
  String get sharedWithMe;

  /// No description provided for @sharedItems.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get sharedItems;

  /// No description provided for @noSharedTrousseausSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trousseaus shared with you will appear here'**
  String get noSharedTrousseausSubtitle;

  /// No description provided for @removeFromHome.
  ///
  /// In en, this message translates to:
  /// **'Remove from home'**
  String get removeFromHome;

  /// No description provided for @addToHome.
  ///
  /// In en, this message translates to:
  /// **'Add to home'**
  String get addToHome;

  /// No description provided for @completedProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% completed'**
  String completedProgress(int percent);

  /// No description provided for @productCount.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String productCount(int count);

  /// No description provided for @mustLogin.
  ///
  /// In en, this message translates to:
  /// **'You must log in'**
  String get mustLogin;

  /// No description provided for @mustLoginToViewInvitations.
  ///
  /// In en, this message translates to:
  /// **'Log in to view invitations'**
  String get mustLoginToViewInvitations;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @noNewInvitations.
  ///
  /// In en, this message translates to:
  /// **'No new invitations'**
  String get noNewInvitations;

  /// No description provided for @noNewInvitationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invitations sent to you will appear here'**
  String get noNewInvitationsSubtitle;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @invitationAcceptedWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Invitation accepted! It will appear in the Shared tab.'**
  String get invitationAcceptedWillAppear;

  /// No description provided for @nameAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This name is already used'**
  String get nameAlreadyUsed;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @productNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Product name is required'**
  String get productNameRequired;

  /// No description provided for @enterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price'**
  String get enterValidPrice;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get invalid;

  /// No description provided for @addingProduct.
  ///
  /// In en, this message translates to:
  /// **'Adding product...'**
  String get addingProduct;

  /// No description provided for @letsGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Get Started!'**
  String get letsGetStarted;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @productNameExample.
  ///
  /// In en, this message translates to:
  /// **'E.g: Cutlery Set'**
  String get productNameExample;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInformation;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @productDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Details about the product'**
  String get productDetailsHint;

  /// No description provided for @productLink.
  ///
  /// In en, this message translates to:
  /// **'Product Link 1'**
  String get productLink;

  /// No description provided for @productLink2.
  ///
  /// In en, this message translates to:
  /// **'Product Link 2'**
  String get productLink2;

  /// No description provided for @productLink3.
  ///
  /// In en, this message translates to:
  /// **'Product Link 3'**
  String get productLink3;

  /// No description provided for @selectTrousseau.
  ///
  /// In en, this message translates to:
  /// **'Which Trousseau to Add To?'**
  String get selectTrousseau;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @giveUp.
  ///
  /// In en, this message translates to:
  /// **'Give Up'**
  String get giveUp;

  /// No description provided for @deleteProductWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product? This action cannot be undone.'**
  String get deleteProductWarning;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @editPermission.
  ///
  /// In en, this message translates to:
  /// **'Edit permission'**
  String get editPermission;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @startPlanningDream.
  ///
  /// In en, this message translates to:
  /// **'Start planning your dream trousseau'**
  String get startPlanningDream;

  /// No description provided for @trousseauNameExample.
  ///
  /// In en, this message translates to:
  /// **'E.g: My Wedding Trousseau'**
  String get trousseauNameExample;

  /// No description provided for @budgetExample.
  ///
  /// In en, this message translates to:
  /// **'E.g: 50,000 (Optional)'**
  String get budgetExample;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @trousseauInformation.
  ///
  /// In en, this message translates to:
  /// **'Trousseau Information'**
  String get trousseauInformation;

  /// No description provided for @selectSymbolAndColor.
  ///
  /// In en, this message translates to:
  /// **'Select Symbol and Color'**
  String get selectSymbolAndColor;

  /// No description provided for @existingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Existing Photos'**
  String get existingPhotos;

  /// No description provided for @newPhotos.
  ///
  /// In en, this message translates to:
  /// **'New Photos'**
  String get newPhotos;

  /// No description provided for @addNewPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add New Photo'**
  String get addNewPhoto;

  /// No description provided for @changeSymbolAndColor.
  ///
  /// In en, this message translates to:
  /// **'Change Symbol and Color'**
  String get changeSymbolAndColor;

  /// No description provided for @enterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Enter category name'**
  String get enterCategoryName;

  /// No description provided for @noCustomCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No custom categories yet. You can add them from the top right.'**
  String get noCustomCategoriesYet;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @myFeedback.
  ///
  /// In en, this message translates to:
  /// **'My Feedback'**
  String get myFeedback;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @noFeedbackYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t sent any feedback yet'**
  String get noFeedbackYet;

  /// No description provided for @shareYourOpinions.
  ///
  /// In en, this message translates to:
  /// **'Share your opinions and suggestions with us'**
  String get shareYourOpinions;

  /// No description provided for @yourMessage.
  ///
  /// In en, this message translates to:
  /// **'Your Message'**
  String get yourMessage;

  /// No description provided for @fromSupportTeam.
  ///
  /// In en, this message translates to:
  /// **'From Support Team'**
  String get fromSupportTeam;

  /// No description provided for @notAnsweredYet.
  ///
  /// In en, this message translates to:
  /// **'Not answered yet'**
  String get notAnsweredYet;

  /// No description provided for @feedbackInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Share your opinions and suggestions about the app with us.'**
  String get feedbackInfoMessage;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Your improvement suggestions, bug reports or general comments...'**
  String get feedbackHint;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @emailForResponse.
  ///
  /// In en, this message translates to:
  /// **'Leave your email if you want us to respond'**
  String get emailForResponse;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get currentPasswordRequired;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get newPasswordRequired;

  /// No description provided for @passwordMustContain.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase, one lowercase and one number'**
  String get passwordMustContain;

  /// No description provided for @newPasswordMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from current password'**
  String get newPasswordMustBeDifferent;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation is required'**
  String get confirmPasswordRequired;

  /// No description provided for @newPasswordAgain.
  ///
  /// In en, this message translates to:
  /// **'New Password Again'**
  String get newPasswordAgain;

  /// No description provided for @strongPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password: At least 6 characters, including uppercase/lowercase letters and numbers.'**
  String get strongPasswordHint;

  /// No description provided for @themeSelection.
  ///
  /// In en, this message translates to:
  /// **'Theme Selection'**
  String get themeSelection;

  /// No description provided for @customizeAppearance.
  ///
  /// In en, this message translates to:
  /// **'Customize the app\'s appearance'**
  String get customizeAppearance;

  /// No description provided for @modernVibrantColors.
  ///
  /// In en, this message translates to:
  /// **'Modern and vibrant colors'**
  String get modernVibrantColors;

  /// No description provided for @monochromeTheme.
  ///
  /// In en, this message translates to:
  /// **'Monochrome'**
  String get monochromeTheme;

  /// No description provided for @pureBlackWhiteAccent.
  ///
  /// In en, this message translates to:
  /// **'Pure black with white accents'**
  String get pureBlackWhiteAccent;

  /// No description provided for @darkGreyPurpleAccents.
  ///
  /// In en, this message translates to:
  /// **'Dark grey background, purple accents'**
  String get darkGreyPurpleAccents;

  /// No description provided for @naturalGreenTones.
  ///
  /// In en, this message translates to:
  /// **'Natural green tones'**
  String get naturalGreenTones;

  /// No description provided for @warmOrangePinkPurple.
  ///
  /// In en, this message translates to:
  /// **'Warm orange, pink and purple tones'**
  String get warmOrangePinkPurple;

  /// No description provided for @exampleInputField.
  ///
  /// In en, this message translates to:
  /// **'Example Input Field'**
  String get exampleInputField;

  /// No description provided for @enterText.
  ///
  /// In en, this message translates to:
  /// **'Enter text'**
  String get enterText;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @kacSaatFeatureInfo.
  ///
  /// In en, this message translates to:
  /// **'This feature shows how many hours of work product prices are equivalent to'**
  String get kacSaatFeatureInfo;

  /// No description provided for @showWorkHoursPrices.
  ///
  /// In en, this message translates to:
  /// **'Show work hours next to product prices'**
  String get showWorkHoursPrices;

  /// No description provided for @monthlySalaryTL.
  ///
  /// In en, this message translates to:
  /// **'Monthly Salary (TL)'**
  String get monthlySalaryTL;

  /// No description provided for @forExample17000.
  ///
  /// In en, this message translates to:
  /// **'For example: 17000'**
  String get forExample17000;

  /// No description provided for @salaryRequired.
  ///
  /// In en, this message translates to:
  /// **'Salary is required'**
  String get salaryRequired;

  /// No description provided for @enterValidSalary.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid salary'**
  String get enterValidSalary;

  /// No description provided for @dailyWorkHours.
  ///
  /// In en, this message translates to:
  /// **'Daily Work Hours'**
  String get dailyWorkHours;

  /// No description provided for @forExample8.
  ///
  /// In en, this message translates to:
  /// **'For example: 8'**
  String get forExample8;

  /// No description provided for @workHoursRequired.
  ///
  /// In en, this message translates to:
  /// **'Work hours are required'**
  String get workHoursRequired;

  /// No description provided for @enterValidHours024.
  ///
  /// In en, this message translates to:
  /// **'Enter valid hours (0-24)'**
  String get enterValidHours024;

  /// No description provided for @bonusInfo.
  ///
  /// In en, this message translates to:
  /// **'Bonus Information'**
  String get bonusInfo;

  /// No description provided for @iReceiveBonus.
  ///
  /// In en, this message translates to:
  /// **'I Receive Bonus'**
  String get iReceiveBonus;

  /// No description provided for @every3Months.
  ///
  /// In en, this message translates to:
  /// **'Every 3 Months'**
  String get every3Months;

  /// No description provided for @quarterlyBonusAmountTL.
  ///
  /// In en, this message translates to:
  /// **'Quarterly Bonus Amount (TL)'**
  String get quarterlyBonusAmountTL;

  /// No description provided for @sameAsSalary.
  ///
  /// In en, this message translates to:
  /// **'Same as salary'**
  String get sameAsSalary;

  /// No description provided for @bonusAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Bonus amount is required'**
  String get bonusAmountRequired;

  /// No description provided for @every12Months.
  ///
  /// In en, this message translates to:
  /// **'Every 12 Months'**
  String get every12Months;

  /// No description provided for @yearlyBonusAmountTL.
  ///
  /// In en, this message translates to:
  /// **'Yearly Bonus Amount (TL)'**
  String get yearlyBonusAmountTL;

  /// No description provided for @kacSaatFeatureDisabled.
  ///
  /// In en, this message translates to:
  /// **'Work Hours feature disabled'**
  String get kacSaatFeatureDisabled;

  /// No description provided for @selectBonusFrequency.
  ///
  /// In en, this message translates to:
  /// **'If you receive bonus, you must select bonus frequency'**
  String get selectBonusFrequency;

  /// No description provided for @statisticsGuideTooltip.
  ///
  /// In en, this message translates to:
  /// **'Statistics Guide'**
  String get statisticsGuideTooltip;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @percentUsed.
  ///
  /// In en, this message translates to:
  /// **'used'**
  String get percentUsed;

  /// No description provided for @withinBudget.
  ///
  /// In en, this message translates to:
  /// **'Within budget'**
  String get withinBudget;

  /// No description provided for @excess.
  ///
  /// In en, this message translates to:
  /// **'excess'**
  String get excess;

  /// No description provided for @fromBudget.
  ///
  /// In en, this message translates to:
  /// **'from budget'**
  String get fromBudget;

  /// No description provided for @perProduct.
  ///
  /// In en, this message translates to:
  /// **'Per product'**
  String get perProduct;

  /// No description provided for @mostExpensive.
  ///
  /// In en, this message translates to:
  /// **'Most Expensive'**
  String get mostExpensive;

  /// No description provided for @kacSaatAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Work Hours Analysis'**
  String get kacSaatAnalysis;

  /// No description provided for @budgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'Budget Exceeded!'**
  String get budgetExceeded;

  /// No description provided for @excessSpent.
  ///
  /// In en, this message translates to:
  /// **'excess spent.'**
  String get excessSpent;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noCategoryDataYet.
  ///
  /// In en, this message translates to:
  /// **'No category data yet'**
  String get noCategoryDataYet;

  /// No description provided for @settingsIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Settings Incomplete'**
  String get settingsIncomplete;

  /// No description provided for @completeKacSaatSettings.
  ///
  /// In en, this message translates to:
  /// **'Complete your settings for work hours calculation.'**
  String get completeKacSaatSettings;

  /// No description provided for @hourlyEarnings.
  ///
  /// In en, this message translates to:
  /// **'Your hourly earnings'**
  String get hourlyEarnings;

  /// No description provided for @workDays.
  ///
  /// In en, this message translates to:
  /// **'work days'**
  String get workDays;

  /// No description provided for @completionEstimate.
  ///
  /// In en, this message translates to:
  /// **'Completion Estimate'**
  String get completionEstimate;

  /// No description provided for @veryFast.
  ///
  /// In en, this message translates to:
  /// **'Very Fast'**
  String get veryFast;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @slow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get slow;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @productsPerDay.
  ///
  /// In en, this message translates to:
  /// **'products/day'**
  String get productsPerDay;

  /// No description provided for @estimatedCompletion.
  ///
  /// In en, this message translates to:
  /// **'Estimated Completion'**
  String get estimatedCompletion;

  /// No description provided for @cannotCalculate.
  ///
  /// In en, this message translates to:
  /// **'Cannot calculate'**
  String get cannotCalculate;

  /// No description provided for @mostProducts.
  ///
  /// In en, this message translates to:
  /// **'Most Products'**
  String get mostProducts;

  /// No description provided for @leastProducts.
  ///
  /// In en, this message translates to:
  /// **'Least Products'**
  String get leastProducts;

  /// No description provided for @budgetHealth.
  ///
  /// In en, this message translates to:
  /// **'Budget Health'**
  String get budgetHealth;

  /// No description provided for @beCareful.
  ///
  /// In en, this message translates to:
  /// **'Be Careful'**
  String get beCareful;

  /// No description provided for @healthScore.
  ///
  /// In en, this message translates to:
  /// **'Health Score'**
  String get healthScore;

  /// No description provided for @budgetHealthPerfect.
  ///
  /// In en, this message translates to:
  /// **'You\'re managing your budget perfectly!'**
  String get budgetHealthPerfect;

  /// No description provided for @budgetHealthGood.
  ///
  /// In en, this message translates to:
  /// **'Going well! Keep your spending under control.'**
  String get budgetHealthGood;

  /// No description provided for @budgetHealthBeCareful.
  ///
  /// In en, this message translates to:
  /// **'You\'ve spent most of your budget. Proceed carefully.'**
  String get budgetHealthBeCareful;

  /// No description provided for @budgetHealthRisky.
  ///
  /// In en, this message translates to:
  /// **'Planned spending exceeds budget. Make a plan.'**
  String get budgetHealthRisky;

  /// No description provided for @budgetHealthCritical.
  ///
  /// In en, this message translates to:
  /// **'You\'ve exceeded your budget! Review your spending.'**
  String get budgetHealthCritical;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @remainingBudget.
  ///
  /// In en, this message translates to:
  /// **'Remaining Budget'**
  String get remainingBudget;

  /// No description provided for @plannedTotal.
  ///
  /// In en, this message translates to:
  /// **'Planned Total'**
  String get plannedTotal;

  /// No description provided for @averagePrice.
  ///
  /// In en, this message translates to:
  /// **'Average Price'**
  String get averagePrice;

  /// No description provided for @categoryAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Category Analysis'**
  String get categoryAnalysis;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get average;

  /// No description provided for @budgetAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Budget Analysis'**
  String get budgetAnalysis;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @defaultText.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultText;

  /// No description provided for @completionMessage.
  ///
  /// In en, this message translates to:
  /// **'At your current pace, you can complete your trousseau around ~{date}.'**
  String completionMessage(String date);

  /// No description provided for @totalCategoryCount.
  ///
  /// In en, this message translates to:
  /// **'You have products in {count} different categories.'**
  String totalCategoryCount(int count);

  /// No description provided for @currentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current Version'**
  String get currentVersion;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @photosCount.
  ///
  /// In en, this message translates to:
  /// **'Photos ({current}/{max})'**
  String photosCount(int current, int max);

  /// No description provided for @symbol.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get symbol;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @canEditPermission.
  ///
  /// In en, this message translates to:
  /// **'Has edit permission'**
  String get canEditPermission;

  /// No description provided for @viewOnlyPermission.
  ///
  /// In en, this message translates to:
  /// **'View only'**
  String get viewOnlyPermission;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I accept the terms and conditions and privacy policy'**
  String get acceptTerms;

  /// No description provided for @mustAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms and conditions'**
  String get mustAcceptTerms;

  /// No description provided for @iAccept.
  ///
  /// In en, this message translates to:
  /// **'I accept'**
  String get iAccept;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @emailNotVerifiedMessage.
  ///
  /// In en, this message translates to:
  /// **'You need to verify your email address to log in to your account.'**
  String get emailNotVerifiedMessage;

  /// No description provided for @updateRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Update Required!'**
  String get updateRequiredMessage;

  /// No description provided for @trousseauSlogan.
  ///
  /// In en, this message translates to:
  /// **'Manage your dream trousseau easily'**
  String get trousseauSlogan;

  /// No description provided for @addedBy.
  ///
  /// In en, this message translates to:
  /// **'Added by: {name}'**
  String addedBy(String name);

  /// No description provided for @purchasedLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchasedLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @linksLabel.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get linksLabel;

  /// No description provided for @userDefaultName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userDefaultName;

  /// No description provided for @membershipSince.
  ///
  /// In en, this message translates to:
  /// **'Member since: {date}'**
  String membershipSince(String date);

  /// No description provided for @shareTrousseauInstruction.
  ///
  /// In en, this message translates to:
  /// **'You can share this trousseau with others to manage it together'**
  String get shareTrousseauInstruction;

  /// No description provided for @trousseauListeningFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to listen to trousseaus: {error}'**
  String trousseauListeningFailed(String error);

  /// No description provided for @trousseauLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load trousseaus: {error}'**
  String trousseauLoadFailed(String error);

  /// No description provided for @trousseauCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create trousseau: {error}'**
  String trousseauCreateFailed(String error);

  /// No description provided for @trousseauUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update trousseau: {error}'**
  String trousseauUpdateFailed(String error);

  /// No description provided for @noEditPermission.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to edit this trousseau'**
  String get noEditPermission;

  /// No description provided for @trousseauDeleteFailedPermission.
  ///
  /// In en, this message translates to:
  /// **'Only the trousseau owner can delete it'**
  String get trousseauDeleteFailedPermission;

  /// No description provided for @trousseauDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete trousseau: {error}'**
  String trousseauDeleteFailed(String error);

  /// No description provided for @onlyOwnerCanShare.
  ///
  /// In en, this message translates to:
  /// **'Only the trousseau owner can share it'**
  String get onlyOwnerCanShare;

  /// No description provided for @cannotShareWithSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot share with yourself'**
  String get cannotShareWithSelf;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @invitationAlreadySent.
  ///
  /// In en, this message translates to:
  /// **'An invitation has already been sent to this user'**
  String get invitationAlreadySent;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to share: {error}'**
  String shareFailed(String error);

  /// No description provided for @acceptShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to accept share: {error}'**
  String acceptShareFailed(String error);

  /// No description provided for @declineShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to decline invitation: {error}'**
  String declineShareFailed(String error);

  /// No description provided for @leaveShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to leave sharing: {error}'**
  String leaveShareFailed(String error);

  /// No description provided for @removeShareFailedPermission.
  ///
  /// In en, this message translates to:
  /// **'Only the trousseau owner can remove sharing'**
  String get removeShareFailedPermission;

  /// No description provided for @removeShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove sharing: {error}'**
  String removeShareFailed(String error);

  /// No description provided for @cannotPinOwnTrousseau.
  ///
  /// In en, this message translates to:
  /// **'You cannot add your own trousseau to home (it\'s already visible)'**
  String get cannotPinOwnTrousseau;

  /// No description provided for @addToHomeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to home: {error}'**
  String addToHomeFailed(String error);

  /// No description provided for @removeFromHomeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove from home: {error}'**
  String removeFromHomeFailed(String error);

  /// No description provided for @maxPhotosError.
  ///
  /// In en, this message translates to:
  /// **'You can add up to {max} photos'**
  String maxPhotosError(int max);

  /// No description provided for @productImage.
  ///
  /// In en, this message translates to:
  /// **'Product Image'**
  String get productImage;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchPlaceholder;

  /// No description provided for @risky.
  ///
  /// In en, this message translates to:
  /// **'Risky'**
  String get risky;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @perfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect'**
  String get perfect;

  /// No description provided for @newVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'New Version'**
  String get newVersionLabel;

  /// No description provided for @forceUpdateText.
  ///
  /// In en, this message translates to:
  /// **'This update is required'**
  String get forceUpdateText;

  /// No description provided for @addLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addLabel;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @piecesLabel.
  ///
  /// In en, this message translates to:
  /// **'pcs'**
  String get piecesLabel;

  /// No description provided for @hoursLabel.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hoursLabel;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortBy;

  /// No description provided for @sortPurchasedFirst.
  ///
  /// In en, this message translates to:
  /// **'Purchased First'**
  String get sortPurchasedFirst;

  /// No description provided for @sortNotPurchasedFirst.
  ///
  /// In en, this message translates to:
  /// **'Not Purchased First'**
  String get sortNotPurchasedFirst;

  /// No description provided for @sortPriceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price (High → Low)'**
  String get sortPriceHighToLow;

  /// No description provided for @sortPriceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price (Low → High)'**
  String get sortPriceLowToHigh;

  /// No description provided for @sortNameAZ.
  ///
  /// In en, this message translates to:
  /// **'Name (A → Z)'**
  String get sortNameAZ;

  /// No description provided for @sortNameZA.
  ///
  /// In en, this message translates to:
  /// **'Name (Z → A)'**
  String get sortNameZA;

  /// No description provided for @trousseauManagement.
  ///
  /// In en, this message translates to:
  /// **'Trousseau Management'**
  String get trousseauManagement;

  /// No description provided for @manageTrousseaus.
  ///
  /// In en, this message translates to:
  /// **'Manage Trousseaus'**
  String get manageTrousseaus;

  /// No description provided for @reorderTrousseaus.
  ///
  /// In en, this message translates to:
  /// **'Reorder Trousseaus'**
  String get reorderTrousseaus;

  /// No description provided for @holdAndDragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Hold and drag to reorder'**
  String get holdAndDragToReorder;

  /// No description provided for @orderUpdated.
  ///
  /// In en, this message translates to:
  /// **'Order updated'**
  String get orderUpdated;

  /// No description provided for @sortType.
  ///
  /// In en, this message translates to:
  /// **'Sort Type'**
  String get sortType;

  /// No description provided for @sortTypeManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get sortTypeManual;

  /// No description provided for @sortTypeOldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get sortTypeOldestFirst;

  /// No description provided for @sortTypeNewestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get sortTypeNewestFirst;

  /// No description provided for @sortTypeChanged.
  ///
  /// In en, this message translates to:
  /// **'Sort type changed'**
  String get sortTypeChanged;

  /// No description provided for @noTrousseausYet.
  ///
  /// In en, this message translates to:
  /// **'No trousseaus yet'**
  String get noTrousseausYet;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @shared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get shared;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;
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
