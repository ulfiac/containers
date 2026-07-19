FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

ARG TFLINT_VERSION

LABEL org.opencontainers.image.title="tflint" \
      org.opencontainers.image.description="tflint" \
      org.opencontainers.image.source="https://github.com/ulfiac/containers"

ENV TFLINT_PLUGIN_DIR=/usr/local/lib/tflint/plugins

RUN apk add --no-cache \
    ca-certificates \
    curl \
    unzip

# Install tflint
RUN set -eux; \
    ARCH="amd64"; \
    ZIP="tflint_linux_${ARCH}.zip"; \
    cd /tmp; \
    curl -fsSL \
        "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/${ZIP}" \
        -o "${ZIP}"; \
    curl -fsSL \
        "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/checksums.txt" \
        -o checksums.txt; \
    grep -F " ${ZIP}" checksums.txt > checksums.filtered; \
    sha256sum -c checksums.filtered; \
    unzip "${ZIP}" -d /usr/local/bin; \
    rm "${ZIP}" checksums.txt checksums.filtered; \
    tflint --version

# Copy config and pre-install plugins at build time
COPY .tflint.hcl /etc/tflint/.tflint.hcl

RUN addgroup -g 1001 tflint && \
    adduser -D -u 1001 -G tflint tflint && \
    install -d -m 0755 -o tflint -g tflint "${TFLINT_PLUGIN_DIR}"

USER tflint

RUN tflint --init --config /etc/tflint/.tflint.hcl && \
    tflint --version

ENTRYPOINT ["tflint", "--config", "/etc/tflint/.tflint.hcl"]
