FROM debian:bookworm-slim@sha256:abd67ffcfa541b485a3dff59865ab629aa048a6c613e639d36e7456b0b229241

ARG TERRAFORM_VERSION
ARG TERRAGRUNT_VERSION

LABEL org.opencontainers.image.title="terragrunt-runner" \
      org.opencontainers.image.description="terraform and terragrunt" \
      org.opencontainers.image.source="https://github.com/ulfiac/containers"

RUN apt-get update && apt-get install -y --no-install-recommends \
    bsdextrautils \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    perl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

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

RUN addgroup --gid 1001 terragrunt-runner && \
    adduser --disabled-password --gecos "" --uid 1001 --gid 1001 terragrunt-runner

USER 1001:1001
