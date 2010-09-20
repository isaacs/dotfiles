######
# .extra.bashrc - Isaac's Bash Extras
# This file is designed to be a drop-in for any machine that I log into.
# Currently, that means it has to work under Darwin, Ubuntu, and yRHEL
#
# Per-platform includes at the bottom, but most functionality is included
# in this file, and forked based on resource availability.
#
# Functions are preferred over shell scripts, because then there's just
# a few files to rsync over to a new host for me to use it comfortably.
#
# .extra_Darwin.bashrc has significantly more stuff, since my mac is also
# a GUI environment, and my primary platform.
######

# Note for Leopard Users #
# If you use this, it will probably make your $PATH variable pretty long,
# which will cause terrible performance in a stock Leopard install.
# To fix this, comment out the following lines in your /etc/profile file:

# if [ -x /usr/libexec/path_helper ]; then
# 	eval `/usr/libexec/path_helper -s`
# fi

# Thanks to "allan" in irc://irc.freenode.net/#textmate for knowing this!

echo "loading bash extras..."

# set some globals
if ! [ -f "$HOME" ]; then
	export HOME="$(echo ~)"
fi

# try to avoid polluting the global namespace with lots of garbage.
# the *right* way to do this is to have everything inside functions,
# and use the "local" keyword.  But that would take some work to
# reorganize all my old messes.  So this is what I've got for now.
__garbage_list=""
__garbage () {
	local i
	if [ $# -eq 0 ]; then
		for i in ${__garbage_list}; do
			unset $i
		done
		unset __garbage_list
	else
		for i in "$@"; do
			__garbage_list="${__garbage_list} $i"
		done
	fi
}

! [ -d $HOME/bin ] && mkdir $HOME/bin
__garbage __set_path
__set_path () {
	local var="$1"
	local p="$2"

	local path_elements="${p//:/ }"
	p=""
	local i
	for i in $path_elements; do
		[ "$(echo $p | egrep "(^| )$i")" == "" ] && [ -d $i ] && p="$p$i "
	done
	export $var=$(p=$(echo $p); echo ${p// /:})
}

# homebrew="$HOME/.homebrew"
homebrew="/usr/local"
__garbage homebrew
__set_path PATH "$PATH:$HOME/bin:$HOME/local/bin:$HOME/scripts:$HOME/node/bin:/usr/nodejs/bin/:/usr/local/nginx/sbin:/opt/PalmSDK/Current/bin:$homebrew/bin:$homebrew/sbin:/opt/kakai/bin:$HOME/dev/js/narwhal/bin:$HOME/dev/js/jack/bin:/opt/local/sbin:/opt/local/bin:/opt/local/libexec:/opt/local/apache2/bin:/opt/local/lib/mysql/bin:/opt/local/lib/erlang/bin:/usr/local/sbin:/usr/local/bin:/usr/local/libexec:/usr/sbin:/usr/bin:/usr/libexec:/sbin:/bin:/libexec:/usr/X11R6/bin:/home/y/include:/opt/local/share/mysql5/mysql:/usr/local/mysql/bin:/opt/local/include:/opt/local/apache2/include:/usr/local/include:/usr/include:/usr/X11R6/include:/opt/local/etc/LaunchDaemons/org.macports.lighttpd/:$HOME/appsup/TextMate/Support/bin:$homebrew/Cellar/autoconf213/2.13/bin:/usr/local/android:$homebrew/Cellar/gnutls/2.8.5/include:/Users/isaacs/.gem/ruby/1.8/bin:/opt/couchdb-1.0.0/bin"

__set_path LD_LIBRARY_PATH "$homebrew/lib:/opt/kakai/lib:/usr/lib"
__set_path PKG_CONFIG_PATH "$homebrew/lib/pkgconfig:/opt/kakai/lib/pkgconfig:/opt/local/lib/pkgconfig:/usr/X11/lib/pkgconfig:/opt/gnome-2.14/lib/pkgconfig:/usr/lib/pkgconfig"
export KAKAI_DISABLE_HISTORY=true
export DB_FOLDER=$HOME/.local/share/webkit/databases/http_localhost_0
export DB_FILE=0000000000000001.db

__set_path CLASSPATH "./:$HOME/dev/js/rhino/build/classes:$HOME/dev/yui/yuicompressor/src"
__set_path CDPATH ".:..:$HOME/dev:$HOME"
# __set_path NODE_PATH "$HOME/.node_libraries:$HOME/dev/js/node/lib:$homebrew/lib/node_libraries:$HOME/dev/js/node-glob/build/default"

__set_path PYTHONPATH "$HOME/dev/js/node/deps/v8/tools/:$HOME/dev/js/node/tools"

jsreg () {
	local pid=$(cat ~/.jsregpid)
	if [ "$pid" ]; then
		echo kill $pid
		kill $pid
		if [ "$?" == 0 ]; then
			sleep 1
			echo "" > ~/.jsregpid
		fi
	fi
	if [ "$1" == "kill" ]; then
		return 0
	fi
	ssh -N -L 5984:localhost:5984 izs.me &
	echo $! > ~/.jsregpid
	disown
}

# fail if the file is not an executable in the path.
inpath () {
	! [ $# -eq 1 ] && echo "usage: inpath <file>" && return 1
	f="$(which "$1" 2>/dev/null)"
	[ -f "$f" ] && return 0
	return 1
}

echo_error () {
	echo "$@" 1>&2
	return 0
}

if [ -z "$BASH_COMPLETION_DIR" ]; then
	# [ -f /opt/local/etc/bash_completion ] && . /opt/local/etc/bash_completion
	inpath brew && [ -f "$(brew --prefix)/etc/bash_completion" ] && . "$(brew --prefix)/etc/bash_completion"
	[ -f /etc/bash_completion ] && . /etc/bash_completion
fi

if inpath rlwrap; then
  alias js="NODE_NO_READLINE=1 rlwrap node"
else
  alias js=node
fi



# Use UTF-8, and throw errors in PHP and Perl if it's not available.
# Note: this is VERY obnoxious if UTF8 is not available!
# That's the point!
export LC_CTYPE=en_US.UTF-8
export LC_ALL=""
export LANG=$LC_CTYPE
export LANGUAGE=$LANG
export TZ=America/Los_Angeles
export HISTSIZE=10000
export HISTFILESIZE=1000000000
# I prefer to use : instead of ^ for history replacements
# much faster to type.  It'd be neat to use /, but then it gets
# confused with absolute paths, like "/bin/env"
export histchars="!:#"

if ! [ -z "$BASH" ]; then
	__garbage __shopt
	__shopt () {
		local i
		for i in "$@"; do
			shopt -s $i
		done
	}
	# see http://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html#The-Shopt-Builtin
	__shopt \
		histappend histverify histreedit \
		cdspell expand_aliases cmdhist \
		hostcomplete no_empty_cmd_completion nocaseglob
fi

hist () {
	history \
		| grep "$@" \
		| uniq -f 2 -u
}

# A little hack to add forward-and-back traversal with cd
if inpath php && inpath godir.php; then
  c () {
  	local a
  	alias cd="cd"
  	a="$(godir.php "$@")"
  	[ "$a" != "" ] && eval $a
  	alias cd="c"
  }
  alias cd="c"
  alias ..="c .."
  alias -- -="c -1"
  alias -- _="c +1"
  alias s="c --show"
else
  alias ..="cd .."
  alias -- -="cd -"
fi


# read a line from stdin, write to stdout.
getln () { read "$@" t && echo $t; }

# chooses the first argument that matches a file in the path.
choose_first () {
	for i in "$@"; do
		if ! [ -f "$i" ] && inpath "$i"; then
			i="$(which "$i")"
		fi
		if [ -f "$i" ]; then
			echo $i
			break
		fi
	done
}


# show a certain line of a file, or stdin
line () {
	sed ${1-0}'!d;q' < ${2-/dev/stdin}
}

# headless <command> [<key>]
# to reconnect, do: headless "" <key>
headless () {
	if [ "$2" == "" ]; then
		hash=$(md5 -qs "$1")
	else
		hash="$2"
	fi
	if [ "$1" != "" ]; then
		dtach -n /tmp/headless-$hash bash -l -c "$1"
	else
		dtach -A /tmp/headless-$hash bash -l
	fi
}

# do something in the background
back () {
	( "$@" ) &
}
# do something very quietly.
quiet () {
	( "$@" ) &>/dev/null
}
#do something to all the things on standard input.
# echo 1 2 3 | foreach echo foo is like calling echo foo 1; echo foo 2; echo foo 3;
fe () {
	local $i
	for i in $(cat /dev/stdin); do
		"$@" $i;
	done
}

# test javascript files for syntax errors.
if inpath yuicompressor; then
	testjs () {
		local i
		local err
		for i in $(find . -name "*.js"); do
			err="$(yuicompressor -o /dev/null $i 2>/dev/stdout)"
			if [ "$err" != "" ]; then
				echo "$i has errors:"
				echo "$err"
			fi
		done
	}
fi

# # give a little colou?r to grep commands, if supported
# grep=grep
# if [ "$(grep --help | grep color)" != "" ]; then
# 	grep="grep --color"
# elif [ "$(grep --help | grep colour)" != "" ]; then
# 	grep="grep --colour"
# fi
# alias grep="$grep"

# substitute "this" for "that" if "this" exists and is in the path.
substitute () {
	! [ $# -eq 2 ] && echo "usage: substitute <desired> <orig>" && return 1
	inpath "$1" && new="$(which "$1")" && alias $2="$new"
}

substitute yssh ssh
substitute yscp scp

export SVN_RSH=$(choose_first yssh ssh)
export RSYNC_RSH=$(choose_first yssh ssh)
export INPUTRC=$HOME/.inputrc
# export POSIXLY_CORRECT=1

# useful commands:
__get_edit_cmd () {
	echo "$( choose_first "$@" )"
}
# my list of editors, by preference.
__edit_cmd="$( __get_edit_cmd mate vim vi pico ed )"
alias edit="${__edit_cmd}"
alias e="${__edit_cmd} ."
ew () {
  edit $(which $1)
}
alias sued="sudo ${__edit_cmd}"
export EDITOR="$( choose_first ${__edit_cmd}_wait ${__edit_cmd} )"
export VISUAL="$EDITOR"
__garbage __get_edit_cmd __edit_cmd

# shebang <file> <program> [<args>]
shebang () {
	local sb="shebang"
	if [ $# -lt 2 ]; then
		echo "usage: $sb <file> <program> [<arg string>]"
		return 1
	elif ! [ -f "$1" ]; then
		echo "$sb: $1 is not a file."
		return 1
	fi
	if ! [ -w "$1" ]; then
		echo "$sb: $1 is not writable."
		return 1
	fi
	local prog="$2"
	! [ -f "$prog" ] && prog="$(which "$prog" 2>/dev/null)"
	if ! [ -x "$prog" ]; then
		echo "$sb: $2 is not executable, or not in path."
		return 1
	fi
	chmod ogu+x "$1"
	prog="#!$prog"
	[ "$3" != "" ] && prog="$prog $3"
	if ! [ "$(head -n 1 "$1")" == "$prog" ]; then
		local tmp=$(mktemp shebang.XXXX)
		( echo $prog; cat $1 ) > $tmp && cat $tmp > $1 && rm $tmp && return 0 || \
			echo "Something fishy happened!" && return 1
	fi
	return 0
}

# Probably a better way to do this, but whatevs.
rand () {
	echo $(php -r 'echo mt_rand();')
}

pickrand () {
	local cnt=0
	local tst="-d"
	if [ $# == 1 ]; then
		tst="$1"
	fi
	for i in *; do
		[ $tst "$i" ] && let 'cnt += 1'
	done
	[ $cnt -eq 0 ] && return 1
	local r=$(rand)
	local p=0
	let 'p = r % cnt'
	# echo "[$cnt $r --- $p]"
	cnt=0
	for i in *; do
		# echo "[$cnt]"
		[ $tst "$i" ] && let 'cnt += 1' && [ $cnt -eq $p ] && echo "$i" && return
	done
}

# md5 from the command line
# I like the BSD/Darwin "md5" util a bit better than md5sum flavor.
# Ported here to always have it.
# Yeah, that's right.  My bash profile has a PHP program embedded
# inside. You wanna fight about it?
if ! inpath md5 && inpath php; then
	# careful on this next trick. The php code can *not* use single-quotes.
	echo '<?php
		// The BSD md5 checksum program, ported to PHP by Isaac Z. Schlueter

		exit main($argc, $argv);

		function /* int */ main ($argc, $argv) {
			global $bin;
			$return = true;
			$bin = basename( array_shift($argv) );
			$return = 0;
			foreach (parseargs($argv, $argc) as $target => $action) {
				// echo "$action($target)\n";
				if ( !$action( $target ) ) {
					$return ++;
				}
			}
			// convert to bash success/failure flag
			return $return;
		}

		function parseargs ($argv, $argc) {
			$actions = array();
			$getstring = false;
			$needstdin = true;
			foreach ($argv as $arg) {
				// echo "arg: $arg\n";
				if ($getstring) {
					$getstring = false;
					$actions[ "\"$arg\"" ] = "cksumString";
					continue;
				}
				if ($arg[0] !== "-") {
					// echo "setting $arg to cksumFile\n";
					$needstdin = false;
					$actions[$arg] = "cksumFile";
				} else {
					// is a flag
					$arg = substr($arg, 1);
					if (strlen($arg) === 0) {
						$actions["-"] = "cksumFile";
					} else {
						while (strlen($arg)) {
							$flag = $arg{0};
							$arg = substr($arg, 1);
							switch ($flag) {
								case "s":
									if ($arg) {
										$actions["\"$arg\""] = "cksumString";
										$arg = "";
									} else {
										$getstring = true;
									}
									$needstdin = false;
								break;
								case "p": $actions[] = "cksumStdinPrint"; $needstdin = false; break;
								case "q": flag("quiet", true); break;
								case "r": flag("reverse",true); break;
								case "t": $actions["timeTrial"] = "timeTrial"; $needstdin = false; break;
								case "x": $actions["runTests"] = "runTests"; $needstdin = false; break;
								default : $actions["$flag"] = "usage"; $needstdin = false; break;
							} // switch
						} // while
					} // strlen($arg)
				}
			} // end foreach
			if ($getstring) {
				global $bin;
				// exited without getting a string!
				error_log("$bin: option requires an argument -- s");
				usage();
			}
			if ($needstdin) {
				$actions[] = "cksumStdin";
			}
			return $actions;
		}

		/*
		-s string
			Print a checksum of the given string.
		-p
			Echo stdin to stdout and appends the MD5 sum to stdout.
		-q
			Quiet mode - only the MD5 sum is printed out.  Overrides the -r option.
		-r
			Reverses the format of the output.  This helps with visual diffs.
			Does nothing when combined with the -ptx options.
		-t
			Run a built-in time trial.
		-x
			Run a built-in test script.
		*/

		function cksumFile ($file) {
			$missing = !file_exists($file);
			$isdir = $missing ? 0 : is_dir($file); // only call if necessary
			if ( $missing || $isdir ) {
				global $bin;
				error_log("$bin: $file: " . ($missing ? "No such file or directory" : "is a directory."));
				// echo "bout to return\n";
				return false;
			}
			output("MD5 (%s) = %s", $file, md5(file_get_contents($file)));
		}
		function cksumStdin () {
			$stdin = file_get_contents("php://stdin");
			writeln(md5($stdin));
			return true;
		}
		function cksumStdinPrint () {
			$stdin = file_get_contents("php://stdin");
			output("%s%s", $stdin, md5($stdin), array("reverse"=>false));
			return true;
		}

		function cksumString ($str) {
			return output("MD5 (%s) = %s", $str, md5(substr($str,1,-1)));
		}
		function runTests () {
			writeln("MD5 test suite:");
			$return = true;
			foreach (array(
					"", "a", "abc", "message digest", "abcdefghijklmnopqrstuvwxyz",
					"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
					"12345678901234567890123456789012345678901234567890123456789012345678901234567890") as $str ) {
				$return = $return && cksumString("\"$str\"");
			}
			return $return;
		}
		function timeTrial () {
			error_log("Time trial not supported in this version.");
			return false;
		}
		function flag ($flag, $set = null) {
			static $flags = array();
			$f = in_array($flag, $flags) ? $flags[$flag] : ($flags[$flag] = false);
			return ($set === null) ? $f : (($flags[$flag] = (bool)$set) || true) && $f;
		}

		function usage ($option = "") {
			global $bin;
			if (!empty($option)) {
				error_log("$bin: illegal option -- $option");
			}
			writeln("usage: $bin [-pqrtx] [-s string] [files ...]");
			return false;
		}
		function output ($format, $input, $digest, $flags = array()) {
			$orig_flags = array();
			foreach ($flags as $flag => $value) {
				$orig_flags[$flag] = flag($flag);
				flag($flag, $value);
			}
			if ( flag("quiet") ) {
				writeln($digest);
			} elseif ( flag("reverse") ) {
				writeln( "$digest $input" );
			} else {
				writeln( sprintf($format, $input, $digest) );
			}
			foreach ($orig_flags as $flag=>$value) {
				flag($flag, $value);
			}
			return true;
		}
		function writeln ($str) {
			echo "$str\n";
		}
	?>'>$HOME/bin/md5
	shebang $HOME/bin/md5 php "-d open_basedir="
fi

# a friendlier delete on the command line
! [ -d $HOME/.Trash ] && mkdir $HOME/.Trash
alias emptytrash="find $HOME/.Trash -not -path $HOME/.Trash -exec rm -rf {} \; 2>/dev/null"
if ! inpath del; then
	if [ -d $HOME/.Trash ]; then
		del () {
			for i in "$@"; do
				mv "$i" $HOME/.Trash/
			done
		}
	else
		alias del=rm
	fi
fi

alias mvsafe="mv -i"

lscolor=""
__garbage lscolor
if [ "$TERM" != "dumb" ] && [ -f "$(which dircolors 2>/dev/null)" ]; then
	eval "$(dircolors -b)"
	lscolor=" --color=auto"
	#alias dir='ls --color=auto --format=vertical'
	#alias vdir='ls --color=auto --format=long'
fi
ls_cmd="ls$lscolor"
__garbage ls_cmd
alias ls="$ls_cmd"
alias la="$ls_cmd -Flas"
alias lal="$ls_cmd -FLlash"
alias ll="$ls_cmd -Flsh"
alias ag="alias | grep"
fn () {
	local func=$(declare -f "$1")
	[ -z "$func" ] && echo_error "$1 is not a function" && return 1
	echo $func && return 0
}
alias lg="$ls_cmd -Flash | grep --color"
alias chdir="cd"
# alias more="less -e"
export MANPAGER=more
alias lsdevs="sudo lsof | grep ' /dev'"

# domain sniffing
wi () {
	whois $1 | egrep -i '(registrar:|no match|record expires on|holder:)'
}

#make tree a little cooler looking.
alias tree="tree -CFa -I 'rhel.*.*.package|.git' --dirsfirst"

__garbage yapr
if [ -f /etc/init.d/nginx ]; then
	yapr="sudo /etc/init.d/nginx restart"
elif inpath nginx; then
	yapr="sudo nginx -s reload"
elif inpath lighttpd-angel; then
	yapr="sudo lighttpd-angel -f /usr/local/etc/lighttpd/lighttpd.conf restart"
elif inpath lighttpd.wrapper; then
	yapr="sudo lighttpd.wrapper restart"
elif [ -f /etc/init.d/lighttpd ]; then
	yapr="sudo /etc/init.d/lighttpd reload"
elif inpath apache2ctl; then
	yapr="sudo apache2ctl graceful"
elif inpath apachectl; then
	yapr="sudo apachectl graceful"
else
	# very strange!
	yapr="echo Looks like nginx, lighttpd, and apache are not installed."
fi
alias yapr="$yapr"

__garbage http_log
http_log="$(choose_first /opt/local/var/log/lighttpd/error.log /home/y/logs/yapache/php-error /home/y/logs/yapache/error /home/y/logs/yapache/error_log /home/y/logs/yapache/us/error_log /home/y/logs/yapache/us/error /opt/local/apache2/logs/error_log /var/log/httpd/error_log /var/log/httpd/error /private/var/log/apache2/error_log)"
yapl="tail -f $http_log | egrep -v '^E|udbClient'"
alias yaprl="$yapr;$yapl"
alias yapl="$yapl"

prof () {
	. $HOME/.extra.bashrc
}
editprof () {
	s=""
	if [ "$1" != "" ]; then
		s="_$1"
	fi
	$EDITOR $HOME/.extra$s.bashrc
	prof
}
pushprof () {
	[ "$1" == "" ] && echo "no hostname provided" && return 1
	local failures=0
	local rsync="rsync --copy-links -v -a -z"
	for each in "$@"; do
		if [ "$each" != "" ]; then
			if $rsync $HOME/.{inputrc,tarsnaprc,profile,extra,git}* $each:~ && \
					$rsync $HOME/.ssh/*{.pub,authorized_keys,config} $each:~/.ssh/; then
				echo "Pushed bash extras and public keys to $each"
			else
				echo "Failed to push to $each"
				let 'failures += 1'
			fi
		fi
	done
	return $failures
}

if inpath port; then
	alias inst="sudo port install"
	alias yl="port list installed"
	yg () {
		port list installed | grep "$@"
	}
	alias upup="sudo port sync && sudo port upgrade outdated"
	cleanpkg () {
		for i in "$@"; do
			sudo port uninstall -f $i
			sudo port clean $i
			sudo port install $i
		done
	}
elif inpath brew; then
	alias inst="brew install"
	alias yl="brew list"
	yg () {
		brew list | grep "$@"
	}
elif inpath apt-get; then
	alias inst="sudo apt-get install"
	alias yl="dpkg --list | egrep '^ii'"
	yg () {
		dpkg --list | egrep '^ii' | grep "$@"
	}
	alias upup="sudo apt-get update && sudo apt-get upgrade"
fi

# git stuff
export GITHUB_TOKEN=$(git config --get github.token)
export GITHUB_USER=$(git config --get github.user)
export GIT_COMMITTER_NAME=$(git config --get github.user)
export GIT_COMMITTER_EMAIL=$(git config --get user.email)
export GIT_AUTHOR_NAME=$(git config --get user.name)
export GIT_AUTHOR_EMAIL=$(git config --get user.email)
alias gci="git commit"
alias gap="git add -p"
alias gst="git status"
alias glg="git lg"
ghadd () {
	local me="$(git config --get github.user)"
	[ "$me" == "" ] && echo "Please enter your github name as the github.user git config." && return 1
	# like: "git@github.com:$me/$repo.git"
	local mine="$( git config --get remote.origin.url )"
	local repo="${mine/git@github.com:$me\//}"
	local nick="$1"
	local who="$2"
	[ "$who" == "" ] && who="$nick"
	[ "$who" == "" ] && ( echo "usage: ghadd [nick] <who>" >&2 ) && return 1
	# eg: git://github.com/isaacs/jack.git
	local theirs="git://github.com/$who/$repo"
	git remote add "$nick" "$theirs"
}
alias gpa="git push --all"
alias gpt="git push --tags"
gps () {
	gpa "$@"
	gpt "$@"
}
# Look up any ref's sha, and also copy it for pasting into bugs and such
gsh () {
	local sha
	sha=$(git show ${1-HEAD} | head -n1 | awk '{print $2}' | xargs echo -n)
	echo -n $sha | pbcopy
	echo $sha
}
alias ngr="npm config get root"
rmnpm () {
  rm -rf {$(npm config get binroot),$(npm config get root)}/{.npm/,}npm*
}

# a context-sensitive rebasing git pull.
# usage:
# ghadd someuser  # add the github remote account
# git checkout somebranch
# gpm someuser    # similar to "git pull someuser somebranch"
# Remote branch is rebased, and local changes stashed and reapplied if possible.
alias gpm=gp
gp () {
	local s
	local head
	s=$(git stash 2>/dev/null)
	head=$(basename $(git symbolic-ref HEAD 2>/dev/null) 2>/dev/null)
	if [ "" == "$head" ]; then
		echo_error "Not on a branch, can't pull"
		return 1
	fi
	git fetch -a $1
	git pull --rebase $1 "$head"
	[ "$s" != "No local changes to save" ] && git stash pop
}

# look up a word
dict () {
	curl -s dict://dict.org/d:$1 | perl -ne 's/\r//; last if /^\.$/; print if /^151/../^250/' | more
}

#get the ip address of a host easily.
getip () {
	for each in "$@"; do
		echo $each
		echo "nslookup:"
		nslookup $each | grep Address: | grep -v '#' | egrep -o '([0-9]+\.){3}[0-9]+'
		echo "ping:"
		ping -c1 -t1 $each | egrep -o '([0-9]+\.){3}[0-9]+' | head -n1
	done
}

# Show the IP addresses of this machine, with each interface that the address is on.
ips () {
	local interface=""
	local types='vmnet|en|eth|vboxnet'
	local i
	for i in $(
		ifconfig \
		| egrep -o '(^('$types')[0-9]|inet (addr:)?([0-9]+\.){3}[0-9]+)' \
		| egrep -o '(^('$types')[0-9]|([0-9]+\.){3}[0-9]+)' \
		| grep -v 127.0.0.1
	); do
		if ! [ "$( echo $i | perl -pi -e 's/([0-9]+\.){3}[0-9]+//g' )" == "" ]; then
			interface="$i":
		else
			echo $interface $i
		fi
	done
}

# Like the ips function, but for mac addrs.
macs () {
	local interface=""
	local i
	local types='vmnet|en|eth|vboxnet'
	for i in $(
		ifconfig \
		| egrep -o '(^('$types')[0-9]:|ether ([0-9a-f]{2}:){5}[0-9a-f]{2})' \
		| egrep -o '(^('$types')[0-9]:|([0-9a-f]{2}:){5}[0-9a-f]{2})'
	); do
		if [ ${i:(${#i}-1)} == ":" ]; then
			interface=$i
		else
			echo $interface $i
		fi
	done
}

# set the bash prompt and the title function

# export __bg=$([ $(uname) == "Darwin" ] && echo 40 || echo 42)
# export __color=$([ $(uname) == "Darwin" ] && echo 37 || echo 30)
# 
PROMPT_COMMAND='history -a
echo "         "
DIR=${PWD/$HOME/\~}
DIR=${DIR/~\/Documents\/src/~\/dev}
echo -ne "\033]0;$(__git_ps1 "%s - " 2>/dev/null)$HOSTNAME:$DIR\007"
if [ "$NAVE" != "" ]; then echo -ne "\033[44m $NAVE \033[m"; fi
if [ -x ./configure ] || [ -d ./.git ]; then echo -ne "\033[42m\033[1;30m→\033[m"; fi
echo -ne "$(__git_ps1 "\033[41m\033[37m %s \033[0m" 2>/dev/null)"
echo -ne "\033[40m\033[37m$USER@\033[$([ ${HOSTNAME:0:14} == "sistertrain-lm" ] && echo 40 || echo 42)m\033[$([ ${HOSTNAME:0:14} == "sistertrain-lm" ] && echo 37 || echo 30)m$(uname -n)\033[0m:$DIR"'
#this part gets repeated when you tab to see options
PS1="\n[\t] \\$ "

# view processes.
alias processes="ps axMuc | egrep '^[a-zA-Z0-9]'"
pg () {
	ps aux | grep "$@" | grep -v "$( echo grep "$@" )"
}
pid () {
	pg "$@" | awk '{print $2}'
}

alias fh="ssh izs.me"
alias p="ssh isaacs.xen.prgmr.com"
alias st="ssh sistertrain.com"


# shorthand for checking on ssh agents.
sshagents () {
	pg -i ssh
	set | grep SSH | grep -v grep
	find /tmp/ -type s | grep -i ssh
}
# shorthand for creating a new ssh agent.
agent () {
	eval $( ssh-agent )
	ssh-add
}

vazu () {
	rsync -vazuR --stats --no-implied-dirs --delete "$@"
}

# floating-point calculations
calc () {
	local expression="$@"
	[ "${expression:0:6}" != "scale=" ] && expression="scale=16;$expression"
	echo "$expression" | bc
}

# more handy wget for fetching files to a specific filename.
fetch_to () {
	local from=$1
	local to=$2
	[ "$to" == "" ] && to=$( basname "$from" )
	[ "$to" == "" ] && echo "usage: fetch_to <url> [<filename>]" && return 1
	wget -U "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.0.5) Gecko/2008120121 Firefox/3.0.5" -O "$to" "$from" || return 1
}

# command-line perl prog
alias pie="perl -pi -e "
# c++ compilation shortcuts
stripc () {
	local f="$1"
	local o="$f"
	o=${o%.c}
	o=${o%.cpp}
	o=${o%.cc}
	echo $o
}
cm () {
	g++ -o $(stripc "$1") "$1"
}
cr () {
	cm "$1" && ./$(stripc "$1")
}
cmi () { m cmi && return 0 || return 1; }
m () {
	p=$(pwd)
	while [ "$p" != "/" ] && ! [ -x "$p/configure" ]; do
		p=$(dirname "$p")
	done
	if [ "$p" == "/" ]; then
		echo_error "Not in a project."
		return 1
	fi
	[ "$p" != "$PWD" ] && cd "$p"
	[ "$1" == "cmi" ] && sudo make clean 2>/dev/null
	( [ "$1" == "cmi" ] && ./configure || true) && make && sudo make install && ( [ "$p" != "$PWD" ] && cd - || true ) && return 0
	return 1
}


# convert dmgs to isos
dmg2iso () {
	dmg="$1"
	iso="${dmg%.dmg}.iso"
	hdiutil convert "$dmg" -format UDTO -o "$iso" \
		&& mv "$iso"{.cdr,} \
		&& return 0
	return 1
}

# tarsnap wrappers.
# http://tarsnap.com
ts () {
	local e=echo
	inpath growlnotify && e="growlnotify -t tarsnap -m "
	if [ $# -lt 1 ] || ! [ -e "$1" ]; then
		$e "Need to supply a file/directory to back up" 1>&2
		return 1
	fi
	if [ $# -gt 1 ]; then
		local errors=0
		for i in "$@"; do
			ts $i || let 'errors += 1'
		done
		return $errors
	fi
	local thetitle=$(title)
	local thefile="$1"
	$e "backing up $thefile"
	title "backing up $thefile"
	backupfile="$(hostname):${thefile/\//}:$(date +%Y-%m-%d-%H-%M-%S)"
	backupfile=${backupfile//\//-}
	tarsnap -cvf "$backupfile" $thefile 2> $HOME/.tslog
	$e "done backing up $thefile"
	title "$thetitle"
}
tsbg () {
	( ts "$@" ) &
}
tsh () {
	# headless <command> [<key>]
	headless "ts $@" ts-headless-backup
}
tskill () {
	kill -s SIGQUIT $(pid tarsnap)
}
tsabort () {
	kill $(pid tarsnap)
}
tslisten () {
	tail -f $HOME/.tslog
}
tsl () {
	tslisten
}

#load any per-platform .extra.bashrc files.
__garbage arch machinearch
arch=$(uname -s)
machinearch=$(uname -m)
[ -f $HOME/.extra_$arch.bashrc ] && . $HOME/.extra_$arch.bashrc
[ -f $HOME/.extra_${arch}_${machinearch}.bashrc ] && . $HOME/.extra_${arch}_${machinearch}.bashrc
inpath "git" && [ -f $HOME/.git-completion ] && . $HOME/.git-completion

# call in the cleaner.
__garbage

export BASH_EXTRAS_LOADED=1
