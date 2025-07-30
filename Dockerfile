# Dockerfile otimizado para builds multi-plataforma
FROM dart:stable AS builder

# Instalar dependências para cross-compilation
RUN apt-get update && apt-get install -y \
    gcc-aarch64-linux-gnu \
    libc6-dev-arm64-cross \
    file \
    && rm -rf /var/lib/apt/lists/*

# Definir diretório de trabalho
WORKDIR /app

# Copiar arquivos de configuração primeiro (melhor cache)
COPY pubspec.yaml pubspec.lock ./

# Instalar dependências Dart
RUN dart pub get

# Copiar código fonte
COPY . .

# Detectar arquitetura e compilar apropriadamente
ARG TARGETPLATFORM
ARG BUILDPLATFORM

RUN echo "Building on $BUILDPLATFORM for $TARGETPLATFORM"

# Compilar baseado na plataforma target
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        export CC=aarch64-linux-gnu-gcc && \
        export CXX=aarch64-linux-gnu-g++ && \
        dart compile exe bin/main.dart -o /xpoz-linux-amd64; \
    else \
        dart compile exe bin/main.dart -o /xpoz-linux-amd64; \
    fi

# Verificar o binário gerado
RUN file /xpoz-linux-amd64 && ls -la /xpoz-linux-amd64

# Stage final minimalista
FROM scratch
COPY --from=builder /xpoz-linux-amd64 /xpoz-linux-amd64