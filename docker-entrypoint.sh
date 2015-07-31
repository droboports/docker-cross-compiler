#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

if [ "${1:-}" = "build" ]; then
  touch "/dist/.${2}"
  cd ~/build
  git clone "https://github.com/droboports/${2}.git"
  cd "${2}"
  exec ./build.sh
  cp *.tgz *.egg /dist/
else
  exec "$@"
fi
