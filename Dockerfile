# Stage 1: Build the Flutter web app
FROM debian:latest AS build-env

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 && \
    apt-get clean

# Clone the flutter repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor -v

# Enable flutter web
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

# Copy files to container and build
WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web --no-tree-shake-icons

RUN ls -l build/web/assets/ || mkdir -p build/web/assets/

COPY assets/ build/web/assets/

# Stage 2: Create nginx server to serve the app
FROM nginx:1.21-alpine

# Убираем worker_processes из default.conf (этот параметр разрешён только в nginx.conf)
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Правильная конфигурация nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Копируем конфиг сервера
COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
