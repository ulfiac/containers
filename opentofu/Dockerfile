FROM alpine:3.24.2@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

ARG OPENTOFU_VERSION

LABEL org.opencontainers.image.title="opentofu" \
      org.opencontainers.image.description="opentofu" \
      org.opencontainers.image.source="https://github.com/ulfiac/containers"

RUN apk add --no-cache \
    ca-certificates \
    curl \
    unzip

# Install OpenTofu
RUN set -eux; \
    ARCH="amd64"; \
    ZIP="tofu_${OPENTOFU_VERSION}_linux_${ARCH}.zip"; \
    cd /tmp; \
    curl -fsSL \
        "https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/${ZIP}" \
        -o "${ZIP}"; \
    curl -fsSL \
        "https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_SHA256SUMS" \
        -o tofu_SHA256SUMS; \
    grep -F " ${ZIP}" tofu_SHA256SUMS > tofu_SHA256SUMS.filtered; \
    sha256sum -c tofu_SHA256SUMS.filtered; \
    unzip "${ZIP}" -d /usr/local/bin; \
    rm "${ZIP}" tofu_SHA256SUMS tofu_SHA256SUMS.filtered; \
    tofu --version

RUN addgroup -g 1001 opentofu && \
    adduser -D -u 1001 -G opentofu opentofu

USER 1001:1001

ENTRYPOINT ["tofu"]
