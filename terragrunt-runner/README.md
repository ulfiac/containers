# terragrunt-runner

Bundles `terraform`, `terragrunt`, and the AWS CLI (plus `git`, `jq`) for use as a
GitHub Actions **job container**, replacing the pinned `hashicorp/setup-terraform` and
`gruntwork-io/terragrunt-action` actions in `ulfiac/infra`'s
`reusable_terragrunt_action.yaml`.

## Why a job container instead of a step-level action

Terragrunt has to run from a specific unit directory (`./terragrunt/<working_dir>`),
and the reusable workflow sets that via `defaults.run.working-directory`. That default
only applies to `run:` steps — `working-directory` is not a valid property on `uses:`
steps (confirmed with `actionlint`). Since each terraform/terragrunt command needed a
different working directory, running this image as a single-step `uses: docker://...`
action per command would have meant rewriting every call to pass `-chdir`/
`--working-dir` flags instead. Running the whole job inside this container via
`jobs.<job_id>.container` lets every existing `run:` step (and its working directory)
keep working unchanged.

## Why debian instead of alpine

Every other container in this repo is alpine-based, but this one runs as a job
container (`jobs.<job_id>.container`), not a single-step `docker://` action. That means
the GitHub Actions runner executes *every* step in the job inside it, including
JavaScript actions (`actions/checkout`, `aws-actions/configure-aws-credentials`). The
runner injects its own glibc-linked Node.js binary into the container to run those,
which fails on musl-based alpine unless a compatibility shim (`gcompat`) is added. The
job's existing scripts (`dump_input_context.sh`, `show_tg_plan_summary.sh`, etc.) are
`#!/bin/bash` and use `jq`, neither of which ship with alpine by default. debian gives
us all of this natively, so we used it instead of alpine plus workarounds.

## Why the AWS CLI is included

`aws-actions/configure-aws-credentials` uses the AWS JavaScript SDK directly and never
shells out to the `aws` CLI, and nothing in the terraform/terragrunt run path (S3
backend, AWS provider) calls it either -- those use their own Go SDK. However,
`ulfiac/aws-bootstrap`'s `import_bootstrap.sh` script (run as a step in this container)
shells out to `aws` directly (`aws sts get-caller-identity`, `aws iam ...`,
`aws s3api ...`) to check whether resources already exist before importing them, so the
image installs the AWS CLI v2 command line installer, pinned to a version and verified
against AWS's published PGP signature (`aws-cli-pubkey.asc`, matching the public key
documented at
[docs.aws.amazon.com](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html),
fingerprint `FB5D B77F D5C1 18B8 0511 ADA8 A631 0ACC 4672 475C`).

## Why no ENTRYPOINT

The image is consumed as a job container, and GitHub Actions ignores an image's
`ENTRYPOINT`/`CMD` for job containers (it injects its own to keep the container running
and execs each step's command directly). An `ENTRYPOINT` would only matter if this image
were ever invoked as a single-step `uses: docker://...` action, which isn't a good fit
here anyway: `working-directory` is not a valid property on `uses:` steps, and
terragrunt needs to run from a specific unit directory per step.

## Why no WORKDIR

`/github/workspace` is the fixed mount point GitHub uses for Docker container *actions*
(`uses: docker://...` steps) — it doesn't apply here, since this image runs as a job
container instead. For a job container, GitHub mounts the repository at whatever
`$GITHUB_WORKSPACE` resolves to for that runner (a `/home/runner/work/...`-style path on
the host, exposed to containers at a runner-internal path such as `/__w/...`), not a
fixed `/github/workspace`. Setting `WORKDIR` to a hardcoded location could still break
paths that assume `$GITHUB_WORKSPACE`, so this Dockerfile intentionally omits it (and
ignores hadolint's DL3003 for it, along with the other containers in this repo) —
steps should reference `$GITHUB_WORKSPACE` rather than a fixed path.

## Supporting packages

Besides `terraform`, `terragrunt`, and the AWS CLI themselves, the image installs:

- `bsdextrautils` — provides `column`, which `infra`'s `show_tg_plan_summary.sh` and
  `show_tg_apply_summary.sh` scripts use to align the plan/apply/destroy summary
  tables. Missing this caused those steps to fail with `column: command not found`.
- `ca-certificates` — root CA certificates, needed for `curl` (and for
  terraform/terragrunt's own HTTPS calls, e.g. provider/module downloads) to verify
  TLS certificates.
- `curl` — downloads the terraform, terragrunt, and AWS CLI release archives and
  checksum/signature files during the image build.
- `git` — terraform modules and terragrunt configs can reference git sources
  directly, and `actions/checkout` prefers a real `git` binary when one is available.
- `gnupg` — verifies the AWS CLI installer's PGP signature at build time (AWS doesn't
  publish a plain SHA256SUMS file for it the way HashiCorp does for terraform).
- `jq` — used by `dump_input_context.sh`/`dump_all_contexts.sh` to pretty-print the
  JSON context dumps.
- `unzip` — extracts the terraform and AWS CLI release `.zip` archives during the
  image build; terragrunt ships as a plain binary and doesn't need it.

## Non-root user

The image runs as `1001:1001`, matching the convention of the other containers in this
repo. Non-root job containers can occasionally hit permission errors against
`$GITHUB_WORKSPACE` depending on the runner; if that happens, add
`options: --user 0:0` to the consuming workflow's `container:` block, or switch this
image to run as root.

## Pre-mirrored terraform providers

`ulfiac/infra` and `ulfiac/aws-bootstrap` pin `hashicorp/aws`, `hashicorp/archive`,
`hashicorp/local`, `hashicorp/random`, and `integrations/github` at exact versions.
Rather than let every `terraform init` re-download those providers from the registry on
every job run, the image mirrors them at build time (`terraform providers mirror`, from
`providers.tf`) into `/opt/terraform-providers-mirror`, and points Terraform at that
mirror via a CLI config file (`cli-config.tfrc`, copied to
`/etc/terraform/cli-config.tfrc` and referenced through the `TF_CLI_CONFIG_FILE` env
var so it doesn't depend on `$HOME` or which UID the container runs as).

`providers.tf` is not a real root module -- it exists solely so Renovate's built-in
terraform manager (matches any `*.tf` file, no custom manager needed) has a
`required_providers` block to bump, and so the Dockerfile has something concrete to
mirror against.

The CLI config's `direct` method excludes these 5 providers unconditionally, with no
network fallback: if a consuming repo's actual required version ever drifts ahead of
what's mirrored here (e.g. its own Renovate bumped first), `terraform init` fails loudly
instead of silently falling back to a slower network download. That's intentional --
it surfaces the drift immediately so the image gets rebuilt, rather than letting the
"no download needed" benefit quietly erode unnoticed. Any provider *not* in this list
still installs normally over the network, so new provider types can be added to a
consuming repo before this image is updated to mirror them.

We use the packed (zip) filesystem-mirror layout that `terraform providers mirror`
produces natively, rather than manually unpacking it into the unpacked/symlink layout
Terraform also supports -- the latter would save a small amount of per-job unzip time
but isn't worth the added build complexity for 5 providers.

## Linting `providers.tf`

`providers.tf` is the only `*.tf` file in this repo, so `_linter.yaml` enables
`terraform-fmt` (real value, zero false positives so far -- catches HCL formatting
drift) but leaves `tflint` disabled. tflint's default rules assume `providers.tf` is a
conventional root module: it expects `variables.tf`/`outputs.tf` and each declared
provider to actually be used (a `provider {}` block or resource of that type). Since
`providers.tf` is intentionally a manifest only, those warnings are permanent false
positives rather than issues to fix.

## Build workflow doubles as a PR check

`build_terragrunt_runner.yaml` follows the same shared pattern as every other build
workflow in this repo -- see
[containers/README.md](../README.md#build-workflow-doubles-as-a-pr-check) for the
full rationale (PR-triggered build+scan, conditional login/push, the `packages:
write` trade-off).

## Versioning

`terraform` and `terragrunt` versions are read from `.terraform-version` and
`.terragrunt-version` at build time. Both files are updated automatically by
Renovate's built-in `terraform-version`/`terragrunt-version` managers (no custom
regex manager needed). The published image tag tracks the terragrunt version only.

The AWS CLI version is read from `.aws-cli-version` at build time, tracked by a custom
regex manager in `renovate.json` (datasource `github-tags` against `aws/aws-cli`). This
uses `github-tags` rather than the `github-releases` datasource used for
`.opentofu-version`/`.tflint-version`, because `aws/aws-cli` only publishes its actual
CLI versions (e.g. `2.36.40`) as plain git tags -- its GitHub Releases list contains
just one old `2.0.0dev0` preview release, so `github-releases` would never find a
newer version to bump to. `aws/aws-cli`'s tags also have no `v` prefix, so no
`extractVersionTemplate` is needed (unlike `opentofu`/`tflint`).

`terraform`, `terragrunt`, and the AWS CLI are the only tools versioned this way,
because they're fetched by direct download + checksum/signature verification, which
Renovate can track cleanly via a plain version file, and their specific versions
materially affect this job's behavior. The supporting packages (`ca-certificates`,
`curl`, `git`, `gnupg`, `jq`, `unzip`) are installed unpinned via `apt-get install`,
consistent with every other container in this repo (see the DL3008/DL3018 ignores in
`.hadolint.yaml`): Renovate has no clean way to track individual apt/apk package
versions pinned inline in a `RUN` command, and their exact versions don't materially
affect this job's behavior. Pinning the base image by digest still gives us a
reproducible starting point even without pinning each package.
