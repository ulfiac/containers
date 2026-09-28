FROM alpine:3.24.2@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

ARG TERRAFORM_VERSION

LABEL org.opencontainers.image.title="terraform-fmt" \
      org.opencontainers.image.description="terraform fmt" \
      org.opencontainers.image.source="https://github.com/ulfiac/containers"

RUN apk add --no-cache \
    ca-certificates \
    curl \
    unzip

# Install Terraform
RUN set -eux; \
    ARCH="amd64"; \
    ZIP="terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip"; \
    cd /tmp; \
    curl -fsSL \
        "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${ZIP}" \
        -o "${ZIP}"; \
    curl -fsSL \
        "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS" \
        -o terraform_SHA256SUMS; \
    grep -F " ${ZIP}" terraform_SHA256SUMS > terraform_SHA256SUMS.filtered; \
    sha256sum -c terraform_SHA256SUMS.filtered; \
    unzip "${ZIP}" -d /usr/local/bin; \
    rm "${ZIP}" terraform_SHA256SUMS terraform_SHA256SUMS.filtered; \
    terraform --version

RUN addgroup -g 1001 terraform && \
    adduser -D -u 1001 -G terraform terraform

USER 1001:1001

ENTRYPOINT ["terraform", "fmt"]
