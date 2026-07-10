FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

LABEL org.opencontainers.image.title="utils" \
      org.opencontainers.image.description="utility container" \
      org.opencontainers.image.source="https://github.com/ulfiac/containers"

RUN apk add --no-cache \
    ca-certificates \
    gnupg \
    libcap-setcap \
    nmap

# Allow the non-root user below to run nmap scan types that need raw
# sockets (e.g. -sn; SYN scans like -sS still require additional privileges) without full root. Only NET_RAW is granted here:
# it's the only one of nmap's desired capabilities included in the
# container engine's default capability bounding set (Docker/Podman/
# OrbStack all omit NET_ADMIN by default). Granting a capability via
# setcap that ISN'T in the bounding set doesn't just get silently masked
# out -- it makes the exec fail entirely with "operation not permitted"
# for ALL of the binary's setcap'd capabilities, confirmed via testing.
# If NET_ADMIN-dependent nmap features are ever needed, both this setcap
# line and `--cap-add=NET_ADMIN` at run time would need to be added together.
RUN setcap 'cap_net_raw+eip' "$(command -v nmap)"

RUN addgroup -g 1000 utils && \
    adduser -D -u 1000 -G utils utils

USER utils
WORKDIR /home/utils
