library;

/// Kaç Saat Hesaplayıcı Servisi
///
/// Bu servis, kullanıcıların ürün fiyatlarını çalışma saatlerine dönüştürmesini sağlar.
/// Kullanıcı profil ayarlarındaki bilgilere göre hesaplama yapar.

class KacSaatCalculator {
  final double monthlySalary;
  final List<String> workingDays;
  final double dailyHours;
  final bool hasPrim;
  final bool quarterlyPrim;
  final double quarterlyPrimAmount;
  final bool yearlyPrim;
  final double yearlyPrimAmount;

  const KacSaatCalculator({
    required this.monthlySalary,
    required this.workingDays,
    required this.dailyHours,
    this.hasPrim = false,
    this.quarterlyPrim = false,
    this.quarterlyPrimAmount = 0,
    this.yearlyPrim = false,
    this.yearlyPrimAmount = 0,
  });

  /// Efektif aylık geliri hesaplar (prim dahil)
  double get effectiveMonthlyIncome {
    double income = monthlySalary;
    if (hasPrim) {
      if (quarterlyPrim) {
        income += quarterlyPrimAmount / 3;
      }
      if (yearlyPrim) {
        income += yearlyPrimAmount / 12;
      }
    }
    return income;
  }

  /// Haftada seçilen gün sayısından aylık ortalama çalışma günü hesaplar
  double get averageDaysPerMonth {
    return (workingDays.length / 7) * (365.25 / 12);
  }

  /// Aylık toplam çalışma saati
  double get monthlyWorkHours {
    return averageDaysPerMonth * dailyHours;
  }

  /// Saatlik kazanç
  double get hourlyRate {
    if (monthlyWorkHours <= 0) return 0;
    return effectiveMonthlyIncome / monthlyWorkHours;
  }

  /// Belirli bir fiyat için kaç saat çalışılması gerektiğini hesaplar
  double calculateHoursForPrice(double price) {
    if (hourlyRate <= 0) return 0;
    return price / hourlyRate;
  }

  /// Saat ve dakika olarak formatlanmış string döner
  String formatHours(double hours) {
    final totalMinutes = (hours * 60).round();
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '$h saat $m dakika';
  }

  /// Kaç iş günü olduğunu hesaplar
  double calculateWorkingDaysForPrice(double price) {
    if (dailyHours <= 0) return 0;
    final totalHours = calculateHoursForPrice(price);
    return totalHours / dailyHours;
  }

  /// Hesaplamanın geçerli olup olmadığını kontrol eder
  bool get isValid {
    return monthlySalary > 0 &&
        workingDays.isNotEmpty &&
        dailyHours > 0;
  }

  /// Kullanıcı ayarları için bir özet metni döner
  String getSummary(double price) {
    if (!isValid) {
      return 'Kaç Saat hesaplaması için profil ayarlarınızı tamamlayın';
    }

    final hours = calculateHoursForPrice(price);
    final days = calculateWorkingDaysForPrice(price);

    return '${formatHours(hours)} (yaklaşık ${days.toStringAsFixed(1)} iş günü)';
  }
}

/// Kaç Saat ayarları modeli
class KacSaatSettings {
  final bool enabled;
  final double monthlySalary;
  final List<String> workingDays;
  final double dailyHours;
  final bool hasPrim;
  final bool quarterlyPrim;
  final double quarterlyPrimAmount;
  final bool yearlyPrim;
  final double yearlyPrimAmount;

  const KacSaatSettings({
    this.enabled = false,
    this.monthlySalary = 0,
    this.workingDays = const ['pazartesi', 'salı', 'çarşamba', 'perşembe', 'cuma'],
    this.dailyHours = 8,
    this.hasPrim = false,
    this.quarterlyPrim = false,
    this.quarterlyPrimAmount = 0,
    this.yearlyPrim = false,
    this.yearlyPrimAmount = 0,
  });

  factory KacSaatSettings.fromJson(Map<String, dynamic> json) {
    return KacSaatSettings(
      enabled: json['enabled'] ?? false,
      monthlySalary: (json['monthlySalary'] ?? 0).toDouble(),
      workingDays: List<String>.from(json['workingDays'] ?? ['pazartesi', 'salı', 'çarşamba', 'perşembe', 'cuma']),
      dailyHours: (json['dailyHours'] ?? 8).toDouble(),
      hasPrim: json['hasPrim'] ?? false,
      quarterlyPrim: json['quarterlyPrim'] ?? false,
      quarterlyPrimAmount: (json['quarterlyPrimAmount'] ?? 0).toDouble(),
      yearlyPrim: json['yearlyPrim'] ?? false,
      yearlyPrimAmount: (json['yearlyPrimAmount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'monthlySalary': monthlySalary,
      'workingDays': workingDays,
      'dailyHours': dailyHours,
      'hasPrim': hasPrim,
      'quarterlyPrim': quarterlyPrim,
      'quarterlyPrimAmount': quarterlyPrimAmount,
      'yearlyPrim': yearlyPrim,
      'yearlyPrimAmount': yearlyPrimAmount,
    };
  }

  KacSaatSettings copyWith({
    bool? enabled,
    double? monthlySalary,
    List<String>? workingDays,
    double? dailyHours,
    bool? hasPrim,
    bool? quarterlyPrim,
    double? quarterlyPrimAmount,
    bool? yearlyPrim,
    double? yearlyPrimAmount,
  }) {
    return KacSaatSettings(
      enabled: enabled ?? this.enabled,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      workingDays: workingDays ?? this.workingDays,
      dailyHours: dailyHours ?? this.dailyHours,
      hasPrim: hasPrim ?? this.hasPrim,
      quarterlyPrim: quarterlyPrim ?? this.quarterlyPrim,
      quarterlyPrimAmount: quarterlyPrimAmount ?? this.quarterlyPrimAmount,
      yearlyPrim: yearlyPrim ?? this.yearlyPrim,
      yearlyPrimAmount: yearlyPrimAmount ?? this.yearlyPrimAmount,
    );
  }

  /// Bu ayarlardan bir calculator oluşturur
  KacSaatCalculator toCalculator() {
    return KacSaatCalculator(
      monthlySalary: monthlySalary,
      workingDays: workingDays,
      dailyHours: dailyHours,
      hasPrim: hasPrim,
      quarterlyPrim: quarterlyPrim,
      quarterlyPrimAmount: quarterlyPrimAmount,
      yearlyPrim: yearlyPrim,
      yearlyPrimAmount: yearlyPrimAmount,
    );
  }
}
