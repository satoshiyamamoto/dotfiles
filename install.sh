#
# install.sh
#===========

timestamp=$(date +"%Y%m%d")
list='.bash_profile .bashrc'

if [ -f ~/.bash_profile ]; then
	echo -n '.bash_profile exists. are you override? [Y/n] '
	read override
	if [ "$override" = "n" ]; then
		exit 0
	fi

  if [ -L ~/.bash_profile ]; then
		rm -f ~/.bash_profile
	else
		mv -f ~/.bash_profile ~/.bash_profile.$timestamp
	fi
	echo 'cleaning ~/.bash_profile'
fi
echo 'installing .bash_profile...'
ln -s $(pwd)/.bash_profile ~/
