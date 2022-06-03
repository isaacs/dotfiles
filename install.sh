#!/bin/bash
! [ -d ~/.dotfile_backup ] && mkdir ~/.dotfile_backup
for i in .*; do
	if ! [ "$i" == "." ] && ! [ "$i" == ".." ] && ! [ "$i" == ".git" ]; then
		if [ -e ~/$i ]; then
			if ! ( cp ~/$i ~/.dotfile_backup/$i ) || ! ( rm ~/$i || unlink ~/$i ); then
				echo "Failed on $i" > /dev/stderr
				exit 1
			fi
		fi
		if ln -s $(pwd)/$i ~/$i; then
			echo "Linked: $i" > /dev/stderr
		else
			echo "Failed on $i" > /dev/stderr
			exit 1
		fi
	fi
done

# kitty is special
if [ -e ~/.config/kitty/kitty.conf ]; then
  cp ~/.config/kitty/kitty.conf ~/.dotfile_backup
  rm ~/.config/kitty/kitty.conf || unlink ~/.config/kitty/kitty.conf
fi
mkdir -p ~/.config/kitty
ln -s $(pwd)/kitty.conf ~/.config/kitty/kitty.conf

# so is karabiner, but it is annoying about being a symlink, so just cp it
if [ -e ~/.config/karabiner/karabiner.json ]; then
  cp ~/.config/karabiner/karabiner.json ~/.dotfile_backup
fi
mkdir -p ~/.config/karabiner
cp $(pwd)/karabiner.json ~/.config/karabiner/karabiner.json

exit 0
