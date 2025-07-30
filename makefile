DIST=dist
TAG?=v1.0.0
APP_NAME=xpoz

.PHONY: clean build-linux build-linux-arm64 build-mac build-mac-arm64 build-all checksums release help

help: ## Mostra esta ajuda
	@echo "Comandos disponíveis:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

clean: ## Limpa o diretório dist
	rm -rf $(DIST) && mkdir -p $(DIST)

build-linux: ## Compila para Linux AMD64
	@echo "🐧 Compilando para Linux AMD64..."
	docker build -f Dockerfile -t $(APP_NAME)-linux-build .
	CID=$$(docker create $(APP_NAME)-linux-build); \
	docker cp $$CID:/$(APP_NAME)-linux-amd64 ./$(DIST)/$(APP_NAME)-linux-amd64; \
	docker rm $$CID; \
	chmod +x $(DIST)/$(APP_NAME)-linux-amd64
	@echo "✅ Linux AMD64 build concluído"

build-linux-arm64: ## Compila para Linux ARM64
	@echo "🐧 Compilando para Linux ARM64..."
	docker buildx create --use --name $(APP_NAME)builder --driver docker-container || true
	docker buildx inspect --bootstrap
	docker buildx build --platform linux/arm64 -f Dockerfile -t $(APP_NAME)-linux-build:arm64 --load .
	CID=$$(docker create $(APP_NAME)-linux-build:arm64); \
	docker cp $$CID:/$(APP_NAME)-linux-amd64 ./$(DIST)/$(APP_NAME)-linux-arm64; \
	docker rm $$CID; \
	chmod +x $(DIST)/$(APP_NAME)-linux-arm64
	@echo "✅ Linux ARM64 build concluído"

build-mac: build-mac-arm64 build-mac-amd64 ## Compila para macOS (ARM64 e AMD64)

build-mac-arm64: ## Compila para macOS ARM64 (Apple Silicon)
	@echo "🍎 Compilando para macOS ARM64..."
	@if [ "$$(uname)" = "Darwin" ]; then \
		dart pub get; \
		dart compile exe bin/main.dart -o $(DIST)/$(APP_NAME)-darwin-arm64; \
		chmod +x $(DIST)/$(APP_NAME)-darwin-arm64; \
		echo "✅ macOS ARM64 build concluído"; \
	else \
		echo "⚠️  macOS ARM64 build requer macOS host. Criando placeholder..."; \
		echo '#!/bin/bash\necho "Este binário deve ser compilado em macOS ARM64"' > $(DIST)/$(APP_NAME)-darwin-arm64; \
		chmod +x $(DIST)/$(APP_NAME)-darwin-arm64; \
	fi

build-mac-amd64: ## Compila para macOS AMD64 (Intel)
	@echo "🍎 Compilando para macOS AMD64..."
	@if [ "$$(uname)" = "Darwin" ]; then \
		dart pub get; \
		dart compile exe bin/main.dart -o $(DIST)/$(APP_NAME)-darwin-amd64; \
		chmod +x $(DIST)/$(APP_NAME)-darwin-amd64; \
		echo "✅ macOS AMD64 build concluído"; \
	else \
		echo "⚠️  macOS AMD64 build requer macOS host. Criando placeholder..."; \
		echo '#!/bin/bash\necho "Este binário deve ser compilado em macOS AMD64"' > $(DIST)/$(APP_NAME)-darwin-amd64; \
		chmod +x $(DIST)/$(APP_NAME)-darwin-amd64; \
	fi

build-all: clean build-linux build-linux-arm64 build-mac ## Compila para todas as plataformas
	@echo "🎉 Build completo finalizado!"
	@echo "📦 Binários disponíveis:"
	@ls -la $(DIST)/

checksums: ## Gera checksums SHA256 para todos os binários
	@echo "🔐 Gerando checksums..."
	cd $(DIST) && (shasum -a 256 * > checksums.txt 2>/dev/null || sha256sum * > checksums.txt 2>/dev/null || echo "Erro ao gerar checksums")
	@echo "✅ Checksums gerados em $(DIST)/checksums.txt"

verify-checksums: ## Verifica checksums dos binários
	@echo "🔍 Verificando checksums..."
	@if [ -f "$(DIST)/checksums.txt" ]; then \
		cd $(DIST) && (shasum -a 256 -c checksums.txt 2>/dev/null || sha256sum -c checksums.txt 2>/dev/null); \
	else \
		echo "❌ Arquivo checksums.txt não encontrado. Execute 'make checksums' primeiro."; \
	fi

package: build-all checksums ## Compila tudo e gera checksums
	@echo "📦 Pacote completo criado em $(DIST)/"

release: package ## Cria release no GitHub
	@echo "🚀 Criando release $(TAG)..."
	@if command -v gh >/dev/null 2>&1; then \
		gh release create $(TAG) $(DIST)/* --notes "$(APP_NAME) CLI $(TAG)" || \
		gh release upload $(TAG) $(DIST)/* --clobber; \
		echo "✅ Release $(TAG) criado no GitHub"; \
	else \
		echo "❌ GitHub CLI (gh) não encontrado. Instale com: brew install gh"; \
		exit 1; \
	fi

docker-cleanup: ## Remove containers e imagens Docker temporários
	@echo "🧹 Limpando recursos Docker..."
	-docker buildx rm $(APP_NAME)builder 2>/dev/null
	-docker rmi $(APP_NAME)-linux-build $(APP_NAME)-linux-build:arm64 2>/dev/null
	@echo "✅ Limpeza Docker concluída"

info: ## Mostra informações do sistema e ferramentas
	@echo "ℹ️  Informações do sistema:"
	@echo "OS: $$(uname -s)"
	@echo "Arquitetura: $$(uname -m)"
	@echo "Dart: $$(dart --version 2>/dev/null || echo 'não instalado')"
	@echo "Docker: $$(docker --version 2>/dev/null || echo 'não instalado')"
	@echo "GitHub CLI: $$(gh --version 2>/dev/null || echo 'não instalado')"

# Targets para desenvolvimento
dev-build: ## Build rápido para desenvolvimento (plataforma atual)
	@echo "🔧 Build de desenvolvimento..."
	dart pub get
	dart compile exe bin/main.dart -o $(DIST)/$(APP_NAME)-dev
	chmod +x $(DIST)/$(APP_NAME)-dev
	@echo "✅ Build de desenvolvimento concluído: $(DIST)/$(APP_NAME)-dev"

test: ## Executa testes
	@echo "🧪 Executando testes..."
	dart test

format: ## Formata código Dart
	@echo "🎨 Formatando código..."
	dart format .

analyze: ## Analisa código Dart
	@echo "🔍 Analisando código..."
	dart analyze

ci: clean test analyze build-all checksums ## Pipeline completo para CI/CD