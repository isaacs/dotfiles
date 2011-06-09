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

# install the centschbook mono font
f=~/Library/Fonts
c=Century-Schoolbook-Monospace-BT.ttf
if [ -d $f ]; then
  if [ -f $f/$c ]; then
    mv $f/$c ~/.dotfile_backup
  fi
  ln -s $(pwd)/$c $f/$c
fi

# install the iterm2 prefs
lp=~/Library/Preferences
i2=com.googlecode.iterm2.plist
if [ -d $lp ]; then
  if [ -f $lp/$i2 ]; then
    mv $lp/$i2 ~/.dotfile_backup
  fi
  ln -s $(pwd)/$i2 $lp/$i2
fi

exit 0
