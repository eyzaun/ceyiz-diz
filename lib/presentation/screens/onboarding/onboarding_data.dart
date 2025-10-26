import 'package:flutter/material.dart';

/// Onboarding Page Data Model
class OnboardingPageData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;
  final List<String> features;

  const OnboardingPageData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
  });
}

/// 8 Sayfalık Onboarding İçeriği
class OnboardingContent {
  static const List<OnboardingPageData> pages = [
    // ═══════════════════════════════════════════════════════════════════
    // SAYFA 1: HOŞ GELDİNİZ
    // ═══════════════════════════════════════════════════════════════════
    OnboardingPageData(
      icon: Icons.waving_hand_outlined,
      iconColor: Color(0xFF6C63FF),
      title: 'Çeyiz Diz\'e Hoş Geldiniz!',
      subtitle: 'Çeyiz hazırlığı artık çok kolay',
      description:
          'Çeyiz hazırlığınızı dijital ortamda yönetin, bütçe takibi yapın ve sevdiklerinizle paylaşın. Her şey artık elinizin altında!',
      features: [
        '📱 Mobil ve Web\'de kullanın',
        '☁️ Verileriniz güvende (Firebase)',
        '🔐 Güvenli giriş (Email veya Google)',
        '🎨 5 farklı tema seçeneği',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════════
    // SAYFA 2: ÇEYİZ OLUŞTURMA
    // ═══════════════════════════════════════════════════════════════════
    OnboardingPageData(
      icon: Icons.inventory_2_outlined,
      iconColor: Color(0xFF2563EB),
      title: 'Çeyiz Listelerinizi Oluşturun',
      subtitle: 'Sınırsız çeyiz, organize yaşam',
      description:
          'İstediğiniz kadar çeyiz listesi oluşturun. Her biri için hedef bütçe belirleyin ve ilerlemenizi takip edin.',
      features: [
        '📝 İsim ve açıklama ekleyin',
        '💰 Hedef bütçe belirleyin',
        '📌 Önemli çeyizleri sabitleyin',
        '♾️ Sınırsız çeyiz oluşturun',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════════
    // SAYFA 3: ÜRÜN EKLEME
    // ═══════════════════════════════════════════════════════════════════
    OnboardingPageData(
      icon: Icons.add_shopping_cart_outlined,
      iconColor: Color(0xFF10B981),
      title: 'Ürünlerinizi Detaylıca Kaydedin',
      subtitle: 'Fotoğraf, fiyat, link - hepsi bir arada',
      description:
          'Mağazada gördüğünüz ürünü hemen fotoğraflayın, fiyatını, linkini ve notlarını ekleyin. Hiçbir detayı kaçırmayın!',
      features: [
        '📸 Her ürüne max 5 fotoğraf',
        '🏷️ Kategori belirleyin (varsayılan + özel)',
        '💵 Fiyat ve adet bilgisi',
        '🔗 3 farklı link kaydedebilirsiniz',
        '📝 Özel notlar ekleyin',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════════
    // SAYFA 4: BÜTÇE TAKİBİ
    // ═══════════════════════════════════════════════════════════════════
    OnboardingPageData(
      icon: Icons.analytics_outlined,
      iconColor: Color(0xFFFFB74D),
      title: 'Bütçenizi Takip Edin',
      subtitle: 'Her kuruşun hesabı sizde',
      description:
          'Toplam harcamanızı, kalan bütçenizi ve kategori bazında dağılımı anlık olarak görün. Bütçe kontrolü hiç bu kadar kolay olmamıştı!',
      features: [
        '📊 Kategori bazında dağılım grafiği',
        '💰 Toplam/harcanan/kalan bütçe',
        '✅ Satın alınan ürünleri işaretleyin',
        '📈 İlerleme yüzdesini görün',
        '📑 Excel\'e aktarın ve paylaşın',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════════
    // SAYFA 5: KAÇ SAAT ÖZELLİĞİ
    // ═══════════════════════════════════════════════════════════════════
    OnboardingPageData(
      icon: Icons.timer_outlined,
      iconColor: Color(0xFFEC4899),
      title: 'Ürünler Kaç Saatlik Çalışmanıza Eşit?',
      subtitle: 'Benzersiz "Kaç Saat" özelliği',
      description:
          'Maaşınızı girin, her ürünün kaç saatlik çalışmanıza denk geldiğini görün. "Bu koltuk 2 gün çalışmama eşit" diyebileceksiniz!',
      features: [
        '⏱️ Saatlik ücretinizi otomatik hesaplayın',
        '📅 Çalışma günlerinizi seçin',
        '💼 3 aylık/yıllık prim ekleyin',
        '🔢 Her üründe otomatik gösterim',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════════
    // SAYFA 6: PAYLAŞIM VE İŞBİRLİĞİ
    // ═══════════════════════════════════════════════════════════════════
    OnboardingPageData(
      icon: Icons.people_outline,
      iconColor: Color(0xFF8B5CF6),
      title: 'Sevdiklerinizle Paylaşın',
      subtitle: 'Ortak çeyiz, ortak mutluluk',
      description:
          'Çeyizinizi email ile paylaşın. Nişanlınız, aileniz veya arkadaşlarınızla birlikte yönetin. 3 farklı yetki seviyesi ile tam kontrol sizde!',
      features: [
        '👥 Email ile çeyiz paylaşımı',
        '🔒 3 yetki seviyesi (Görüntüleme/Düzenleme/Tam)',
        '📧 Davet sistemi (kabul/reddet)',
        '👨‍👩‍👧‍👦 Aile ve arkadaşlarla ortak liste',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════════
    // SAYFA 7: KİŞİSELLEŞTİRME
    // ═══════════════════════════════════════════════════════════════════
    OnboardingPageData(
      icon: Icons.palette_outlined,
      iconColor: Color(0xFFF97316),
      title: 'Uygulamayı Kişiselleştirin',
      subtitle: 'Tarzınızı yansıtın',
      description:
          '5 farklı tema, özel kategoriler ve daha fazlası. Uygulamayı tamamen size göre özelleştirin!',
      features: [
        '🎨 5 farklı tema (Varsayılan, Monokrom, Mor Okyanus...)',
        '🏷️ Kendi kategorilerinizi oluşturun',
        '🌙 Karanlık/açık mod desteği',
        '⚙️ Tüm ayarlar kontrolünüzde',
      ],
    ),

    // ═══════════════════════════════════════════════════════════════════
    // SAYFA 8: HAZIRSINIZ!
    // ═══════════════════════════════════════════════════════════════════
    OnboardingPageData(
      icon: Icons.rocket_launch_outlined,
      iconColor: Color(0xFF14B8A6),
      title: 'Artık Hazırsınız!',
      subtitle: 'Hadi başlayalım',
      description:
          'Tüm özellikleri keşfetmeye başlayın. Unutmayın, çeyiz hazırlığı artık eğlenceli ve organize!',
      features: [
        '✨ Ürün linklerini mutlaka kaydedin',
        '📸 Beğendiğiniz ürünleri hemen fotoğraflayın',
        '✅ Satın aldıklarınızı işaretlemeyi unutmayın',
        '🔔 Düzenli bütçe kontrolü yapın',
        '💡 Kaç Saat özelliğini deneyin!',
      ],
    ),
  ];
}
