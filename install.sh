#!/bin/bash
# install.sh

readonly FILES=('.bash_profile' '.bashrc' '.vimrc' '.vim')

for file in "${FILES[@]}"
do
  currdir="$(pwd dirname)"
  ln -s ${currdir}/$file ${HOME}/$file
  if [ "$?" -eq 0 ]; then
    echo " installing $file"
  fi
done

echo 'done.'
