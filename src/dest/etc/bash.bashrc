[ -z "$PS1" ] && return
shopt -s checkwinsize
PS1='\u@\h \w \$? \$ '
