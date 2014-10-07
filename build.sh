#!/usr/bin/env bash

### bash best practices ###
# exit on error code
set -o errexit
# exit on unset variable
set -o nounset
# return error of last failed command in pipe
set -o pipefail
# expand aliases
shopt -s expand_aliases
# print trace
set -o xtrace

### logfile ###
timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
logfile="logfile_${timestamp}.txt"
echo "${0} ${@}" > "${logfile}"
# save stdout to logfile
exec 1> >(tee -a "${logfile}")
# redirect errors to stdout
exec 2> >(tee -a "${logfile}" >&2)

### environment variables ###
source crosscompile.sh
export NAME="bash"
export DEST="/mnt/DroboFS/Shares/DroboApps/${NAME}"
export DEPS="${PWD}/target/install"
export XDEST=~/xtools/python2
#export CFLAGS="$CFLAGS -Os -fPIC -ffunction-sections -fdata-sections"
export CFLAGS="$CFLAGS -Os"
export CXXFLAGS="$CXXFLAGS $CFLAGS"
#export CPPFLAGS="-I${DEPS}/include"
#export LDFLAGS="${LDFLAGS:-} -Wl,-rpath,${DEST}/lib -L${DEST}/lib"
export PKG_CONFIG_LIBDIR="${DEST}/lib/pkgconfig"
alias make="make -j8 V=1 VERBOSE=1"

# $1: file
# $2: url
# $3: folder
_download_tgz() {
  [[ ! -f "download/${1}" ]] && wget -O "download/${1}" "${2}"
  [[ -d "target/${3}" ]] && rm -v -fr "target/${3}"
  [[ ! -d "target/${3}" ]] && tar -zxvf "download/${1}" -C target
}

### BASH ###
_build_bash() {
local VERSION="4.3"
local FOLDER="bash-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://ftp.gnu.org/gnu/bash/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
for n in {001..030}; do
  if [[ ! -f "${PWD}/download/bash-${VERSION}-${n}.patch" ]]; then
    wget -O "${PWD}/download/bash-${VERSION}-${n}.patch" "http://ftp.gnu.org/gnu/bash/bash-4.3-patches/bash43-${n}"
  fi
done

for f in ${PWD}/download/bash-${VERSION}-*.patch; do
  pushd "target/${FOLDER}"
  echo "${f}"
  patch -p0 < "${f}"
  popd
done

pushd "target/${FOLDER}"
./configure --host=arm-none-linux-gnueabi --prefix="${DEST}"
# LDFLAGS="$LDFLAGS -Wl,--gc-sections"
make
make install
"${STRIP}" --strip-all -R .comment -R .note -R .note.ABI-tag "${DEST}/bin/bash"
popd
}

### BUILD ###
_build() {
  _build_bash
  _package
}

_create_tgz() {
  local appname="$(basename ${PWD})"
  local appfile="${PWD}/${appname}.tgz"

  if [[ -f "${appfile}" ]]; then
    rm -v "${appfile}"
  fi

  pushd "${DEST}"
  tar --verbose --create --numeric-owner --owner=0 --group=0 --gzip --file "${appfile}" *
  popd
}

_package() {
  cp -v -aR src/dest/* "${DEST}"/
  find "${DEST}" -name "._*" -print -delete
  _create_tgz
}

_clean() {
  rm -v -fr "${DEPS}"
  rm -v -fr "${DEST}"
  rm -v -fr target/*
}

_dist_clean() {
  _clean
  rm -v -f logfile*
  rm -v -fr download/*
}

case "${1:-}" in
  clean)     _clean ;;
  distclean) _dist_clean ;;
  package)   _package ;;
  "")        _build ;;
  *)         _build_${1} ;;
esac
