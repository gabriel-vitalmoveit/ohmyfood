# DEPLOYMENT (cPanel) — Courier App (`estafetas.ohmyfood.eu`)

## Objetivo

Publicar automaticamente o `apps/courier_app` (Flutter Web) no subdomínio **`estafetas.ohmyfood.eu`** via cPanel.

## Problema atual (P0)

O subdomínio **`estafetas.ohmyfood.eu`** não funciona por (no mínimo) um destes motivos:

- **DNS/subdomínio**: o repo e documentação histórica referem **`estafeta.ohmyfood.eu`** (singular) — se o DNS estiver apontado para `estafetas`, não vai servir o docroot correto.
- **Docroot sem build**: no snapshot do repo, `public_html/estafeta.ohmyfood.eu/` tinha apenas `.htaccess` (sem `index.html`, `main.dart.js`, `assets/`, etc.).
- **`.htaccess` incorreto para subdomínio**: para subdomínios com docroot próprio, `RewriteBase` deve ser `/` e a regra deve apontar para `/index.html`.

Neste commit foram adicionados/ajustados:
- `public_html/estafetas.ohmyfood.eu/.htaccess`
- correções em `public_html/estafeta.ohmyfood.eu/.htaccess` e `public_html/restaurante.ohmyfood.eu/.htaccess` (RewriteBase `/`)

## Configuração de ambiente (Flutter web)

O `courier_app` lê variáveis **compile-time** via `--dart-define`:

- `ENV=prod`
- `API_BASE_URL=https://api.ohmyfood.eu` (ou a URL que quiser; o app normaliza para terminar em `/api`)
- `HERE_MAPS_API_KEY=<valor>`

### Importante (HERE key)

Não commitar a key no código. O app faz fallback para rota simples se a key estiver vazia.

## Deploy manual (P1)

### Opção A — Script (recomendado)

1. (Opcional) Editar `apps/courier_app/.env.production` e preencher **apenas** `API_BASE_URL`.  
   **Não** preencher `HERE_MAPS_API_KEY` no git; usar env local.

2. Exportar credenciais (exemplo):

```bash
export CPANEL_HOST="ftp.seu-dominio.com"
export CPANEL_USER="seu_user"
export CPANEL_PASS="*****"
export CPANEL_PROTOCOL="ftp"   # ou ftps / sftp
export CPANEL_PORT="21"
export CPANEL_REMOTE_DIR="/public_html/estafetas.ohmyfood.eu"

export ENV="prod"
export API_BASE_URL="https://api.ohmyfood.eu"
export HERE_MAPS_API_KEY="*****"
```

3. Executar:

```bash
./deploy-courier.sh
```

O script faz build e tenta upload via `lftp` (se existir). Se não tiver `lftp`, ele cria um zip em `dist/` para upload manual.

### Opção B — Upload manual via cPanel File Manager

1. Build local:

```bash
cd apps/courier_app
flutter clean
flutter pub get
flutter build web --release \
  --dart-define=ENV=prod \
  --dart-define=API_BASE_URL=https://api.ohmyfood.eu \
  --dart-define=HERE_MAPS_API_KEY=SEU_VALOR
```

2. No cPanel File Manager, fazer upload de **todo o conteúdo** de `apps/courier_app/build/web/` para o docroot do subdomínio:
- recomendado: `/public_html/estafetas.ohmyfood.eu/`

3. Garantir que existe `.htaccess` com SPA routing (exemplo já no repo):
- `public_html/estafetas.ohmyfood.eu/.htaccess`

## Deploy automático (P2) — GitHub Actions

Foi criado:
- `.github/workflows/deploy-courier.yml`

### Trigger

- `push` para `main` com alterações em `apps/courier_app/**`

### Secrets necessários (GitHub)

- `CPANEL_FTP_SERVER`
- `CPANEL_FTP_USERNAME`
- `CPANEL_FTP_PASSWORD`
- `CPANEL_FTP_PORT` (opcional; default 21)
- `CPANEL_FTP_SERVER_DIR` (ex.: `/public_html/estafetas.ohmyfood.eu/`)

- `COURIER_API_BASE_URL` (ex.: `https://api.ohmyfood.eu`)
- `HERE_MAPS_API_KEY`

## Troubleshooting

### 1) Subdomínio não abre / NXDOMAIN
- DNS do `estafetas.ohmyfood.eu` não existe/está errado.
- Confirmar no cPanel o subdomínio e docroot.

### 2) Abre mas dá página em branco
- Falta `index.html` ou faltam assets (`main.dart.js`, `assets/`, `canvaskit/`).
- Ver Console do browser (F12) e Network tab para 404.

### 3) Rotas dão 404 (ex.: /orders/123)
- `.htaccess` não está correto (SPA routing).

### 4) API falha (401/403)
- Verificar `API_BASE_URL` usado no build.
- Verificar CORS no backend (precisa permitir `https://estafetas.ohmyfood.eu`).

### 5) HERE não funciona
- Confirmar que `HERE_MAPS_API_KEY` foi passado via `--dart-define`.
- Mesmo sem key, o app deve mostrar fallback (rota simples).

