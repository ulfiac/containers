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
# sockets (e.g. -sS, -sn) without full root. Note: the container's default
# capability bounding set only includes NET_RAW by default -- NET_ADMIN
# additionally requires `--cap-add=NET_ADMIN` at `docker run`/`podman run`
# time to actually take effect, since setcap alone can't exceed the
# container's bounding set.
RUN setcap 'cap_net_raw,cap_net_admin+eip' "$(command -v nmap)"

RUN addgroup -g 1000 utils && \
    adduser -D -u 1000 -G utils utils

USER utils
WORKDIR /home/utils
