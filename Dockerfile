FROM debian:bullseye AS build-env

# Instalar dependencias (combinadas en una sola capa para reducir el tamaño de la imagen)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    git \
    wget \
    unzip \
    gdb \
    libstdc++6 \
    libglu1-mesa \
    fonts-droid-fallback \
    lib32stdc++6 \
    python3 \
    psmisc \
    libgtk-3-0 \
    xz-utils \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Descargar Flutter SDK - Usamos una versión específica para mayor estabilidad
RUN git clone -b stable --depth 1 https://github.com/flutter/flutter.git /usr/local/flutter

# Añadir flutter al PATH
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Configurar Flutter para web y verificar la instalación
RUN flutter config --no-analytics && \
    flutter config --enable-web && \
    flutter doctor -v

# Primero copiamos solo los archivos necesarios para resolver dependencias
COPY pubspec.* /app/
WORKDIR /app/

# Obtener dependencias (esto se almacenará en caché si no cambian los archivos pubspec)
RUN flutter pub get

# Ahora copiamos el resto del proyecto
COPY . /app/

# Construir para la web con optimización
RUN flutter build web --release

# Etapa de producción
FROM nginx:1.21.0-alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copiar la configuración de nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exponer el puerto 80
EXPOSE 80

# Comando para iniciar nginx
CMD ["nginx", "-g", "daemon off;"]
