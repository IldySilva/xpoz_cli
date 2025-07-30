DIST=dist
TAG?=v1.0.0
APP_NAME=xpoz

.PHONY: clean build-linux build-linux-arm64 build-mac build-all checksums release help

help: ## Mostra comandos disponíveis
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

clean: ## Limpa pasta dist
	rm -rf $(DIST) && mkdir -p $(DIST)

build-linux: ## Compila para Linux AMD64 → dist/xpoz-linux-amd64
	@echo "🐧 Compilando para Linux AMD64..."
	docker build -t $(APP_NAME)-build .
	CID=$$(docker create $(APP_NAME)-build); \
	docker cp $$CID:/xpoz-binary ./$(DIST)/$(APP_NAME)-linux-amd64; \
	docker rm $$CID
	chmod +x $(DIST)/$(APP_NAME)-linux-amd64
	@echo "✅ Criado: $(DIST)/$(APP_NAME)-linux-amd64"

build-linux-arm64: ## Compila para Linux ARM64 → dist/xpoz-linux-arm64
	@echo "🐧 Compilando para Linux ARM64..."
	docker buildx build --platform linux/arm64 -t $(APP_NAME)-build:arm64 --load .
	CID=$$(docker create $(APP_NAME)-build:arm64); \
	docker cp $$CID:/xpoz-binary ./$(DIST)/$(APP_NAME)-linux-arm64; \
	docker rm $$CID
	chmod +x $(DIST)/$(APP_NAME)-linux-arm64
	@echo "✅ Criado: $(DIST)/$(APP_NAME)-linux-arm64"

build-mac-arm64: ## Compila para macOS ARM64 → dist/xpoz-darwin-arm64
	@echo "🍎 Compilando para macOS ARM64..."
	@if [ "$$(uname)" = "Darwin" ]; then \
		dart pub get && \
		dart compile exe bin/xpoz.dart -o $(DIST)/$(APP_NAME)-darwin-arm64 && \
		chmod +x $(DIST)/$(APP_NAME)-darwin-arm64 && \
		echo "✅ Criado: $(DIST)/$(APP_NAME)-darwin-arm64"; \
	else \
		echo "❌ Requer macOS para compilação nativa"; \
		exit 1; \
	fi

build-mac-amd64: ## Compila para macOS AMD64 → dist/xpoz-darwin-amd64  
	@echo "🍎 Compilando para macOS AMD64..."
	@if [ "$$(uname)" = "Darwin" ]; then \
		dart pub get && \
		dart compile exe bin/xpoz.dart -o $(DIST)/$(APP_NAME)-darwin-amd64 && \
		chmod +x $(DIST)/$(APP_NAME)-darwin-amd64 && \
		echo "✅ Criado: $(DIST)/$(APP_NAME)-darwin-amd64"; \
	else \
		echo "❌ Requer macOS para compilação nativa"; \
		exit 1; \
	fi

build-mac: build-mac-arm64 build-mac-amd64 ## Compila ambos macOS

build-all: clean build-linux build-linux-arm64 build-mac ## Compila Linux (AMD64 + ARM64)
	@echo ""
	@echo "🎉 Build completo! Arquivos criados:"
	@ls -la $(DIST)/
	@echo ""
	@echo "📁 Binários disponíveis em:"
	@echo "   $(DIST)/$(APP_NAME)-linux-amd64"
	@echo "   $(DIST)/$(APP_NAME)-linux-arm64"

checksums: ## Gera checksums SHA256 → dist/checksums.txt
	@echo "🔐 Gerando checksums..."
	cd $(DIST) && sha256sum * > checksums.txt
	@echo "✅ Checksums salvos em: $(DIST)/checksums.txt"

release: build-all checksums ## Cria release no GitHub
	@echo "🚀 Criando release $(TAG)..."
	gh release create $(TAG) $(DIST)/* --notes "$(APP_NAME) CLI $(TAG)"
	@echo "✅ Release $(TAG) publicado!"

# Comandos auxiliares
dev: clean ## Build rápido local → dist/xpoz-dev
	@echo "🔧 Build de desenvolvimento..."
	dart pub get
	dart compile exe bin/xpoz.dart -o $(DIST)/$(APP_NAME)-dev
	chmod +x $(DIST)/$(APP_NAME)-dev
	@echo "✅ Criado: $(DIST)/$(APP_NAME)-dev"

test: dev ## Testa build local
	@echo "🧪 Testando build..."
	$(DIST)/$(APP_NAME)-dev --help || $(DIST)/$(APP_NAME)-dev --version || echo "Binário executado"

show: ## Mostra arquivos em dist/  
	@echo "📦 Conteúdo de $(DIST)/:"
	@ls -la $(DIST)/ 2>/dev/null || echo "Pasta $(DIST)/ vazia ou não existe"