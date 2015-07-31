#!/bin/sh

set -o errexit
set -o nounset

if [ "${1}" == "build" ]; then
  cd ~/build
  git clone "https://github.com/droboports/${2}.git"
  cd "${2}"
  exec ./build.sh
  exit $?
fi

exec "$@"
