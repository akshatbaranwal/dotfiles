#!/bin/bash

# change rubbish file names of tv series episodes to a more sensible format
episodeRename() {
	SAVEIFS=$IFS
	IFS=$'\n'
	for f in $(ls); do
	   	mv -- "$f" "$(echo $f | grep -oE 'E[0-9]{2}').${f##*.}"
   	done
	IFS=$SAVEIFS
}

countdown(){
	date1=$((`date +%s` + $1 + 60*${2:-0} + 3600*${3:-0})); 
	while [ "$date1" -ge `date +%s` ]; do 
		echo -ne " $(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)\r";
		sleep 0.1
	done
	echo
}

stopwatch(){
	date1=$((`date +%s` + $1 + 60*${2:-0} + 3600*${3:-0}));
   	while [ "$date1" -ge `date +%s` ]; do 
    	echo -ne " $(date -u --date @$((`date +%s` - $date1 + $1)) +%H:%M:%S)\r"; 
    	sleep 0.1
   	done
   	echo
}

# you'll need terminator and a profile named 'timer'
timer() {
	Xaxis=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)
	terminator --geometry=280x1+$(($Xaxis/2-140))+0 -p "timer" -x bash ~/.bash_functions countdown $1 $2 $3 2>/dev/null & exit
}

# convert topcoder irritating test case format
tpc(){
	str="'$@'"
	str=$(sed 's/[,{}\n]//g' <<< $str);
	echo
	echo $str | wc -w
	echo $str | xargs
	echo
}

# brightness hack
b() {
	echo $((685*$1/100)) | sudo tee /sys/class/backlight/intel_backlight/brightness > /dev/null
}

# install deb pkg with dependencies
deb(){
	for var in "$@"
	do
		sudo dpkg -i $var
	done
	sudo apt install -f
}

# quick C/C++ compile and run
g() {
	rm temporaryCode 2>/dev/null
	if [ ${1#*.} == "cpp" ] || grep 'bits/stdc++.h' -- $1 >/dev/null; then
		g++ -o temporaryCode $1
	elif grep -E 'pthread.h|semaphore.h' -- $1 >/dev/null; then
		gcc -pthread -o temporaryCode $1
	elif grep -E 'math.h' -- $1 >/dev/null; then
		gcc -lm -o temporaryCode $1
	else
		gcc -o temporaryCode $1
	fi
	./temporaryCode ${@:2}
	rm temporaryCode 2>/dev/null
	echo
}

# quick java compile and run
jv() {
	if [ ${1#*.} == "java" ]; then
		javac -verbose $1 2> >(grep wrote) | grep -v '\$' | awk {'print substr($2,0,length($2)-1)'}
		#javac $1 2> >(grep -v "^Picked up _JAVA_OPTIONS:" >&2)
	elif [ ${1#*.} == "class" ]; then
		java ${1%.*} ${@:2} 2> >(grep -v "^Picked up _JAVA_OPTIONS:" >&2)
	else
		java $1 ${@:2} 2> >(grep -v "^Picked up _JAVA_OPTIONS:" >&2)
	fi
	echo
}

# toggle turbo boost
turbo() {
	cd /sys/devices/system/cpu/intel_pstate
	echo $((1-$(cat no_turbo))) | sudo tee no_turbo >/dev/null
	if [ $(cat no_turbo) -eq 1 ]; then
		echo Turbo Boost OFF
	else
		echo Turbo Boost ON
	fi
	cd ~-
}


# function Extract for common file formats
extract() {
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

# google classroom quick class join
# put the following lines in crontab
# 1 9,15 * * 1-5 export DISPLAY=:0 && /home/$(whoami)/.bash_functions class
# 11 11 * * 1-5 export DISPLAY=:0 && /home/$(whoami)/.bash_functions class
# echo <password> | sudo -S /home/akshat/.bash_functions <function> 2>/dev/null | xargs -d '\n' notify-send
class() {
	classDetails='

	 9-11 11-1 3-5
Mon: DAA  PPL  DAA
Tue: SOE  CN   PPL
Wed: SOE  DBMS PPL
Thu: CN   DBMS SOE
Fri: DBMS CN   DAA

PPL https://meet.google.com/lookup/ew55xe2fqk?authuser=1
SOE https://meet.google.com/lookup/aifyofpkns?authuser=1
CN https://meet.google.com/lookup/f76m7gdhyh?authuser=1
DBMS https://meet.google.com/lookup/hwlsbmorxm?authuser=1
DAA https://iiita.webex.com/iiita/j.php?MTID=m360c447cfed36debd0295c1d7ccc386e'

	if [ $(date +%u) -gt 5 ]; then
		echo "Enjoy Your Weekend!"
	elif [ $(date +%H) -gt 16 ] || [ $(date +%H) -lt 8 ]; then
		echo "No More Classes Left!"
	else
		echo "$classDetails" | grep $(echo "$classDetails" | awk -v row="$(($(date +%u)+3))" -v col="$(date +%H)" 'NR==row { 
				if(col >= 8 && col <= 10) print $2; 
				else if(col >= 11 && col <= 13) print $3; 
				else if(col >= 14 && col <= 16) print $4;
				}' | tr '[:lower:]' '[:upper:]') | tail -n1 | pee "cut -f1 -d' ' | xargs notify-send --hint int:transient:1" "cut -f2 -d' ' | xargs xdg-open" & exit
	fi
}

sql() {
	if ! systemctl --no-pager status mariadb >/dev/null; then
		systemctl start mariadb
	fi
	echo
	mycli -u akshat -p a
}

# check if shutdown is scheduled
shutdownCheck() {
	k="$(date --date=@$(($(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager ScheduledShutdown | cut -d' ' -f3)/1000000)))"
	if [ $(echo $k | cut -f4 -d' ') -ne 1970 ]; then
		echo $k
		read -p "Want to Cancel? [Y/n] " k
		echo ${k:=n} > /dev/null
		if [ ${k:0:1} = 'y' ] || [ ${k:0:1} = 'Y' ]; then
			shutdown -c
		fi
	else
		echo "No Shutdown Scheduled"
	fi
}

# bubbyee
byee() {
	shutdown -P +${1:-0}
}

# battery conservation mode toggle
conservationMode () {
	cd /sys/bus/platform/drivers/ideapad_acpi/VPC2004\:00/
    echo $((1-$(cat conservation_mode))) | sudo tee conservation_mode > /dev/null;
    if [ $(cat conservation_mode) -eq 1 ]; then
        echo Conservation Mode ON;
    else
        echo Conservation Mode OFF;
    fi
    cd ~-
}

"$@"
