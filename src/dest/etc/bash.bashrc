# preferred timezone
tz="GMT"
# preferred locale
locale="en_US.UTF-8"

export TZ="${tz}"
if [ -x /mnt/DroboFS/Shares/DroboApps/locale/bin/locale ]; then
  export LANG="${locale}"
  export LC_ALL="${locale}"
fi

if [ -f /mnt/DroboFS/Shares/DroboApps/bash/etc/inputrc ]; then
  export INPUTRC=/mnt/DroboFS/Shares/DroboApps/bash/etc/inputrc
fi

if [ -f /mnt/DroboFS/Shares/DroboApps/bash/etc/droboapps.profile ]; then
  . /mnt/DroboFS/Shares/DroboApps/bash/etc/droboapps.profile
fi

[ -z "$PS1" ] && return

shopt -s checkwinsize
case "$TERM" in
  xterm-color) color_prompt=yes ;;
esac

if [ "$color_prompt" = yes ] && [ -f /usr/bin/esa_color.sh ]; then
  unset color_prompt
  export PS1='\[\033[$(/usr/bin/esa_color.sh)m\]\h\[\033[0m\]:\w \$ '
else
  export PS1='\h:\w \$ '
fi
