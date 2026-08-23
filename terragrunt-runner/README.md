# terragrunt-runner

Bundles `terraform` and `terragrunt` (plus `git`, `gnupg`, `shasum`, `jq`) for use as a
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

## Why no AWS CLI

`aws-actions/configure-aws-credentials` uses the AWS JavaScript SDK directly and never
shells out to the `aws` CLI, and nothing in the terraform/terragrunt run path (S3
backend, AWS provider) calls it either — those use their own Go SDK. The image
intentionally omits `awscli`.

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

## Non-root user

The image runs as `1001:1001`, matching the convention of the other containers in this
repo. Non-root job containers can occasionally hit permission errors against
`$GITHUB_WORKSPACE` depending on the runner; if that happens, add
`options: --user 0:0` to the consuming workflow's `container:` block, or switch this
image to run as root.

## Versioning

`terraform` and `terragrunt` versions are read from `.terraform-version` and
`.terragrunt-version` at build time. Both files are updated automatically by
Renovate's built-in `terraform-version`/`terragrunt-version` managers (no custom
regex manager needed). The published image tag tracks the terragrunt version only.

`terraform` and `terragrunt` are the only tools versioned this way, because they're the
actual product of this image (their specific version affects plan/apply behavior) and
they're fetched by direct download + checksum verification, which Renovate can track
cleanly via a plain version file. The supporting packages (`ca-certificates`, `curl`,
`git`, `gnupg`, `jq`, `perl`, `unzip`) are installed unpinned via `apt-get install`,
consistent with every other container in this repo (see the DL3008/DL3018 ignores in
`.hadolint.yaml`): Renovate has no clean way to track individual apt/apk package
versions pinned inline in a `RUN` command, and their exact versions don't materially
affect this job's behavior. Pinning the base image by digest still gives us a
reproducible starting point even without pinning each package.
