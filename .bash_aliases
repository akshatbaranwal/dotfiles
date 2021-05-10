alias aliases='vim ~/.bash_aliases; sort ~/.bash_aliases > ~/.aliass; cat ~/.aliass > ~/.bash_aliases; rm ~/.aliass; source ~/.bash_aliases; cd ~-'
alias bashfn='vim ~/.bash_functions; source ~/.bash_functions'
alias bashrc='vim ~/.bashrc; source ~/.bashrc'
alias ...='cd ../..'
alias ..='cd ..'
alias clg='cd /media/akshat/Data/Documents/IIITA'
alias doc='cd /home/akshat/Documents/MyCodes'
alias docs='cd /media/akshat/Data/Documents'
alias dow='cd /media/akshat/Data/Downloads'
alias ERROR='sudo rm /var/lib/apt/lists/lock;sudo rm /var/cache/apt/archives/lock;sudo rm /var/lib/dpkg/lock'
alias fd='fdfind'
alias files="find . -type f | sed -rn 's|.*/[^/]+\.([^/.]+)$|\1|p' | sort | uniq -c | sort -nr"
alias flut='cd /media/akshat/Data/Documents/Coding/Udemy/Flutter/Complete\ Guide'
alias iiit='cd ~/ProxyMan;./main.sh load iiit;cd ~-; echo'
alias insta='py /home/akshat/Documents/MyCodes/Python/insta.py'
alias ipy='ipython3'
alias ipynb='doc; jupyter notebook </dev/null &>/dev/null & exit'
alias isis='cd ~/ProxyMan;./main.sh unset;cd ~-; echo'
alias la='ls -ad .*'
alias lr='ls -hartlF'
alias myip='ifconfig | grep -oE "[0-9]{3}\.[0-9]{3}\.[0-9]{2}\.[0-9]{2,3}" | head -n 1'
alias naut='xdg-open .; exit'
alias openchrome='ls | sort -n | grep -E "\.html$" | xargs -d "\n" google-chrome >/dev/null 2>&1 &'
alias opencode='ls | sort -n | grep -Ev "\.(mp3|mp4|avi|mkv|pdf|zip|html|srt)$" | xargs -d "\n" code'
alias openfirefox='ls | sort -n | grep -E "\.html$" | xargs -d "\n" firefox >/dev/null 2>&1 &'
alias opengedit='ls | sort -n | grep -E "\.txt$" | xargs -d "\n" gedit'
alias openpdf='ls | sort -n | grep -E "\.pdf$" | xargs -d "\n" evince >/dev/null 2>&1 &'
alias opensubl='ls | sort -n | grep -Ev "\.(mp3|mp4|avi|mkv|pdf|zip|html|srt)$" | xargs -d "\n" subl'
alias openvlc='ls | sort -n | grep -E "\.(mp3|mp4|mkv|avi)$" | xargs -d "\n" vlc 1>/dev/null 2>&1 & exit'
alias pgsql='pgcli -h localhost -p 5432 -U postgres -W'
alias pid="ps aux | grep -v grep | grep -i -e VSZ -e"
alias pip='pip3'
alias pubip='curl http://ipecho.net/plain; echo'
alias py='python3'
alias sap='sudo snap'
alias sapt='yes | sudo apt'
alias sdiff="sdiff -w \'tput cols\'"
alias sl='sl -e'
alias stalk='py /home/akshat/Documents/MyCodes/Python/stalk.py'
alias udmy='opensubl & openfirefox & openpdf & openvlc'
alias update='sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y'
alias updatetime='sudo timedatectl set-ntp off; sudo timedatectl set-ntp on'
alias uphone='sudo umount /media/akshat/Phone'
alias webd='cd /media/akshat/Data/Documents/Coding/Udemy/Web\ Designing'
alias ym='youtube-dl -f bestaudio -x --audio-format mp3 --embed-thumbnail --add-metadata --xattrs --geo-bypass'
alias yv='youtube-dl -f best --embed-thumbnail --add-metadata --xattrs --geo-bypass --write-auto-sub --embed-sub --ignore-errors'
