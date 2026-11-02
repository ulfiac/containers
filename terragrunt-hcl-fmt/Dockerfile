FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

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

USER 1001:1001

ENTRYPOINT ["terragrunt", "hcl", "fmt"]
