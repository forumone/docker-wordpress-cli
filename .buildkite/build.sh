#!/bin/bash

set -euo pipefail

# USAGE: $0 <version> [tags...]
# * version is the full PHP version (major, minor, and patch)
# * tag is an extra tag to use (e.g., 7.2 or latest)

# Required environment variables: WP_CLI_VERSION
# * WP_CLI_VERSION is the full version of the latest WP-CLI release

repository=forumone/wordpress-cli

# This is the full PHP version, as mentioned above in the USAGE block.
version="$1"
shift

# Tags other than the full PHP version to apply to this build - typically just the minor
# version (e.g., 7.2) but may include the major version or "latest".
extra_tags=("$@")

# Used by build() function - we have two sets of variable arguments passed to build,
# so one of them has to get passed laterally.
#
# It's easier to use the tags array because its size depends on the arguments to this script,
# so we will have to do a loop over the array regardless of whether it gets passed as $@,
# whereas there is a fixed number of build args, making it easier to simply write them out
# in the function call.
declare -a tags

# Usage: should-push
#
# This function determines if the built images should be pushed up to the Docker Hub.
# There are a few conditions:
#   1. This must not be a local build,
#   2. This must not be triggered by a pull request, and
#   3. The branch being built must be master.
should-push() {
  test "$BUILDKITE_PIPELINE_PROVIDER" != local &&
    test "$BUILDKITE_PULL_REQUEST" == false &&
    test "$BUILDKITE_BRANCH" == master
}

# Usage:
#
#   # Set up the tags array variable before calling
#   tags=([tag-name...])
#   build [build-arg...]
#
# * build-arg is of the form ARG_NAME=value, as expected by --build-arg
# * tag-name is a Docker image tag
#
# NB. This function reads from the tags variable as well as its own arguments.
build() {
  local build_args=("$@")

  # Holds arguments to docker build
  local docker_args=()

  for tag in "${tags[@]}"; do
    docker_args+=(--tag "$tag")
  done

  for arg in "${build_args[@]}"; do
    docker_args+=(--build-arg "$arg")
  done

  docker build . \
    --pull \
    "${docker_args[@]}"
}

echo "--- Build"
tags=()
for tag in "$version" "${extra_tags[@]}"; do
  cli_tag="$tag-cli$WP_CLI_VERSION"
  tags+=("$repository:$tag" "$repository:${cli_tag#latest-}")
done

build PHP_VERSION="$version" WP_CLI_VERSION="$WP_CLI_VERSION"

if should-push; then
  echo "--- Push"
  docker push "$repository"
fi
