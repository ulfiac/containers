# opentofu

Pinned OpenTofu CLI packaged as a single-step GitHub Action image (`ENTRYPOINT
["tofu"]`) -- a consuming workflow step only needs
`uses: docker://ghcr.io/ulfiac/opentofu:<version>@<digest>` plus `with: args: <opentofu args>`.

## Versioning
The OpenTofu version is read from `.opentofu-version` at build time and passed in
as the `OPENTOFU_VERSION` build arg. Renovate has no built-in manager for OpenTofu
version files, so a `customManagers` regex entry in
[renovate.json](../renovate.json) keeps that file current instead; the published
image tag tracks it directly. The binary is downloaded directly from the OpenTofu
GitHub releases and verified against its published `SHA256SUMS` before install.

See [containers/README.md](../README.md#shared-conventions) for conventions shared
across every image in this repo (alpine base, non-root user, digest-pinned base
image), and
[containers/README.md](../README.md#build-workflow-doubles-as-a-pr-check) for how
`build_opentofu.yaml` also runs as a PR check.
