#!/bin/sh

# Start Docker daemon (DinD)
dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 &

# Wait for Docker to initialize
sleep 5

# Start SSH service
/usr/sbin/sshd

# Keep container running
tail -f /dev/null
