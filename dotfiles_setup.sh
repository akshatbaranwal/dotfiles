#!/bin/bash

for df in $(ls -ad .* | grep -Ev '\.\B|.git$|.gitignore'); do
	ln -nfs "${PWD}/${df}" "${HOME}/${df}"
done

