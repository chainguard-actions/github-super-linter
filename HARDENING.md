<!-- markdownlint-disable -->

# Hardening Report: github--super-linter/v7

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **github--super-linter/v7** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Both action.yml and slim/action.yml use Docker image references with mutable version tags instead of immutable SHA digests. This means the action could silently pull a different (potentially malicious) image if the tag is moved. Failing references:
- action.yml: `image: "docker://ghcr.io/super-linter/super-linter:v7.1.0"` (tag, not a digest)
- slim/action.yml: `image: "docker://ghcr.io/super-linter/super-linter:slim-v7.1.0"` (tag, not a digest)
These should be replaced with SHA digest references, e.g. `image: "docker://ghcr.io/super-linter/super-linter@sha256:<64-hex-char-digest>"`.

Locations:

- `action.yml:7`
- `slim/action.yml:7`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses

**Notes:**

Pinned both Docker image references to immutable SHA digests:
- action.yml: ghcr.io/super-linter/super-linter:v7.1.0 → @sha256:83a2361d90aa21e7894e86fe20e7cf0fe7f1560a56431da3aed6ae4c8155457a # v7.1.0
- slim/action.yml: ghcr.io/super-linter/super-linter:slim-v7.1.0 → @sha256:7dc9a88c0e8373ce71cb066eff788bac209a93eb005dffe36782ce84edc23acd # slim-v7.1.0
Comments are placed outside the YAML quotes to preserve readability while using immutable digests.

