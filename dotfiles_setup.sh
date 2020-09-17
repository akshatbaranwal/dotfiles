#!/bin/bash

dotfiles=($(ls -adp .* | grep -v /))

dir="/media/akshat/Data/Documents/MyCodes/dotfiles"

for df in "${dotfiles[@]}"; do
	ln -nsf "${dir}/${df}" "${HOME}/${df}"
done

