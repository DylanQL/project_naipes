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

# Crear un usuario no-root para Flutter
RUN groupadd -r flutter && useradd -r -g flutter -m -d /home/flutter flutter

# Descargar Flutter SDK - Usamos una versión específica para mayor estabilidad
RUN git clone -b stable --depth 1 https://github.com/flutter/flutter.git /usr/local/flutter

# Cambiar la propiedad de la carpeta Flutter
RUN chown -R flutter:flutter /usr/local/flutter

# Añadir flutter al PATH
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Configurar Flutter para la web (solo habilitamos la web, sin descargar Gradle)
USER flutter
ENV PUB_CACHE=/home/flutter/.pub-cache
RUN mkdir -p $PUB_CACHE && \
    flutter config --no-analytics && \
    flutter config --enable-web && \
    flutter precache --web --no-android --no-ios --no-linux --no-macos --no-windows --no-fuchsia

# Verificar la instalación (sin realizar descargas adicionales)
RUN flutter doctor -v

# Volver al usuario root para las siguientes operaciones
USER root

# Crear y preparar el directorio de la aplicación
RUN mkdir -p /app && chown -R flutter:flutter /app
WORKDIR /app/

# Primero copiamos solo los archivos necesarios para resolver dependencias
COPY --chown=flutter:flutter pubspec.* /app/

# Cambiar al usuario flutter para operaciones de Flutter
USER flutter

# Obtener dependencias (esto se almacenará en caché si no cambian los archivos pubspec)
RUN flutter pub get

# Volver a root para copiar todos los archivos
USER root

# Ahora copiamos el resto del proyecto y aseguramos permisos correctos
COPY --chown=flutter:flutter . /app/
RUN find /app -type d -exec chmod 755 {} \; && \
    find /app -type f -exec chmod 644 {} \;

# Cambiar al usuario flutter para construir la aplicación
USER flutter

# Construir para la web con optimización
RUN flutter build web --release

# Volver a root para etapa final
USER root

# Etapa de producción
FROM nginx:1.21.0-alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copiar la configuración de nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exponer el puerto 80
EXPOSE 80

# Comando para iniciar nginx
CMD ["nginx", "-g", "daemon off;"]
