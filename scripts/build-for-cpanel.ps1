# Script PowerShell para build das apps Flutter para deploy no cPanel
# Uso: .\scripts\build-for-cpanel.ps1 [RAILWAY_API_URL]

param(
    [string]$RailwayApiUrl = ""
)

Write-Host "🚀 Building Flutter apps for cPanel deployment..." -ForegroundColor Cyan

if ([string]::IsNullOrEmpty($RailwayApiUrl)) {
    Write-Host "⚠️  Aviso: RAILWAY_API_URL não fornecido." -ForegroundColor Yellow
    Write-Host "📝 Continuando com build sem URL específica..." -ForegroundColor Yellow
}

# Customer App
Write-Host "`n📱 Building Customer App..." -ForegroundColor Green
Set-Location apps/customer_app
flutter clean
flutter pub get
if (-not [string]::IsNullOrEmpty($RailwayApiUrl)) {
    # URL da API (NestJS usa prefixo global /api, então o client deve apontar para .../api)
    $apiUrl = $RailwayApiUrl.TrimEnd('/')
    if (-not $apiUrl.EndsWith('/api')) {
        $apiUrl = "$apiUrl/api"
    }
    flutter build web --release --dart-define=ENV=prod --dart-define=API_BASE_URL=$apiUrl
} else {
    flutter build web --release --dart-define=ENV=prod
}
Write-Host "✅ Customer App build concluído em: apps/customer_app/build/web/" -ForegroundColor Green
Set-Location ../..

# Restaurant App
Write-Host "`n🏪 Building Restaurant App..." -ForegroundColor Green
Set-Location apps/restaurant_app
flutter clean
flutter pub get
if (-not [string]::IsNullOrEmpty($RailwayApiUrl)) {
    # URL da API (NestJS usa prefixo global /api, então o client deve apontar para .../api)
    $apiUrl = $RailwayApiUrl.TrimEnd('/')
    if (-not $apiUrl.EndsWith('/api')) {
        $apiUrl = "$apiUrl/api"
    }
    flutter build web --release --dart-define=ENV=prod --dart-define=API_BASE_URL=$apiUrl
} else {
    flutter build web --release --dart-define=ENV=prod
}
Write-Host "✅ Restaurant App build concluído em: apps/restaurant_app/build/web/" -ForegroundColor Green
Set-Location ../..

# Admin Panel
Write-Host "`n👨‍💼 Building Admin Panel..." -ForegroundColor Green
Set-Location apps/admin_panel
flutter clean
flutter pub get
if (-not [string]::IsNullOrEmpty($RailwayApiUrl)) {
    # URL da API (NestJS usa prefixo global /api, então o client deve apontar para .../api)
    $apiUrl = $RailwayApiUrl.TrimEnd('/')
    if (-not $apiUrl.EndsWith('/api')) {
        $apiUrl = "$apiUrl/api"
    }
    flutter build web --release --dart-define=ENV=prod --dart-define=API_BASE_URL=$apiUrl
} else {
    flutter build web --release --dart-define=ENV=prod
}
Write-Host "✅ Admin Panel build concluído em: apps/admin_panel/build/web/" -ForegroundColor Green
Set-Location ../..

Write-Host "`n✅ Todos os builds concluídos!" -ForegroundColor Green
Write-Host "`n📦 Próximos passos:" -ForegroundColor Cyan
Write-Host "1. Upload do conteúdo de apps/customer_app/build/web/ para /public_html/ no cPanel"
Write-Host "2. Upload do conteúdo de apps/restaurant_app/build/web/ para /public_html/restaurant/ no cPanel"
Write-Host "3. Upload do conteúdo de apps/admin_panel/build/web/ para /public_html/admin/ no cPanel"
Write-Host "4. Copiar public_html/.htaccess para cada pasta no cPanel"

