#!/bin/bash

# Script para gerar SQL do schema Prisma
# Uso: ./scripts/generate-schema-sql.sh

echo "🔄 Gerando SQL do schema Prisma..."

cd "$(dirname "$0")/.." || exit

# Gera SQL do schema atual
npx prisma migrate diff \
  --from-empty \
  --to-schema-datamodel prisma/schema.prisma \
  --script > schema.sql

if [ $? -eq 0 ]; then
  echo "✅ SQL gerado com sucesso em schema.sql"
  echo "📝 Pode executar este arquivo no cPanel PostgreSQL"
else
  echo "❌ Erro ao gerar SQL"
  exit 1
fi

