#!/usr/bin/env bash
#
# Deploy manual do Courier App (Flutter Web) para cPanel.
#
# Faz:
# - build web (release)
# - gera um ZIP (para upload manual, se quiser)
# - faz upload via FTP/SFTP usando lftp (recomendado) OU mostra instruções
#
# Requisitos locais:
# - flutter no PATH
# - zip
# - (opcional) lftp para upload automático
#
# Uso:
#   ./deploy-courier.sh
#
# Variáveis (env):
#   CPANEL_HOST=...
#   CPANEL_USER=...
#   CPANEL_PASS=...
#   CPANEL_PORT=21
#   CPANEL_PROTOCOL=ftp|ftps|sftp  (default: ftp)
#   CPANEL_REMOTE_DIR=/public_html/estafetas.ohmyfood.eu
#
# Build env (dart-define):
#   ENV=prod
#   API_BASE_URL=https://api.ohmyfood.eu
#   HERE_MAPS_API_KEY=...
#
# Pode também preencher `apps/courier_app/.env.production` (sem segredos no git).
#

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$ROOT_DIR/apps/courier_app"

ENV_FILE="$APP_DIR/.env.production"

load_env_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    return 0
  fi
  # shellcheck disable=SC2162
  while IFS='=' read key value; do
    [[ -z "${key:-}" ]] && continue
    [[ "${key:0:1}" == "#" ]] && continue
    value="${value%\"}"
    value="${value#\"}"
    value="${value%\'}"
    value="${value#\'}"
    export "$key=$value"
  done < "$file"
}

echo "==> Loading env from $ENV_FILE (if present)"
load_env_file "$ENV_FILE"

ENV="${ENV:-prod}"
API_BASE_URL="${API_BASE_URL:-https://api.ohmyfood.eu}"
HERE_MAPS_API_KEY="${HERE_MAPS_API_KEY:-}"

echo "==> Building courier_app (ENV=$ENV, API_BASE_URL=$API_BASE_URL)"

(
  cd "$APP_DIR"
  flutter clean
  flutter pub get

  flutter build web --release \
    --dart-define=ENV="$ENV" \
    --dart-define=API_BASE_URL="$API_BASE_URL" \
    --dart-define=HERE_MAPS_API_KEY="$HERE_MAPS_API_KEY"
)

BUILD_DIR="$APP_DIR/build/web"
if [[ ! -d "$BUILD_DIR" ]]; then
  echo "ERROR: build output not found at $BUILD_DIR"
  exit 1
fi

DIST_DIR="$ROOT_DIR/dist"
mkdir -p "$DIST_DIR"

STAMP="$(date +%Y%m%d_%H%M%S)"
ZIP_PATH="$DIST_DIR/courier_web_$STAMP.zip"

echo "==> Creating ZIP: $ZIP_PATH"
(
  cd "$BUILD_DIR"
  # zip contents (not the folder)
  zip -r "$ZIP_PATH" . >/dev/null
)

echo "==> ZIP ready: $ZIP_PATH"

CPANEL_PROTOCOL="${CPANEL_PROTOCOL:-ftp}"
CPANEL_PORT="${CPANEL_PORT:-21}"
CPANEL_REMOTE_DIR="${CPANEL_REMOTE_DIR:-/public_html/estafetas.ohmyfood.eu}"

if [[ -z "${CPANEL_HOST:-}" || -z "${CPANEL_USER:-}" || -z "${CPANEL_PASS:-}" ]]; then
  echo ""
  echo "==> Upload automático não configurado (faltam CPANEL_HOST/CPANEL_USER/CPANEL_PASS)."
  echo "    Pode fazer upload manual do conteúdo de:"
  echo "    - $BUILD_DIR  (recomendado) ou do ZIP:"
  echo "    - $ZIP_PATH"
  echo ""
  echo "    Destino cPanel esperado: $CPANEL_REMOTE_DIR"
  exit 0
fi

if ! command -v lftp >/dev/null 2>&1; then
  echo ""
  echo "==> lftp não está instalado; não consigo fazer upload automático."
  echo "    Upload manual: extrair e copiar conteúdo de $BUILD_DIR para $CPANEL_REMOTE_DIR"
  echo "    (ou enviar $ZIP_PATH e extrair no File Manager)"
  exit 0
fi

echo "==> Uploading via lftp ($CPANEL_PROTOCOL) to $CPANEL_HOST:$CPANEL_PORT -> $CPANEL_REMOTE_DIR"

LFTP_URL="$CPANEL_PROTOCOL://$CPANEL_HOST:$CPANEL_PORT"

lftp -u "$CPANEL_USER","$CPANEL_PASS" "$LFTP_URL" <<EOF
set ssl:verify-certificate no
set ftp:ssl-allow yes
set net:timeout 10
set net:max-retries 2
set net:reconnect-interval-base 5
mkdir -p "$CPANEL_REMOTE_DIR"
mirror -R --delete --verbose "$BUILD_DIR" "$CPANEL_REMOTE_DIR"
bye
EOF

echo "==> Deploy concluído."

