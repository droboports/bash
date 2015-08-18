# Add all DroboApps to the proper environment variables
export DROBOAPPS=/mnt/DroboFS/Shares/DroboApps

for APP in ${DROBOAPPS}/*; do
  if [ -d "$APP/bin" ]; then
    if [ "$PATH" == "${PATH/$APP\/bin/}" ]; then
      export PATH="$APP/bin:$PATH"
    fi
  fi
  if [ "${UID}" == 0 -a -d "$APP/sbin" ]; then
    if [ "$PATH" == "${PATH/$APP\/sbin/}" ]; then
      export PATH="$APP/sbin:$PATH"
    fi
  fi
# All DroboApps should be self-contained. Uncomment only if you know what you are doing.
#  if [ -d "$APP/lib" ]; then
#    if [ "$LD_LIBRARY_PATH" == "${LD_LIBRARY_PATH/$APP\/lib/}" ]; then
#      export LD_LIBRARY_PATH="$APP/lib:$LD_LIBRARY_PATH"
#    fi
#  fi
done
