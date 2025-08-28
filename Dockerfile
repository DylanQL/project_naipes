FROM debian:latest AS build-env

# Instalar dependencias
RUN apt-get update 
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 psmisc
RUN apt-get clean

# Descargar Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Añadir flutter al PATH
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Ejecutar flutter doctor
RUN flutter doctor -v
RUN flutter channel stable
RUN flutter upgrade

# Copiar los archivos del proyecto
COPY . /app/
WORKDIR /app/

# Obtener dependencias
RUN flutter pub get
# Construir para la web
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
