# DEPLOYMENT (cPanel) — Deploy automático (GitHub Actions) + fallback manual

## Objetivo

Ter **deploy automático** para cPanel sempre que houver push para `main`, sem necessidade de builds manuais.

Se o deploy automático via FTP falhar (rede/firewall), existe um **fallback** via GitHub Releases (ZIPs) para upload manual no cPanel.

Apps cobertas:

- **estafeta**: `apps/courier_app` → `estafeta.ohmyfood.eu`
- **restaurante**: `apps/restaurant_app` → `restaurante.ohmyfood.eu`
- **cliente**: `apps/customer_app` → `ohmyfood.eu`

## GitHub Actions (deploy automático via cPanel FTP)

Workflow:

- `/.github/workflows/deploy-flutter-apps.yml`

### Quando dispara

Em `push` para `main` quando muda algo em:

- `apps/courier_app/**`
- `apps/restaurant_app/**`
- `apps/customer_app/**`
- `packages/**` (rebuild das apps afetadas por packages partilhados)

### O que ele faz

- Faz `flutter build web --release` (matrix: **courier/restaurant/customer**) com `--dart-define`
- Garante `.htaccess` no `build/web` (SPA routing)
- Faz deploy para o docroot do cPanel via **SamKirkland/FTP-Deploy-Action**
- Gera **3 ZIPs** (cada um já com `.htaccess`) e cria um **GitHub Release** com tag `web-build-YYYYMMDD-HHMMSS`
- Comenta no commit com o link do Release

### Secrets necessários (GitHub)

Configurar em **GitHub → Settings → Secrets and variables → Actions → Secrets**:

- **FTP (cPanel)**
  - `FTP_SERVER`: `ftp.ohmyfood.com`
  - `FTP_USERNAME`: (o user de deploy)
  - `FTP_PASSWORD`: (a password de deploy)
  - `FTP_PORT`: `21` (opcional; default 21)

- **Build (Flutter)**
  - `API_BASE_URL`: `https://api.ohmyfood.eu`
  - `ENV`: `prod`
  - `HERE_MAPS_API_KEY`: (opcional; recomendado para `courier_app`)

> Nota: se `HERE_MAPS_API_KEY` estiver vazio, o courier usa fallback.

## Deploy manual via cPanel File Manager (fallback)

Se o runner não conseguir ligar ao FTP (rede/firewall), usar o workflow de releases como alternativa:

- `/.github/workflows/deploy-apps.yml` (gera ZIPs + GitHub Release) — executar manualmente via `workflow_dispatch`

### 1) Baixar o ZIP do Release

1. Ir a **GitHub → Releases**
2. Abrir o release com tag `web-build-...`
3. Fazer download do ZIP do domínio que quer atualizar:
   - `estafeta.ohmyfood.eu_web_<STAMP>.zip`
   - `restaurante.ohmyfood.eu_web_<STAMP>.zip`
   - `ohmyfood.eu_web_<STAMP>.zip`

### 2) Upload + Extract no docroot correto

No **cPanel → File Manager**, para cada domínio:

- **estafeta.ohmyfood.eu**
  - Upload do ZIP para: `/public_html/estafeta.ohmyfood.eu/`
  - Usar **Extract** dentro dessa pasta

- **restaurante.ohmyfood.eu**
  - Upload do ZIP para: `/public_html/restaurante.ohmyfood.eu/`
  - Usar **Extract** dentro dessa pasta

- **ohmyfood.eu**
  - Upload do ZIP para: `/public_html/ohmyfood.eu/`
  - Usar **Extract** dentro dessa pasta

Recomendação (evitar ficheiros antigos):

- Apagar o conteúdo antigo (ou pelo menos `assets/`, `main.dart.js`, `flutter.js`, `index.html`) **antes** de extrair.

### 3) Verificar SPA routing (.htaccess)

Os ZIPs já incluem `.htaccess` com regras de SPA (redirect para `/index.html`).

### 4) Teste rápido pós-deploy (auth)

- Aceder direto: `/#/login` → deve abrir a tela de login (sem redirecionar para onboarding)
- Aceder direto: `/#/dashboard` (janela anónima) → deve redirecionar para `/#/login`

## Builds locais (opcional)

Para gerar ZIPs localmente (sem GitHub):

- `./deploy-all-flutter.sh` (gera ZIPs em `dist/deploy_<timestamp>/zips/`)


