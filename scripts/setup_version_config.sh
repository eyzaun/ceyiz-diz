#!/bin/bash

# Firebase Web Version Update - Firestore Setup Script
# Bu script Firestore'da gerekli config document'i oluşturur

echo "🔥 Firebase Firestore - Version Config Setup"
echo "=============================================="
echo ""

# Firebase CLI kontrolü
if ! command -v firebase &> /dev/null
then
    echo "❌ Firebase CLI bulunamadı!"
    echo "📦 Kurulum: npm install -g firebase-tools"
    exit 1
fi

echo "✅ Firebase CLI bulundu"
echo ""

# Login kontrolü
echo "🔐 Firebase login kontrol ediliyor..."
firebase projects:list &> /dev/null
if [ $? -ne 0 ]; then
    echo "❌ Firebase'e giriş yapmanız gerekiyor"
    echo "🔑 Komut: firebase login"
    exit 1
fi

echo "✅ Firebase login OK"
echo ""

# Project seçimi
echo "📂 Mevcut project: $(firebase use)"
echo ""

# Firestore document oluşturma
echo "📝 Firestore config document oluşturuluyor..."
echo ""

# pubspec.yaml'dan version oku
VERSION=$(grep "version:" pubspec.yaml | head -1 | cut -d':' -f2 | cut -d'+' -f1 | tr -d ' ')

if [ -z "$VERSION" ]; then
    echo "❌ pubspec.yaml'da version bulunamadı!"
    exit 1
fi

echo "📌 Mevcut versiyon: $VERSION"
echo ""

# Firestore document JSON
cat > /tmp/firebase_version_config.json <<EOF
{
  "version": "$VERSION",
  "forceUpdate": false,
  "message": "Yeni özellikler ve iyileştirmeler! Güncellemek ister misiniz?"
}
EOF

echo "📄 Config document içeriği:"
cat /tmp/firebase_version_config.json
echo ""
echo ""

echo "⚠️  DİKKAT: Bu işlem Firestore'da 'config/app_version' document'ini oluşturacak/güncelleyecek"
echo ""
read -p "Devam etmek istiyor musunuz? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ İşlem iptal edildi"
    exit 1
fi

echo ""
echo "🚀 Firestore document oluşturuluyor..."

# Firebase Firestore REST API kullanarak document oluştur
firebase firestore:delete config/app_version --recursive --force &> /dev/null
firebase firestore:write config/app_version /tmp/firebase_version_config.json

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Başarılı! Firestore config document oluşturuldu"
    echo ""
    echo "📊 Kontrol etmek için:"
    echo "   https://console.firebase.google.com/project/ceyiz-diz/firestore"
    echo ""
    echo "🎯 Şimdi yapmanız gerekenler:"
    echo "   1. flutter build web --release"
    echo "   2. firebase deploy --only hosting"
    echo "   3. Web'de test edin"
    echo ""
else
    echo ""
    echo "❌ Hata oluştu! Manuel olarak oluşturun:"
    echo ""
    echo "   Collection: config"
    echo "   Document ID: app_version"
    echo "   Fields:"
    echo "     - version: \"$VERSION\" (string)"
    echo "     - forceUpdate: false (boolean)"
    echo "     - message: \"Yeni özellikler mevcut!\" (string)"
    echo ""
fi

# Temp file temizle
rm -f /tmp/firebase_version_config.json

echo "✨ İşlem tamamlandı!"
