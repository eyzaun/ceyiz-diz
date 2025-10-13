# Firestore App Version Setup

## Firebase Console'dan yapılacaklar:

1. Firebase Console'a git: https://console.firebase.google.com/
2. Projeyi seç: `ceyiz-diz`
3. Sol menüden **Firestore Database** seç
4. **Start collection** tıkla
5. Collection ID: `app_versions`
6. Document ID: `latest`
7. Şu field'ları ekle:

```
version (string): 1.0.5
buildNumber (number): 12
minBuildNumber (number): 1
forceUpdate (boolean): false
updateMessage (string): Uygulamanın yeni bir sürümü mevcut. Daha iyi deneyim için lütfen güncelleyin.
updateUrl (string): https://play.google.com/store/apps/details?id=com.Loncagames.ceyizdiz
lastUpdated (timestamp): [Otomatik]
```

## Yeni versiyon yayınladığında:

`app_versions/latest` dokümanını güncelle:
- `version`: Yeni versiyon numarası (örn: "1.0.6")
- `buildNumber`: pubspec.yaml'daki yeni build number (örn: 13)
- `minBuildNumber`: Minimum desteklenen build (eskiden zorla güncelleme için)
- `forceUpdate`: true yapılırsa "Daha Sonra" butonu gizlenir
- `lastUpdated`: Otomatik güncellenir

## Nasıl çalışır?

1. Kullanıcı uygulamayı açar
2. AuthProvider._checkForUpdates() Firestore'dan son versiyonu çeker
3. Eğer `latestBuildNumber > currentBuildNumber` ise:
   - `_updateAvailable = true` olur
   - HomeScreen bunu görür ve dialog gösterir
4. Kullanıcı "Güncelle" butonuna basarsa Play Store'a yönlendirilir
