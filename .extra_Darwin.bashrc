# commands that only get loaded on the Darwin platform.
# Mostly, these commands interact with specific Mac programs.

alias compressmail='sqlite3 ~/Library/Mail/Envelope\ Index vacuum index'

viewsvn () {
	if [ $# -lt 1 ]; then
		viewsvn .
		return $?
	elif [ $# -eq 1 ]; then
		f="$1"
		[ -d "$f" ] && [ -f "$f/.svn/entries" ] && f="$f/."
		if ! [ -f "`dirname "$f"`/.svn/entries" ]; then
			echo "$f - Not in an SVN repository." > /dev/stderr
		else
			open "$( \
				grep svn+ssh `dirname $f`/.svn/entries \
					| head -n1 \
					| sed \
						-e 's/svn\+ssh/http/g' \
						-e 's/svn\.corp\.yahoo\.com\/yahoo/svn.corp.yahoo.com\/view\/yahoo/g' \
			)/`basename $f`"
		fi
	else
		RET=0
		for i in $@; do
			viewsvn $i || let 'RET += 1'
		done
		return $RET
	fi
}

viewcvs () {
	wd=`pwd`
	for x in $@; do
		x="$wd/$x"
		# argument should be a file or folder.
		if [ -f "$x" ]; then
			folder=`dirname "$x"`
			thefile=`basename "$x"`
		elif [ -d "$x" ]; then
			folder="$x"
			thefile=""
		else
			#echo "invalid argument : $x"
			return
		fi
	
		cvsfolder="$folder/CVS"
		#echo "cvsfolder = $cvsfolder"
		if ! [ -d "$cvsfolder" ]; then
			#echo "not in a cvs folder"
			return
		fi
		repo=`cat "$folder/CVS/Repository"`
	
		open http://vault.yahoo.com/viewcvs/$repo/$thefile
	done
}

cvsdiff () {
	SCRIPTNAME="${0##*/}"
	OLDFILE=/tmp/"${1##*/}"
	NEWFILE="$1"

	if [ $# -eq 1 ]
	then
	   cvs update -p "$NEWFILE" > "$OLDFILE"
	elif [ $# -eq 2 ]
	then
	   cvs update -p -r "$2" "$NEWFILE"  > "$OLDFILE"
	else
	   echo "usage: $SCRIPTNAME <file> [rev]"
	   return 1
	fi

	#echo "newfile $NEWFILE"
	#echo "oldfile $OLDFILE"
	#echo "pwd `pwd`"

	opendiff "$OLDFILE" "$NEWFILE" -merge "`pwd`/$NEWFILE"
}


unison_bin="`which unison`"
unison_prof="yap"
unison () {
	$unison_bin -logfile /dev/null -ui text -times -ignore 'Regex .*docs/2008[0-9]{4}/.*' -ignore 'Regex .*/(FreeBSD|rhel)\.[0-9]+\.[0-9]+\.package.*' -ignore 'Regex .*\.svn' -ignore 'Regex .*/svn-commit*.tmp' -ignore 'Regex .*/\.DS_Store' $@ $unison_prof
}
# unison () {
# 	$unison_bin -ui text -logfile /dev/stdout -ignore 'Regex .*docs/2008[0-9]{4}/.*' -ignore 'Regex .*/(FreeBSD|rhel)\.[0-9]+\.[0-9]+\.package.*' -ignore 'Regex .*/\.DS_Store' -times $@ $unison_prof
# }
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
	pid=`pid unison`
	if [ "$pid" == "" ]; then
		unisonquiet
	else
		echo "[$pid] (already running)"
	fi
	tail -f ~/.unisonlog
}
unisonkill () {
	killall $1 unison
	for id in `pid unison`; do
		kill $1 $id
	done
}
alias uk=unisonkill

[ `basename "$EDITOR"` == "mate_wait" ] && export LESSEDIT='mate_wait -l %lm %f'

export UNISONLOCALHOSTNAME=sistertrain-lm.corp.yahoo.com

alias sethost="sudo hostname sistertrain-lm; sudo scutil --set LocalHostName sistertrain-lm; sudo scutil --set HostName sistertrain-lm"

ahyaneupdate () {
	fh '. ~/.extra.bashrc; cd dev/ahyane; agent; git fetch; git rebase origin/master; bin/build.php'
}

alias photoshop='open -a Adobe\ Photoshop\ CS3'

export QTDIR=/opt/local/lib/qt3
