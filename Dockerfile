# This is a containerized build automation for: LINUX, ANDROID, WEB
FROM ubuntu:latest

# Install required dependencies
RUN apt-get update && \
    apt-get install -y curl git unzip zip && \
    apt-get clean

# Install Flutter SDK
RUN curl -O https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_1.22.2-stable.tar.xz && \
    tar xf flutter_linux_1.22.2-stable.tar.xz && \
    rm flutter_linux_1.22.2-stable.tar.xz
ENV PATH "$PATH:/flutter/bin"

# Set the working directory and copy the app source code
WORKDIR /app
COPY . .

# Run Flutter builds
RUN flutter pub get && \
    flutter build apk --release && \
    flutter build web --web-renderer html && \
    flutter build linux --release