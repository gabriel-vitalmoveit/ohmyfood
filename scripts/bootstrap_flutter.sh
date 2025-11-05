#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter &>/dev/null; then
  echo "❌ Flutter SDK não encontrado. Instalação necessária." >&2
  exit 1
fi

echo "🚀 Instalando dependências Flutter para todas as apps..."

for app in apps/*_app; do
  if [ -d "$app" ]; then
    echo "➡️  $app"
    (cd "$app" && flutter pub get)
  fi
done

echo "🚀 Instalando dependências para pacotes partilhados..."
for package in packages/*; do
  if [ -d "$package" ]; then
    echo "➡️  $package"
    (cd "$package" && flutter pub get || dart pub get)
  fi
done

echo "✅ Bootstrap concluído."
