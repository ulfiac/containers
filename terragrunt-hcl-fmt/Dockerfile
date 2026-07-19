FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

ARG TERRAGRUNT_VERSION

LABEL org.opencontainers.image.title="terragrunt-hcl-fmt" \
      org.opencontainers.image.description="terragrunt hcl fmt" \
      org.opencontainers.image.source="https://github.com/ulfiac/containers"

RUN apk add --no-cache \
    ca-certificates \
    curl

# Install Terragrunt
RUN set -eux; \
    ARCH="amd64"; \
    BINARY="terragrunt_linux_${ARCH}"; \
    cd /tmp; \
    curl -fsSL \
        "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/${BINARY}" \
        -o "${BINARY}"; \
    curl -fsSL \
        "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/SHA256SUMS" \
        -o SHA256SUMS; \
    grep " ${BINARY}$" SHA256SUMS > SHA256SUMS.filtered; \
    sha256sum -c SHA256SUMS.filtered; \
    install -m 0755 "${BINARY}" /usr/local/bin/terragrunt; \
    rm "${BINARY}" SHA256SUMS SHA256SUMS.filtered; \
    terragrunt --version

RUN addgroup -g 1001 terragrunt && \
    adduser -D -u 1001 -G terragrunt terragrunt

USER terragrunt

ENTRYPOINT ["terragrunt", "hcl", "fmt"]
