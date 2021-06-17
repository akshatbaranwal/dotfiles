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
        cp -n "${HOME}/${df}" "${PWD}/.backup/${df}"
        ln -nfs "${PWD}/${df}" "${HOME}/${df}"
    done
    echo dotfiles updated

    # automate dphone
    echo setting autodphone rules
    cp -n "/etc/udev/rules.d/dphone.rules" "${PWD}/.backup/dphone.rules"
    sudo ln -nfs "${PWD}/dphone.rules" "/etc/udev/rules.d/dphone.rules"
    sudo udevadm control --reload-rules
    sudo systemctl restart udev.service

    # libinput gestures
    cp -n "${HOME}/.config/libinput-gestures.conf" "${PWD}/.backup/libinput-gestures.conf"
    ln -nfs "${PWD}/libinput-gestures.conf" "${HOME}/.config/libinput-gestures.conf"
    echo libinput_gestures updated

    chmod +x .bash_functions

elif [[ $1 == "uninstall" ]]; then
    # revert all the changes
    for df in $(ls -ad .* | grep -Ev '\.\B|.git$|.gitignore|.backup'); do
        cp --remove-destination -f "${PWD}/.backup/${df}" "${HOME}/${df}"
    done
    sudo cp --remove-destination -f "${PWD}/.backup/dphone.rules" "/etc/udev/rules.d/dphone.rules"
    cp --remove-destination -f "${PWD}/.backup/libinput-gestures.conf" "${HOME}/.config/libinput-gestures.conf"
    echo Changes reverted to original
else
    echo "Usage: bash dotfiles_setup.sh install"
    echo "       bash dotfiles_setup.sh uninstall"
fi

cd "$OLDPWD" || exit
