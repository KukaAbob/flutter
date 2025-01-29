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

# Stage 2: Create nginx server to serve the app
FROM nginx:1.21-alpine

# Copy built files to nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Optimize nginx configuration
RUN echo 'worker_processes 1;' > /etc/nginx/nginx.conf && \
    echo 'events { worker_connections 1024; use epoll; multi_accept on; }' >> /etc/nginx/nginx.conf && \
    echo 'http { include /etc/nginx/conf.d/*.conf; }' >> /etc/nginx/nginx.conf

# Add custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]