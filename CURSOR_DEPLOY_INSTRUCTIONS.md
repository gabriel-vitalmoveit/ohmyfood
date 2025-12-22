# INSTRUÇÕES PARA O CURSOR AI - ADAPTAÇÃO CPANEL

Adapte este projeto Flutter + NestJS monorepo para funcionar com as seguintes limitações do GoDaddy cPanel:

## CONTEXTO DO AMBIENTE
- Servidor: GoDaddy Shared Hosting cPanel
- Node.js: Versão 14.21.1 (desatualizado)
- PHP: Suporta múltiplas versões
- Banco de dados: MySQL disponível
- SSH: Acesso limitado, não completo
- Deploy: Manual via File Manager ou Git pull

## ESTRATÉGIA HÍBRIDA RECOMENDADA

### BACKEND (NestJS)
**MIGRAR PARA RAILWAY.APP**
- Deploy o backend completo no Railway
- PostgreSQL gratuito incluído
- Node.js moderno suportado
- Variáveis de ambiente seguras
- URL: Será gerada automaticamente (ex: backend-production-xxxx.up.railway.app)

### FRONTEND (Flutter Web)
**MANTER NO CPANEL**
- Compilar Flutter Web localmente: flutter build web
- Upload da pasta build/web/ para /public_html no cPanel
- Configurar .htaccess para SPA routing
- Servir arquivos estáticos HTML/CSS/JS

## PASSOS DE ADAPTAÇÃO

### 1. BACKEND - PREPARAR PARA RAILWAY
```bash
# No diretório backend/
npm install
npm run build

# Criar railway.json na raiz do backend
{
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "npm run start:prod",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

### 2. FRONTEND - ADAPTAR PARA CPANEL
```bash
# No diretório frontend/
flutter pub get
flutter build web --release

# O output estará em: frontend/build/web/
# Fazer upload de TODO conteúdo de build/web/ para /public_html/
```

### 3. CONFIGURAÇÃO .HTACCESS (criar em /public_html/.htaccess)
```apache
RewriteEngine On
RewriteBase /

# Não reescrever se o arquivo existe
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d

# Redirecionar tudo para index.html
RewriteRule ^ index.html [L]

# Headers de segurança
Header set X-Content-Type-Options "nosniff"
Header set X-Frame-Options "SAMEORIGIN"
Header set X-XSS-Protection "1; mode=block"
```

### 4. VARIÁVEIS DE AMBIENTE FRONTEND
**Criar arquivo .env.production no frontend:**
```env
API_BASE_URL=https://seu-backend.up.railway.app/api
ENABLE_ANALYTICS=true
```

**Atualizar código Flutter para usar variável:**
```dart
// Em lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );
}
```

### 5. CORS - BACKEND NESTJS
**Atualizar main.ts do NestJS:**
```typescript
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // CORS para o domínio cPanel
  app.enableCors({
    origin: ['https://ohmyfood.eu', 'http://ohmyfood.eu'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  });
  
  await app.listen(process.env.PORT || 3000);
}
bootstrap();
```

### 6. BANCO DE DADOS
**Opção 1 (Recomendado): PostgreSQL no Railway**
- Criar database PostgreSQL no Railway (free tier)
- Conectar ao backend NestJS via DATABASE_URL

**Opção 2: MySQL no cPanel**
- Criar database via cPanel MySQL Databases
- Adaptar TypeORM do NestJS para MySQL
- Limite: 1GB de armazenamento

## CHECKLIST DE DEPLOY

### Backend Railway
- [ ] Criar conta no Railway.app
- [ ] Conectar repositório GitHub
- [ ] Selecionar pasta /backend
- [ ] Adicionar PostgreSQL database
- [ ] Configurar variáveis de ambiente
- [ ] Deploy automático
- [ ] Copiar URL pública gerada

### Frontend cPanel
- [ ] Compilar: flutter build web --release --dart-define=API_BASE_URL=https://seu-backend.railway.app/api
- [ ] Baixar build/web/ como ZIP
- [ ] Upload para cPanel File Manager em /public_html/
- [ ] Extrair ZIP
- [ ] Criar .htaccess
- [ ] Testar https://ohmyfood.eu

## LIMITAÇÕES CONHECIDAS
- **NO SSR**: cPanel não suporta server-side rendering
- **NO WebSockets persistentes**: Use polling ou HTTP/2
- **NO node_modules**: Apenas arquivos estáticos compilados
- **NO build automático**: CI/CD manual ou via GitHub Actions

## WORKFLOW ATUALIZAÇÃO
1. Desenvolver localmente
2. Commit & push para GitHub main branch
3. Railway: Auto-deploy do backend
4. cPanel: Pull manual via Git ou upload de build/web/

## ALTERNATIVA COMPLETA RAILWAY
Se o cPanel for muito limitante, migrar tudo para Railway:
- Backend: NestJS ✅
- Frontend: Flutter Web servido como static site ✅
- Database: PostgreSQL ✅
- Custom domain: Apontar DNS ohmyfood.eu para Railway

---

**Adaptações necessárias:**
1. Substituir todas as referências localhost:3000 pela URL Railway
2. Remover dependências node incompatíveis (node-gyp, etc)
3. Otimizar assets para shared hosting (comprimir imagens)
4. Testar CORS entre domínios
5. Implementar cache estático no .htaccess
