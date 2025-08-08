# Use a Ubuntu image as the base. Ubuntu is a common and stable choice.
FROM ubuntu:22.04

# Set a non-interactive mode for commands to prevent prompts during installation.
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install all necessary tools.
# 'curl' is for downloading the sshx binary and Docker's GPG key.
# The other packages are required for a proper Docker installation.
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    ca-certificates \
    software-properties-common \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Download the latest stable sshx binary directly from GitHub Releases.
# This approach is more reliable than piping the install script.
# It places the executable directly in a directory that is in the container's PATH.
RUN curl -L -o /usr/local/bin/sshx "https://github.com/sshx/sshx/releases/latest/download/sshx-x86_64-linux"

# Make the downloaded binary executable.
RUN chmod +x /usr/local/bin/sshx

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

# This is the command that runs when the container starts.
# It starts an sshx session with a bash shell, which will print a URL in the container logs.
# This grants full root access to anyone with the session URL.
CMD ["sshx", "--shell=/bin/bash"]
