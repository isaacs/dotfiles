# commands that only get loaded on the Darwin platform.
# Mostly, these commands interact with specific Mac programs.

alias compressmail='sqlite3 ~/Library/Mail/Envelope\ Index vacuum index'

unison () {
	local unison_prof="yap"
	local unison_bin="$(which unison)"
	$unison_bin -logfile /dev/null -ui text -times \
		-ignore 'Regex .*docs/2008[0-9]{4}/.*' \
		-ignore 'Regex .*/(FreeBSD|rhel)\.[0-9]+\.[0-9]+\.package.*' \
		-ignore 'Regex .*\.svn' \
		-ignore 'Regex .*/svn-commit*.tmp' \
		-ignore 'Regex .*/\.DS_Store' $@ $unison_prof
}
unisondev () {
	unison -terse -repeat 1 -batch
}
unisonpush () {
	unison -force /Users/isaacs/dev/yap/ -batch -terse
}
unisonstart () {
	echo "pushing..."
	growlnotify -a Unison -t Unison -m pushing...
	unisonpush
	echo "starting..."
	growlnotify -a Unison -t Unison -m starting...
	unisondev
	echo "stopped."
	growlnotify -a Unison -t Unison -m stopped.
}
unisonquiet () {
	headless 'back unisonstart &>~/.unisonlog' unisonsession
}
unisonlisten () {
	title unison
	local pid=$(pid unison)
	if [ "$pid" == "" ]; then
		unisonquiet
	else
		echo "[$pid] (already running)"
	fi
	tail -f ~/.unisonlog
}
unisonkill () {
	killall $1 unison
	for id in $(pid unison); do
		kill $1 $id
	done
}
alias uk=unisonkill

[ $(basename "$EDITOR") == "mate_wait" ] && export LESSEDIT='mate_wait -l %lm %f'

export UNISONLOCALHOSTNAME=sistertrain-lm.corp.yahoo.com

sethost () {
	sudo hostname sistertrain-lm
	sudo scutil --set LocalHostName sistertrain-lm
	sudo scutil --set HostName sistertrain-lm
}

ahyaneupdate () {
	fh '. ~/.extra.bashrc; cd dev/ahyane; agent; git fetch; git rebase origin/master; bin/build.php'
}

alias photoshop='open -a Adobe\ Photoshop\ CS3'

update_webkit () {
	local rev=$( cat /Applications/WebKit.app/Contents/Resources/VERSION )
	local url=$( curl --silent http://nightly.webkit.org/builds/trunk/mac/latest | egrep "http://.*WebKit-SVN-r[0-9]+.dmg" -o | head -n 1 )
	local latest=$( echo $url | egrep '[0-9]{4,}' -o )
	if [ "$latest" != "" ]; then
		echo "Couldn't get latest WebKit revision" > /dev/stderr
		return 1
	fi
	if [ "$latest" == "$rev" ]; then
		echo "WebKit already up to date [$rev]" > /dev/stderr
		return 0
	fi
	echo "Updating WebKit from $rev to $latest..." > /dev/stderr
	
	curl -sL $url > /tmp/latest-webkit-svn.dmg
	if ! [ -f /tmp/latest-webkit-svn.dmg ]; then
		echo "Download from $url failed" > /dev/stderr
		return 1
	fi
	
	hdiutil attach /tmp/latest-webkit-svn.dmg -mountpoint /tmp/latest-webkit-svn -quiet
	
	killall -QUIT WebKit 2>/dev/null
	rm -rf /Applications/WebKit.app 2>/dev/null

	ret=0
	if cp -R /tmp/latest-webkit-svn/WebKit.app /Applications/WebKit.app; then
		echo "WebKit updated to $latest."
	else
		echo "Failed to update" >/dev/stderr
		ret=1
	fi

	hdiutil detach /tmp/latest-webkit-svn -quiet
	rm /tmp/latest-webkit-svn.dmg 2>/dev/null

	return $ret
}

export QTDIR=/opt/local/lib/qt3


