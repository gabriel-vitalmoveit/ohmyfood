#!/bin/bash

# Script para build das apps Flutter para deploy no cPanel
# Uso: ./scripts/build-for-cpanel.sh [RAILWAY_API_URL]

set -e

RAILWAY_API_URL=${1:-""}

echo "🚀 Building Flutter apps for cPanel deployment..."

if [ -z "$RAILWAY_API_URL" ]; then
  echo "⚠️  Aviso: RAILWAY_API_URL não fornecido. Use: ./scripts/build-for-cpanel.sh https://seu-backend.railway.app"
  echo "📝 Continuando com build sem URL específica..."
fi

# Customer App
echo "📱 Building Customer App..."
cd apps/customer_app
flutter clean
flutter pub get
if [ -n "$RAILWAY_API_URL" ]; then
  # URL da API (NestJS usa prefixo global /api, então o client deve apontar para .../api)
  API_URL=$(echo "$RAILWAY_API_URL" | sed 's|/$||')
  if [[ ! "$API_URL" == */api ]]; then
    API_URL="$API_URL/api"
  fi
  flutter build web --release --dart-define=ENV=prod --dart-define=API_BASE_URL=$API_URL
else
  flutter build web --release --dart-define=ENV=prod
fi
echo "✅ Customer App build concluído em: apps/customer_app/build/web/"
cd ../..

# Restaurant App
echo "🏪 Building Restaurant App..."
cd apps/restaurant_app
flutter clean
flutter pub get
if [ -n "$RAILWAY_API_URL" ]; then
  # URL da API (NestJS usa prefixo global /api, então o client deve apontar para .../api)
  API_URL=$(echo "$RAILWAY_API_URL" | sed 's|/$||')
  if [[ ! "$API_URL" == */api ]]; then
    API_URL="$API_URL/api"
  fi
  flutter build web --release --dart-define=ENV=prod --dart-define=API_BASE_URL=$API_URL
else
  flutter build web --release --dart-define=ENV=prod
fi
echo "✅ Restaurant App build concluído em: apps/restaurant_app/build/web/"
cd ../..

# Admin Panel
echo "👨‍💼 Building Admin Panel..."
cd apps/admin_panel
flutter clean
flutter pub get
if [ -n "$RAILWAY_API_URL" ]; then
  # URL da API (NestJS usa prefixo global /api, então o client deve apontar para .../api)
  API_URL=$(echo "$RAILWAY_API_URL" | sed 's|/$||')
  if [[ ! "$API_URL" == */api ]]; then
    API_URL="$API_URL/api"
  fi
  flutter build web --release --dart-define=ENV=prod --dart-define=API_BASE_URL=$API_URL
else
  flutter build web --release --dart-define=ENV=prod
fi
echo "✅ Admin Panel build concluído em: apps/admin_panel/build/web/"
cd ../..

echo ""
echo "✅ Todos os builds concluídos!"
echo ""
echo "📦 Próximos passos:"
echo "1. Upload do conteúdo de apps/customer_app/build/web/ para /public_html/ no cPanel"
echo "2. Upload do conteúdo de apps/restaurant_app/build/web/ para /public_html/restaurant/ no cPanel"
echo "3. Upload do conteúdo de apps/admin_panel/build/web/ para /public_html/admin/ no cPanel"
echo "4. Copiar public_html/.htaccess para cada pasta no cPanel"

