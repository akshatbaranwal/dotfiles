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

# productivity hack
function timer() {
	Xaxis=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)
	terminator --geometry=280x1+$(($Xaxis/2-140))+0 -p "timer" -x bash ~/.bash_functions countdown $1 $2 $3 2>/dev/null & exit
}

#convert topcoder test case format
function tpc(){
	str="'$@'"
	str=$(sed 's/[,{}\n]//g' <<< $str);
	echo
	echo $str | wc -w
	echo $str | xargs
	echo
}

# ignore
function b(){
	eval $(xdotool getmouselocation --shell); 
	xdotool mousemove 1900 20; 
	xdotool click 1; 
	xdotool mousemove $((1592+3*$1)) 153; 
	xdotool click 1; 
	xdotool mousemove $X $Y; 
	xdotool click 1;
}

# install deb pkg with dependencies
function deb(){
	for var in "$@"
	do
		sudo dpkg -i $var
		if [ $? -gt 0 ]; then
			sudo apt install -f
		fi
	done
}

# quick C++ compile and run
function g+ (){
	rm temporaryCode 2>/dev/null
	g++ -o temporaryCode $1
	./temporaryCode ${@:2}
	rm temporaryCode 2>/dev/null
}

# quick C compile and run
function g() {
	rm temporaryCode 2>/dev/null
	if [ ${1#*.} == "cpp" ] || grep 'bits/stdc++.h' -- $1 >/dev/null; then
		g++ -o temporaryCode $1
	elif grep -E 'pthread.h|semaphore.h' -- $1 >/dev/null; then
		gcc -pthread -o temporaryCode $1
	else
		gcc -o temporaryCode $1
	fi
	./temporaryCode ${@:2}
	rm temporaryCode 2>/dev/null
}

# quick java compile and run
function jv() {
	if [ ${1#*.} == "java" ]; then
		javac -verbose $1 2> >(grep wrote) | grep -v '\$' | awk {'print substr($2,0,length($2)-1)'}
		#javac $1 2> >(grep -v "^Picked up _JAVA_OPTIONS:" >&2)
	elif [ ${1#*.} == "class" ]; then
		java ${1%.*} ${@:2} 2> >(grep -v "^Picked up _JAVA_OPTIONS:" >&2)
	else
		java $1 ${@:2} 2> >(grep -v "^Picked up _JAVA_OPTIONS:" >&2)
	fi
}

# toggle turbo boost
function turbo() {
	echo $((1-$(cat /sys/devices/system/cpu/intel_pstate/no_turbo))) | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo >/dev/null
	if [ $(cat /sys/devices/system/cpu/intel_pstate/no_turbo) -eq 1 ]; then
		echo Turbo Boost OFF
	else
		echo Turbo Boost ON
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

"$@"
