# Frontend Dockerfile for karmgyan (Flutter Web)
# This builds the Flutter web app for production deployment

FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_VERSION=3.16.0
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    libgtk-3-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure Git to avoid ownership issues in Docker (Git security feature)
RUN git config --global --add safe.directory '*'

# Download and install Flutter
RUN cd /opt && \
    curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz -o flutter.tar.xz && \
    tar xf flutter.tar.xz && \
    rm flutter.tar.xz && \
    chmod -R 755 /opt/flutter

# Enable web support and accept licenses
RUN flutter config --enable-web && \
    flutter doctor --android-licenses || true && \
    flutter precache --web

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Get Flutter dependencies
RUN flutter pub get

# Copy application code
COPY . .

# Build Flutter web app
RUN flutter build web --release --web-renderer canvaskit

# Use nginx to serve the built web app
FROM nginx:alpine

# Copy built web app to nginx html directory
COPY --from=0 /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration (optional)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

