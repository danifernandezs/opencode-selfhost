FROM ghcr.io/anomalyco/opencode:latest

# Runs as root intentionally: the agent needs to install packages,
# clone repos, and manage files inside the container at runtime.
RUN apk add --no-cache git

RUN apk add --no-cache \
    jq \
    curl
