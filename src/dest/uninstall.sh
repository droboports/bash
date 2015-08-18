#!/usr/bin/env sh

prog_dir="$(dirname "$(realpath "${0}")")"
name="$(basename "${prog_dir}")"
tmp_dir="/tmp/DroboApps/${name}"
logfile="${tmp_dir}/uninstall.log"

# boilerplate
if [ ! -d "${tmp_dir}" ]; then mkdir -p "${tmp_dir}"; fi
exec 3>&1 4>&2 1>> "${logfile}" 2>&1
echo "$(date +"%Y-%m-%d %H-%M-%S"):" "${0}" "${@}"
set -o errexit  # exit on uncaught error code
set -o nounset  # exit on unset variable
set -o xtrace   # enable script tracing

if [ -h "/etc/bash.bashrc" ] && [ "$(readlink /etc/bash.bashrc)" = "${prog_dir}/etc/bash.bashrc" ]; then
  rm -f "/etc/bash.bashrc"
fi
if [ -h "/bin/bash" ] && [ "$(readlink /bin/bash)" = "${prog_dir}/bin/bash" ]; then
  rm -f "/bin/bash"
fi

