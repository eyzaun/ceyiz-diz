@echo off
echo ===================================
echo Ceyiz Diz - Release Build Script
echo ===================================
echo.

echo [1/4] Flutter temizleniyor...
call flutter clean
if %errorlevel% neq 0 goto error

echo.
echo [2/4] Paketler aliniyor...
call flutter pub get
if %errorlevel% neq 0 goto error

echo.
echo [3/4] App Bundle olusturuluyor...
call flutter build appbundle --release
if %errorlevel% neq 0 goto error

echo.
echo [4/4] Mapping dosyasi kontrol ediliyor...
if exist "build\app\outputs\mapping\release\mapping.txt" (
    echo ✓ Mapping dosyasi olusturuldu: build\app\outputs\mapping\release\mapping.txt
) else (
    echo ⚠ Uyari: Mapping dosyasi bulunamadi!
)

echo.
echo ===================================
echo ✓ Build basariyla tamamlandi!
echo ===================================
echo.
echo App Bundle konumu:
echo build\app\outputs\bundle\release\app-release.aab
echo.
echo Mapping dosyasi konumu:
echo build\app\outputs\mapping\release\mapping.txt
echo.
echo Google Play Console'a yukleme:
echo 1. AAB dosyasini yukleyin
echo 2. Mapping dosyasini yukleyin (R8/ProGuard mapping)
echo.
goto end

:error
echo.
echo ===================================
echo ✗ Build sirasinda hata olustu!
echo ===================================
echo.

:end
pause
