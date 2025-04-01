# Use official Docker-in-Docker (DinD) image
FROM docker:dind

# Install Alpine Linux packages (not Ubuntu!)
RUN apk add --no-cache \
    bash \
    curl \
    git \
    nano \
    neofetch \
    sudo \
    docker-compose

# Install SSHX web terminal
RUN curl -sSf https://sshx.io/get | sh

# Configure non-root user for Railway compatibility
RUN adduser -D user && \
    echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    # Grant Docker access
    adduser user docker && \
    # Fix permissions for DinD
    mkdir -p /home/user/.docker && \
    chown -R user:user /home/user

# Switch to non-root user
USER user
WORKDIR /home/user

# Start Docker daemon + SSHX (critical fix: no sudo)
CMD ["sh", "-c", "dockerd > /tmp/docker.log 2>&1 & sleep 5; sshx"]
