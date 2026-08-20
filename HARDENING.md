<!-- markdownlint-disable -->

# Hardening Report: github--super-linter/v7

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **github--super-linter/v7** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple action references use mutable tags instead of pinned SHA digests, making the workflow vulnerable to supply-chain attacks.

action.yml: `image: docker://ghcr.io/super-linter/super-linter:v7.1.0` (tag, not SHA digest)
slim/action.yml: `image: docker://ghcr.io/super-linter/super-linter:slim-v7.1.0` (tag, not SHA digest)

.github/workflows/cd.yml unpinned uses:
- actions/checkout@v4
- docker/setup-buildx-action@v3
- docker/build-push-action@v6
- docker/login-action@v3.3.0
- actions/github-script@v7
- googleapis/release-please-action@v4.1.3
- akhilerm/tag-push-action@v2.2.0

.github/workflows/ci.yml unpinned uses:
- actions/checkout@v4
- docker/setup-buildx-action@v3
- docker/build-push-action@v6
- actions/upload-artifact@v4.3.6
- actions/download-artifact@v4.1.8

.github/workflows/dependabot-automation.yaml unpinned uses:
- dependabot/fetch-metadata@v2

.github/workflows/lint-commit.yaml unpinned uses:
- actions/checkout@v4

.github/workflows/stale.yml unpinned uses:
- actions/stale@v9
- actions/github-script@v7

.github/workflows/thank_contributors.yaml unpinned uses:
- github/contributors@v1
- peter-evans/create-issue-from-file@v5

Locations:

- `action.yml:6`
- `slim/action.yml:6`
- `.github/workflows/cd.yml:35`
- `.github/workflows/cd.yml:75`
- `.github/workflows/cd.yml:79`
- `.github/workflows/cd.yml:107`
- `.github/workflows/cd.yml:121`
- `.github/workflows/cd.yml:148`
- `.github/workflows/cd.yml:162`
- `.github/workflows/cd.yml:170`
- `.github/workflows/cd.yml:196`
- `.github/workflows/ci.yml:28`
- `.github/workflows/ci.yml:97`
- `.github/workflows/ci.yml:101`
- `.github/workflows/ci.yml:136`
- `.github/workflows/ci.yml:155`
- `.github/workflows/ci.yml:163`
- `.github/workflows/dependabot-automation.yaml:20`
- `.github/workflows/lint-commit.yaml:16`
- `.github/workflows/stale.yml:24`
- `.github/workflows/stale.yml:44`
- `.github/workflows/thank_contributors.yaml:22`
- `.github/workflows/thank_contributors.yaml:27`

### script-injection (severity: high)

GitHub Actions expressions (${{ }}) are directly interpolated inside run: shell command strings, allowing an attacker to inject arbitrary shell commands.

**cd.yml — 'Set build metadata' step (sub-rule a):**
- `if [[ ${{ github.event_name }} == 'push' ]]` — github context interpolated directly in shell
- `BUILD_REVISION=${{ github.sha }}` — github context interpolated directly in shell
- `BUILD_REVISION=${{ github.event.pull_request.head.sha }}` — github context interpolated directly in shell

**cd.yml — 'Configure release metadata' step (sub-rule a):**
- `RELEASE_VERSION="${{ steps.release.outputs.tag_name }}"` — steps output interpolated directly in shell
- `SEMVER_MAJOR_VERSION=v${{ steps.release.outputs.major }}` — steps output interpolated directly in shell

**cd.yml — 'Tag major, minor, and latest versions' step (sub-rule a):**
- `git tag --annotate --force ${{ env.SEMVER_MAJOR_VERSION }} -m "Release ${{ env.SEMVER_MAJOR_VERSION }}"` — env context interpolated directly in shell
- `git push --force origin ${{ env.SEMVER_MAJOR_VERSION }}` — env context interpolated directly in shell

**ci.yml — 'Set build metadata' step (sub-rule a):**
- `if [[ ${{ github.event_name }} == 'push' ]]` — github context interpolated directly in shell
- `BUILD_REVISION=${{ github.sha }}` — github context interpolated directly in shell
- `BUILD_REVISION=${{ github.event.pull_request.head.sha }}` — github context interpolated directly in shell

**ci.yml — 'Load image' step (sub-rule a):**
- `docker load <"/tmp/${{ env.CONTAINER_IMAGE_OUTPUT_IMAGE_NAME }}.tar"` — env context interpolated directly in shell

**ci.yml — 'Test case' step (sub-rule a):**
- `echo "Running: ${{ env.CONTAINER_IMAGE_OUTPUT_IMAGE_NAME }} - ${{ matrix.test-case }}"` — matrix context interpolated directly in shell
- `make ${{ matrix.test-case }}` — matrix context interpolated directly in shell (high risk: attacker-controlled matrix value passed directly to make)

**lint-commit.yaml — 'Check if the pull request contains a single commit' step (sub-rule a):**
- `commit_count=${{ github.event.pull_request.commits }}` — github event data interpolated directly in shell

**lint-commit.yaml — 'Set commit metadata' step (sub-rule a):**
- `if [[ ${{ github.event_name }} == 'push' ]]` — github context interpolated directly in shell
- `FROM_INTERVAL_COMMITLINT=${{ github.event.pull_request.head.sha }}~${{ github.event.pull_request.commits }}` — github event data interpolated directly in shell

Locations:

- `.github/workflows/cd.yml:39`
- `.github/workflows/cd.yml:41`
- `.github/workflows/cd.yml:43`
- `.github/workflows/cd.yml:131`
- `.github/workflows/cd.yml:139`
- `.github/workflows/cd.yml:175`
- `.github/workflows/ci.yml:35`
- `.github/workflows/ci.yml:37`
- `.github/workflows/ci.yml:39`
- `.github/workflows/ci.yml:120`
- `.github/workflows/ci.yml:228`
- `.github/workflows/ci.yml:229`
- `.github/workflows/lint-commit.yaml:22`
- `.github/workflows/lint-commit.yaml:34`
- `.github/workflows/lint-commit.yaml:36`

### github-env-injection (severity: high)

Values derived from untrusted GitHub context expressions are written to $GITHUB_ENV and $GITHUB_OUTPUT without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). This allows an attacker to inject arbitrary environment variables or output values by embedding newlines in the source data.

**cd.yml — 'Set build metadata' step:**
`BUILD_REVISION` is set from `${{ github.sha }}` or `${{ github.event.pull_request.head.sha }}` via direct expression interpolation, then written unsanitized to `$GITHUB_ENV`:
```
echo "BUILD_REVISION=${BUILD_REVISION}" >> "${GITHUB_ENV}"
```

**cd.yml — 'Configure release metadata' step:**
`SEMVER_MAJOR_VERSION` is set from `v${{ steps.release.outputs.major }}` via direct expression interpolation, then written unsanitized to `$GITHUB_ENV`:
```
echo "SEMVER_MAJOR_VERSION=${SEMVER_MAJOR_VERSION}" >> "${GITHUB_ENV}"
```

**ci.yml — 'Set build metadata' step:**
`BUILD_REVISION` is set from `${{ github.sha }}` or `${{ github.event.pull_request.head.sha }}` via direct expression interpolation, then written unsanitized to both `$GITHUB_ENV` and `$GITHUB_OUTPUT`:
```
echo "BUILD_REVISION=${BUILD_REVISION}" >> "${GITHUB_ENV}"
echo "CONTAINER_IMAGE_BUILD_REVISION=${BUILD_REVISION}" >> "${GITHUB_OUTPUT}"
```

**lint-commit.yaml — 'Set commit metadata' step:**
`FROM_INTERVAL_COMMITLINT` and `TO_INTERVAL_COMMITLINT` are set from `${{ github.event.pull_request.head.sha }}` and `${{ github.event.pull_request.commits }}` via direct expression interpolation, then written unsanitized to `$GITHUB_ENV`:
```
echo "FROM_INTERVAL_COMMITLINT=${FROM_INTERVAL_COMMITLINT}" >> "${GITHUB_ENV}"
echo "TO_INTERVAL_COMMITLINT=${TO_INTERVAL_COMMITLINT}" >> "${GITHUB_ENV}"
```

Locations:

- `.github/workflows/cd.yml:41`
- `.github/workflows/cd.yml:43`
- `.github/workflows/cd.yml:60`
- `.github/workflows/cd.yml:139`
- `.github/workflows/cd.yml:143`
- `.github/workflows/ci.yml:37`
- `.github/workflows/ci.yml:39`
- `.github/workflows/ci.yml:58`
- `.github/workflows/ci.yml:63`
- `.github/workflows/lint-commit.yaml:36`
- `.github/workflows/lint-commit.yaml:37`
- `.github/workflows/lint-commit.yaml:55`
- `.github/workflows/lint-commit.yaml:56`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, github-env-injection

**Notes:**

Fixed all three finding types across 7 files:

1. **unpinned-uses**: Pinned all action references to full commit SHAs with tag comments. Container images in action.yml and slim/action.yml pinned with sha256 digests while preserving the docker:// scheme and tag.

2. **script-injection**: Moved all ${{ github.* }}, ${{ steps.* }}, ${{ matrix.* }}, and ${{ env.* }} expressions from run: shell strings into step-level env: blocks. Shell scripts now reference plain environment variables (e.g., ${GH_EVENT_NAME} instead of ${{ github.event_name }}). The matrix.test-case value passed to `make` is now quoted as "${TEST_CASE}" to prevent shell injection.

3. **github-env-injection**: Added sanitization using `printf '%s' "${VAR}" | tr -d '\n\r'` before writing any GitHub context-derived values to $GITHUB_ENV or $GITHUB_OUTPUT in cd.yml, ci.yml, and lint-commit.yaml.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed three unquoted variable expansions:
1. hardened/action/.github/workflows/lint-commit.yaml: Added double-quotes around `${commit_count}` in both `if [ -z "${commit_count}" ]` and `if [[ "${commit_count}" -ne 1 ]]` to prevent shell metacharacter injection from the attacker-influenced `github.event.pull_request.commits` value.
2. hardened/action/.github/workflows/ci.yml (test-local-action job, ~line 196): Changed `docker load --input /tmp/${OUTPUT_IMAGE_NAME}.tar` to `docker load --input "/tmp/${OUTPUT_IMAGE_NAME}.tar"` to properly quote the matrix-derived variable.
3. hardened/action/.github/workflows/ci.yml (run-test-suite job, ~line 270): Same fix applied to the identical pattern in the run-test-suite job.

