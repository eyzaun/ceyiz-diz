# 🔐 Google Sign-In Kurulum Rehberi - DETAYLI

Bu rehber, **Çeyiz Diz** uygulamasında Google Sign-In özelliğini **Android, iOS ve Web** platformlarında aktif hale getirmek için gereken **TÜM ADIMLARI** detaylıca açıklar.

---

## ⚠️ ÖNEMLİ NOTLAR

- ✅ Kod tarafı tamamen hazır
- ⚠️ Firebase Console ayarları **MUTLAKA** yapılmalı
- 📱 Android için **SHA-1 fingerprint** şart
- 🍎 iOS için **URL Schemes** gerekli
- 🌐 Web için **Client ID** eklenmiş olmalı
- ⏱️ Toplam kurulum süresi: ~15-20 dakika

---

## 📋 İçindekiler

1. [Firebase Console - Genel Ayarlar](#1-firebase-console---genel-ayarlar-zorunlu)
2. [Android Konfigürasyonu](#2-android-konfigürasyonu-zorunlu)
3. [iOS Konfigürasyonu](#3-ios-konfigürasyonu-zorunlu)
4. [Web Konfigürasyonu](#4-web-konfigürasyonu-zorunlu)
5. [Test Etme](#5-test-etme)
6. [Sorun Giderme](#6-sorun-giderme)

---

## 1. Firebase Console - Genel Ayarlar (ZORUNLU)

### Adım 1.1: Firebase Console'a Giriş

1. **Tarayıcıda aç:** https://console.firebase.google.com/
2. **Google hesabınızla giriş yapın**
3. **Projenizi seçin:** `ceyiz-diz` (veya proje adınız)

### Adım 1.2: Authentication - Google Provider Etkinleştirme

**TAM YOLCULUK:**

1. **Sol menüden** `Build` sekmesine tıklayın
2. `Authentication` seçeneğini tıklayın
3. **Üstte** `Sign-in method` sekmesine geçin
4. **Native providers** bölümünde `Google` satırını bulun
5. **Google satırına** tıklayın (sağ tarafta kalem ikonu da olabilir)

**Açılan popup'ta:**

6. **Enable** (Etkinleştir) switch'ini **AÇIN** (mavi olmalı)
7. **Project public-facing name** alanı:
   - Otomatik dolu olmalı (örn: "ceyiz-diz")
   - Değilse projenizin adını yazın
8. **Project support email** dropdown'unu açın:
   - Firebase'e kayıtlı email'inizi seçin
   - Örnek: `eyyup.zaferr.unal@gmail.com`
9. **En altta** `Save` (Kaydet) butonuna tıklayın

**✅ Kontrol:** Google provider'ın yanında **yeşil tik** görünmeli.

### Adım 1.3: Authorized Domains (Web için)

Web platformunda çalışması için:

1. **Authentication** → **Settings** → **Authorized domains** sekmesine gidin
2. **Varsayılan domainler** (zaten ekli olmalı):
   - `localhost` ✅
   - `YOUR-PROJECT-ID.firebaseapp.com` ✅
   - `YOUR-PROJECT-ID.web.app` ✅

3. **Kendi domain'iniz varsa** (örn: `ceyizdiz.com`):
   - `Add domain` butonuna tıklayın
   - Domain'i yazın ve ekleyin

---

## 2. Android Konfigürasyonu (ZORUNLU)

Android'de Google Sign-In çalışması için **SHA-1 certificate fingerprint** Firebase'e eklenmelidir.

### Adım 2.1: SHA-1 Fingerprint Alma

#### A) Debug SHA-1 (Geliştirme/Test için)

**Komut Satırında:**

```powershell
# Projenin android klasörüne gidin
cd e:\web_project2\ceyiz_diz\android

# Gradle signing report çalıştırın
.\gradlew signingReport
```

**veya CMD'de:**

```cmd
cd e:\web_project2\ceyiz_diz\android
gradlew signingReport
```

**Çıktıda arayın:**

```
Variant: debug
Config: debug
Store: C:\Users\YOUR_USER\.android\debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:...
SHA1: 12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78
SHA-256: ...
```

**SHA1 satırındaki değeri kopyalayın!** (Örnek: `12:34:56:78:90:AB:CD:EF:...`)

#### B) Release SHA-1 (Üretim/Yayın için)

Eğer `android/key.properties` dosyanız varsa:

**Komut:**

```powershell
# key.properties'de tanımlı keystore path'ini kullanın
keytool -list -v -keystore "E:\web_project2\ceyiz_diz\android\upload-keystore.jks" -alias upload
```

**Şifre sorar:** `key.properties` dosyasındaki `storePassword`'u girin

**Çıktıda arayın:**

```
Certificate fingerprints:
	 SHA1: AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12
	 SHA256: ...
```

**⚠️ ÖNEMLİ:** Hem **debug** hem **release** SHA-1'lerini ekleyin!

### Adım 2.2: Firebase Console'a SHA-1 Ekleme

**TAM YOLCULUK:**

1. **Firebase Console** ana sayfasında
2. **Sol üst köşede** ⚙️ (Settings) ikonuna tıklayın
3. **Project settings** seçeneğini tıklayın
4. **Your apps** bölümüne inin
5. **Android uygulamanızı** bulun:
   - Package name: `com.Loncagames.ceyizdiz` olmalı
   - Yoksa `Add app` → `Android` ile ekleyin

6. **Android app kartında** en altta `Add fingerprint` butonu var
7. **Butona tıklayın**
8. **SHA certificate fingerprints** alanına:
   - Debug SHA-1'i yapıştırın
   - `Save` butonuna tıklayın

9. **Tekrar** `Add fingerprint` yapın:
   - Release SHA-1'i yapıştırın
   - `Save` butonuna tıklayın

**✅ Kontrol:** Android app kartında **2 fingerprint** görünmeli (debug + release).

### Adım 2.3: google-services.json Güncelleme

SHA-1 ekledikten sonra dosyayı yenileyin:

1. **Firebase Console** → **Project settings** → **Your apps** → **Android**
2. En altta `google-services.json` butonu var
3. **İndir** butonuna tıklayın
4. **İndirilen dosyayı:**
   ```
   e:\web_project2\ceyiz_diz\android\app\google-services.json
   ```
   **Bu yola kopyalayın** (eski dosyanın üzerine yazın)

5. **Dosyayı açın ve kontrol edin:**
   ```json
   {
     "project_info": {
       "project_number": "...",
       "project_id": "ceyiz-diz"
     },
     "client": [
       {
         "client_info": {
           "mobilesdk_app_id": "...",
           "android_client_info": {
             "package_name": "com.Loncagames.ceyizdiz"
           }
         },
         "oauth_client": [
           {
             "client_id": "...-...apps.googleusercontent.com", // BU OLMALI!
             "client_type": 3
           }
         ]
       }
     ]
   }
   ```

**✅ `oauth_client` array'inin dolu olması ZORUNLU!**

---

## 3. iOS Konfigürasyonu (ZORUNLU)

iOS'ta da Google Sign-In için ayar gerekli.

### Adım 3.1: Firebase'e iOS App Ekleme

1. **Firebase Console** → **Project settings** → **Your apps**
2. **iOS app yoksa** `Add app` → `iOS` seçin
3. **Apple bundle ID:** `com.Loncagames.ceyizdiz`
4. **App nickname:** `Çeyiz Diz iOS` (opsiyonel)
5. **App Store ID:** Boş bırakın (henüz yok)
6. **Register app** butonuna tıklayın

### Adım 3.2: GoogleService-Info.plist İndirme

1. **Download GoogleService-Info.plist** butonuna tıklayın
2. Dosyayı indirin
3. **Şu yola kopyalayın:**
   ```
   e:\web_project2\ceyiz_diz\ios\Runner\GoogleService-Info.plist
   ```

### Adım 3.3: URL Schemes Ekleme (KRİTİK!)

**A) REVERSED_CLIENT_ID Bulma:**

1. `ios/Runner/GoogleService-Info.plist` dosyasını **metin editörüyle** açın
2. **Arayın:** `REVERSED_CLIENT_ID` anahtarını bulun
3. **Değeri kopyalayın:**
   ```xml
   <key>REVERSED_CLIENT_ID</key>
   <string>com.googleusercontent.apps.123456789-xxxxxxx</string>
   ```
   **Kopyala:** `com.googleusercontent.apps.123456789-xxxxxxx`

**B) Xcode'da URL Scheme Ekleme:**

**Yöntem 1: Xcode ile (Önerilen)**

1. **Xcode'u açın:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Sol panelde** `Runner` projesini seçin
3. **TARGETS** altında `Runner`'ı seçin
4. **Info** sekmesine gidin
5. **URL Types** bölümünü bulun (en altta olabilir)
6. **`+` butonuna** tıklayın (sol alt köşede)
7. **URL Schemes** alanına:
   - Kopyaladığınız `REVERSED_CLIENT_ID`'yi yapıştırın
   - Örnek: `com.googleusercontent.apps.123456789-xxxxxxx`
8. **Identifier:** `google` yazın (opsiyonel)
9. **File → Save** (Cmd+S)

**Yöntem 2: Manuel (Info.plist düzenleme)**

1. `ios/Runner/Info.plist` dosyasını açın
2. **`</dict>` satırından ÖNCE** ekleyin:

```xml
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<string>com.googleusercontent.apps.123456789-xxxxxxx</string>
		</array>
	</dict>
</array>
```

**⚠️ DİKKAT:** `123456789-xxxxxxx` kısmını **kendi REVERSED_CLIENT_ID**'nizle değiştirin!

---

## 4. Web Konfigürasyonu (ZORUNLU)

Web'de Google Sign-In için Client ID gerekli.

### Adım 4.1: Web Client ID Bulma

1. **Firebase Console** → **Project settings** → **Your apps**
2. **Web app yoksa:**
   - `Add app` → `Web` seçin
   - App nickname: `Çeyiz Diz Web`
   - Firebase Hosting: ✅ (opsiyonel)
   - **Register app**

3. **Web app kartında:**
   - `Web client ID` satırını bulun
   - **Kopyalayın:**
     ```
     123456789-abcdefghijklmnop.apps.googleusercontent.com
     ```

### Adım 4.2: index.html Güncelleme

**Dosya yolu:** `e:\web_project2\ceyiz_diz\web\index.html`

**Açın ve `<head>` bölümüne ekleyin:**

```html
<!DOCTYPE html>
<html>
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Çeyiz yönetim uygulaması">
  
  <!-- ✅ BURAYA EKLE -->
  <meta name="google-signin-client_id" content="123456789-abcdefghijklmnop.apps.googleusercontent.com">
  
  <meta name="apple-mobile-web-app-capable" content="yes">
  ...
</head>
```

**⚠️ DİKKAT:** `123456789-abcdefghijklmnop.apps.googleusercontent.com` kısmını **kendi Web Client ID**'nizle değiştirin!

---

## 5. Test Etme

### 5.1 Android Test

**Build ve Çalıştırma:**

```powershell
# Temiz build
flutter clean
flutter pub get

# Android'de çalıştır
flutter run -d <device_id>

# veya emulator varsa
flutter run
```

**Test Senaryosu:**

1. Uygulama açıldığında **Login Screen** görünmeli
2. **"Google ile Giriş Yap"** butonuna tıklayın
3. **Google hesap seçme ekranı** açılmalı
4. Hesabınızı seçin
5. **İzin ekranı** gelirse `Allow` deyin
6. **Ana ekrana** yönlendirilmelisiniz

**✅ Başarılı ise:**
- Ana ekran yüklendi
- Firebase Console → Authentication → Users'ta kullanıcı görünüyor
- Provider: `google.com`

### 5.2 iOS Test

**Build ve Çalıştırma:**

```bash
# iOS simulator çalıştır
flutter run -d ios

# veya gerçek cihaz
flutter run -d <iphone_id>
```

**⚠️ DİKKAT:** iOS Simulator'da Google Sign-In tam çalışmayabilir. **Gerçek cihazda** test edin!

### 5.3 Web Test

**Çalıştırma:**

```powershell
# Web sunucusu başlat
flutter run -d chrome

# veya production build
flutter build web
```

**Test:**

1. Tarayıcıda `localhost:xxxx` açılır
2. Login ekranında **Google ile Giriş Yap** butonuna tıklayın
3. Google OAuth popup açılmalı
4. Hesap seçin ve izin verin

**⚠️ CORS Hatası alırsanız:**
- Firebase Console → Authentication → Settings → Authorized domains'de `localhost` olmalı

---

## 6. Sorun Giderme

### ❌ Android: "PlatformException (sign_in_failed, 10)"

**Sebep:** SHA-1 fingerprint eksik veya yanlış

**Çözüm:**

1. SHA-1'i tekrar alın:
   ```powershell
   cd android
   .\gradlew signingReport
   ```

2. Firebase Console → Project Settings → Android app → Add fingerprint
3. SHA-1'i ekleyin
4. **Mutlaka** `google-services.json` dosyasını yeniden indirin!
5. `android/app/google-services.json` dosyasını güncelleyin
6. Uygulamayı temiz build edin:
   ```powershell
   flutter clean
   flutter run
   ```

---

### ❌ Android: "Developer Error" / "API Console'da yanlış yapılandırılmış"

**Sebep:** `google-services.json` güncel değil veya `oauth_client` eksik

**Çözüm:**

1. Firebase Console → Project Settings → Android app
2. SHA-1 fingerprint'lerin **ekli olduğunu** kontrol edin (en az 1 tane)
3. **Yeni** `google-services.json` indirin
4. `android/app/google-services.json` dosyasını **değiştirin**
5. Dosyayı açın ve şunu kontrol edin:
   ```json
   "oauth_client": [
     {
       "client_id": "...-....apps.googleusercontent.com",
       "client_type": 3
     }
   ]
   ```
   **Bu bölüm OLMALI!**

6. Clean build:
   ```powershell
   flutter clean
   flutter run
   ```

---

### ❌ iOS: "No valid identity found" / Signing hatası

**Sebep:** Apple Developer hesabı veya code signing eksik

**Çözüm:**

1. Xcode'u açın:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Runner** → **Signing & Capabilities**
3. **Team** dropdown'unda Apple Developer hesabınızı seçin
4. **Bundle Identifier:** `com.Loncagames.ceyizdiz` olmalı

---

### ❌ iOS: Google Sign-In popup açılmıyor

**Sebep:** URL Schemes eksik veya yanlış

**Çözüm:**

1. `ios/Runner/GoogleService-Info.plist` dosyasını açın
2. `REVERSED_CLIENT_ID` değerini bulun ve kopyalayın
3. `ios/Runner/Info.plist` dosyasını açın
4. `CFBundleURLSchemes` array'inde bu değerin olduğunu kontrol edin:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.123456789-xxxxxxx</string>
       </array>
     </dict>
   </array>
   ```

---

### ❌ Web: "redirect_uri_mismatch" hatası

**Sebep:** Authorized domain eksik

**Çözüm:**

1. Firebase Console → Authentication → Settings → Authorized domains
2. **localhost** ekli mi kontrol edin
3. Yoksa **Add domain** ile ekleyin
4. Tarayıcıyı yenileyin

---

### ❌ Web: "popup_closed_by_user"

**Sebep:** Kullanıcı popup'ı kapatmış (normal davranış)

**Çözüm:** Tekrar "Google ile Giriş Yap" butonuna tıklayın

---

### ❌ "account-exists-with-different-credential"

**Sebep:** Kullanıcı daha önce email/password ile kayıt olmuş

**Firebase Ayarı:**

1. Firebase Console → Authentication → Settings
2. **User account management** bölümüne gidin
3. **Advanced** altında:
   - **One account per email address** seçili olmalı ✅
   - **Prevent creation of multiple accounts** açık olmalı ✅

**Kullanıcı Çözümü:**

1. Email/password ile giriş yap
2. Settings'te "Link Google Account" özelliği eklenebilir (ileri seviye)

---

### ❌ "API not enabled" hatası

**Sebep:** Google Cloud Console'da API kapalı

**Çözüm:**

1. https://console.cloud.google.com/ adresine gidin
2. Firebase projenizi seçin (üst dropdown)
3. **APIs & Services** → **Library**
4. **"Google Sign-In"** veya **"Google+ API"** araması yapın
5. **Enable** butonuna tıklayın

---

## 📝 Final Kontrol Listesi

### ✅ Firebase Console

- [ ] Authentication → Google Provider **Enabled**
- [ ] Project support email seçilmiş
- [ ] Authorized domains (localhost, firebaseapp.com) ekli

### ✅ Android

- [ ] Debug SHA-1 eklendi
- [ ] Release SHA-1 eklendi (varsa)
- [ ] `google-services.json` güncel
- [ ] `oauth_client` array'i dolu

### ✅ iOS

- [ ] iOS app Firebase'e eklendi
- [ ] `GoogleService-Info.plist` indirildi
- [ ] `REVERSED_CLIENT_ID` URL Schemes'e eklendi
- [ ] Bundle ID doğru: `com.Loncagames.ceyizdiz`

### ✅ Web

- [ ] Web app Firebase'e eklendi
- [ ] Web Client ID kopyalandı
- [ ] `web/index.html`'e `<meta name="google-signin-client_id">` eklendi
- [ ] Authorized domains `localhost` içeriyor

### ✅ Kod

- [ ] `pubspec.yaml`: `google_sign_in: ^6.3.0` ✅ (zaten ekli)
- [ ] `flutter pub get` çalıştırıldı ✅
- [ ] `flutter analyze` hatasız ✅

---

## 🎯 Platform Desteği Özeti

| Platform | Durum | Gereksinimler |
|----------|-------|---------------|
| **Android** | ✅ TAM HAZIR | SHA-1 + google-services.json |
| **iOS** | ✅ TAM HAZIR | URL Schemes + GoogleService-Info.plist |
| **Web** | ✅ TAM HAZIR | Client ID + index.html |

**Kod tarafı 3 platform için de hazır!** Sadece Firebase Console ayarlarını tamamlayın.

---

## � Yardım

**Hala sorun mu yaşıyorsunuz?**

1. **Flutter Doctor çalıştırın:**
   ```powershell
   flutter doctor -v
   ```

2. **Build klasörünü temizleyin:**
   ```powershell
   flutter clean
   flutter pub get
   ```

3. **Log'ları kontrol edin:**
   ```powershell
   flutter run --verbose
   ```

4. **Firebase Console → Authentication → Users** bölümünde kullanıcı oluşturuldu mu kontrol edin

---

**Son Güncelleme:** 2025-10-19  
**Proje:** Çeyiz Diz v1.0.17+24  
**Geliştirici:** eyzaun

**⭐ Başarılı kurulum sonrası lütfen bu dosyayı güncel tutun!**

