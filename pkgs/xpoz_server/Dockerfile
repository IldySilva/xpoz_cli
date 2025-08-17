# Etapa 1: Build
FROM dart:stable AS build

# Cria diretório da aplicação
WORKDIR /app

# Copia arquivos de dependência e instala
COPY pubspec.* ./
RUN dart pub get

# Copia o restante do código
COPY . .

# Garante que as dependências já estão no cache offline
RUN dart pub get --offline

# Compila o binário AOT
RUN dart compile exe lib/main.dart -o /app/server

# Etapa 2: Runtime
FROM scratch

# Copia o runtime da imagem base do Dart
COPY --from=build /runtime/ /

# Copia o binário compilado
COPY --from=build /app/server /app/server

# Define a porta do servidor
EXPOSE 8080
EXPOSE 8081
# Comando para executar
CMD ["/app/server"]
