# Script PowerShell para build das apps Flutter Mobile (Android/iOS)
# Uso: .\scripts\build-mobile.ps1 [RAILWAY_API_URL] [APP_NAME] [PLATFORM]

param(
    [string]$RailwayApiUrl = "",
    [string]$AppName = "customer_app",
    [string]$Platform = "android" # android ou ios
)

Write-Host "🚀 Building Flutter Mobile App: $AppName for $Platform..." -ForegroundColor Cyan

if ([string]::IsNullOrEmpty($RailwayApiUrl)) {
    Write-Host "⚠️  Aviso: RAILWAY_API_URL não fornecido." -ForegroundColor Yellow
    Write-Host "📝 Usando URL padrão de produção..." -ForegroundColor Yellow
    $RailwayApiUrl = "https://api.ohmyfood.eu"
}

# Garantir que a URL tem /api
if (-not $RailwayApiUrl.EndsWith("/api")) {
    $RailwayApiUrl = "$RailwayApiUrl/api"
}

Set-Location "apps/$AppName"

Write-Host "🧹 Cleaning..." -ForegroundColor Yellow
flutter clean

Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "🔨 Building for $Platform..." -ForegroundColor Green

if ($Platform -eq "android") {
    # Build Android APK
    flutter build apk --release `
        --dart-define=ENV=prod `
        --dart-define=API_BASE_URL=$RailwayApiUrl
    
    Write-Host "✅ APK build concluído em: apps/$AppName/build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Green
    
} elseif ($Platform -eq "ios") {
    # Build iOS
    flutter build ios --release `
        --dart-define=ENV=prod `
        --dart-define=API_BASE_URL=$RailwayApiUrl
    
    Write-Host "✅ iOS build concluído em: apps/$AppName/build/ios/" -ForegroundColor Green
} else {
    Write-Host "❌ Plataforma inválida: $Platform. Use 'android' ou 'ios'" -ForegroundColor Red
    exit 1
}

Set-Location ../..

Write-Host "🎉 Build concluído!" -ForegroundColor Green

