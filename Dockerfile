# Use official Docker-in-Docker (DinD) image
FROM docker:dind

# Install dependencies (Alpine Linux packages)
RUN apk add --no-cache \
    bash \
    curl \
    git \
    nano \
    neofetch \
    sudo \
    docker-compose

# Install SSHX terminal
RUN curl -sSf https://sshx.io/get | sh

# Configure non-root user
RUN adduser -D user && \
    echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    adduser user docker

# Switch to non-root user
USER user
WORKDIR /home/user

# Start Docker daemon + SSHX web terminal
CMD ["sh", "-c", "sudo dockerd >/dev/null 2>&1 & sleep 5; sshx"]
