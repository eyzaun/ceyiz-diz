# 🔥 Firebase Versiyon Kontrolü Kurulum Adımları

## ✅ Kod Tarafı Tamamlandı!

Versiyon kontrolü sistemi kodlanmış durumda. Artık sadece Firebase'de ayarları yapman gerekiyor.

## 📱 Firebase Console Kurulumu

### 1. Firebase Console'a Git
https://console.firebase.google.com/project/ceyiz-diz/firestore

### 2. Firestore Database'i Aç
- Sol menüden **Firestore Database** seç
- "Start collection" butonuna tıkla

### 3. Collection Oluştur
- **Collection ID**: `app_versions`
- **Document ID**: `latest`

### 4. Field'ları Ekle

Aşağıdaki field'ları ekle (Add field butonuyla):

| Field Name | Type | Value |
|------------|------|-------|
| version | string | `1.0.5` |
| buildNumber | number | `12` |
| forceUpdate | boolean | `false` |
| updateMessage | string | `Uygulamanın yeni bir sürümü mevcut. Daha iyi deneyim için lütfen güncelleyin.` |
| updateUrl | string | `https://play.google.com/store/apps/details?id=com.Loncagames.ceyizdiz` |
| lastUpdated | timestamp | (şimdi) |

### 5. Kaydet
"Save" butonuna tıkla.

---

## 🚀 Yeni Versiyon Yayınlama Süreci

### Adım 1: Kodu Güncelle
1. `pubspec.yaml`'da versiyonu artır:
   ```yaml
   version: 1.0.6+13  # version+buildNumber
   ```

2. APK derle:
   ```bash
   flutter build apk --release
   ```

### Adım 2: Google Play'e Yükle
1. Google Play Console'a git
2. Yeni APK'yı yükle
3. Yayınla

### Adım 3: Firebase'i Güncelle
Firestore'da `app_versions/latest` dokümanını güncelle:
- **version**: `"1.0.6"`
- **buildNumber**: `13`
- **lastUpdated**: (otomatik güncellenir)

---

## 🎯 Nasıl Çalışır?

### Normal Güncelleme (forceUpdate: false)
1. Kullanıcı uygulamayı açar
2. Sistem Firestore'dan son versiyonu kontrol eder
3. Eğer yeni versiyon varsa:
   - "Güncelleme Mevcut" dialogu gösterilir
   - Kullanıcı "Daha Sonra" veya "Güncelle" seçebilir
   - "Güncelle" seçerse Play Store açılır

### Zorunlu Güncelleme (forceUpdate: true)
1. Kullanıcı uygulamayı açar
2. "Güncelleme Mevcut" dialogu gösterilir
3. **"Daha Sonra" butonu gizlenir**
4. Dialog geri tuşuyla kapatılamaz
5. Kullanıcı uygulamayı kullanmak için güncellemek zorundadır

---

## 🔧 Örnek Senaryolar

### Senaryo 1: Kritik Güncelleme (Zorunlu)
```
forceUpdate: true
updateMessage: "Kritik bir güvenlik güncellemesi mevcut. Devam etmek için uygulamayı güncellemelisiniz."
```

### Senaryo 2: Özellik Güncellemesi (Opsiyonel)
```
forceUpdate: false
updateMessage: "Yeni kategoriler ve iyileştirmeler eklendi! Güncellemek ister misin?"
```

### Senaryo 3: Hata Düzeltme (Opsiyonel)
```
forceUpdate: false
updateMessage: "Bazı hatalar düzeltildi. Daha stabil deneyim için güncelleyin."
```

---

## 📊 Versiyon Numarası Sistemi

pubspec.yaml formatı: `version: X.Y.Z+BUILD`

- **X**: Major versiyon (büyük değişiklikler)
- **Y**: Minor versiyon (yeni özellikler)
- **Z**: Patch versiyon (hata düzeltmeleri)
- **BUILD**: Build numarası (her yayında artır)

Örnekler:
- `1.0.5+12` → versiyon 1.0.5, build 12
- `1.0.6+13` → versiyon 1.0.6, build 13
- `1.1.0+14` → versiyon 1.1.0, build 14
- `2.0.0+15` → versiyon 2.0.0, build 15

**Önemli**: Kod sadece **buildNumber**'ı karşılaştırır! Version string sadece gösterim içindir.

---

## 🧪 Test Etme

Güncellemeleri test etmek için:

1. Firestore'da `buildNumber`'ı şu anki değerden büyük yap (örn: 999)
2. Uygulamayı kapat ve tekrar aç
3. Dialog gösterilmeli
4. Test sonrası `buildNumber`'ı gerçek değere geri döndür (12)

---

## 🛡️ Güvenlik

Firestore Rules'da `app_versions` collection'ı herkes tarafından okunabilir olmalı:

```javascript
match /app_versions/{document} {
  allow read: if true;
  allow write: if false; // Sadece admin dashboard'dan düzenlenebilir
}
```

---

## ❓ Sorun Giderme

### "Güncelleme dialogu gösterilmiyor"
- Firestore'da `app_versions/latest` dokümanı var mı?
- `buildNumber` şu anki build'den büyük mü?
- Web'de çalıştırıyorsan (kIsWeb), güncelleme kontrolü devre dışıdır

### "Play Store açılmıyor"
- URL'i kontrol et: `https://play.google.com/store/apps/details?id=com.Loncagames.ceyizdiz`
- Package ID doğru mu? (AndroidManifest.xml'de kontrol et)

### "Her açılışta dialog gösteriliyor"
- Bu normaldir! Kullanıcı güncellemediği sürece her açılışta gösterilir
- Kullanıcı güncelledikten sonra gösterilmeyecektir
