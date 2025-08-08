# Use a Ubuntu image as the base. Ubuntu is a common and stable choice.
FROM ubuntu:22.04

# Set a non-interactive mode for commands to prevent prompts during installation.
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install all necessary tools for this setup.
# 'curl' is for downloading sshx and Docker's GPG key.
# 'gnupg', 'lsb-release', 'ca-certificates', and 'software-properties-common'
# are required dependencies for installing Docker on Ubuntu.
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    ca-certificates \
    software-properties-common \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Install the sshx binary. This command fetches the installation script
# directly from GitHub and pipes it to the shell, ensuring you get the latest version.
# The 'sudo' command has been removed to fix the exit code 127 error.
RUN curl -sS https://raw.githubusercontent.com/sshx/sshx/main/install.sh | sh

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
# It starts an sshx session, which will print a URL in the container logs.
# The `--shell=/bin/bash` option ensures that the new terminal session uses bash.
# This grants full root access to anyone with the session URL.
CMD ["sshx", "--shell=/bin/bash"]
