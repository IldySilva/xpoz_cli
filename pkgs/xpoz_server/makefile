# Caminhos
DART=dart
SERVER=bin/server/main.dart
CLIENT=bin/xpoz.dart

run-server:
	@echo "🚀 A iniciar o servidor Xpoz..."
	@$(DART) run $(SERVER)

run-client:
ifndef PORT
	$(error ❌ Por favor, fornece a PORT: ex: make run-client PORT=3000)
endif
	@echo "🌐 A iniciar o cliente Xpoz na porta $(PORT)..."
	@$(DART) run $(CLIENT) http $(PORT)

# Atalhos rápidos
server: run-server
client: run-client
