#!/usr/bin/env bash
#
# Build + package + deploy (FTP) das apps Flutter Web:
# - customer_app  -> ohmyfood.eu (public_html root)
# - restaurant_app -> restaurante (pasta ou subdomínio, configurável)
# - courier_app -> estafeta (pasta ou subdomínio, configurável)
#
# NÃO guarda credenciais no repo. Lê tudo de variáveis de ambiente.
#
# Requisitos:
# - flutter no PATH
# - zip
# - lftp (para upload)
#
# Vars obrigatórias:
#   API_BASE_URL=https://api.ohmyfood.eu
#
# Vars opcionais:
#   ENV=prod
#   FLUTTER_BIN=flutter
#   HERE_MAPS_API_KEY=...   (courier usa; vazio -> fallback)
#
# FTP (obrigatórias para upload):
#   FTP_SERVER=ftp.ohmyfood.com
#   FTP_USER=...
#   FTP_PASS=...
#   FTP_PORT=21
#
# Pastas remotas (defaults) — docroots típicos de cPanel Subdomains:
#   REMOTE_ROOT=/public_html
#   REMOTE_CUSTOMER_DIR=$REMOTE_ROOT
#   REMOTE_RESTAURANT_DIR=$REMOTE_ROOT/restaurante.ohmyfood.eu
#   REMOTE_COURIER_DIR=$REMOTE_ROOT/estafeta.ohmyfood.eu
#

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ENV="${ENV:-prod}"
API_BASE_URL="${API_BASE_URL:-}"
HERE_MAPS_API_KEY="${HERE_MAPS_API_KEY:-}"

if [[ -z "$API_BASE_URL" ]]; then
  echo "ERROR: API_BASE_URL is required (ex.: https://api.ohmyfood.eu)" >&2
  exit 1
fi

if [[ -z "$HERE_MAPS_API_KEY" ]]; then
  echo "WARN: HERE_MAPS_API_KEY não definido; courier app usará fallback de rota simples." >&2
fi

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
if ! command -v "$FLUTTER_BIN" >/dev/null 2>&1; then
  echo "ERROR: flutter not found in PATH (set FLUTTER_BIN or PATH)" >&2
  exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
  echo "ERROR: zip not found" >&2
  exit 1
fi

if ! command -v lftp >/dev/null 2>&1; then
  echo "ERROR: lftp not found (install lftp to enable FTP upload)" >&2
  exit 1
fi

FTP_SERVER="${FTP_SERVER:-}"
FTP_USER="${FTP_USER:-}"
FTP_PASS="${FTP_PASS:-}"
FTP_PORT="${FTP_PORT:-21}"

REMOTE_ROOT="${REMOTE_ROOT:-/public_html}"
REMOTE_CUSTOMER_DIR="${REMOTE_CUSTOMER_DIR:-$REMOTE_ROOT}"
REMOTE_RESTAURANT_DIR="${REMOTE_RESTAURANT_DIR:-$REMOTE_ROOT/restaurante.ohmyfood.eu}"
REMOTE_COURIER_DIR="${REMOTE_COURIER_DIR:-$REMOTE_ROOT/estafeta.ohmyfood.eu}"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT_BASE="$ROOT_DIR/dist/deploy_$STAMP"
UPLOAD_DIR="$OUT_BASE/upload"
ZIPS_DIR="$OUT_BASE/zips"

mkdir -p "$UPLOAD_DIR" "$ZIPS_DIR"

write_htaccess() {
  local target="$1"
  mkdir -p "$target"
  cat > "$target/.htaccess" <<'EOF'
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>

<IfModule mod_expires.c>
  ExpiresActive On
  ExpiresByType text/css "access plus 1 year"
  ExpiresByType application/javascript "access plus 1 year"
  ExpiresByType image/png "access plus 1 year"
  ExpiresByType image/jpg "access plus 1 year"
  ExpiresByType image/jpeg "access plus 1 year"
  ExpiresByType image/gif "access plus 1 year"
  ExpiresByType image/svg+xml "access plus 1 year"
</IfModule>
EOF
}

build_one() {
  local app_name="$1"      # customer_app, restaurant_app, courier_app
  local out_name="$2"      # ohmyfood.eu, restaurante, estafeta

  local app_dir="$ROOT_DIR/apps/$app_name"
  local build_dir="$app_dir/build/web"
  local stage_dir="$UPLOAD_DIR/$out_name"
  local zip_path="$ZIPS_DIR/${out_name}_web_${STAMP}.zip"

  echo "==> Building $app_name"
  (
    cd "$app_dir"
    "$FLUTTER_BIN" clean
    "$FLUTTER_BIN" pub get
    "$FLUTTER_BIN" build web --release \
      --dart-define=ENV="$ENV" \
      --dart-define=API_BASE_URL="$API_BASE_URL" \
      --dart-define=HERE_MAPS_API_KEY="$HERE_MAPS_API_KEY"
  )

  if [[ ! -d "$build_dir" ]]; then
    echo "ERROR: build output missing: $build_dir" >&2
    exit 1
  fi

  echo "==> Staging $out_name"
  rm -rf "$stage_dir"
  mkdir -p "$stage_dir"
  cp -R "$build_dir/"* "$stage_dir/"
  write_htaccess "$stage_dir"

  echo "==> Zipping $out_name -> $(basename "$zip_path")"
  (
    cd "$stage_dir"
    zip -r "$zip_path" . >/dev/null
  )
}

build_one "customer_app" "ohmyfood.eu"
build_one "restaurant_app" "restaurante"
build_one "courier_app" "estafeta"

echo ""
echo "==> Build & packages OK"
echo "    Output: $OUT_BASE"
echo "    Zips:   $ZIPS_DIR"

if [[ -z "$FTP_SERVER" || -z "$FTP_USER" || -z "$FTP_PASS" ]]; then
  echo ""
  echo "==> FTP upload skipped (missing FTP_SERVER/FTP_USER/FTP_PASS)."
  exit 0
fi

echo ""
echo "==> Uploading via FTP to $FTP_SERVER:$FTP_PORT"

# Não imprimir credenciais
lftp -u "$FTP_USER","$FTP_PASS" "ftp://$FTP_SERVER:$FTP_PORT" <<EOF
set ssl:verify-certificate no
set ftp:ssl-allow yes
set net:timeout 15
set net:max-retries 2
set net:reconnect-interval-base 5

mkdir -p "$REMOTE_CUSTOMER_DIR"
mkdir -p "$REMOTE_RESTAURANT_DIR"
mkdir -p "$REMOTE_COURIER_DIR"

mirror -R --delete --verbose "$UPLOAD_DIR/ohmyfood.eu" "$REMOTE_CUSTOMER_DIR"
mirror -R --delete --verbose "$UPLOAD_DIR/restaurante" "$REMOTE_RESTAURANT_DIR"
mirror -R --delete --verbose "$UPLOAD_DIR/estafeta" "$REMOTE_COURIER_DIR"
bye
EOF

echo "==> Deploy concluído."

