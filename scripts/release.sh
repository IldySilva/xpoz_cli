#!/bin/bash

# Script para fazer release manual
# Uso: ./release.sh v1.0.0

set -e

TAG=${1:-$(date +v%Y.%m.%d)}
DIST=dist
APP_NAME=xpoz

echo "🚀 Iniciando release $TAG"

# Verificar se GitHub CLI está instalado
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI não encontrado. Instale com:"
    echo "   macOS: brew install gh"
    echo "   Ubuntu: sudo apt install gh"
    exit 1
fi

# Verificar se está logado
if ! gh auth status &> /dev/null; then
    echo "🔐 Fazendo login no GitHub..."
    gh auth login
fi

# Limpar e fazer builds
echo "🔨 Fazendo builds..."
make clean
make build-all
make checksums

# Verificar se arquivos existem
echo "📋 Verificando arquivos..."
for file in "$DIST/$APP_NAME-linux-amd64" "$DIST/$APP_NAME-linux-arm64" "$DIST/checksums.txt"; do
    if [[ ! -f "$file" ]]; then
        echo "❌ Arquivo não encontrado: $file"
        exit 1
    fi
done

echo "✅ Arquivos encontrados:"
ls -la $DIST/

# Criar release
echo "📦 Criando release $TAG..."

# Verificar se tag já existe
if gh release view "$TAG" &> /dev/null; then
    echo "⚠️  Release $TAG já existe. Atualizando..."
    gh release upload "$TAG" $DIST/* --clobber
else
    echo "🆕 Criando nova release $TAG..."
    gh release create "$TAG" $DIST/* \
        --title "Release $TAG" \
        --notes "Binários multi-plataforma para $APP_NAME $TAG

📦 **Arquivos incluídos:**
- \`$APP_NAME-linux-amd64\` - Linux x86_64
- \`$APP_NAME-linux-arm64\` - Linux ARM64
- \`checksums.txt\` - Hashes SHA256

🔧 **Como usar:**
\`\`\`bash
# Download e instalação rápida (Linux AMD64)
wget https://github.com/\$(gh repo view --json owner,name -q '.owner.login + \"/\" + .name')/releases/download/$TAG/$APP_NAME-linux-amd64
chmod +x $APP_NAME-linux-amd64
sudo mv $APP_NAME-linux-amd64 /usr/local/bin/$APP_NAME
\`\`\`"
fi

echo "🎉 Release $TAG criado com sucesso!"
echo "🔗 Veja em: $(gh release view $TAG --web --json url -q .url 2>/dev/null || echo 'GitHub')"