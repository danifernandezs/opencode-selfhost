FROM ghcr.io/anomalyco/opencode:latest

RUN apk add --no-cache git

RUN apk add --no-cache \
    jq \
    curl
