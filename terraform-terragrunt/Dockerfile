FROM alpine:3.21

ARG TERRAFORM_VERSION=1.15.6
ARG TERRAGRUNT_VERSION=1.0.8
ARG TARGETARCH

LABEL org.opencontainers.image.title="terraform-terragrunt" \
      org.opencontainers.image.description="Terraform and Terragrunt CLI tools" \
      org.opencontainers.image.source="https://github.com/ulfiac/containers"

RUN apk add --no-cache \
    ca-certificates \
    curl \
    unzip

# Install Terraform
RUN set -eux; \
    ARCH="${TARGETARCH:-amd64}"; \
    ZIP="terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip"; \
    cd /tmp; \
    curl -fsSL \
        "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${ZIP}" \
        -o "${ZIP}"; \
    curl -fsSL \
        "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS" \
        -o terraform_SHA256SUMS; \
    grep "${ZIP}" terraform_SHA256SUMS | sha256sum -c; \
    unzip "${ZIP}" -d /usr/local/bin; \
    rm "${ZIP}" terraform_SHA256SUMS; \
    terraform --version

# Install Terragrunt
RUN set -eux; \
    ARCH="${TARGETARCH:-amd64}"; \
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
