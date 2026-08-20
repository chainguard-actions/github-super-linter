#!/usr/bin/env bash
set -euo pipefail

# A simple valid shell script for testing super-linter
main() {
  local name="${1:-world}"
  echo "Hello, ${name}!"
}

main "$@"
