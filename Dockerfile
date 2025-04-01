# Dockerfile
FROM docker:dind

# Install dependencies
RUN apk add --no-cache curl nano git openssh sudo

# Install sshx.io
RUN curl -sSf https://sshx.io/get | sh

# Create SSH directory and config
RUN mkdir -p /root/.ssh && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose required ports
EXPOSE 22 2375 2376

# Start services via entrypoint
ENTRYPOINT ["/entrypoint.sh"]
