# containers

Container images used by GitHub Actions workflows across the `ulfiac` organization,
either as job containers (`jobs.<job_id>.container`) or as single-step `uses:
docker://...` actions.

## Images
- [opentofu](opentofu) — pinned OpenTofu CLI
- [terraform-fmt](terraform-fmt) — pinned Terraform CLI, entrypoint `terraform fmt`
- [terragrunt-hcl-fmt](terragrunt-hcl-fmt) — pinned Terragrunt CLI, entrypoint `terragrunt hcl fmt`
- [terragrunt-runner](terragrunt-runner) — Terraform + Terragrunt job container for `ulfiac/infra`
- [tflint](tflint) — pinned tflint CLI with plugins pre-installed
- [utils](utils) — general-purpose scanning/utility image (nmap, gnupg)

## Shared conventions
This section covers decisions that span every image in this repo. Anything specific
to a single image belongs in that image's own README instead.

- Base image is `alpine`, pinned by digest, unless a container has a documented
  reason not to be (see [terragrunt-runner/README.md](terragrunt-runner/README.md)
  for the one exception).
- Every image runs as a non-root user (`USER 1001:1001`, or `1000:1000` for
  `utils`), created explicitly in the Dockerfile rather than relying on a base
  image default.
- Tool versions are pinned via build `ARG`s populated from a `.<tool>-version` file
  (e.g. `.terraform-version`). `.terraform-version` and `.terragrunt-version` are
  bumped by Renovate's built-in `terraform-version`/`terragrunt-version` managers;
  `.opentofu-version` and `.tflint-version` have no built-in Renovate manager for
  their upstream project, so they're bumped by the two `customManagers` regex
  entries in [renovate.json](renovate.json) instead.
- `.hadolint.yaml` applies the same Dockerfile lint ignore rules (DL3008/DL3018
  unpinned package installs, DL3003 no `WORKDIR`) across every container via the
  repo-wide recursive `hadolint` job in [_linter.yaml](.github/workflows/_linter.yaml).
  `.trivyignore.yaml` (DS-0026 no `HEALTHCHECK`) is consumed by that same
  workflow's `trivy-config` misconfiguration scan (via `ulfiac/commons`'s
  `reusable_linter.yaml`), not by the per-image `scan image` vulnerability-scan
  step in each `build_*.yaml` workflow -- those don't pass `trivyignores` at all.
  See those files for the rationale on each ignored rule.

## Build workflow doubles as a PR check
Every `build_*.yaml` workflow in `.github/workflows/` runs on `pull_request` (not
just `push`/`workflow_dispatch`), reusing the "build and load image" (`push: false,
load: true`) and "scan image" (Trivy) steps unconditionally, so a PR touching a
container's Dockerfile or build inputs actually gets built and scanned before
merge -- e.g. catching a Renovate-bumped version that no longer resolves. `login to
ghcr.io` and `push image` are gated with `if: github.event_name != 'pull_request'`
so PR runs never touch the registry, while `workflow_dispatch` and `push`-to-`main`
runs still publish like before. This reuses the same build definition for both
purposes rather than a separate workflow, so there's no risk of the PR check
drifting from what actually gets published.

Each job still declares `packages: write` at the job level, so that permission is
technically present (though unused by any step) during `pull_request` runs too --
GitHub Actions has no per-step permission scoping, only per-job. The stricter fix is
to split each into a read-only build/scan job plus a separate push-only job, but
that costs the free layer-cache reuse the "push image" step currently gets from
"build and load image" running in the same job. Left as a single job for now: this
repo has a single, 2FA-protected contributor and no external PRs, so the main
residual risk is generic supply-chain (a compromised pinned action/base image),
which the split wouldn't fully close either -- it would only shrink how often the
elevated token is present. Revisit if this repo ever accepts outside contributions.
