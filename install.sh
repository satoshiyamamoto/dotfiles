#!/bin/bash
# install.sh

getopts f force
readonly files=('zshrc' 'zpreztorc' 'config/git' 'config/nvim' 'tmux.conf' 'tigrc' 'editorconfig')

for file in ${files[@]}; do
  src="$(pwd dirname)/${file}"
  dest="${HOME}/.${file}"

  # Clean up for the original files
  if [ "${force}" == 'f' ]; then
    if [ -L "${dest}" ]; then
      rm -f "${dest}"
    elif [ -e "${dest}" ]; then
      mv -f "${dest}" "${dest}.bak"
    fi
  fi

  # Create the symbolic link
  ln -s ${src} ${dest}
  if [ "$?" -eq 0 ]; then
    echo " installing ${file}"
  fi
done

echo 'done.'
