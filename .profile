if [ -n "$BASH_VERSION" ]; then
	[ -f ~/.bashrc ] && . ~/.bashrc
	[ -f ~/.extra.bashrc ] && ! [ "$BASH_EXTRAS_LOADED" ] && . .extra.bashrc
fi