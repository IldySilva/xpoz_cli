# Dockerfile simples - compila binário Dart
FROM dart:stable

WORKDIR /app

# Copiar projeto
COPY . .

# Instalar dependências e compilar
RUN dart pub get && \
    dart compile exe bin/xpoz.dart -o /xpoz-binary

# Binário fica em /xpoz-binary