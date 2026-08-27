# utils

General-purpose scanning/utility image (`gnupg`, `nmap`, `ca-certificates`), not
built around a single pinned CLI version. Runs on `ubuntu-24.04-arm`/`linux/arm64`
only, and has no `ENTRYPOINT`, unlike the other single-purpose images in this repo.

## `nmap` capability
The image grants `cap_net_raw+eip` to the `nmap` binary via `setcap` so the
non-root user can run capability-scoped scan types (e.g. `-sn`) without full root.
Only `NET_RAW` is granted since it's the only nmap-desired capability included in
Docker/Podman/OrbStack's default capability bounding set -- see the comment in
[Dockerfile](Dockerfile) for what happens if a capability outside that set is
requested.

## Versioning
Unlike the other images in this repo, `utils` has no upstream tool version to
track -- it's tagged `latest` and by `${{ github.sha }}` instead of a version
string.

See [containers/README.md](../README.md#shared-conventions) for conventions shared
across every image in this repo, and
[containers/README.md](../README.md#build-workflow-doubles-as-a-pr-check) for how
`build_utils.yaml` also runs as a PR check.
