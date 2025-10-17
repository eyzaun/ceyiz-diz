/// App Button - Tasarım Kurallarına Uyumlu Buton Sistemi
///
/// FITTS YASASI: Her buton minimum 48dp touch area
/// GESTALT (Benzerlik): Aynı türdeki butonlar aynı görünür
/// JAKOB YASASI: Standart Material Design pattern'leri

import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// PRIMARY BUTTON - Ana Eylemler (Kaydet, Giriş Yap, Onayla)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Kullanım: Her ekranda SADECE 1 tane olmalı (Hick Yasası)
/// Örnek: Giriş ekranında "Giriş Yap", Form'da "Kaydet"

class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: AppDimensions.buttonHeightLarge,
      width: isFullWidth ? AppDimensions.buttonFullWidth : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.38),
          elevation: AppElevation.flat,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          // Minimum touch target garanti altında
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightLarge,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppDimensions.iconSizeMedium),
                    AppSpacing.sm.horizontalSpace,
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: AppTypography.sizeMD,
                      fontWeight: AppTypography.semiBold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// SECONDARY BUTTON - İkincil Eylemler (İptal, Geri, vb.)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Kullanım: Ekranda max 2 tane olmalı
/// Görsel olarak primary'den daha az vurgulanmalı

class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;

  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: AppDimensions.buttonHeightMedium,
      width: isFullWidth ? AppDimensions.buttonFullWidth : null,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          backgroundColor: backgroundColor,
          side: BorderSide(
            color: theme.colorScheme.outline,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMedium,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppDimensions.iconSizeMedium),
                    AppSpacing.sm.horizontalSpace,
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: AppTypography.sizeBase,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// TEXT BUTTON - Üçüncül Eylemler (Minimal vurgu)
/// ═══════════════════════════════════════════════════════════════════════════

class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const AppTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        minimumSize: const Size(
          AppDimensions.buttonMinWidth,
          AppDimensions.buttonHeightMedium,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppDimensions.iconSizeMedium),
            AppSpacing.sm.horizontalSpace,
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: AppTypography.sizeBase,
              fontWeight: AppTypography.medium,
            ),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// ICON BUTTON - Icon-Only Butonlar
/// ═══════════════════════════════════════════════════════════════════════════
///
/// FITTS YASASI: Görsel icon 24dp, ama touch area 48x48dp

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color; // Backward compatibility (alias for iconColor)
  final Color? backgroundColor;
  final Color? iconColor;
  final double? iconSize;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      color: iconColor ?? color, // Use iconColor first, fallback to color
      iconSize: iconSize ?? AppDimensions.iconSizeMedium,
      // Touch target garanti
      constraints: const BoxConstraints(
        minWidth: AppDimensions.touchTargetSize,
        minHeight: AppDimensions.touchTargetSize,
      ),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// DANGER BUTTON - Tehlikeli Eylemler (Sil, Çıkış Yap)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Renk: Kırmızı (error color)
/// Kullanım: Confirmation dialog'larda

class AppDangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool isFullWidth;

  const AppDangerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    if (isOutlined) {
      return SizedBox(
        height: AppDimensions.buttonHeightMedium,
        width: isFullWidth ? AppDimensions.buttonFullWidth : null,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: errorColor,
            side: BorderSide(color: errorColor, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusMD,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            minimumSize: const Size(
              AppDimensions.buttonMinWidth,
              AppDimensions.buttonHeightMedium,
            ),
          ),
          child: _buildChild(context, errorColor),
        ),
      );
    }

    return SizedBox(
      height: AppDimensions.buttonHeightMedium,
      width: isFullWidth ? AppDimensions.buttonFullWidth : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: errorColor,
          foregroundColor: theme.colorScheme.onError,
          elevation: AppElevation.flat,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMedium,
          ),
        ),
        child: _buildChild(context, theme.colorScheme.onError),
      ),
    );
  }

  Widget _buildChild(BuildContext context, Color iconColor) {
    if (isLoading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppDimensions.iconSizeMedium),
          AppSpacing.sm.horizontalSpace,
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.sizeBase,
            fontWeight: AppTypography.medium,
          ),
        ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// FAB (Floating Action Button) - Ana Eylem
/// ═══════════════════════════════════════════════════════════════════════════
///
/// FITTS YASASI: Sağ alt köşe - baş parmağın en kolay ulaştığı yer
/// Kullanım: Ekranın primary action'ı (örn: Ürün Ekle)

class AppFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final String? tooltip;

  const AppFAB({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Extended FAB (with label)
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: AppElevation.floating,
        icon: Icon(icon, size: AppDimensions.iconSizeMedium),
        label: Text(
          label!,
          style: TextStyle(
            fontSize: AppTypography.sizeBase,
            fontWeight: AppTypography.semiBold,
          ),
        ),
        tooltip: tooltip,
      );
    }

    // Regular FAB (icon only)
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: AppElevation.floating,
      tooltip: tooltip,
      child: Icon(icon, size: AppDimensions.iconSizeLarge),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// BUTTON GROUP - Yan Yana Butonlar
/// ═══════════════════════════════════════════════════════════════════════════
///
/// GESTALT (Yakınlık): İlgili eylemler gruplanmalı
/// Kullanım: Form'larda "İptal + Kaydet"

class AppButtonGroup extends StatelessWidget {
  final Widget primaryButton;
  final Widget? secondaryButton;
  final MainAxisAlignment alignment;

  const AppButtonGroup({
    super.key,
    required this.primaryButton,
    this.secondaryButton,
    this.alignment = MainAxisAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (secondaryButton != null) ...[
          Flexible(child: secondaryButton!),
          AppSpacing.md.horizontalSpace,
        ],
        Flexible(child: primaryButton),
      ],
    );
  }
}
