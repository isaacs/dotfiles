#!/bin/bash
DOT_PROFILE_LOADED=1

export GPG_TTY=$(tty)

if [ -n "$BASH_VERSION" ]; then
	[ -f ~/.bashrc ] && ! [ "$DOT_BASHRC_LOADED" == "1" ] && . ~/.bashrc
	[ -f ~/.extra.bashrc ] && . ~/.extra.bashrc
fi
