#!/bin/bash

# important env variables
display=":$(find /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"
user=$(who | grep '('"$display"')' | awk '{print $1}' | head -n 1)
uid=$(id -u "$user")
phoneMac="30:4b:07:69:63:12"
bluetoothMac="00:1B:66:C8:13:C3"
# password of phone
password=4739

# notify for root
notify_send() {
    \sudo -u "$user" DISPLAY="$display" DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$uid"/bus notify-send --hint int:transient:1 "$@"
}

kill_notify() {
    sleep "${1:-0}"
    eval "$(xdotool getmouselocation --shell)"
    xdotool mousemove 960 80
    xdotool mousemove "$X" "$Y"
}

# change rubbish file names of tv series episodes to a more sensible format
trimFilenames() {
    if [ -z "$1" ]; then
        files=$(ls -d -- * 2>/dev/null)
    else
        files=$(ls -d -- *."$1" 2>/dev/null)
    fi
    prefix=$(echo "$files" | sed -e 'N;s/^\(.*\).*\n\1.*$/\1\n\1/;D')
    suffix=$(echo "$files" | rev | sed -e 'N;s/^\(.*\).*\n\1.*$/\1\n\1/;D' | rev)
    ext=$(echo "${files##*.}" | head -n1)
    if [ "$(echo "$files" | wc -l)" -lt 2 ]; then
        echo Nothing to change
        return
    fi
    echo Common Prefix: "$prefix"
    echo Common Suffix: "${suffix%.*}"
    echo
    if [[ "$prefix" = "$suffix" ]] || [[ $suffix != *.$ext ]] || [[ $prefix.$ext = "$suffix" ]] && [ -n "$1" ]; then
        echo "No change done"
        return
    fi
    local IFS=$'\n'
    if [ "$ZSH_VERSION" ]; then
        setopt sh_word_split
    fi
    if [ -z "$1" ]; then
        for f in $files; do
            mv -iv -- "$f" "$(echo "$f" | cut -c $((${#prefix} + 1))-$((${#f} - ${#suffix})))"
        done
    else
        for f in $files; do
            mv -iv -- "$f" "$(echo "$f" | cut -c $((${#prefix} + 1))-$((${#f} - ${#suffix}))).$ext"
        done
    fi
}

countdown() {
    date1=$(($(date +%s) + $1 + 60 * ${2:-0} + 3600 * ${3:-0}))
    while [ "$date1" -ge "$(date +%s)" ]; do
        echo -ne " $(date -u --date @$(($date1 - $(date +%s))) +%H:%M:%S)\r"
        sleep 1
    done
    echo
}

stopwatch() {
    date1=$(($(date +%s) + $1 + 60 * ${2:-0} + 3600 * ${3:-0}))
    while [ "$date1" -ge "$(date +%s)" ]; do
        echo -ne " $(date -u --date @$(($(date +%s) - $date1 + $1)) +%H:%M:%S)\r"
        sleep 1
    done
    echo
}

# you'll need terminator and a profile named 'timer'
timer() {
    Xaxis=$(xrandr --current | grep '\*' | uniq | awk '{print $1}' | cut -d 'x' -f1)
    terminator --geometry=280x1+$((Xaxis / 2 - 140))+0 -p "timer" -x bash ~/.bash_functions countdown "$1" "$2" "$3" 2>/dev/null &
    disown
    exit
}

# convert topcoder irritating test case format
tpc() {
    str="$*"
    str="${str//[\]\[\,\{\}\n]/}"
    echo
    echo "$str" | wc -w
    echo "$str" | xargs
    echo
}

# brightness hack
brightness() {
    cd /sys/class/backlight/intel_backlight || return
    brightness=$(cat brightness)
    case $# in
    1)
        brightness=$((685 * $1))
        ;;
    2)
        if [ "$1" = '--increase' ]; then
            brightness=$((brightness + $2 * 685))
        elif [ "$1" = '--decrease' ]; then
            brightness=$((brightness - $2 * 685))
        else
            echo "Usage: b [--increase|--decrease] brightness_percent"
            cd ~- || return
            return 1
        fi
        ;;
    *)
        echo "Usage: b [--increase|--decrease] brightness_percent"
        cd ~- || return
        return 1
        ;;
    esac
    if [ $brightness -lt 0 ]; then
        brightness=0
    elif [ $brightness -gt "$(cat max_brightness)" ]; then
        brightness=$(cat max_brightness)
    fi
    echo "$brightness" | sudo tee brightness >/dev/null
    cd ~- || return
}

# install deb pkg with dependencies
deb() {
    if [ $# -eq 0 ]; then
        ls -c1 -- *.deb
    else
        for var in "$@"; do
            sudo dpkg -i "$var"
        done
        yes | sudo apt install -f
    fi
}

# quick C/C++ compile and run
g() {
    rm temporaryCode 2>/dev/null
    if [[ ${1#*.} == cpp ]] || grep 'bits/stdc++.h' -- "$1" >/dev/null; then
        g++ -o temporaryCode "$1"
    elif grep -E 'pthread.h|semaphore.h' -- "$1" >/dev/null; then
        gcc -pthread -o temporaryCode "$1"
    elif grep -E 'math.h' -- "$1" >/dev/null; then
        gcc -o temporaryCode "$1" -lm
    else
        gcc -o temporaryCode "$1"
    fi
    ./temporaryCode "${@:2}"
    rm temporaryCode 2>/dev/null
    echo
}

# quick java compile and run
jv() {
    if [[ ${1#*.} == java ]]; then
        javac -verbose "$1" 2> >(grep wrote) | grep -v '\$' | awk '{print substr($2,0,length($2)-1)}'
        #javac $1 2> >(grep -v "^Picked up _JAVA_OPTIONS:" >&2)
    elif [[ ${1#*.} == class ]]; then
        java "${1%.*}" "${@:2}" 2> >(grep -v "^Picked up _JAVA_OPTIONS:" >&2)
    else
        java "$1" "${@:2}" 2> >(grep -v "^Picked up _JAVA_OPTIONS:" >&2)
    fi
    echo
}

# toggle turbo boost
turbo() {
    cd /sys/devices/system/cpu/intel_pstate >/dev/null || return
    echo $((1 - $(cat no_turbo))) | sudo tee no_turbo >/dev/null
    if [ "$(cat no_turbo)" -eq 1 ]; then
        echo Turbo Boost Disabled
    else
        echo Turbo Boost Enabled
    fi
    cd ~- >/dev/null || return
}

# function Extract for common file formats
extract_old() {
    SAVEIFS=$IFS
    IFS="$(printf '\n\t')"
    if [ -z "$1" ]; then
        # display usage if no parameters given
        echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
        echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
    else
        for n in "$@"; do
            if [ -f "$n" ]; then
                case "${n%,}" in
                *.cbt | *.tar.bz2 | *.tar.gz | *.tar.xz | *.tbz2 | *.tgz | *.txz | *.tar)
                    tar xvf "$n"
                    ;;
                *.lzma) unlzma ./"$n" ;;
                *.bz2) bunzip2 ./"$n" ;;
                *.cbr | *.rar) unrar x -ad ./"$n" ;;
                *.gz) gunzip ./"$n" ;;
                *.cbz | *.epub | *.zip) unzip ./"$n" ;;
                *.z) uncompress ./"$n" ;;
                *.7z | *.apk | *.arj | *.cab | *.cb7 | *.chm | *.deb | *.dmg | *.iso | *.lzh | *.msi | *.pkg | *.rpm | *.udf | *.wim | *.xar)
                    7z x ./"$n"
                    ;;
                *.xz) unxz ./"$n" ;;
                *.exe) cabextract ./"$n" ;;
                *.cpio) cpio -id <./"$n" ;;
                *.cba | *.ace) unace x ./"$n" ;;
                *.zpaq) zpaq x ./"$n" ;;
                *.arc) arc e ./"$n" ;;
                *.cso) ciso 0 ./"$n" ./"$n.iso" &&
                    extract "$n".iso && \rm -f "$n" ;;
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
# echo <password> | sudo -S /home/"$user"/.bash_functions <function> 2>/dev/null
class() {
    emailId="iit2019010@iiita.ac.in"

    timeTable="
     08-09 09-10 10-11 11-12 12-01 01-02 02-03 03-04 04-05 05-06 06-07 07-08
Mon: NA    NA    NA    RSG-L RSG-L NA    NA    ENB-T ENB-T BCC-L BCC-L NA
Tue: NA    NA    NA    RSG-T RSG-T NA    NA    ENB-L ENB-L BCC-T BCC-T NA
Wed: NA    DMW-L DMW-L NA    NA    NA    NA    ENB-P ENB-P BCC-P BCC-P NA
Thu: NA    DMW-P DMW-P RSG-P RSG-P NA    NA    NA    NA    DMW-T DMW-T NA"

    classLinks="
RSG https://meet.google.com/biz-xnsg-sai?authuser=$emailId
ENB https://meet.google.com/ufi-asyn-uxa?authuser=$emailId
BCC https://meet.google.com/zks-bsws-uoi?authuser=$emailId
DMW-P https://meet.google.com/nox-neer-fkk?authuser=$emailId
DMW-T https://meet.google.com/nox-neer-fkk?authuser=$emailId
DMW-L https://iiita.webex.com/iiita/j.php?MTID=m3ab2097c9782d8544b07c8ab6276b2ea"

    classNames="
RSG Remote Sensing and GIS
ENB Engineering Biology
BCC Blockchain and Cryptocurrencies
DMW Data Mining and Warehousing"

    if [ "$(date +%m)" -gt 4 ] && [ "$(date +%m)" -lt 8 ]; then
        notify_send "Summer Holidays!"
    elif [ "$(date +%m)" -eq 12 ]; then
        notify_send "Winter Holidays!"
    elif [ "$(date +%u)" -gt 4 ]; then
        notify_send "Enjoy Your Weekend!"
    elif [ "$(date +%H)" -gt 19 ]; then
        notify_send "No More Classes Left!"
    elif [ "$(date +%H)" -lt 8 ]; then
        notify_send "Classes yet to start!"
    else
        classID="$(echo "$timeTable" | awk -v row="$(echo "$(date +%u) + 2" | bc -l)" -v col="$(echo "$(date +%H) - 6" | bc -l)" 'NR==row {print $col}')"
        if [ "$classID" = "NA" ]; then
            notify_send "No Class Right Now"
        else
            classType="$(echo "$classID" | cut -f2 -d-)"
            if [ "$classType" = "L" ]; then
                classType="Lecture"
            elif [ "$classType" = "T" ]; then
                classType="Tutorial"
            elif [ "$classType" = "P" ]; then
                classType="Practical"
            fi
            classLink="$(echo "$classLinks" | grep "\b$classID " | cut -f2 -d' ')"
            classID="$(echo "$classID" | cut -f1 -d-)"
            [[ -z "$classLink" ]] && classLink="$(echo "$classLinks" | grep "\b$classID " | cut -f2 -d' ')"
            className="$(echo "$classNames" | grep "\b$classID " | cut -f2- -d' ')"
            notify_send "$classID ($className)" "$classType"
            echo "$classLink" | xargs \sudo -u "$user" DISPLAY="$display" DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$uid"/bus xdg-open
        fi
    fi
}

# mycli shortcut
sql() {
    if ! systemctl --no-pager status mariadb >/dev/null; then
        systemctl start mariadb
    fi
    echo
    mycli -u "$user" -p a
}

# check if shutdown is scheduled
schk() {
    k="$(date --date=@$(($(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager ScheduledShutdown | cut -d' ' -f3) / 1000000)))"
    if ! [ "$(echo "$k" | awk '{print $7}')" = "1970" ]; then
        echo "$k"
        echo -n "Want to Cancel? [N/y] "
        read -r k
        echo "${k:=n}" >/dev/null
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
    shutdown -P +"${1:-0}"
}

# battery conservation mode toggle
conservationMode() {
    \sudo -v
    cd /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/ >/dev/null || return
    if [ -z "$1" ]; then
        echo $((1 - $(cat conservation_mode))) | sudo tee conservation_mode >/dev/null
    else
        echo "$1" | sudo tee conservation_mode >/dev/null
    fi
    if [ "$(cat conservation_mode)" -eq 1 ]; then
        notify_send "Conservation Mode ON"
    else
        notify_send "Conservation Mode OFF"
    fi
    cd ~- >/dev/null || return
}

# ssh to phone
sphone() {
    if [ -z "$1" ]; then
        ipAddress="$(ip neigh | grep "$phoneMac" | cut -d' ' -f1 | head -n1)"
        ping -c1 "$ipAddress" >/dev/null 2>&1
        ssh -xp 8022 u0_a210@"$ipAddress"
    else
        ssh -xp 8022 u0_a210@"$1"
    fi
}

# mount phone
mphone() {
    if [ -z "$(ls /media/"$user"/Phone)" ]; then
        if [ -z "$1" ]; then
            ipAddress="$(ip neigh | grep "$phoneMac" | cut -d' ' -f1 | head -n1)"
            ping -c1 "$ipAddress" >/dev/null 2>&1
            sudo sshfs -o allow_other u0_a210@"$ipAddress":/storage/emulated/0 /media/"$user"/Phone -p 8022
        else
            sudo sshfs -o allow_other u0_a210@"$1":/storage/emulated/0 /media/"$user"/Phone -p 8022
        fi
    fi
    if [ -z "$(ls /media/"$user"/Phone)" ]; then
        echo "Mount Failed"
    else
        cd /media/"$user"/Phone || return
    fi
}

# display phone screen on ur laptop

# connect phone and pc to same network
# enable usb debugging on phone
# run this
# disconnect usb

# use this to create a shortcut
# gnome-terminal --geometry=50x6+1870 -- sh -c 'echo > $HOME/nohup.out; /usr/bin/nohup $HOME/.bash_functions dphone 2>/dev/null & while ! ps x | grep -v grep | grep scrcpy; do timeout 2 tail -f $HOME/nohup.out; done'

acquireLock() {
    echo "$1" >/home/"$user"/.dphone_lock
    pkill scrcpy
    # sleep 1
}

dphone() {
    pkill scrcpy
    unlock() {
        if ! adb -s "$(adb devices | head -n2 | tail -n1 | awk '{print $1}')" shell dumpsys power | grep mUserActivityTimeoutOverrideFromWindowManager=10000 >/dev/null; then
            return
        fi
        e=$(adb devices | head -n2 | tail -n1 | awk '{print $1}')
        if [ "$(adb -s "$e" shell dumpsys power | grep mWakefulness= | cut -f2 -d=)" = 'Awake' ]; then
            adb -s "$e" shell input keyevent 26
        fi
        sleep 1
        adb -s "$e" shell input keyevent 26 && adb -s "$e" shell input keyevent 82 && adb -s "$e" shell input text $password && adb -s "$e" shell input keyevent 66
        sleep 1
        unlock
    }
    waitForUSB() {
        while ! adb devices -l | grep "\busb\b" >/dev/null; do
            sleep 1
        done
    }
    export -f waitForUSB
    pingPhone() {
        ping -c 1 "$(adb devices | tail -n2 | head -n1 | awk '{print $1}' | cut -f1 -d:)" 2>/dev/null | grep Unreachable >/dev/null 2>&1
    }
    displayPhone() {
        unlock
        params=(--serial "$(adb devices | head -n2 | tail -n1 | awk '{print $1}')" $1 --turn-screen-off --lock-video-orientation=0 --window-x 1528 --window-y 218)
        # if ! adb devices -l | grep "\busb\b" >/dev/null; then
        #     params+=(--max-fps 15 --bit-rate 2M)
        # fi
        if pgrep -f vscode >/dev/null; then
            params+=(--always-on-top)
        fi
        (sudo -u "$user" DISPLAY="$display" DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$uid"/bus scrcpy "${params[@]}" >/dev/null 2>&1)
        sleep 1
        if ! pgrep -f scrcpy >/dev/null && [ "$(adb -s "$(adb devices | head -n2 | tail -n1 | awk '{print $1}')" shell dumpsys power | grep mWakefulness= | cut -f2 -d=)" = 'Awake' ]; then
            adb -s "$(adb devices | head -n2 | tail -n1 | awk '{print $1}')" shell input keyevent 26
        fi
        #if [ $(adb -s $(adb devices | head -n2 | tail -n1 | awk '{print $1}') shell dumpsys activity services com.termux | wc -l) -eq 2 ]; then
        #   adb -s $(adb devices | head -n2 | tail -n1 | awk '{print $1}') shell monkey -p com.termux 1 >/dev/null;
        #fi
    }
    connectPhoneToWifi() {
        adb shell svc wifi disable
        adb shell svc wifi enable
        # adb shell am start -n com.steinwurf.adbjoinwifi/.MainActivity -e ssid Vandanalok4G >/dev/null
        # adb shell am force-stop com.steinwurf.adbjoinwifi
        sleep "$1"
    }
    connectPhone() {
        adb kill-server
        adb start-server 2>/dev/null
        waitForUSB
        if ! curl -s --head --request GET www.google.com | grep "200 OK" >/dev/null; then
            nmcli radio wifi on
            echo Connecting laptop to wifi
        fi
        while ! curl -s --head --request GET www.google.com | grep "200 OK" >/dev/null; do
            sleep 1
        done
        if [ "$(adb shell settings get global wifi_on)" -eq 0 ]; then
            connectPhoneToWifi 3
        fi
        adb tcpip 5555 >/dev/null
        waitForUSB
        (displayPhone &)
        echo Trying to connect
        adb connect "$(adb shell ip route 2>/dev/null | grep wlan0 | awk '{print $9}')":5555 >/dev/null
        for i in {4..7}; do
            sleep 1
            if adb devices 2>/dev/null | grep 5555 >/dev/null; then
                break
            fi
            echo "Trial $((i - 3))"
            connectPhoneToWifi "$i"
            adb connect "$(adb shell ip route 2>/dev/null | grep wlan0 | awk '{print $9}')":5555 >/dev/null
        done
        if adb devices 2>/dev/null | grep 5555 >/dev/null; then
            echo -e "Wireless connected: $(adb devices -l | tail -n2 | head -n1 | cut -f4 -d: | awk '{print $1}')"
            notify_send "Wireless connected: $(adb devices -l | tail -n2 | head -n1 | cut -f4 -d: | awk '{print $1}')"
        else
            echo -e "Could not connect"
            # notify-send "Could not connect"
        fi
    }
    if ! pgrep -f adb >/dev/null; then
        adb start-server 2>/dev/null
    fi

    if [ -f "/home/$user/.dphone_lock" ] && [ "$(cat /home/"$user"/.dphone_lock)" -eq 3 ]; then
        (displayPhone $1 &)
    elif [ "$(adb devices | wc -l)" -eq 2 ] || ([ "$(adb devices | wc -l)" -eq 3 ] && (adb devices | grep offline >/dev/null || adb devices -l | grep "\busb\b" >/dev/null || (echo "Trying to reach network" && pingPhone))); then
        if ! timeout 1 bash -c waitForUSB; then
            echo "Waiting for USB connection..."
        fi
        while ! timeout 1 bash -c waitForUSB; do
            sleep 1
        done
        if ! adb devices -l | grep "\busb\b" >/dev/null && [ "$(adb devices | wc -l)" -eq 3 ] && ! pingPhone; then
            (displayPhone &)
        elif timeout 10 bash -c waitForUSB; then
            (connectPhone &)
        else
            echo "No USB device detected"
        fi
    else
        if adb devices -l | grep "\busb\b" >/dev/null && ! [ "$(adb -d shell ip route | grep wlan0 | awk '{print $9}')" = "$(adb devices | tail -n2 | head -n1 | awk '{print $1}' | cut -f1 -d:)" ] 2>/dev/null; then
            (connectPhone &)
        elif ! pingPhone; then
            (displayPhone &)
            echo "Wireless connected: $(adb devices -l | tail -n2 | head -n1 | cut -f4 -d: | awk '{print $1}')"
            notify_send "Wireless connected: $(adb devices -l | tail -n2 | head -n1 | cut -f4 -d: | awk '{print $1}')"
        elif adb devices -l | grep "\busb\b" >/dev/null; then
            (displayPhone &)
        else
            echo "Phone on a different network"
        fi
    fi
}

# dphone when USB connected
dphone_usb() {
    if (($(cat /home/"$user"/.dphone_lock) > 1)); then
        return
    fi
    # echo >>"/home/akshat/.dphone_debug"
    # echo dphone_usb >>"/home/akshat/.dphone_debug"

    unlock_usb() {
        sleep 0.5
        if adb -d shell dumpsys power | grep mUserActivityTimeoutOverrideFromWindowManager=10000 >/dev/null; then
            # echo unlock_usb >>"/home/akshat/.dphone_debug"
            acquireLock 1
            if [ "$(adb -d shell dumpsys power | grep mWakefulness= | cut -f2 -d=)" = 'Awake' ]; then
                sleep 0.5
                adb -d shell input keyevent 26
            fi
            sleep 0.5
            adb -d shell input keyevent 26 && adb -d shell input keyevent 82 && adb -d shell input text $password && adb -d shell input keyevent 66
            sleep 0.5
            exit
        fi
    }
    waitForUSB() {
        # echo waitForUSB >>"/home/akshat/.dphone_debug"
        while ! adb devices -l | grep "\busb\b" >/dev/null; do
            sleep 1
        done
    }
    displayPhone_usb() {
        # echo displayPhone_usb >>"/home/akshat/.dphone_debug"
        params=(--serial "$(adb devices | head -n2 | tail -n1 | awk '{print $1}')" --max-size 800 --turn-screen-off --lock-video-orientation=0 --window-x 1528 --window-y 223)
        if pgrep -f vscode >/dev/null; then
            params+=(--always-on-top)
        fi
        (sudo -u "$user" DISPLAY="$display" DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$uid"/bus scrcpy "${params[@]}")
        if (($(cat /home/"$user"/.dphone_lock) > 2)); then
            exit
        fi
        echo 0 >/home/"$user"/.dphone_lock
        # sleep 1
        if adb devices -l | grep "\busb\b" >/dev/null && ! pgrep -f scrcpy >/dev/null && ! pgrep -f dphone_wifi >/dev/null && [ "$(adb -s "$(adb devices | head -n2 | tail -n1 | awk '{print $1}')" shell dumpsys power | grep mWakefulness= | cut -f2 -d=)" = 'Awake' ]; then
            adb -s "$(adb devices | head -n2 | tail -n1 | awk '{print $1}')" shell input keyevent 26
        fi
    }
    restartPhoneWifi() {
        # echo restartPhoneWifi >>"/home/akshat/.dphone_debug"
        adb -d shell svc wifi disable
        adb -d shell svc wifi enable
        sleep "${1:-0}"
    }
    connectLaptopToWifi() {
        # echo connectLaptopToWifi >>"/home/akshat/.dphone_debug"
        if ! curl -s --head --request GET www.google.com | grep "200 OK"; then
            nmcli radio wifi on
        fi
        while ! curl -s --head --request GET www.google.com | grep "200 OK"; do
            sleep 1
        done
    }

    unlock_usb

    acquireLock 2
    waitForUSB
    displayPhone_usb &
    connectLaptopToWifi

    if [ "$(adb -d shell settings get global wifi_on)" -eq 0 ]; then
        restartPhoneWifi 3
    fi

    phoneIp="$(adb -d shell ip route | grep wlan0 | awk '{print $9}')"

    if adb devices | grep "$phoneIp" >/dev/null && ping -c 1 "$phoneIp" && ! ping -c 1 "$phoneIp" | grep Unreachable >/dev/null; then
        # echo wifi_connected_already >>"/home/akshat/.dphone_debug"
        notify_send "Wireless connected: $(adb devices -l | tail -n2 | head -n1 | cut -f4 -d: | awk '{print $1}')"
        exit
    fi

    acquireLock 3
    adb tcpip 5555
    waitForUSB
    acquireLock 2
    displayPhone_usb &
    adb connect "$phoneIp"
    for i in {4..7}; do
        sleep 1
        if adb devices | grep "$phoneIp" >/dev/null; then
            break
        fi
        restartPhoneWifi "$i"
        adb connect "$phoneIp"
    done
    if adb devices | grep "$phoneIp" >/dev/null; then
        # echo wifi_connected_now >>"/home/akshat/.dphone_debug"
        notify_send "Wireless connected: $(adb devices -l | head -n2 | tail -n1 | cut -f4 -d: | awk '{print $1}')"
    else
        notify-send "Could not connect"
    fi

}

# dphone over wifi when USB disconnected
dphone_wifi() {
    if (($(cat /home/"$user"/.dphone_lock) > 0)); then
        return
    fi
    # echo >>"/home/akshat/.dphone_debug"
    # echo dphone_wifi >>"/home/akshat/.dphone_debug"

    unlock_wifi() {
        if ! adb -e shell dumpsys power | grep mUserActivityTimeoutOverrideFromWindowManager=10000 >/dev/null; then
            return
        fi
        # echo unlock_wifi >>"/home/akshat/.dphone_debug"
        if [ "$(adb -e shell dumpsys power | grep mWakefulness= | cut -f2 -d=)" = 'Awake' ]; then
            adb -e shell input keyevent 26
        fi
        # sleep 1
        adb -e shell input keyevent 26 && adb -e shell input keyevent 82 && adb -e shell input text $password && adb -e shell input keyevent 66
        sleep 1
        unlock_wifi
    }
    displayPhone_wifi() {
        # echo displayPhone_wifi >>"/home/akshat/.dphone_debug"
        params=(--serial "$(adb devices | head -n2 | tail -n1 | awk '{print $1}')" --max-size 800 --turn-screen-off --lock-video-orientation=0 --window-x 1528 --window-y 223 --max-fps 15 --bit-rate 2M)
        if pgrep -f vscode >/dev/null; then
            params+=(--always-on-top)
        fi
        unlock_wifi
        (sudo -u "$user" DISPLAY="$display" DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$uid"/bus scrcpy "${params[@]}")
        if (($(cat /home/"$user"/.dphone_lock) > 1)); then
            exit
        fi
        echo 0 >/home/"$user"/.dphone_lock
        # sleep 1
        if ! pgrep -f scrcpy >/dev/null && [ "$(adb -e shell dumpsys power | grep mWakefulness= | cut -f2 -d=)" = 'Awake' ]; then
            adb -e shell input keyevent 26
        fi
    }

    if adb devices 2>/dev/null | grep 5555 >/dev/null; then
        echo 1 >/home/"$user"/.dphone_lock
        displayPhone_wifi &
    fi
}

# automate dphone using async udev rules
autodphone() {
    if ! [ -f "/home/$user/.dphone_lock" ]; then
        echo 0 >"/home/$user/.dphone_lock"
        chmod 777 "/home/$user/.dphone_lock"
    fi
    if (($(cat /home/"$user"/.dphone_lock) == 3)); then
        return
    fi
    if [ "$1" = "usb" ]; then
        echo "/bin/bash /home/\"$user\"/.bash_functions dphone_usb" | at now
    elif [ "$1" = "wifi" ]; then
        sleep 0.5
        echo "/bin/bash /home/\"$user\"/.bash_functions dphone_wifi" | at now
    fi
}

# toggle automatic dphone
dphoneToggle() {
    if ! [ -f "/home/$user/.dphone_lock" ]; then
        echo 0 >"/home/$user/.dphone_lock"
        chmod 777 "/home/$user/.dphone_lock"
    fi
    if [ "$(cat /home/"$user"/.dphone_lock)" -lt 3 ]; then
        echo 3 >"/home/$user/.dphone_lock"
        notify_send "autodphone DISABLED"
        pkill scrcpy
    else
        echo 0 >"/home/$user/.dphone_lock"
        notify_send "autodphone ENABLED"
        if adb devices -l | grep "\busb\b" >/dev/null; then
            dphone_usb
        else
            dphone_wifi
        fi
    fi
}

# search through the history
hgrep() {
    temp_history="$(history)"
    for word in "$@"; do
        temp_history=$(echo "$temp_history" | grep "$word")
    done
    echo "$temp_history"
    unset temp_history
}

# easily change Prompt
ps1() {
    if [ $# -eq 0 ]; then
        echo '\[\e]0;${PWD/#$HOME/~}\a\]\[\e[1;32m\][\W\[\e[m\e[0;32m\]$(__git_ps1 " (%s)")\[\e[m\e[1;32m\]]> \[\e[m\]' >~/.ps1_current
    else
        echo "\[\e]0;$*: \W\a\]\[\e[1;31m\]$*\[\e[m\]:\[\e[1;34m\]\W\[\e[m\]\$ " >~/.ps1_current
    fi
    PS1="$(cat ~/.ps1_current)"
}

# toggle headphone profile a2dp_sink/headset_head_unit
headphone() {
    mac() {
        pacmd list-cards | grep bluez_card | cut -f2 -d. | tr _ : | tr -d '>'
    }
    index() {
        pacmd list-cards | grep -B1 bluez_card | grep index | awk '{print $2}'
    }
    if pacmd list-cards | grep bluez_card >/dev/null; then
        pacmd set-card-profile "$(index)" "$(echo -e "a2dp_sink\nhandsfree_head_unit" | grep -v "$(pacmd list-cards | grep bluez_card -B1 -A30 | grep active | awk '{print $3}' | tr -d '<>')")"
    else
        bluetoothctl connect $bluetoothMac
    fi
}

# toggle audio output device
switchAudio() {
    pactl set-default-sink "$(pactl list short sinks | grep "alsa\|bluez" | grep -v "$(pactl info | grep 'Default Sink:' | cut -f3 -d' ')" | awk '{print $2}')"
}

# toggle noise torch
switchMic() {
    if [ "$(pactl info | grep 'Default Source:' | cut -f3 -d' ')" = "nui_mic_remap" ]; then
        /home/akshat/.local/bin/noisetorch -u
        pactl set-default-source "$(pactl list short sources | grep alsa_input | awk '{print $2}')"
    else
        /home/akshat/.local/bin/noisetorch -i
        pactl set-default-source nui_mic_remap
    fi
}

# cd with ls
cd() {
    if builtin cd "$@"; then
        clear -x
        ls
    fi
}

# copy to clipboard
cb() {
    xclip -sel clip "$@"
}

# open multiple files
o() {
    if [ $# -eq 0 ]; then
		xdg-open .
        return
	fi
    for file in "$@"; do
        find . -maxdepth 1 -iname "$file" -print0 | xargs -0 -n1 xdg-open >/dev/null 2>&1
    done
}

openchrome() {
    ls | sort -n | grep -E "\.html$" | tail -n+"${1:-0}" | xargs -d "\n" google-chrome >/dev/null 2>&1 &
}
openfx() {
    ls | sort -n | grep -E "\.html$" | tail -n+"${1:-0}" | xargs -d "\n" firefox >/dev/null 2>&1 &
}
opengedit() {
    ls | sort -n | grep -E "\.txt$" | tail -n+"${1:-0}" | xargs -d "\n" gedit
}
openpdf() {
    ls | sort -n | grep -E "\.pdf$" | tail -n+"${1:-0}" | xargs -d "\n" evince >/dev/null 2>&1 &
}
opensubl() {
    ls | sort -n | grep -Ev "\.(mp3|mp4|avi|mkv|pdf|zip|html|srt)$" | tail -n+"${1:-0}" | xargs -d "\n" subl
}
openvlc() {
    ls | sort -n | grep -E "\.(mp3|mp4|mkv|avi)$" | tail -n+"${1:-0}" | xargs -d "\n" vlc 1>/dev/null 2>&1 &
    disown
    exit
}

ipynb() {
    jupyter notebook "$@" &
    disown
    exit
}

# cycle through pulseeffects presets
pulsepreset() {
    if pactl info | grep 'Default Sink:' | grep bluez >/dev/null; then
        fpath=~/.config/PulseEffects/autoload/"$(pactl info | grep 'Default Sink:' | cut -f3 -d' ')":headset-output.json
        presets=("None" "Headphone" "Headphones Bass" "None")
    else
        fpath=~/.config/PulseEffects/autoload/"$(pactl info | grep 'Default Sink:' | cut -f3 -d' ')":analog-output-speaker.json
        presets=("None" "Surround" "Vocals" "None")
    fi
    for ((i = 0; i < ${#presets}; ++i)); do
        if [[ "${presets[$i]}" == "$(cat $fpath | grep name | cut -f4 -d\")" ]]; then
            pulseeffects -l "${presets[$i + 1]}"
            echo -e "{\n    \"name\": \"${presets[$i + 1]}\"\n}" >"$fpath"
            # if [[ ${presets[$i + 1]} == None ]]; then
            #     notify_send "Equalizer Off"
            # fi
            return
        fi
    done
}

# toggle power saving mode
caffeine() {
    if ! [ -z "$1" ]; then
        if [ $1 -eq 0 ]; then
            notify_send "Caffeine OFF"
            gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend'
            gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'suspend'
        else
            notify_send "Caffeine ON"
            gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
            gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
        fi
    else
        if [ "$(gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type)" = "'suspend'" ]; then
            notify_send "Caffeine ON"
            gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
            gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
        else
            notify_send "Caffeine OFF"
            gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend'
            gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'suspend'
        fi
    fi
}

# download youtube music
ym() {
    builtin cd ${2:-~/Music} || return
    youtube-dl -f bestaudio -x --audio-format mp3 --embed-thumbnail --add-metadata --xattrs --geo-bypass "$1"
}

# download youtube video
yv() {
    builtin cd ${2:-~/Videos} || return
    youtube-dl -f best --embed-thumbnail --add-metadata --xattrs --geo-bypass --write-auto-sub --embed-sub --ignore-errors "$1"
}

timezsh() {
    shell=${1-$SHELL}
    for i in $(seq 1 10); do /usr/bin/time "$shell" -i -c exit; done
}

gc() {
    repo="$(xclip -o -sel clip)"
    git clone "$repo" && cd "$(basename "$repo" .git)" || return
}

countLines() {
    find . -name "*.$1" | sed 's/.*/"&"/' | xargs  wc -l | sort -n
}

nf() {
    notify_send "$((($(date +%s) - $(date -d 20220624 +%s)) / 86400)) Day Streak!" "100 HOUR WORK WEEK"
    x=$(($(cat ~/.devOpsProgress)+1))
    echo $x > ~/.devOpsProgress
    cd /media/akshat/Data/Documents/COURSES/DevOps/DevOps\ Bootcamp
    y=$(xdotool get_desktop)
    xdotool set_desktop $(($(xdotool get_num_desktops)-1))
    vlc --fullscreen --rate 1.4 --play-and-exit "$x.mp4" && xdotool set_desktop $y
}

productivity() {
    cd /home/$user/dotfiles/.productivity
    state=$(cat state)
    seconds=$(cat seconds)
    epoch0=$(cat epoch)
    epoch1=$(date +%s)
    progress=$((($epoch1 - $epoch0) * $state))
    state=$((1-$(cat state)))
    if [[ "$(date -d @$epoch0 | cut -f1-4 -d' ')" != "$(date -d @$epoch1 | cut -f1-4 -d' ')" ]]; then
        seconds=0
    fi
    seconds=$(($seconds + $progress))
    if [[ $state == 0 ]]; then
        notify_send "BREAK TIME" "Last session: $(date -d@$progress -u +%H) hours $(date -d@$progress -u +%M) minutes"
    else
        notify_send "WORK STARTED" "Total Work: $(date -d@$seconds -u +%H) hours $(date -d@$seconds -u +%M) minutes"
    fi
    echo $state > state
    echo $seconds > seconds
    echo $epoch1 > epoch
    cd ~-
}

fix-home-dir() {
    echo "    # This file is written by xdg-user-dirs-update
    # If you want to change or add directories, just edit the line you're
    # interested in. All local changes will be retained on the next run.
    # Format is XDG_xxx_DIR=\"$HOME/yyy\", where yyy is a shell-escaped
    # homedir-relative path, or XDG_xxx_DIR="/yyy", where /yyy is an
    # absolute path. No other format is supported.
    # 
    XDG_DESKTOP_DIR=\"$HOME/Desktop\"
    XDG_DOWNLOAD_DIR=\"$HOME/Downloads\"
    XDG_TEMPLATES_DIR=\"$HOME/Templates\"
    XDG_PUBLICSHARE_DIR=\"$HOME/Public\"
    XDG_DOCUMENTS_DIR=\"$HOME/Documents\"
    XDG_MUSIC_DIR=\"$HOME/Music\"
    XDG_PICTURES_DIR=\"$HOME/Pictures\"
    XDG_VIDEOS_DIR=\"$HOME/Videos\"
    " > .config/user-dirs.dirs
    xdg-user-dirs-update
}

bluelight() {
    redshift -x
    sleep 0.2
    redshift -P -O ${1:-6000}
}

# Determine size of a file or total size of a directory
fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh
	else
		local arg=-sh
	fi
	if [[ -n "$@" ]]; then
		\du $arg -- "$@"
	else
		\du $arg .[^.]* ./*
	fi
}

mkd() {
	mkdir -p "$@" && cd "$_";
}

clipscreenshot() {
    TMPFILE=`mktemp -u /tmp/screenshotclip.XXXXXXXX.png`
    gnome-screenshot "$@" -f $TMPFILE && xclip $TMPFILE -selection clipboard -target image/png
    rm $TMPFILE || echo ""
}

unlock_medium() {
    twurl -u "baranwal_akshat" -A "Content-type: application/json" -X POST /1.1/direct_messages/events/new.json -d "{\"event\": {\"type\": \"message_create\", \"message_create\": {\"target\": {\"recipient_id\": \"741487052236021761\"}, \"message_data\": {\"text\": \"$(xclip -o -sel clip)\"}}}}" | jq '.event.message_create.message_data.text' | xargs firefox
}

neigh() {
    sudo timeout 1s arping "$(ip neigh | awk '{print $1}' | grep -P "^\d{3}\.\d{3}\.\d{2,3}\.1$")" >/dev/null 2>&1
    ip neigh
}

"$@"
