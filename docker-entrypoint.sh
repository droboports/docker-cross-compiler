#!/bin/sh

set -o errexit
set -o nounset

if [ -n "${WITH_BINFMT:-}" ]; then
  sudo /bin/mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc || true
  sudo /usr/sbin/update-binfmts --enable qemu-arm || true
  update-binfmts --display | grep qemu-arm
fi

if [ "${1:-}" = "build" ]; then
  set -o xtrace
  shift
  _name="$(basename "${1}" .git)"
  # test write access to /dist
  touch "/dist/.${_name}"
  rm -f "/dist/.${_name}"
  cd /home/drobo/build

  # base assumptions: arg == URL, no branch/tag
  _repo_url="${1}"
  _branch_tag=""

  # see if URL has a fragment ID ('#') indicating the branch/tag. ('0' means no)
  # NOTE: expr returns a non-zero exit status if it can't find the index, which
  # stops the execution due to errexit. to work around this, we or the command
  # with true to ensure the return value of the subshell is always true
  _hash_idx=$(expr index "${1}" '#' || true)
  if [ "${_hash_idx}" != "0" ]; then
    # NOTE: /bin/sh does not allow for advanced parameter expansions, hence the
    # awk hoops we need to jump through to do simple substrings.
    _repo_url=$(echo $1 | awk -v hashidx=$_hash_idx '{ s=substr($0, 0, hashidx); print s; }' )
    _strlen=${#1}
    _branch_tag=$(echo $1 | awk -v hashidx=$_hash_idx -v strlen=$_strlen '{ s=substr($0, hashidx + 1, strlen - 1); print s; }' )
  fi

  _name="$(basename "${_repo_url}" .git)"

  if [ "${_name}" = "${1}" ]; then
    # arg is repo name, so assume it's a droboports repo
    git clone "https://github.com/droboports/${1}.git" "${_name}"
  else
    if [ "${_branch_tag}" = "" ]; then
      # arg is repo URL without a branch/tag: https://github.com/user/repo.git
      git clone "${1}" "${_name}"
    else
      # arg is repo URL with a branch/tag: https://github.com/user/repo.git#branch-or-tag-name
      git clone -b "${_branch_tag}" --single-branch "${_repo_url}" "${_name}"
    fi
  fi

  cd "${_name}"
  export GOPATH="/mnt/DroboFS/Shares/DroboApps/${_name}"
  shift
  ./build.sh "$@"
  if [ -n "$(find . -maxdepth 1 -name '*.tgz' -print -quit)" ]; then
    cp *.tgz /dist/
  elif [ -n "$(find . -maxdepth 1 -name '*.egg' -print -quit)" ]; then
    cp *.egg /dist/
  else
    exec /bin/bash
  fi
elif [ -z "${1:-}" ]; then
  echo "INFO: Do not forget to export GOPATH=/mnt/DroboFS/Shares/DroboApps/<appname> if using the Golang compiler"
  exec /bin/bash
else
  exec "$@"
fi
