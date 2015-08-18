#!/usr/bin/env sh
#
# Service.sh for bash

# import DroboApps framework functions
. /etc/service.subr

framework_version="2.1"
name="bash"
version="4.3.42"
description="Bourne Again Shell version 4.3.42"
depends=""
webui=""

prog_dir="$(dirname "$(realpath "${0}")")"
tmp_dir="/tmp/DroboApps/${name}"
pidfile="${tmp_dir}/pid.txt"
logfile="${tmp_dir}/log.txt"
statusfile="${tmp_dir}/status.txt"
errorfile="${tmp_dir}/error.txt"

# backwards compatibility
if [ -z "${FRAMEWORK_VERSION:-}" ]; then
  framework_version="2.0"
  . "${prog_dir}/libexec/service.subr"
fi

# symlink /etc/bash.bashrc
if [ ! -e "/etc/bash.bashrc" ]; then
  ln -s "${prog_dir}/etc/bash.bashrc" "/etc/bash.bashrc"
elif [ -h "/etc/bash.bashrc" ] && [ "$(readlink /etc/bash.bashrc)" != "${prog_dir}/etc/bash.bashrc" ]; then
  ln -fs "${prog_dir}/etc/bash.bashrc" "/etc/bash.bashrc"
fi
# symlink /bin/bash
if [ ! -e "/bin/bash" ]; then
  ln -s "${prog_dir}/bin/bash" "/bin/bash"
elif [ -h "/bin/bash" ] && [ "$(readlink /bin/bash)" != "${prog_dir}/bin/bash" ]; then
  ln -fs "${prog_dir}/bin/bash" "/bin/bash"
fi

start() {
  rm -f "${errorfile}"
  echo "Bash is configured." > "${statusfile}"
  touch "${pidfile}"
  return 0
}

is_running() {
  [ -f "${pidfile}" ]
}

stop() {
  rm -f "${pidfile}"
  return 0
}

force_stop() {
  rm -f "${pidfile}"
  return 0
}

# boilerplate
if [ ! -d "${tmp_dir}" ]; then mkdir -p "${tmp_dir}"; fi
exec 3>&1 4>&2 1>> "${logfile}" 2>&1
STDOUT=">&3"
STDERR=">&4"
echo "$(date +"%Y-%m-%d %H-%M-%S"):" "${0}" "${@}"
set -o errexit  # exit on uncaught error code
set -o nounset  # exit on unset variable
set -o xtrace   # enable script tracing

main "${@}"
