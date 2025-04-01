FROM ubuntu:22.04

# Install dependencies and Docker
RUN apt update && apt install -y wget curl nano git neofetch \
    && curl -fsSL https://get.docker.com | sh  # Install Docker [[5]]

# Install sshx.io
RUN curl -sSf https://sshx.io/get | sh

# Create entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose required ports
EXPOSE 22 2375 2376

# Start services via entrypoint
ENTRYPOINT ["/entrypoint.sh"]
