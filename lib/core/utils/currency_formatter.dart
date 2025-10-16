import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Para birimi formatı için yardımcı sınıf
class CurrencyFormatter {
  /// Sayıyı Türk Lirası formatına çevirir
  /// Örnek: 1234.56 -> "1.234,56" (ondalık varsa)
  /// Örnek: 1234 -> "1.234" (ondalık yoksa)
  static String format(double value) {
    // Tam sayı mı kontrol et
    if (value == value.toInt()) {
      // Tam sayı - sadece binlik ayırıcı
      final formatter = NumberFormat('#,##0', 'tr_TR');
      return formatter.format(value.toInt()).replaceAll(',', '.');
    } else {
      // Ondalıklı - virgülle göster
      final formatter = NumberFormat('#,##0.##', 'tr_TR');
      return formatter.format(value);
    }
  }

  /// TL sembolü ile birlikte formatlar
  /// Örnek: 1234 -> "₺1.234"
  static String formatWithSymbol(double value) {
    return '₺${format(value)}';
  }

  /// String'i double'a çevirir (Türkçe format'tan)
  /// Örnek: "1.234,56" -> 1234.56
  /// Örnek: "1.234" -> 1234
  static double? parse(String value) {
    if (value.isEmpty) return null;
    
    try {
      // Nokta ve virgülleri temizle
      String cleaned = value
          .replaceAll('₺', '')
          .replaceAll(' ', '')
          .trim();
      
      // Türkçe format: 1.234,56
      if (cleaned.contains(',')) {
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // Sadece nokta var - binlik ayırıcı olarak kaldır
        cleaned = cleaned.replaceAll('.', '');
      }
      
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }
}

/// Para girişi için TextField formatter
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Sadece sayı, nokta ve virgül kabul et
    String text = newValue.text.replaceAll(RegExp(r'[^\d,.]'), '');
    
    // Birden fazla virgül veya nokta varsa düzelt
    if (text.contains(',')) {
      final parts = text.split(',');
      if (parts.length > 2) {
        text = '${parts[0]},${parts.sublist(1).join('')}';
      }
      // Ondalık kısım max 2 basamak
      if (parts.length == 2 && parts[1].length > 2) {
        text = '${parts[0]},${parts[1].substring(0, 2)}';
      }
    }

    // Binlik ayırıcı ekle
    String formatted = _addThousandSeparators(text);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addThousandSeparators(String value) {
    if (value.isEmpty) return value;

    // Virgülü ayır (ondalık kısım)
    final parts = value.split(',');
    String integerPart = parts[0].replaceAll('.', ''); // Mevcut noktaları temizle
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // Tam kısma binlik ayırıcı ekle
    if (integerPart.length > 3) {
      final buffer = StringBuffer();
      int count = 0;
      for (int i = integerPart.length - 1; i >= 0; i--) {
        if (count == 3) {
          buffer.write('.');
          count = 0;
        }
        buffer.write(integerPart[i]);
        count++;
      }
      integerPart = buffer.toString().split('').reversed.join();
    }

    return decimalPart != null ? '$integerPart,$decimalPart' : integerPart;
  }
}
