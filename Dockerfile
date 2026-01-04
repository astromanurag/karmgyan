# Frontend Dockerfile for karmgyan (Flutter Web)
# This builds the Flutter web app for production deployment

FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_VERSION=3.27.0
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

# Create a non-root user for running Flutter (Render recommendation)
RUN useradd -m -u 1000 flutteruser

# Download and install Flutter
RUN cd /opt && \
    curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz -o flutter.tar.xz && \
    tar xf flutter.tar.xz && \
    rm flutter.tar.xz && \
    chown -R flutteruser:flutteruser /opt/flutter && \
    chmod -R 755 /opt/flutter

# Enable web support and accept licenses (run as flutteruser)
USER flutteruser
RUN flutter config --enable-web && \
    flutter doctor --android-licenses || true && \
    flutter precache --web

# Set working directory
WORKDIR /app

# Copy pubspec.yaml first (without lock file to allow dependency resolution)
COPY --chown=flutteruser:flutteruser pubspec.yaml ./

# Get Flutter dependencies (this will generate a compatible pubspec.lock)
RUN flutter pub get

# Copy application code
COPY --chown=flutteruser:flutteruser . .

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
