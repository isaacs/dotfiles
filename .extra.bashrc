#!/bin/bash
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
main () {
# Note for Leopard Users #
# If you use this, it will probably make your $PATH variable pretty long,
# which will cause terrible performance in a stock Leopard install.
# To fix this, comment out the following lines in your /etc/profile file:

# if [ -x /usr/libexec/path_helper ]; then
#   eval `/usr/libexec/path_helper -s`
# fi

# Thanks to "allan" in irc://irc.freenode.net/#textmate for knowing this!

if [ "${BASH_EXTRAS_LOADED}" = "" ] && [ "$TERM_PROGRAM" != "DTerm" ] && [ "$PS1" != "" ]; then
  echo "loading bash extras..."
fi

# node building
export V=
export SIGN="Developer ID Application: Joyent, Inc (X4ETB2T5LK)"

# I actually frequently forget this.
age () {
  node -p <<JS
(Date.now() - (new Date('1979-07-01T19:10:00.000Z')))/(1000 * 60 * 60 * 24 * 365.25)
JS
}

# Why this is not exported in OS X, I have no idea
export HOSTNAME

alias z='date -u "+%Y-%m-%dT%H:%M:%SZ"'

alias irc='dtach -a irssi-session'

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
__garbage __garbage
__garbage __set_path
__set_path () {
  local var="$1"
  local orig=$(eval 'echo $'$var)
  orig=" ${orig//:/ } "
  local p="$2"

  local path_elements=" ${p//:/ } "
  p=""
  local i
  for i in $path_elements; do
    if [ -d $i ]; then
      p="$p $i "
      # strip out from the original set.
      orig=${orig/ $i / }
    fi
  done
  for i in $orig; do
    if ! [ -d $i ]; then
      orig=${orig/ $i / }
    fi
  done
  # put the original at the front, but only the ones that aren't already present
  # This preserves the intended ordering, and allows env hijacking tricks like
  # nave and other subshell programs use.
  # p="$orig $p"
  export $var=$(p=$(echo $p); echo ${p// /:})
}

__garbage __form_paths
local path_roots=( $HOME/ $HOME/local/ /usr/local/ /opt/local/ /usr/ /opt/ / )
__form_paths () {
  local r p paths
  paths=""
  for r in "${path_roots[@]}"; do
    for p in "$@"; do
      paths="$paths:$r$p"
    done
  done
  echo ${paths/:/} # remove the first :
}

# mac tar fixing
export COPYFILE_DISABLE=true
# homebrew="$HOME/.homebrew"
local homebrew="/usr/local"
__garbage homebrew
__set_path PATH "$HOME/bin:$HOME/local/nodejs/bin:/opt/nodejs/bin:/opt/local/gcc34/bin:$homebrew/share/npm/bin:$(__form_paths bin sbin libexec include):/usr/nodejs/bin/:/usr/local/nginx/sbin:$HOME/dev/js/narwhal/bin:/usr/X11R6/bin:/opt/local/share/mysql5/mysql:/usr/local/mysql/bin:/opt/local/apache2/include:/usr/X11R6/include:$homebrew/Cellar/autoconf213/2.13/bin:/Users/isaacs/.gem/ruby/1.8/bin:/opt/couchdb-1.0.0/bin:$HOME/dev/riak/rel/riak/bin:/usr/pkg/sbin:/usr/pkg/bin"
if [ -d "$HOME/Library/Application Support/TextMate/Support/bin" ]; then
  export PATH=$PATH:"$HOME/Library/Application Support/TextMate/Support/bin"
fi

#__set_path LD_LIBRARY_PATH "$(__form_paths lib)"
unset LD_LIBRARY_PATH
__set_path PKG_CONFIG_PATH "$(__form_paths lib/pkgconfig):/usr/X11/lib/pkgconfig:/opt/gnome-2.14/lib/pkgconfig"

__set_path CLASSPATH "./:$HOME/dev/js/rhino/build/classes:$HOME/dev/yui/yuicompressor/src"
__set_path CDPATH ".:..:$HOME/dev:$HOME/dev/js:$HOME/dev/joyent:$HOME"
__set_path PYTHONPATH "$HOME/dev/js/node/deps/v8/tools/:$HOME/dev/js/node/tools"

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

alias nodee=node

js () {
  local n=node
  if [ -x ./node ] && [ -f ./node ]; then
    echo "using ./node "$(./node --version)
    n=./$n
  fi
  NODE_READLINE_SEARCH=1 $n "$@"
}

# Use UTF-8, and throw errors in PHP and Perl if it's not available.
# Note: this is VERY obnoxious if UTF8 is not available!
# That's the point!
# export LC_CTYPE=en_US.UTF-8
# export LC_ALL=""
# export LANG=$LC_CTYPE
# export LANGUAGE=$LANG
# export TZ=America/Los_Angeles
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
      shopt -s $i 2>/dev/null
    done
  }
  # see http://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html#The-Shopt-Builtin
  __shopt \
    histappend histverify histreedit \
    cdspell expand_aliases cmdhist \
    hostcomplete no_empty_cmd_completion nocaseglob \
    checkhash extglob globstar extdebug dirspell
fi

# A little hack to add forward-and-back traversal with cd
if inpath php && inpath godir.php; then
  c () {
    local a
    alias cd="cd"
    a="$(godir.php "$@")"
    [ "$a" != "" ] && eval $a
    [ -f .DS_Store ] && rm .DS_Store
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

# chooses the first argument that matches a file in the path.
choose_first () {
  for i in "$@"; do
    if ! [ -f "$i" ] && inpath "$i"; then
      i="$(which "$i")"
    fi
    if [ -x "$i" ]; then
      echo $i
      break
    fi
  done
}

# headless <command> [<key>]
# to reconnect, do: headless "" <key>
if inpath dtach; then
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
fi

export SVN_RSH=ssh
export RSYNC_RSH=ssh
export INPUTRC=$HOME/.inputrc
export JOBS=1

# list of editors, by preference.
__edit_cmd="vim"
alias edit="${__edit_cmd}"
alias e="${__edit_cmd} ."
ew () {
  edit $(which $1)
}
alias sued="sudo -e"
export EDITOR=vim
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

# a friendlier delete on the command line
alias emptytrash="find $HOME/.Trash -not -path $HOME/.Trash -exec rm -rf {} \; 2>/dev/null"

lscolor=""
__garbage lscolor
if [ "$TERM" != "dumb" ] && [ -f "$(which dircolors 2>/dev/null)" ]; then
  eval "$(dircolors -b)"
  lscolor=" --color=auto"
fi
ls_cmd="ls$lscolor"
__garbage ls_cmd
alias ls="$ls_cmd"
alias la="$ls_cmd -Fla"
alias lah="$ls_cmd -Flah"
alias lal="$ls_cmd -FLlash"
alias ll="$ls_cmd -Flsh"
alias ag="alias | grep"
alias lg="$ls_cmd -Flash | grep --color"

export MANPAGER=more

# domain sniffing
wi () {
  whois $1 | egrep -i '(registrar:|no match|record expires on|holder:)'
}

#make tree a little cooler looking.
alias tree="tree -CFa -I 'rhel.*.*.package|.git' --dirsfirst"

prof () {
  unset BASH_EXTRAS_LOADED
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
      if $rsync $HOME/.{inputrc,profile,extra,git}* $each:~ && \
         $rsync --exclude='{.git,src}/' $HOME/.{vim,gvim}* $each:~
      then
        echo "Pushed bash extras and public keys to $each"
      else
        echo "Failed to push to $each"
        let 'failures += 1'
      fi
    fi
  done
  return $failures
}

if inpath brew; then
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
export MANTA_KEY_ID="66:f2:21:3d:82:a8:21:f7:85:50:60:0b:5a:5e:82:f5"
export MANTA_URL=https://us-east.manta.joyent.com
export MANTA_USER=NodeCore

export GITHUB_TOKEN=$(git config --get github.token)
export GITHUB_USER=$(git config --get github.user)
export GIT_COMMITTER_NAME=${GITHUB_USER:-$(git config --get user.name)}
export GIT_COMMITTER_EMAIL=$(git config --get user.email)
export GIT_AUTHOR_NAME=${GITHUB_USER:-$(git config --get user.name)}
export GIT_AUTHOR_EMAIL=$(git config --get user.email)

grim () {
  local m=${1-master}
  echo "$m"
  git rebase -i $m
}

alias gci="git commit"
alias gap="git add -p"
alias gst="git status"
alias glg="git lg"
alias gti="git"
alias maek="make"
alias meak="make"
alias meak="make"
alias gci-am="git commit -am"
alias authors="(echo 'Isaac Z. Schlueter <i@izs.me>'; git authors | grep -v 'isaacs' | perl -pi -e 's|\([^\)]*\)||g' | sort | uniq)"

gam () {
  if [ $# -eq 0 ]; then
    git ci -a
  else
    git ci -am "$@"
  fi
}

cpg () {
  rm *patch
  git format-patch HEAD^
  gist *patch | pbcopy
}

alias gdiff='git diff --no-index --color'

alias pbind="pbpaste | sed 's|^|    |g' | pbcopy"
alias pbund="pbpaste | sed 's|^    ||g' | pbcopy"
alias pbtxt="pbpaste | pbcopy"
pbgist () {
  pbpaste | gist "$@" | pbcopy
  pbpaste
}

pr () {
  local url="$1"
  if [ "$url" == "" ] && type pbpaste &>/dev/null; then
    url="$(pbpaste)"
  fi
  if [[ "$url" =~ ^[0-9]+$ ]]; then
    local us="$2"
    if [ "$us" == "" ]; then
      us="origin"
    fi
    local num="$url"
    local o="$(git config --get remote.${us}.url)"
    url="${o}"
    url="${url#(git:\/\/|https:\/\/)}"
    url="${url#git@}"
    url="${url#github.com[:\/]}"
    url="${url%.git}"
    url="https://github.com/${url}/pull/$num"
  fi
  url=${url%/commits}
  url=${url%/files}

  local p='^https:\/\/github.com\/[^\/]+\/[^\/]+\/pull\/[0-9]+$'
  if ! [[ "$url" =~ $p ]]; then
    echo "Usage:"
    echo "  pr <pull req url>"
    echo "  pr <pull req number> [<remote name>=origin]"
    type pbpaste &>/dev/null &&
      echo "(will read url/id from clipboard if not specified)"
    return 1
  fi
  local root="${url/\/pull\/+([0-9])/}"
  local ref="refs${url:${#root}}/head"
  echo git pull $root $ref
  pullup $root $ref
}

pullup () {
  local me=$(git rev-list HEAD^..HEAD)
  if [ $? -eq 0 ] && [ "$me" != "" ]; then
    git pull "$@" && git rebase $me
  fi
}



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
  git fetch -a "$nick"
}

gho () {
  local me="$(git config --get github.user)"
  [ "$me" == "" ] && \
    echo "Please enter your github name as the github.user git config." && \
    return 1
  # like: "git@github.com:$me/$repo.git"
  local name="${1:-$(basename "$PWD")}"
  local repo="git@github.com:$me/$name"
  git remote add "origin" "$repo"
  git fetch -a "$origin"
}

gpa () {
  git push --all "$@"
}

gpt () {
  git push --tags "$@"
}

gps () {
  gpa "$@"
  gpt "$@"
}

# Look up any ref's sha, and also copy it for pasting into bugs and such
# the echo -n bit is to remove the trailing \n
gsh () {
  local c="${1:-HEAD}"
  git rev-list $c^..$c | tee >(xargs echo -n | pbcopy)
}

npmswitch () {
  local n1=$1
  local n2=$2
  curl -s http://registry.npmjs.org/-/by-user/$n1 \
  | json $n1 \
  | json -a \
  | xargs -I P sh -x -c \
    'npm cache clean P && \
     npm owner add '$n2' P && \
     npm owner rm '$n1' P'
}

npmgit () {
  local name=$1
  git clone $(npm view $name repository.url) $name
}

gf () {
  git fetch -a "$1"
}

gv () {
  local v=$(npm ls -pl | head -1 | awk -F: '{print $2}' | awk -F@ '{print $2}')
  git ci -am $v && git tag -sm $v $v
}

nsp () {
  npm explore $1 -- git pull origin master
}
alias np="npm prefix"
alias nr="npm root"
alias ngr="npm root -g"
alias ngp="npm prefix -g"
alias cdnp='cd $(npm prefix -g)'

rmnpm () {
  rm -rf /usr/local/{lib/,}{node_modules,node,bin,share/man}/{.npm/,}npm* ~/.npm
}

# I can't type
gi () {
  local c=${1}
  cmd=("$@")
  cmd[1]=${c:1}
  cmd[0]=git
  "${cmd[@]}"
}

# a context-sensitive rebasing git pull.
# usage:
# ghadd someuser  # add the github remote account
# git checkout somebranch
# gpm someuser    # similar to "git pull someuser somebranch"
# Remote branch is rebased, and local changes stashed and reapplied if possible.

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

#get the ip address of a host easily.
getip () {
  for each in "$@"; do
    echo $each
    echo "nslookup:"
    nslookup $each | grep Address: | grep -v '#' | egrep -o '([0-9]+\.){3}[0-9]+'
    echo "ping:"
    ping -c1 -t1 $each | egrep -o '([0-9]+\.){3}[0-9]+' | head -n1
    echo "dig:"
    dig $each | grep . | egrep -v '^;'
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

if [ "$PROMPT_COMMAND" = "" ]; then
  PROMPT_COMMAND='
    echo -ne "\033[m";history -a
    echo ""
    if [ $SHLVL -gt 1 ]; then
      { i=$SHLVL; while [ $i -gt 1 ]; do echo -n '.'; let i--; done; }
    fi
    DIR=${PWD/$HOME/\~}
    echo -ne "\033]0;$(__git_ps1 "%s - " 2>/dev/null)$HOSTNAME:$DIR\007"
    echo -ne "$(__git_ps1 "\033[41;31m[\033[41;37m%s\033[41;31m]\033[0m" 2>/dev/null)"
    echo -ne "\033[40;37m$USER@\033[42;30m$(uname -n)\033[0m:$DIR"
    if [ "$NAVE" != "" ]; then echo -ne " \033[44m\033[37m$NAVE\033[0m"
    else echo -ne " \033[32m$(node -v 2>/dev/null)\033[0m"
    fi
  '
fi

#this part gets repeated when you tab to see options
#PROMPT_COMMAND=
PS1="\n\\$ "

pres () {
  # export PROMPT_COMMAND='echo;
  # p=$(PWD);
  # if [ ${#p} -gt 40 ]; then
  #   d=$(basename "$p")
  #   p=$(dirname "$p")
  #   i=$[ ${#p} - 40 ]
  #   p=...${p:$i}/$d
  # fi
  # echo -n $p
  # '
  export PROMPT_COMMAND=''
  PS1='\n$ '
  clear
}

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
alias dfx="ssh coal 'svcadm disable ntp;host pool.ntp.org | head -1 | awk '"'"'"'"'"'"'{print \$4}'"'"'"'"'"'"' | xargs ntpdate;svcadm enable ntp'"


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

# convert dmgs to isos
dmg2iso () {
  dmg="$1"
  iso="${dmg%.dmg}.iso"
  hdiutil convert "$dmg" -format UDTO -o "$iso" \
    && mv "$iso"{.cdr,} \
    && return 0
  return 1
}

#load any per-platform .extra.bashrc files.

#__garbage arch machinearch
arch=$(uname -s)
machinearch=$(uname -m)
[ -f $HOME/.extra_$arch.bashrc ] && . $HOME/.extra_$arch.bashrc
[ -f $HOME/.extra_${arch}_${machinearch}.bashrc ] && . $HOME/.extra_${arch}_${machinearch}.bashrc
[ -f /etc/bash_completion ] && . /etc/bash_completion
[ -f /opt/local/etc/bash_completion ] && . /opt/local/etc/bash_completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
[ -f $HOME/etc/bash_completion ] && . $HOME/etc/bash_completion
inpath "git" && [ -f $HOME/.git-completion ] && . $HOME/.git-completion
inpath "npm" && . <(npm completion -s)

complete -cf sudo


# call in the cleaner.
__garbage
export BASH_EXTRAS_LOADED=1
return 0
}
main
unset main
