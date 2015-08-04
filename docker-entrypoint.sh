#!/bin/sh

set -o errexit
set -o nounset

if [ "${1:-}" = "build" ]; then
  set -o xtrace
  shift
  _name="$(basename "${1}" .git)"
  # test write access to /dist
  touch "/dist/.${_name}"
  rm -f "/dist/.${_name}"
  cd ~/build
  if [ "${_name}" = "${1}" ]; then
    git clone "https://github.com/droboports/${1}.git" "${_name}"
  else
    git clone "${1}" "${_name}"
  fi
  cd "${_name}"
  shift
  ./build.sh "$@"
  if [ -n "$(find . -maxdepth 1 -name '*.tgz' -print -quit)" ]; then
    cp *.tgz /dist/
  else
    exec /bin/bash
  fi
elif [ -z "${1:-}" ]; then
  exec /bin/bash
else
  exec "$@"
fi
