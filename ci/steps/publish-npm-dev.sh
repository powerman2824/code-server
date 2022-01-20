#!/usr/bin/env bash
set -euo pipefail

main() {
  cd "$(dirname "$0")/../.."
  source ./ci/lib.sh
  source ./ci/steps/steps-lib.sh

  # We need VERSION to update the package.json
  if ! is_env_var_set "TAG"; then
    echo "TAG is not set. Cannot publish to npm without setting a tag."
    exit 1
  fi

  # We need TAG to know what to publish under on npm
  if ! is_env_var_set "TAG"; then
    echo "TAG is not set. Cannot publish to npm without setting a tag."
    exit 1
  fi

  # Needed ot publish on NPM
  if ! is_env_var_set "NPM_TOKEN"; then
    echo "NPM_TOKEN is not set. Cannot publish to npm without credentials."
    exit 1
  fi

  # Needed to use GitHub API
  if ! is_env_var_set "GITHUB_TOKEN"; then
    echo "GITHUB_TOKEN is not set. Cannot download npm release artifact without GitHub credentials."
    exit 1
  fi

  if ! is_env_var_set "NPM_TAG"; then
    echo "NPM_TAG is not set. This is needed for tagging the npm release."
    exit 1
  fi

  echo "using tag: $TAG"

  if [[ ${CI-} ]]; then
    echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > ~/.npmrc
  fi

  download_artifact npm-package ./release-npm-package
  # https://github.com/actions/upload-artifact/issues/38
  tar -xzf release-npm-package/package.tar.gz

  # Ignore symlink when publishing npm package
  # See: https://github.com/cdr/code-server/pull/3935
  echo "node_modules.asar" > release/.npmignore
  # TODO@jsjoeio
  # There are two things that need to happen
  # in order to publish on npm, we need to change the version
  # and possibly change the tag
  pushd release
  # This modifes the version in the package.json
  npm version "$VERSION-$TAG"
  popd

  yarn publish --non-interactive release --tag "$NPM_TAG"
}

main "$@"
