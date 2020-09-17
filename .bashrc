# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoredups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=20000
HISTFILESIZE=20000
HISTTIMEFORMAT=$(echo -e "\e[0;32m"[%F %T] "\e[0m")

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
# PS1='\e[1;32m[\W]> \e[m'
export PATH="/home/akshat/.local/bin:/root/.local/bin:/bin/lscript:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/akshat:$HOME/bin"
export PYTHONSTARTUP=~/.pyrc

# Git configuration
# Branch name in prompt
source ~/.git-prompt.sh
PS1='\e[1;32m[\W\e[m\e[0;32m$(__git_ps1 " (%s)")\e[m\e[1;32m]> \e[m'
export PROMPT_COMMAND='echo -ne "\033]0;${PWD/#$HOME/~}\007"'
# Tab completion for branch names
source ~/.git-completion.bash

# some miscellaneous functions
function countdown(){
	date1=$((`date +%s` + $1 + 60*${2:-0} + 3600*${3:-0})); 
	while [ "$date1" -ge `date +%s` ]; do 
		echo -ne " $(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)\r";
		sleep 0.1
	done
	echo
}
function stopwatch(){
	date1=$((`date +%s` + $1 + 60*${2:-0} + 3600*${3:-0}));
   	while [ "$date1" -ge `date +%s` ]; do 
    	echo -ne " $(date -u --date @$((`date +%s` - $date1 + $1)) +%H:%M:%S)\r"; 
    	sleep 0.1
   	done
   	echo
}
function timer(){
	terminator --geometry=280x1+810+0 -p "timer" -x sh ~/ct.sh $1 $2 $3 2>/dev/null & exit
}
function zzzzz(){
   	date1=$((`date +%s` + 60*$1 + 3600*${2:-0}));
   	while [ "$date1" -ge `date +%s` ]; do 
    	notify-send --hint int:transient:1 "                                                             COUNTDOWN" "                                                       $(date -u --date @$(($date1 - `date +%s`)) +%H:%M)";
    	sleep 2
    	xdotool mousemove_relative 1 1
	   	xdotool mousemove_relative -- -1 -1
    	sleep 57.9
   	done
}
function ztimer(){
	zzzzz $1 ${2:-0} & exit
}
function tpc(){
	str="'$@'"
	str=$(sed 's/[,{}\n]//g' <<< $str);
	echo
	echo $str | wc -w
	echo $str | xargs
	echo
}
function b(){
	eval $(xdotool getmouselocation --shell); 
	xdotool mousemove 1900 20; 
	xdotool click 1; 
	xdotool mousemove $((1592+3*$1)) 153; 
	xdotool click 1; 
	xdotool mousemove $X $Y; 
	xdotool click 1;
}
function deb(){
	for var in "$@"
	do
		sudo dpkg -i $var
		if [ $? -gt 0 ]; then
			sudo apt install -f
		fi
	done
}
function g+ (){
	rm temporaryCode 2>/dev/null
	g++ -o temporaryCode $1
	./temporaryCode ${@:2}
	rm temporaryCode 2>/dev/null
}
function g() {
	rm temporaryCode 2>/dev/null
	if grep 'pthread.h' $1 >/dev/null; then
		gcc -pthread -o temporaryCode $1
	elif grep 'bits/stdc++.h' $1 >/dev/null; then
		g++ -o temporaryCode $1
	else
		gcc -o temporaryCode $1
	fi
	./temporaryCode ${@:2}
	rm temporaryCode 2>/dev/null
}
function jv() {
	if [ ${1#*.} == "java" ]; then
		javac $1 2> >(grep -v "^Picked up _JAVA_OPTIONS:" >&2)
	else
		java $1 2> >(grep -v "^Picked up _JAVA_OPTIONS:" >&2)
	fi
}

# function Extract for common file formats

function extract {
 if [ -z "$1" ]; then
    # display usage if no parameters given
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
 else
    for n in "$@"
    do
      if [ -f "$n" ] ; then
          case "${n%,}" in
            *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar) 
                         tar xvf "$n"       ;;
            *.lzma)      unlzma ./"$n"      ;;
            *.bz2)       bunzip2 ./"$n"     ;;
            *.cbr|*.rar)       unrar x -ad ./"$n" ;;
            *.gz)        gunzip ./"$n"      ;;
            *.cbz|*.epub|*.zip)       unzip ./"$n"       ;;
            *.z)         uncompress ./"$n"  ;;
            *.7z|*.apk|*.arj|*.cab|*.cb7|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
                         7z x ./"$n"        ;;
            *.xz)        unxz ./"$n"        ;;
            *.exe)       cabextract ./"$n"  ;;
            *.cpio)      cpio -id < ./"$n"  ;;
            *.cba|*.ace)      unace x ./"$n"      ;;
            *.zpaq)      zpaq x ./"$n"      ;;
            *.arc)         arc e ./"$n"       ;;
            *.cso)       ciso 0 ./"$n" ./"$n.iso" && \
                              extract $n.iso && \rm -f $n ;;
            *)
                         echo "extract: '$n' - unknown archive method"
                         return 1
                         ;;
          esac
      else
          echo "'$n' - file does not exist"
          return 1
      fi
    done
fi
}
