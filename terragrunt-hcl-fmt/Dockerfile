FROM alpine:3.21

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
    grep "${BINARY}$" SHA256SUMS | sha256sum -c; \
    install -m 0755 "${BINARY}" /usr/local/bin/terragrunt; \
    rm "${BINARY}" SHA256SUMS; \
    terragrunt --version

ENTRYPOINT ["terragrunt", "hcl", "fmt"]
