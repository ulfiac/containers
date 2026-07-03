FROM alpine:3.24

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
    grep "${ZIP}" terraform_SHA256SUMS | sha256sum -c; \
    unzip "${ZIP}" -d /usr/local/bin; \
    rm "${ZIP}" terraform_SHA256SUMS; \
    terraform --version

ENTRYPOINT ["terraform", "fmt"]
