#!/bin/bash

cd "$(dirname "$0")" || exit

if [[ $# != 1 ]]; then
    echo "Usage: bash dotfiles_setup.sh install"
    echo "       bash dotfiles_setup.sh uninstall"
    exit
fi

if [[ $1 == "install" ]]; then
    # create backup directory
    if [ ! -d "${PWD}/.backup" ]; then
        mkdir "${PWD}/.backup"
        echo .backup directory created
    fi

    # copy dotfiles to /home/$USER
    for df in $(ls -ad .* | grep -Ev '\.\B|.git$|.gitignore|.backup'); do
        cp -n "${HOME}/${df}" "${PWD}/.backup/${df}" 2>/dev/null
        ln -nfs "${PWD}/${df}" "${HOME}/${df}"
    done
    echo dotfiles updated

    # automate dphone
    echo setting autodphone rules
    cp -n "/etc/udev/rules.d/dphone.rules" "${PWD}/.backup/dphone.rules" 2>/dev/null
    sudo ln -nfs "${PWD}/dphone.rules" "/etc/udev/rules.d/dphone.rules"
    chmod 644 /etc/udev/rules.d/dphone.rules
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    sudo systemctl restart udev.service

    # libinput gestures
    cp -n "${HOME}/.config/libinput-gestures.conf" "${PWD}/.backup/libinput-gestures.conf" 2>/dev/null
    ln -nfs "${PWD}/libinput-gestures.conf" "${HOME}/.config/libinput-gestures.conf"
    echo libinput_gestures updated

    # add bright and conservationMode to sudoers
    # sudo cp -n "/etc/sudoers" "${PWD}/.backup/sudoers"
    # sudo ln -nfs "${PWD}/sudoers" "/etc/sudoers"
    sudo ln -nfs "${PWD}/bright" "/usr/local/bin/bright"
    sudo ln -nfs "${PWD}/batteryConservationMode" "/usr/local/bin/batteryConservationMode"
    # echo added bright and batteryConservationMode to sudoers

    # custom keyboard shortcuts
    dconf reset -f '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/'
    dconf load '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/' < custom-keybindings.dconf
    dconf write '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings' "$(cat custom-keybindings.dconf)"

    chmod +x .bash_functions

elif [[ $1 == "uninstall" ]]; then
    # revert all the changes
    for df in $(ls -ad .* | grep -Ev '\.\B|.git$|.gitignore|.backup'); do
        cp --remove-destination -f "${PWD}/.backup/${df}" "${HOME}/${df}" 2>/dev/null
    done
    sudo cp --remove-destination -f "${PWD}/.backup/dphone.rules" "/etc/udev/rules.d/dphone.rules" 2>/dev/null
    cp --remove-destination -f "${PWD}/.backup/libinput-gestures.conf" "${HOME}/.config/libinput-gestures.conf" 2>/dev/null
    cp --remove-destination -f "${PWD}/.backup/sudoers" "/etc/sudoers" 2>/dev/null
    echo Changes reverted to original
else
    echo "Usage: bash dotfiles_setup.sh install"
    echo "       bash dotfiles_setup.sh uninstall"
fi

cd "$OLDPWD" || exit
