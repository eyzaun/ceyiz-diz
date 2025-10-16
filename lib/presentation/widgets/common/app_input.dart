/// App Input - Tutarlı Form Input Bileşenleri
///
/// FITTS YASASI: Minimum 56dp yükseklik (kolay dokunma)
/// MILLER YASASI: Form'ları max 5 alana böl
/// GESTALT: Tüm input'lar aynı stil

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/design_tokens.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// TEXT INPUT - Standart Metin Girişi
/// ═══════════════════════════════════════════════════════════════════════════

class AppTextInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;

  const AppTextInput({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      style: TextStyle(
        fontSize: AppTypography.sizeBase,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,

        // FITTS YASASI: 56dp minimum yükseklik
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),

        // Border styling
        filled: true,
        fillColor: theme.colorScheme.surface.withValues(alpha: 0.6),

        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// PASSWORD INPUT - Şifre Girişi (Görünürlük Toggle ile)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// JAKOB YASASI: Standart "göz" ikonu kullanılır

class AppPasswordInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;

  const AppPasswordInput({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.validator,
    this.onChanged,
    this.textInputAction,
  });

  @override
  State<AppPasswordInput> createState() => _AppPasswordInputState();
}

class _AppPasswordInputState extends State<AppPasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppTextInput(
      label: widget.label ?? 'Şifre',
      hint: widget.hint,
      helperText: widget.helperText,
      errorText: widget.errorText,
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      validator: widget.validator,
      onChanged: widget.onChanged,
      textInputAction: widget.textInputAction,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          size: AppDimensions.iconSizeMedium,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        // FITTS YASASI: 48x48 touch area
        constraints: const BoxConstraints(
          minWidth: AppDimensions.touchTargetSize,
          minHeight: AppDimensions.touchTargetSize,
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// SEARCH INPUT - Arama Girişi
/// ═══════════════════════════════════════════════════════════════════════════

class AppSearchInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const AppSearchInput({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller ?? TextEditingController(),
      builder: (context, value, _) {
        return AppTextInput(
          controller: controller,
          hint: hint ?? 'Ara...',
          onChanged: onChanged,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          prefixIcon: Icon(
            Icons.search,
            size: AppDimensions.iconSizeMedium,
          ),
          suffixIcon: value.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: AppDimensions.iconSizeMedium,
                  ),
                  onPressed: () {
                    controller?.clear();
                    onClear?.call();
                  },
                  constraints: const BoxConstraints(
                    minWidth: AppDimensions.touchTargetSize,
                    minHeight: AppDimensions.touchTargetSize,
                  ),
                )
              : null,
        );
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// DROPDOWN INPUT - Seçim Kutusu
/// ═══════════════════════════════════════════════════════════════════════════

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        filled: true,
        fillColor: theme.colorScheme.surface.withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      icon: Icon(
        Icons.arrow_drop_down,
        size: AppDimensions.iconSizeMedium,
      ),
      style: TextStyle(
        fontSize: AppTypography.sizeBase,
        color: theme.colorScheme.onSurface,
      ),
      dropdownColor: theme.colorScheme.surface,
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// FORM SECTION - Form Bölümü (Miller Yasası)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// MILLER YASASI: Form'ları maksimum 5 alanlık bölümlere ayır
/// GESTALT (Yakınlık): İlgili alanlar gruplanır

class AppFormSection extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget> children;

  const AppFormSection({
    super.key,
    this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: AppTypography.semiBold,
              fontSize: AppTypography.sizeLG,
            ),
          ),
          if (subtitle != null) ...[
            AppSpacing.xs.verticalSpace,
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: AppTypography.sizeSM,
              ),
            ),
          ],
          AppSpacing.md.verticalSpace,
        ],
        ...children.map((child) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: child,
          );
        }),
      ],
    );
  }
}
