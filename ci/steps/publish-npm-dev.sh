#!/usr/bin/env bash
set -euo pipefail

main() {
  # We need VERSION to bump the brew formula
  if ! is_env_var_set "TAG"; then
    echo "TAG is not set. Cannot publish to npm without setting a tag"
    exit 1
  fi
  cd "$(dirname "$0")/../.."
  source ./ci/lib.sh

  if [[ ${CI-} ]]; then
    echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > ~/.npmrc
  fi

  download_artifact npm-package ./release-npm-package
  # https://github.com/actions/upload-artifact/issues/38
  tar -xzf release-npm-package/package.tar.gz

  # Ignore symlink when publishing npm package
  # See: https://github.com/cdr/code-server/pull/3935
  echo "node_modules.asar" > release/.npmignore
  yarn publish --non-interactive release --tag "$TAG"
}

main "$@"
