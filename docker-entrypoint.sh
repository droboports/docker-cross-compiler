#!/bin/sh

set -o errexit
set -o nounset

if [ "${1:-}" = "build" ]; then
  set -o xtrace
  _name="$(basename "${2}" .git)"
  touch "/dist/.${_name}"
  cd ~/build
  if [ "${_name}" = "${2}" ]; then
    git clone "https://github.com/droboports/${2}.git" "${_name}"
  else
    git clone "${2}" "${_name}"
  fi
  cd "${_name}"
  ./build.sh && cp *.tgz /dist/ || exec bin/bash
  rm -f "/dist/.${2}"
elif [ -z "${1:-}" ]; then
  exec /bin/bash
else
  exec "$@"
fi
