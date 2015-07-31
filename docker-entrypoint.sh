#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

if [ "${1:-}" = "build" ]; then
  touch "/dist/.${2}"
  cd ~/build
  git clone "https://github.com/droboports/${2}.git"
  cd "${2}"
  ./build.sh
  cp *.tgz *.egg /dist/
elif [ -z "${1:-}" ]; then
  exec /bin/bash
else
  exec "$@"
fi
