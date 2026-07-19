FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

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

USER terraform

ENTRYPOINT ["terraform", "fmt"]
