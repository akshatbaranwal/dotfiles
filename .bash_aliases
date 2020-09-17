alias aliases='cd; vim +1 .bash_aliases; source .bash_aliases; sort .bash_aliases > .alias; cp .alias .bash_aliases; rm .alias; cd ~-'
alias bashrc='vim ~/.bashrc; source ~/.bashrc'
alias byee='shutdown -P now'
alias bye='read -p "Shutdown After : " x;shutdown -P +$x'
alias ...='cd ../..'
alias ..='cd ..'
alias clg='cd /media/akshat/Data/Documents/IIITA'
alias doc='cd /media/akshat/Data/Documents/MyCodes'
alias dow='cd /media/akshat/Data/Downloads'
alias error='sudo rm /var/lib/apt/lists/lock;sudo rm /var/cache/apt/archives/lock;sudo rm /var/lib/dpkg/lock'
alias hgrep='history | grep'
alias iiit='cd ~/ProxyMan;./main.sh load iiit;cd ~-; echo'
alias insta='py /media/akshat/Data/Documents/MyCodes/Python/insta.py'
alias ipy='ipython3'
alias ipynb='doc; jupyter notebook </dev/null &>/dev/null & exit'
alias isis='cd ~/ProxyMan;./main.sh unset;cd ~-; echo'
alias la='ls -ad .*'
alias lmao='doc;rm lmao;gcc -o lmao lol.c;./lmao;echo;cd ~-'
alias lol='doc;rm lol;g++ -o lol lol.cpp;./lol;echo;cd ~-'
alias lr='ls -hartlF'
alias mars='cd ~/Mars4_5; java Mars; cd ~-; echo; echo; echo'
alias mdoc='cd /media/akshat/Phone'
alias mphone='sudo sshfs -o allow_other u0_a188@$(ip neigh | grep -vE "FAILED" | grep -oE "[0-9]{3}\.[0-9]{3}\.[0-9]{2}\.[0-9]{1,3}"):/storage/emulated/0 /media/akshat/Phone -p 8022'
alias myip='ifconfig | grep -oE "[0-9]{3}\.[0-9]{3}\.[0-9]{2}\.[0-9]{2,3}" | head -n 1'
alias naut='open .; exit'
alias open='xdg-open'
alias os='doc;cd os'
alias phone='ssh -p 8022 u0_a188@$(ip neigh | grep -vE "FAILED" | grep -oE "[0-9]{3}\.[0-9]{3}\.[0-9]{2}\.[0-9]{1,3}")'
alias pid="ps aux | grep -v grep | grep -i -e VSZ -e"
alias pubip='curl http://ipecho.net/plain; echo'
alias pypy='cd /media/akshat/Data/Documents/MyCodes;py lol.py;echo;cd ~-'
alias py='python3'
alias sapt='yes | sudo apt'
alias sdiff="sdiff -w \'tput cols\'"
alias search='sudo find ./* -iname'
alias sl='sl -e'
alias stalk='py /media/akshat/Data/Documents/MyCodes/Python/stalk.py'
alias turbo='echo $((1-$(cat /sys/devices/system/cpu/intel_pstate/no_turbo))) | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo >/dev/null'
alias update='sapt update;sapt full-upgrade;sapt autoremove'
alias updatetime='timedatectl set-local-rtc 1; sudo ntpdate ntp.ubuntu.com; timedatectl set-local-rtc 0'
alias uphone='sudo umount /media/akshat/Phone'
alias upload='sudo cp /media/akshat/Data/Downloads/gdrive .;./gdrive upload '
alias vsim='cd ~/intelFPGA_pro/19.4/modelsim_ase/bin;./vsim;cd;echo'
alias xv6='cd ~/xv6; make qemu-nox; cd ~-; echo'
