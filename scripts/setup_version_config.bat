@echo off
REM Firebase Web Version Update - Firestore Setup Script (Windows)
REM Bu script Firestore'da gerekli config document'i oluşturur

echo.
echo ================================
echo Firebase Version Config Setup
echo ================================
echo.

REM Firebase CLI kontrolü
where firebase >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo X Firebase CLI bulunamadi!
    echo Kurulum: npm install -g firebase-tools
    pause
    exit /b 1
)

echo + Firebase CLI bulundu
echo.

REM pubspec.yaml'dan version oku
for /f "tokens=2 delims=: " %%a in ('findstr /r "^version:" pubspec.yaml') do (
    set VERSION_RAW=%%a
)

REM + işaretinden öncesini al
for /f "tokens=1 delims=+" %%a in ("%VERSION_RAW%") do (
    set VERSION=%%a
)

if "%VERSION%"=="" (
    echo X pubspec.yaml'da version bulunamadi!
    pause
    exit /b 1
)

echo Mevcut versiyon: %VERSION%
echo.

echo ============================================
echo FIRESTORE CONFIG DOCUMENT OLUSTURULUYOR
echo ============================================
echo.
echo Collection: app_versions
echo Document ID: latest
echo.
echo Fields:
echo   - version: "%VERSION%" (string)
echo   - buildNumber: 24 (number)
echo   - forceUpdate: false (boolean)
echo   - updateMessage: "Yeni ozellikler mevcut!" (string)
echo   - lastUpdated: timestamp
echo.
echo.

echo MANUEL OLARAK GUNCELLEMEK ICIN:
echo.
echo 1. https://console.firebase.google.com/project/ceyiz-diz/firestore adresine git
echo 2. "app_versions" koleksiyonunu ac
echo 3. "latest" document'ini ac
echo 4. Yukaridaki field'lari guncelle
echo.
echo.

pause

echo.
echo Sonraki adimlar:
echo   1. flutter build web --release
echo   2. firebase deploy --only hosting
echo   3. Web'de test edin (cache temizle)
echo.
echo Islem tamamlandi!
echo.
pause
