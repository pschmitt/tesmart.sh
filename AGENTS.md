# Agent guidance

This repository contains shell utilities related to a TESmart KVM. It also includes packet-capture sample files.

## Development

- Check changed shell scripts with their declared interpreter and `shellcheck` where applicable.
- Treat packet captures and device configuration as potentially sensitive; do not print, upload, or commit additional device identifiers or credentials.
- Do not run commands that switch or configure a live KVM during validation.
- Load the `shell` skill before changing shell code.

## CI

- Before changing GitHub Actions, inspect the current guidance in `pschmitt/ci-workflows`. Use `@main` in every `uses:` reference to a shared workflow or action.
