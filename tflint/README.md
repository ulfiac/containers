# tflint

Pinned tflint CLI packaged as a single-step GitHub Action image (`ENTRYPOINT
["tflint", "--config", "/etc/tflint/.tflint.hcl"]`), consumed by `ulfiac/commons`'s
`reusable_linter.yaml` as the `tflint` job (`args: --recursive --color`).

## Plugins pre-installed at build time
`.tflint.hcl` is copied into the image and `tflint --init` runs during the build
(as the non-root user, so plugins land under `TFLINT_PLUGIN_DIR`), so consuming
workflows don't pay the plugin-download cost on every run.

## Versioning
The tflint version is read from `.tflint-version` at build time and passed in as
the `TFLINT_VERSION` build arg. Renovate's built-in `tflint-version` manager keeps
that file current; the published image tag tracks it directly. The binary is
downloaded directly from the tflint GitHub releases and verified against its
published checksums before install.

See [containers/README.md](../README.md#shared-conventions) for conventions shared
across every image in this repo, and
[containers/README.md](../README.md#build-workflow-doubles-as-a-pr-check) for how
`build_tflint.yaml` also runs as a PR check.
