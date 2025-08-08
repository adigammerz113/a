# Use a Ubuntu image as the base.
FROM ubuntu:22.04

# Set a non-interactive mode for commands.
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install necessary dependencies.
# 'curl' is needed for both sshx and Docker installations.
# The other packages are required for the Docker repository setup.
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    ca-certificates \
    software-properties-common \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Install the sshx binary using the official command.
# The `sh` command is used to execute the script piped from `curl`.
RUN curl -sSf https://sshx.io/get | sh

# Install Docker inside the container. This is a multi-step process
# that adds the official Docker GPG key and repository before installing the packages.
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Set the working directory to the root of the filesystem.
WORKDIR /

# Expose port 80. Railway will automatically handle this port for web services.
EXPOSE 80

# This command runs when the container starts.
# It launches an sshx session with a bash shell, which will print a URL in the container logs.
# This grants full root access to anyone with the session URL.
CMD ["sshx", "--shell=/bin/bash"]
