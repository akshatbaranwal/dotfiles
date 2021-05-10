#!/bin/bash

# notify for root
notify_send() {
    local display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)";
    local user=$(who | grep '('$display')' | awk '{print $1}' | head -n 1);
    local uid=$(id -u $user);
    sudo -u $user DISPLAY=$display DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus notify-send  --hint int:transient:1 "$@"
}

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
brightness() {
	cd /sys/class/backlight/intel_backlight
	brightness=$(cat brightness)
	case $# in
		1)
			brightness=$((685*$1));
			;;
		2)
			if [ $1 = '--increase' ]; then
				brightness=$(($brightness+$2*685));
			elif [ $1 = '--decrease' ]; then
				brightness=$(($brightness-$2*685));
			else
				echo "Usage: b [--increase|--decrease] brightness_percent";
				cd ~-;
				return 1;
			fi
			;;
		*)
			echo "Usage: b [--increase|--decrease] brightness_percent";
			cd ~-;
			return 1;
			;;
	esac
	if [ $brightness -lt 0 ]; then
		brightness=0;
	elif [ $brightness -gt $(cat max_brightness) ]; then
		brightness=$(cat max_brightness);
	fi
	echo $brightness | sudo tee brightness >/dev/null
	cd ~-
}

# install deb pkg with dependencies
deb() {
	if [ $# -eq 0 ]; then
		ls -c | grep --color=NEVER .*\.deb$;
	else
		for var in "$@"; do
			sudo dpkg -i $var
		done
		yes | sudo apt install -f
	fi
}

# quick C/C++ compile and run
g() {
	rm temporaryCode 2>/dev/null
	if [ ${1#*.} == "cpp" ] || grep 'bits/stdc++.h' -- $1 >/dev/null; then
		g++ -o temporaryCode $1
	elif grep -E 'pthread.h|semaphore.h' -- $1 >/dev/null; then
		gcc -pthread -o temporaryCode $1
	elif grep -E 'math.h' -- $1 >/dev/null; then
		gcc -o temporaryCode $1 -lm
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
	cd /sys/devices/system/cpu/intel_pstate > /dev/null
	echo $((1-$(cat no_turbo))) | sudo tee no_turbo >/dev/null
	if [ $(cat no_turbo) -eq 1 ]; then
		echo Turbo Boost OFF
	else
		echo Turbo Boost ON
	fi
	cd ~- > /dev/null
}


# function Extract for common file formats
extract() {
  SAVEIFS=$IFS
  IFS="$(printf '\n\t')"
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
            *.cbr|*.rar) unrar x -ad ./"$n" ;;
            *.gz)        gunzip ./"$n"      ;;
            *.cbz|*.epub|*.zip) unzip ./"$n";;
            *.z)         uncompress ./"$n"  ;;
            *.7z|*.apk|*.arj|*.cab|*.cb7|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
                         7z x ./"$n"        ;;
            *.xz)        unxz ./"$n"        ;;
            *.exe)       cabextract ./"$n"  ;;
            *.cpio)      cpio -id < ./"$n"  ;;
            *.cba|*.ace) unace x ./"$n"     ;;
            *.zpaq)      zpaq x ./"$n"      ;;
            *.arc)       arc e ./"$n"       ;;
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
  IFS=$SAVEIFS
}

# google classroom quick class join
# put the following lines in crontab
# 1 9,15 * * 1-5 export DISPLAY=:0 && /home/$(whoami)/.bash_functions class
# 11 11 * * 1-5 export DISPLAY=:0 && /home/$(whoami)/.bash_functions class

# create gnome-extension with this command
# echo <password> | sudo -S /home/akshat/.bash_functions <function> 2>/dev/null
class() {
	classDetails='

	 9-11 11-1 3-5
Mon: DAA  PPL  DAA
Tue: SOE  CN   PPL
Wed: SOE  DBMS PPL
Thu: CN   DBMS_TUT SOE
Fri: DBMS CN   DAA

PPL https://meet.google.com/lookup/ew55xe2fqk?authuser=1
SOE https://meet.google.com/lookup/aifyofpkns?authuser=1
CN https://meet.google.com/lookup/f76m7gdhyh?authuser=1
DBMS https://iiita.webex.com/iiita/j.php?MTID=mbaa03df1c03de37ee86f93989ae916fc
DBMS_TUT https://meet.google.com/lookup/hwlsbmorxm?authuser=1
DAA https://iiita.webex.com/iiita/j.php?MTID=m360c447cfed36debd0295c1d7ccc386e'

	if [ $(date +%u) -gt 5 ]; then
		notify_send "Enjoy Your Weekend!"
	elif [ $(date +%H) -gt 16 ] || [ $(date +%H) -lt 8 ]; then
		notify_send "No More Classes Left!"
	else
		echo "$classDetails" | grep -iw $(echo "$classDetails" | awk -v row="$(($(date +%u)+3))" -v col="$(date +%H)" 'NR==row { 
				if(col >= 8 && col <= 10) print $2; 
				else if(col >= 11 && col <= 13) print $3; 
				else if(col >= 14 && col <= 16) print $4;
				}') | tail -n1 | pee "cut -f1 -d' ' | xargs $HOME/.bash_functions notify_send" "cut -f2 -d' ' | xargs xdg-open"
	fi
	unset classDetails
}

# mycli shortcut
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
		read -p "Want to Cancel? [N/y] " k
		echo ${k:=n} > /dev/null
		if [ ${k:0:1} = 'y' ] || [ ${k:0:1} = 'Y' ]; then
			shutdown -c
			echo "Shutdown Cancelled"
		else
			echo "Shutdown NOT Cancelled"
		fi
	else
		echo "No Shutdown Scheduled"
	fi
	unset k
}

# bubbyee
byee() {
	shutdown -P +${1:-0}
}

# battery conservation mode toggle
conservationMode () {
	cd /sys/bus/platform/drivers/ideapad_acpi/VPC2004\:00/ >/dev/null
    echo $((1-$(cat conservation_mode))) | sudo tee conservation_mode > /dev/null;
    if [ $(cat conservation_mode) -eq 1 ]; then
		notify_send "Conservation Mode ON"
    else
		notify_send "Conservation Mode OFF"
    fi
    cd ~- >/dev/null
}

# ssh to phone
sphone() {
	if [ -z $1 ]; then
		ssh -p 8022 u0_a188@$(ip neigh | grep "40:b0:76:d4:ca:c6" | cut -d' ' -f1)
	else
		ssh -p 8022 u0_a188@$1
	fi
}

# mount phone
mphone() {
	if [ -z "$(ls /media/akshat/Phone)" ]; then
		if [ -z $1 ]; then
			sudo sshfs -o allow_other u0_a188@$(ip neigh | grep "40:b0:76:d4:ca:c6" | cut -d' ' -f1):/storage/emulated/0 /media/akshat/Phone -p 8022;
		else
			sudo sshfs -o allow_other u0_a188@$1:/storage/emulated/0 /media/akshat/Phone -p 8022;
		fi
	fi
	if [ -z "$(ls /media/akshat/Phone)" ]; then
		echo "Mount Failed";
	else
		cd /media/akshat/Phone;
	fi
}

# display phone screen on ur laptop

# connect phone and pc to same network
# enable usb debugging on phone
# run this
# disconnect usb

# use this to create a shortcut
# gnome-terminal --geometry=50x6+1870 -- sh -c "echo > $HOME/nohup.out; /usr/bin/nohup $HOME/.bash_functions dphone 2>/dev/null & while ! ps x | grep -v grep | grep scrcpy; do timeout 2 tail -f $HOME/nohup.out; done"

dphone() {
	pkill scrcpy
	if ! which adb >/dev/null; then
		sudo apt install adb
	elif ! which scrcpy >/dev/null; then
		sudo apt install scrcpy
	fi
	unlock() {
		e=$(adb devices | head -n2 | tail -n1 | awk '{print $1}')
		if [ $(adb -s $e shell dumpsys power | grep mWakefulness= | cut -f2 -d=) = 'Awake' ]; then
			adb -s $e shell input keyevent 26
		fi
		adb -s $e shell input keyevent 26 && adb -s $e shell input keyevent 82 && adb -s $e shell input text $1 && adb -s $e shell input keyevent 66
	}
	waitForUSB() {
		while ! adb devices -l | grep "\busb\b" >/dev/null; do
			sleep 1
		done;
	}
	export -f waitForUSB
	pingPhone() {
		ping -c 1 $(adb devices | tail -n2 | head -n1 | awk '{print $1}' | cut -f1 -d:) | grep Unreachable >/dev/null
	}
	displayPhone() {
		if adb -s $(adb devices | head -n2 | tail -n1 | awk '{print $1}') shell dumpsys power | grep mUserActivityTimeoutOverrideFromWindowManager=10000 > /dev/null; then
			unlock 4739 && sleep 1
		fi
		if ps x | grep -v grep | grep vscode > /dev/null; then
			(scrcpy --always-on-top --bit-rate 2M --max-size 800 --max-fps 15 --turn-screen-off --lock-video-orientation 0 --window-x 1528 --window-y 214 -s $(adb devices | head -n2 | tail -n1 | awk '{print $1}') >/dev/null 2>&1)
			#(scrcpy --always-on-top --max-size 800 --turn-screen-off --lock-video-orientation 0 --window-x 1528 --window-y 214 -s $(adb devices | head -n2 | tail -n1 | awk '{print $1}') >/dev/null 2>&1)
		else
			(scrcpy --bit-rate 2M --max-size 800 --max-fps 15 --turn-screen-off --lock-video-orientation 0 --window-x 1528 --window-y 214 -s $(adb devices | head -n2 | tail -n1 | awk '{print $1}') >/dev/null 2>&1)
			#(scrcpy --max-size 800 --turn-screen-off --lock-video-orientation 0 --window-x 1528 --window-y 214 -s $(adb devices | head -n2 | tail -n1 | awk '{print $1}') >/dev/null 2>&1)
		fi
		if adb devices -l | grep "\busb\b" >/dev/null; then
			sleep 4
		else
			sleep 1
		fi
		if ! ps x | grep -v grep | grep scrcpy > /dev/null && [ $(adb -s $(adb devices | head -n2 | tail -n1 | awk '{print $1}') shell dumpsys power | grep mWakefulness= | cut -f2 -d=) = 'Awake' ]; then
			adb -s $(adb devices | head -n2 | tail -n1 | awk '{print $1}') shell input keyevent 26
		fi
		#if [ $(adb -s $(adb devices | head -n2 | tail -n1 | awk '{print $1}') shell dumpsys activity services com.termux | wc -l) -eq 2 ]; then
		#	adb -s $(adb devices | head -n2 | tail -n1 | awk '{print $1}') shell monkey -p com.termux 1 >/dev/null;
		#fi
	}
	connectPhone() {
		adb kill-server
		adb start-server 2>/dev/null
		waitForUSB
		if [ -z "$(hostname -I)" ]; then
			echo "Connect Laptop to Wifi"
		else
			if [ $(adb shell settings get global wifi_on) -eq 0 ]; then
				adb shell svc wifi enable
				# adb shell am start -n com.steinwurf.adbjoinwifi/.MainActivity -e ssid Vandanalok4G >/dev/null
				# adb shell am force-stop com.steinwurf.adbjoinwifi
				sleep 3
			fi
			echo Trying to connect
			adb connect $(adb shell ip route 2>/dev/null | grep wlan0 | awk '{print $9}'):5555 >/dev/null
			sleep 1
			for i in {4..7}; do
				if adb devices 2>/dev/null | grep 5555 >/dev/null; then
					break
				fi
				echo "Trial $((i-3))"
				adb shell svc wifi disable
				adb shell svc wifi enable
				# adb shell am start -n com.steinwurf.adbjoinwifi/.MainActivity -e ssid Vandanalok4G >/dev/null
				# adb shell am force-stop com.steinwurf.adbjoinwifi
				sleep $i
				adb connect $(adb shell ip route 2>/dev/null | grep wlan0 | awk '{print $9}'):5555 >/dev/null;
				sleep 1
			done
			if adb devices 2>/dev/null | grep 5555 >/dev/null; then
				notify_send "Wireless connected: $(adb devices -l | tail -n2 | head -n1 | cut -f4 -d: | awk '{print $1}')"
			fi
		fi
	}
	if ! ps x | grep -v grep | grep adb >/dev/null; then
		adb start-server 2>/dev/null
	fi
	if [ -z "$(hostname -I)" ]; then
		echo "Laptop Wifi Not Connected"
	fi
	if [ $(adb devices | wc -l) -eq 2 ] || ([ $(adb devices | wc -l) -eq 3 ] && (adb devices | grep offline >/dev/null || adb devices -l | grep "\busb\b" >/dev/null || (echo "Trying to reach network" && pingPhone))); then
		if ! timeout 1 bash -c waitForUSB; then
			echo "Waiting for USB connection..."
		fi
		while ! timeout 1 bash -c waitForUSB && [ -z "$(hostname -I)" ]; do
			sleep 1
		done
		if [ ! -z "$(hostname -I)" ] && ! adb devices -l | grep "\busb\b" >/dev/null && [ $(adb devices | wc -l) -eq 3 ] && ! pingPhone; then
			displayPhone
		elif timeout 10 bash -c waitForUSB; then
			connectPhone & displayPhone
		else
			echo "No USB device detected"
		fi
	else
		if adb devices -l | grep "\busb\b" >/dev/null && ! [ $(adb -d shell ip route | grep wlan0 | awk '{print $9}') = $(adb devices | tail -n2 | head -n1 | awk '{print $1}' | cut -f1 -d:) ] 2>/dev/null; then
			connectPhone & displayPhone
		elif ! pingPhone; then
			notify_send "Wireless connected: $(adb devices -l | tail -n2 | head -n1 | cut -f4 -d: | awk '{print $1}')"
			displayPhone
		elif adb devices -l | grep "\busb\b" >/dev/null; then
			displayPhone
		else
			echo "Phone on a different network"
		fi
	fi
}

# search through the history
hgrep() {
	temp_history="$(history)"
	for word in "$@"; do
		temp_history=$(echo "$temp_history" | grep $word)
	done;
	echo "$temp_history"
	unset temp_history
}

# easily change Prompt
ps1() {
	if [ $# -eq 0 ]; then
		cat ~/.ps1_default > ~/.ps1_current;
	else
		echo "\[\e]0;$@: \W\a\]\[\e[1;31m\]$@\[\e[m\]:\[\e[1;34m\]\W\[\e[m\]\$ " > ~/.ps1_current;
	fi
	PS1="$(cat ~/.ps1_current)";
}

headphone() {
	mac() {
		echo $(pacmd list-cards | grep bluez_card | cut -f2 -d. | tr _ : | tr -d '>')
	}
	index() {
		pacmd list-cards | grep -B1 bluez_card | grep index | awk '{print $2}'
	}
	if pacmd list-cards | grep bluez_card >/dev/null; then
		pacmd set-card-profile $(index) $(echo -e "a2dp_sink\nheadset_head_unit" | grep -v "$(pacmd list-cards | grep bluez_card -B1 -A30 | grep active | awk '{print $3}' | tr -d '<>')")
	else
		bluetoothctl connect 00:16:94:44:A1:EC
		#sleep 3;
		#if ! pacmd list-cards | grep bluez_card >/dev/null; then
		#	notify_send "Headphone Not Connected"
		#fi
	fi
}

switchAudio() {
	pactl set-default-sink "$(pactl list short sinks | grep -v "$(pactl info | grep 'Default Sink:' | cut -f3 -d' ')\|PulseEffects" | awk '{print $2}')"
}

cd() {
	if builtin cd "$@"; then
		clear -x
		ls
	fi
}

cb() {
	xclip -sel clip "$@"
}

open() {
	for file in "$@"; do
		find -maxdepth 1 -iname "$file" -print0 | xargs -0 -n1 xdg-open >/dev/null 2>&1
	done
}

"$@"
