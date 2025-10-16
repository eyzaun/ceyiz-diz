/// Design Tokens - Universal Design System
///
/// Bu dosya, uygulamanın tüm tasarım kurallarını içerir.
/// HER EKRAN bu değerleri kullanmalıdır - asla hard-coded değer kullanma.
///
/// Tasarım Prensipleri:
/// 1. JAKOB YASASI: Standart UI pattern'leri kullan
/// 2. FITTS YASASI: Minimum 48dp touch target
/// 3. HICK YASASI: Maksimum 3-5 seçenek göster
/// 4. MILLER YASASI: Bilgiyi 5±2 gruplara böl
/// 5. GESTALT: Görsel hiyerarşi ve gruplama

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SPACING SYSTEM - 8dp Grid
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Gestalt Prensibi: YAKINLIK (Proximity)
/// İlgili öğeler yakın, ilgisiz öğeler uzak olmalı

class AppSpacing {
  AppSpacing._();

  /// İlgili öğeler arası (örn: icon + text)
  static const double xs = 4.0;

  /// Küçük elemanlar arası (örn: chip'ler, butonlar)
  static const double sm = 8.0;

  /// Standart boşluk (en çok kullanılan - card içi, list item'lar)
  static const double md = 16.0;

  /// Grup ayırıcı (örn: form sections)
  static const double lg = 24.0;

  /// Major section ayırıcı
  static const double xl = 32.0;

  /// Ekstra büyük (ekran kenarları, hero sections)
  static const double xxl = 48.0;

  // Padding shortcuts
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  // Horizontal paddings (ekran kenarları için)
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);

  // Screen padding (tüm ekranlarda standart)
  static const EdgeInsets screenPadding = EdgeInsets.all(md);
}

/// ═══════════════════════════════════════════════════════════════════════════
/// TOUCH TARGET SYSTEM - Fitts Yasası
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Fitts Yasası: Büyük ve yakın hedefler daha kolay basılır
/// Material Design: Minimum 48dp x 48dp touch area

class AppDimensions {
  AppDimensions._();

  // BUTTON HEIGHTS (her zaman bu değerler kullanılmalı)

  /// Primary action buttons (Kaydet, Giriş Yap, vb.)
  /// 56dp - Baş parmak için ideal yükseklik
  static const double buttonHeightLarge = 56.0;

  /// Secondary action buttons (İptal, Geri, vb.)
  static const double buttonHeightMedium = 48.0;

  /// Small buttons (chip'ler, inline actions)
  /// Görsel: 32dp ama touch area: 48dp
  static const double buttonHeightSmall = 32.0;

  // BUTTON WIDTHS
  static const double buttonMinWidth = 88.0; // Material minimum
  static const double buttonFullWidth = double.infinity;

  // ICON SIZES

  /// Görsel icon boyutu
  static const double iconSizeSmall = 18.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  /// Dokunma alanı (invisible, sadece hit testing için)
  /// HER ZAMAN minimum 48dp olmalı
  static const double touchTargetSize = 48.0;

  // INPUT FIELD HEIGHTS
  static const double inputHeightMedium = 56.0; // Kolay tıklanabilir
  static const double inputHeightSmall = 48.0;

  // CARD PROPERTIES
  static const double cardMinHeight = 80.0;
  static const double cardImageSize = 64.0; // Product card thumbnails
  static const double cardImageSizeLarge = 120.0; // Detail screens

  // FAB (Floating Action Button)
  static const double fabSize = 56.0;
  static const double fabSizeMini = 48.0;

  // AVATAR
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;

  // BOTTOM NAV
  static const double bottomNavHeight = 72.0; // iOS stil - daha kolay erişim
  static const double bottomNavIconSize = 28.0; // Daha büyük, daha kolay
}

/// ═══════════════════════════════════════════════════════════════════════════
/// BORDER RADIUS - Tutarlı Köşe Yuvarlaklıkları
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Gestalt Prensipi: BENZERLİK (Similarity)
/// Aynı türdeki öğeler aynı border radius'a sahip olmalı

class AppRadius {
  AppRadius._();

  static const double xs = 4.0;  // Tiny elements
  static const double sm = 8.0;  // Chips, small badges
  static const double md = 12.0; // Buttons, inputs
  static const double lg = 16.0; // Cards, large containers
  static const double xl = 24.0; // Dialogs, bottom sheets
  static const double xxl = 32.0; // Hero elements

  // BorderRadius shortcuts
  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXXL = BorderRadius.all(Radius.circular(xxl));

  // Circular (avatars, badges)
  static const BorderRadius circular = BorderRadius.all(Radius.circular(999));
}

/// ═══════════════════════════════════════════════════════════════════════════
/// ELEVATION & SHADOWS - Derinlik Hissi
/// ═══════════════════════════════════════════════════════════════════════════

class AppElevation {
  AppElevation._();

  static const double flat = 0;
  static const double subtle = 1;
  static const double medium = 2;
  static const double raised = 4;
  static const double floating = 6;
  static const double modal = 8;
}

/// ═══════════════════════════════════════════════════════════════════════════
/// ANIMATION DURATIONS - Tutarlı Hareketler
/// ═══════════════════════════════════════════════════════════════════════════

class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration verySlow = Duration(milliseconds: 500);
}

/// ═══════════════════════════════════════════════════════════════════════════
/// ANIMATION CURVES - Doğal Hareketler
/// ═══════════════════════════════════════════════════════════════════════════

class AppCurves {
  AppCurves._();

  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve spring = Curves.elasticOut;
}

/// ═══════════════════════════════════════════════════════════════════════════
/// TYPOGRAPHY SCALE - Tutarlı Metin Boyutları
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Material Design 3 Type Scale kullanıyoruz
/// Fonts: Inter (sans-serif, modern, okunabilir)

class AppTypography {
  AppTypography._();

  // Font Family
  static const String fontFamily = 'Inter';

  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Font Sizes (Type Scale)
  static const double sizeXS = 11.0;
  static const double sizeSM = 12.0;
  static const double sizeBase = 14.0;  // Body text
  static const double sizeMD = 16.0;
  static const double sizeLG = 18.0;
  static const double sizeXL = 20.0;
  static const double size2XL = 24.0;
  static const double size3XL = 28.0;
  static const double size4XL = 32.0;
  static const double size5XL = 36.0;

  // Line Heights (okunabilirlik için)
  static const double lineHeightTight = 1.25;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // Letter Spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
}

/// ═══════════════════════════════════════════════════════════════════════════
/// UI CONSTANTS - Sınırlar ve Kurallar
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Miller Yasası + Hick Yasası için kısıtlamalar

class AppLimits {
  AppLimits._();

  // MILLER YASASI: Maksimum 7±2 öğe
  static const int maxVisibleItems = 5;  // Güvenli üst limit
  static const int maxListItemsBeforePagination = 20;

  // HICK YASASI: Maksimum seçenek sayıları
  static const int maxPrimaryActions = 1;   // Ekranda 1 ana eylem
  static const int maxSecondaryActions = 2; // Ekranda 2 ikincil eylem
  static const int maxBottomNavItems = 4;   // Alt navigasyon max 4 sekme

  // FORM LIMITS
  static const int maxVisibleFormFields = 5; // Daha fazlası için adımlara böl
  static const int maxImagesPerProduct = 5;

  // TEXT LIMITS
  static const int maxTitleLength = 50;
  static const int maxDescriptionLength = 200;
  static const int maxSearchQueryLength = 100;
}

/// ═══════════════════════════════════════════════════════════════════════════
/// BREAKPOINTS - Responsive Design
/// ═══════════════════════════════════════════════════════════════════════════

class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 640;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double widescreen = 1280;

  // Content max widths (web için)
  static const double maxContentWidth = 1200;
  static const double maxFormWidth = 600;
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Z-INDEX LAYERS - Katman Sıralaması
/// ═══════════════════════════════════════════════════════════════════════════

class AppLayers {
  AppLayers._();

  static const int background = 0;
  static const int content = 1;
  static const int card = 2;
  static const int dropdown = 3;
  static const int sticky = 4;
  static const int modal = 5;
  static const int popover = 6;
  static const int tooltip = 7;
  static const int notification = 8;
}

/// ═══════════════════════════════════════════════════════════════════════════
/// HELPER EXTENSIONS
/// ═══════════════════════════════════════════════════════════════════════════

extension ResponsiveExtension on BuildContext {
  /// Ekran genişliğini döndürür
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Ekran yüksekliğini döndürür
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Mobile cihaz mı?
  bool get isMobile => screenWidth < AppBreakpoints.mobile;

  /// Tablet mı?
  bool get isTablet => screenWidth >= AppBreakpoints.mobile &&
                       screenWidth < AppBreakpoints.desktop;

  /// Desktop mı?
  bool get isDesktop => screenWidth >= AppBreakpoints.desktop;

  /// Safe horizontal padding (ekran kenarlarından güvenli mesafe)
  double get safePaddingHorizontal => isMobile ? AppSpacing.md : AppSpacing.lg;
}

extension SpacingExtension on num {
  /// Spacing değerini SizedBox'a çevir (vertical)
  Widget get verticalSpace => SizedBox(height: toDouble());

  /// Spacing değerini SizedBox'a çevir (horizontal)
  Widget get horizontalSpace => SizedBox(width: toDouble());
}
