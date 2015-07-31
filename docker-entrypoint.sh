#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

if [ "${1:-}" = "build" ]; then
  cd ~/build
  git clone "https://github.com/droboports/${2}.git"
  cd "${2}"
  exec ./build.sh
else
  exec "$@"
fi
