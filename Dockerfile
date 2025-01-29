# Stage 1: Build the Flutter web app
FROM ubuntu:20.04 AS builder

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_VERSION="3.27.3"
ENV FLUTTER_HOME=/usr/local/flutter

# Install required dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa

# Download and setup Flutter
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME && \
    cd $FLUTTER_HOME && \
    git checkout $FLUTTER_VERSION

# Add flutter to PATH
ENV PATH="$FLUTTER_HOME/bin:$PATH"

# Enable flutter web
RUN flutter config --enable-web

# Copy the app files to the container
WORKDIR /app
COPY . .

# Get app dependencies
RUN flutter pub get

# Build Flutter web app
RUN flutter build web --release

# Stage 2: Create nginx server to serve the app
FROM nginx:alpine

# Copy the built app to nginx's serve directory
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy nginx configuration
RUN echo ' \
server { \
    listen 80; \
    server_name localhost; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html index.htm; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]