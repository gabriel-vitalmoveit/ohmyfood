# Script para iniciar tudo localmente
Write-Host "🚀 Iniciando OhMyFood Localmente..." -ForegroundColor Green
Write-Host ""

# Verificar se estamos no diretório correto
if (-not (Test-Path "backend\api")) {
    Write-Host "❌ Execute este script da raiz do projeto (ohmyfood/ohmyfood)" -ForegroundColor Red
    exit 1
}

# Verificar PostgreSQL
Write-Host "📋 Verificando PostgreSQL..." -ForegroundColor Yellow
$pgRunning = Get-Service -Name "*postgresql*" -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq "Running" }

if (-not $pgRunning) {
    Write-Host "⚠️  PostgreSQL não está rodando!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Opções:" -ForegroundColor Cyan
    Write-Host "1. Instalar PostgreSQL: https://www.postgresql.org/download/windows/" -ForegroundColor White
    Write-Host "2. Usar Docker: docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=postgres postgres" -ForegroundColor White
    Write-Host "3. Iniciar serviço PostgreSQL manualmente" -ForegroundColor White
    Write-Host ""
    $continue = Read-Host "Deseja continuar mesmo assim? (s/n)"
    if ($continue -ne "s") {
        exit 1
    }
}

# Backend
Write-Host ""
Write-Host "🔧 Configurando Backend..." -ForegroundColor Yellow
Set-Location backend\api

# Verificar .env
if (-not (Test-Path ".env")) {
    Write-Host "📝 Criando arquivo .env..." -ForegroundColor Yellow
    @"
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/ohmyfood
PORT=3000
JWT_ACCESS_SECRET=local-dev-secret-key
JWT_REFRESH_SECRET=local-dev-refresh-secret
CORS_ORIGINS=http://localhost:8080,http://localhost:8081,http://localhost:8082,http://localhost:8083
"@ | Out-File -FilePath .env -Encoding utf8
}

# Instalar dependências
Write-Host "📦 Instalando dependências do backend..." -ForegroundColor Yellow
npm install

# Gerar Prisma Client
Write-Host "🔨 Gerando Prisma Client..." -ForegroundColor Yellow
npx prisma generate

# Tentar executar migrations
Write-Host "🗄️  Executando migrations..." -ForegroundColor Yellow
npx prisma migrate dev --name init 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Erro ao executar migrations. Verifique se o PostgreSQL está rodando." -ForegroundColor Yellow
    Write-Host "   Continuando mesmo assim..." -ForegroundColor Yellow
} else {
    Write-Host "✅ Migrations executadas com sucesso!" -ForegroundColor Green
    
    # Executar seed
    Write-Host "🌱 Populando banco de dados..." -ForegroundColor Yellow
    npm run db:seed
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Banco populado com dados mockados!" -ForegroundColor Green
    }
}

# Iniciar backend em background
Write-Host ""
Write-Host "🚀 Iniciando Backend na porta 3000..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; npm run start:dev" -WindowStyle Minimized

# Voltar para raiz
Set-Location ..\..\..

# Frontend
Write-Host ""
Write-Host "🌐 Iniciando Frontend na porta 8080..." -ForegroundColor Green
Set-Location apps\customer_app

# Verificar se build existe
if (-not (Test-Path "build\web\index.html")) {
    Write-Host "🔨 Build não encontrado. Fazendo build..." -ForegroundColor Yellow
    flutter build web --release --dart-define=API_BASE_URL=http://localhost:3000
}

# Iniciar servidor web
Write-Host ""
Write-Host "✅ Tudo iniciado!" -ForegroundColor Green
Write-Host ""
Write-Host "📍 URLs:" -ForegroundColor Cyan
Write-Host "   Frontend: http://localhost:8080" -ForegroundColor White
Write-Host "   Backend:  http://localhost:3000" -ForegroundColor White
Write-Host "   Swagger:  http://localhost:3000/api/docs" -ForegroundColor White
Write-Host ""
Write-Host "🔑 Credenciais de teste:" -ForegroundColor Cyan
Write-Host "   Cliente:    cliente@ohmyfood.pt / customer123" -ForegroundColor White
Write-Host "   Admin:      admin@ohmyfood.pt / admin123" -ForegroundColor White
Write-Host "   Restaurante: restaurante@ohmyfood.pt / restaurant123" -ForegroundColor White
Write-Host ""

# Servir frontend
Write-Host "🌐 Servindo frontend em http://localhost:8080..." -ForegroundColor Yellow
Write-Host "   Pressione Ctrl+C para parar" -ForegroundColor Gray
Write-Host ""

# Tentar usar Python primeiro, depois Node.js
if (Get-Command python -ErrorAction SilentlyContinue) {
    python -m http.server 8080 --directory build\web
} elseif (Get-Command node -ErrorAction SilentlyContinue) {
    npx http-server -p 8080 -c-1 build\web
} else {
    Write-Host "❌ Python ou Node.js necessário para servir o frontend" -ForegroundColor Red
    Write-Host "   Ou use: flutter run -d chrome --web-port=8080" -ForegroundColor Yellow
}

