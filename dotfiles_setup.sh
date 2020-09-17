#!/bin/bash

dotfiles=($(ls -ad .* | grep -Ev '\.\B|.git$|.gitignore'))

for df in "${dotfiles[@]}"; do
	ln -nsf "${PWD}/${df}" "${HOME}/${df}"
done

