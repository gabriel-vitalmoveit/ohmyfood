#!/bin/bash

# Script para build das apps Flutter Mobile (Android/iOS)
# Uso: ./scripts/build-mobile.sh [RAILWAY_API_URL] [APP_NAME] [PLATFORM]

set -e

RAILWAY_API_URL=${1:-""}
APP_NAME=${2:-"customer_app"}
PLATFORM=${3:-"android"} # android ou ios

echo "🚀 Building Flutter Mobile App: $APP_NAME for $PLATFORM..."

if [ -z "$RAILWAY_API_URL" ]; then
  echo "⚠️  Aviso: RAILWAY_API_URL não fornecido."
  echo "📝 Usando URL padrão de produção..."
  RAILWAY_API_URL="https://api.ohmyfood.eu"
fi

# Garantir que a URL tem /api
if [[ ! "$RAILWAY_API_URL" == */api ]]; then
  RAILWAY_API_URL="$RAILWAY_API_URL/api"
fi

cd apps/$APP_NAME

echo "🧹 Cleaning..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔨 Building for $PLATFORM..."

if [ "$PLATFORM" == "android" ]; then
  # Build Android APK
  flutter build apk --release \
    --dart-define=ENV=prod \
    --dart-define=API_BASE_URL=$RAILWAY_API_URL
  
  echo "✅ APK build concluído em: apps/$APP_NAME/build/app/outputs/flutter-apk/app-release.apk"
  
elif [ "$PLATFORM" == "ios" ]; then
  # Build iOS
  flutter build ios --release \
    --dart-define=ENV=prod \
    --dart-define=API_BASE_URL=$RAILWAY_API_URL
  
  echo "✅ iOS build concluído em: apps/$APP_NAME/build/ios/"
else
  echo "❌ Plataforma inválida: $PLATFORM. Use 'android' ou 'ios'"
  exit 1
fi

cd ../..

echo "🎉 Build concluído!"

