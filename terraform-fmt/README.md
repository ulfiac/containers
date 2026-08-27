# terraform-fmt

Pinned Terraform CLI packaged as a single-step GitHub Action image (`ENTRYPOINT
["terraform", "fmt"]`), consumed by `ulfiac/commons`'s `reusable_linter.yaml` as
the `terraform-fmt` job (`args: -check -diff -recursive .`).

## Versioning
The Terraform version is read from `.terraform-version` at build time and passed
in as the `TERRAFORM_VERSION` build arg. Renovate's built-in `terraform-version`
manager keeps that file current; the published image tag tracks it directly. The
binary is downloaded directly from HashiCorp's releases and verified against its
published `SHA256SUMS` before install.

See [containers/README.md](../README.md#shared-conventions) for conventions shared
across every image in this repo, and
[containers/README.md](../README.md#build-workflow-doubles-as-a-pr-check) for how
`build_terraform_fmt.yaml` also runs as a PR check.
