if [ -n "$BASH_VERSION" ]; then
	[ -f ~/.bashrc ] && . ~/.bashrc
	[ -f ~/.extra.bashrc ] && . .extra.bashrc
fi