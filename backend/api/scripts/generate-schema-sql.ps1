# Script PowerShell para gerar SQL do schema Prisma
# Uso: .\scripts\generate-schema-sql.ps1

Write-Host "🔄 Gerando SQL do schema Prisma..." -ForegroundColor Cyan

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptPath
Set-Location $projectRoot

# Gera SQL do schema atual
npx prisma migrate diff `
  --from-empty `
  --to-schema-datamodel prisma/schema.prisma `
  --script | Out-File -FilePath schema.sql -Encoding utf8

if ($LASTEXITCODE -eq 0) {
  Write-Host "✅ SQL gerado com sucesso em schema.sql" -ForegroundColor Green
  Write-Host "📝 Pode executar este arquivo no cPanel PostgreSQL" -ForegroundColor Yellow
} else {
  Write-Host "❌ Erro ao gerar SQL" -ForegroundColor Red
  exit 1
}

