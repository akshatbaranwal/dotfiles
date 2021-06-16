#!/bin/bash

for df in $(ls -ad .* | grep -Ev '\.\B|.git$|.gitignore'); do
    ln -nfs "${PWD}/${df}" "${HOME}/${df}"
done

sudo ln -nfs "${PWD}/dphone.rules" "/etc/udev/rules.d/dphone.rules"
sudo udevadm control --reload-rules
sudo systemctl restart udev.service
ln -nfs "${PWD}/libinput-gestures.conf" "${HOME}/.config/libinput-gestures.conf"

chmod +x .bash_functions
