# DEPLOYMENT (cPanel) — Deploy automático (GitHub Actions) + fallback manual

## Objetivo

Ter **deploy automático** para cPanel sempre que houver push para `main`, sem necessidade de builds manuais.

Se o deploy automático via FTP falhar (rede/firewall), existe um **fallback** via GitHub Releases (ZIPs) para upload manual no cPanel.

Apps cobertas:

- **estafeta**: `apps/courier_app` → `estafeta.ohmyfood.eu`
- **restaurante**: `apps/restaurant_app` → `restaurante.ohmyfood.eu`
- **cliente**: `apps/customer_app` → `ohmyfood.eu`
- **admin**: `apps/admin_panel` → `admin.ohmyfood.eu`

## Melhor abordagem (robusta) para cPanel: Release + Pull via HTTPS

Quando runners do GitHub não conseguem abrir ligação para o cPanel (FTP/FTPS/SFTP bloqueado por firewall/IP allowlist), o método mais robusto é:

- GitHub Actions **builda** e publica ZIPs num **GitHub Release**
- o cPanel faz **pull** do ZIP via HTTPS e faz deploy local (cron/webhook)

Isto evita depender de portas inbound (21/22) e funciona melhor em shared hosting.

### Script de deploy no cPanel (pull do Release)

Foi adicionado ao repo:

- `scripts/cpanel_deploy_from_release.php`

Ele baixa o ZIP do release `web-build-*` (ou um tag específico), extrai, faz swap atómico com backup e mantém só os últimos backups.

### Como usar via CRON (recomendado)

1) Copiar `scripts/cpanel_deploy_from_release.php` para o servidor (pode ficar fora do docroot, ex.: `/home/<user>/deploy/`).

2) Criar 3 tarefas CRON (uma por app), ex.:

```bash
cd /home/<user>/public_html && DEPLOY_TARGET=courier GITHUB_REPO="gabriel-vitalmoveit/ohmyfood" /usr/bin/php scripts/cpanel_deploy_from_release.php
cd /home/<user>/public_html && DEPLOY_TARGET=restaurant GITHUB_REPO="gabriel-vitalmoveit/ohmyfood" /usr/bin/php scripts/cpanel_deploy_from_release.php
cd /home/<user>/public_html && DEPLOY_TARGET=customer GITHUB_REPO="gabriel-vitalmoveit/ohmyfood" /usr/bin/php scripts/cpanel_deploy_from_release.php
cd /home/<user>/public_html && DEPLOY_TARGET=admin GITHUB_REPO="gabriel-vitalmoveit/ohmyfood" /usr/bin/php scripts/cpanel_deploy_from_release.php
```

Se o repo for privado, adicionar `GITHUB_TOKEN="..."` (guardar esse token no servidor, não no repo).

### Como usar via WEBHOOK (opcional)

O workflow suporta chamar um endpoint no cPanel após criar o release, se definires secrets:

- `CPANEL_DEPLOY_WEBHOOK_URL`
- `CPANEL_DEPLOY_WEBHOOK_TOKEN`

O endpoint (no cPanel) deve validar o header `X-Deploy-Token` e executar o script acima (p.ex. chamando `php`).

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
- Tenta deploy para o docroot do cPanel via **SamKirkland/FTP-Deploy-Action** (best-effort; pode falhar por firewall)
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

- **Webhook (opcional)**
  - `CPANEL_DEPLOY_WEBHOOK_URL`
  - `CPANEL_DEPLOY_WEBHOOK_TOKEN`

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


