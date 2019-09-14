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
######
main () {

socks () {
  ssh -ND 8527 isaacs@izs.me
}

# I actually frequently forget this.
age () {
  node -p <<JS
var now = Date.now()
var born = new Date('1979-07-01T19:10:00.000Z').getTime()
age = now - born
age / (1000 * 60 * 60 * 24 * 365.25)
JS
}

now () {
  node -p 'new Date().toISOString()'
}

dy () {
  echo "date: $(now)"
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

export XDG_CONFIG_HOME=$HOME/.config

# mac tar fixing
export COPYFILE_DISABLE=true
# homebrew="$HOME/.homebrew"
local homebrew="/usr/local"
__set_path PATH "$HOME/bin:$HOME/.rvm/bin:$homebrew/opt/ruby/bin:$homebrew/lib/ruby/gems/2.6.0/bin:$homebrew/share/npm/bin:$(__form_paths bin sbin nodejs/bin libexec include):/usr/local/nginx/sbin:/usr/X11R6/bin:/usr/local/mysql/bin:/usr/X11R6/include:$HOME/Library/Application Support/TextMate/Support/bin"

unset LD_LIBRARY_PATH
__set_path PKG_CONFIG_PATH "$(__form_paths lib/pkgconfig):/usr/X11/lib/pkgconfig:/opt/gnome-2.14/lib/pkgconfig"

__set_path CDPATH ".:..:$HOME/dev/npm:$HOME/dev:$HOME/dev/js:$HOME"

alias nodee=node
alias ndoe=node
alias noed=node

js () {
  local n=node
  if [ -x ./node ] && [ -f ./node ]; then
    echo "using ./node "$(./node --version)
    n=./$n
  fi
  NODE_READLINE_SEARCH=1 $n "$@"
}

export NODE_REPL_HISTORY_FILE=~/.node-history
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
    cdspell expand_aliases cmdhist globasciiranges \
    hostcomplete no_empty_cmd_completion nocaseglob \
    checkhash extglob globstar dirspell
fi

# A little hack to add forward-and-back traversal with cd
alias ..="cd .."
alias cd..="cd .."
alias -- -="cd -"
# alias cd='exec nave auto'

export SVN_RSH=ssh
export RSYNC_RSH=ssh
export INPUTRC=$HOME/.inputrc
export JOBS=1

# list of editors, by preference.
alias edit="vim"
alias e="vim"
alias vvim=vim
alias vivm=vim
alias vmi=vim
ew () {
  edit $(which $1)
}
alias sued="sudo -e"
export EDITOR=vim
export VISUAL="$EDITOR"

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

local lscolor=""
if [ "$TERM" != "dumb" ] && [ -f "$(which dircolors 2>/dev/null)" ]; then
  eval "$(dircolors -b)"
  lscolor=" --color=auto"
fi
local ls_cmd="ls$lscolor"
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

# git stuff
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
alias gst="git status -s -uno"
alias glg="git lg"
alias gti="git"
alias maek="make"
alias meak="make"
alias meak="make"
alias gci-am="git commit -am"
alias authors="(echo 'Isaac Z. Schlueter <i@izs.me>'; git authors | grep -v 'isaacs' | perl -pi -e 's|\([^\)]*\)||g' 2>/dev/null | sort | uniq)"

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

gh () {
  local r=${1:-"origin"}
  if [ "$r" == "browse" ]; then
    r="origin"
  fi
  local o=$(git remote -v | grep $r | head -1 | awk '{print $2}')
  o=${o/git\:\/\//git@}
  o=${o/:/\/}
  o=${o/git@/https\:\/\/}
  o=${o%.git}
  local b="$(git branch | grep '\*' | awk '{print $2}')"
  if [ "$b" != "master" ]; then
    o=${o}/tree/$b
  fi
  open $o
}

pr2 () {
  local url="$(prurl "$@")"
  local num=$(basename $url)
  local prpath="${url#git@github.com:}"
  local repo=${prpath%/pull/$num}
  local prweb="https://github.com/$prpath"
  local root="$(prroot "$url")"
  local ref="$(prref "$url" "$root")"
  local curhead="$(git show --no-patch --pretty=%H HEAD)"
  local curbranch="$(git rev-parse --abbrev-ref HEAD)"
  local cleanlines
  IFS=$'\n' cleanlines=($(git status -s -uno))
  if [ ${#cleanlines[@]} -ne 0 ]; then
    echo "working dir not clean" >&2
    IFS=$'\n' echo "${cleanlines[@]}" >&2
    echo "aborting PR merge" >&2
  fi

  # ok, ready to rock
  branch=PR-$num
  if [ "$curbranch" == "$branch" ]; then
    echo "already on $branch, you're on your own" >&2
    return 1
  fi

  exists=$(git show --no-patch --pretty=%H $branch 2>/dev/null)
  if [ "$exists" == "" ]; then
    git fetch origin pull/$num/head:$branch
    git checkout $branch
  else
    git checkout $branch
    git pull --rebase origin pull/$num/head
  fi

  # add the PR-URL to the last commit, after squashing

  git rebase -i $curbranch # squash and test

  if [ $? -eq 0 ]; then
    pr2finish "${curbranch}"
  else
    echo "resolve conflicts and run pr2finish "'"'${curbranch}'"'
  fi
}

pr2finish () {
  local curbranch="$1"
  local ref=$(cat .git/HEAD)
  local prnum
  case $ref in
    "ref: refs/heads/PR-"*)
      prnum=${ref#ref: refs/heads/PR-}
      ;;
    *)
      echo "not on the PR-## branch any more!" >&2
      return 1
      ;;
  esac

  local me=$(git config github.user || git config user.name)
  if [ "$me" == "" ]; then
    echo "run 'git config --add github.user <username>'" >&2
    return 1
  fi

  set -x

  local url="$(prurl "$prnum")"
  local num=$prnum
  local prpath="${url#git@github.com:}"
  local repo=${prpath%/pull/$num}
  local prweb="https://github.com/$prpath"
  local root="$(prroot "$url")"

  local api="https://api.github.com/repos/${repo}/pulls/${num}"
  local user=$(curl -s $api | json user.login)

  local lastmsg="$(git log -1 --pretty=%B)"
  local newmsg="${lastmsg}

PR-URL: ${prweb}
Credit: @${user}
Close: #${num}
Reviewed-by: @${me}
"
  git commit --amend -m "$newmsg"
  git checkout $curbranch
  git merge PR-${prnum} --ff-only
  set +x
}

prurl () {
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
  url="$(echo $url | perl -p -e 's/#issuecomment-[0-9]+$//g')"

  local p='^https:\/\/github.com\/[^\/]+\/[^\/]+\/pull\/[0-9]+$'
  if ! [[ "$url" =~ $p ]]; then
    echo "Usage:"
    echo "  pr <pull req url>"
    echo "  pr <pull req number> [<remote name>=origin]"
    type pbpaste &>/dev/null &&
      echo "(will read url/id from clipboard if not specified)"
    return 1
  fi
  url="${url/https:\/\/github\.com\//git@github.com:}"
  echo "$url"
}

prroot () {
  local url="$1"
  echo "${url/\/pull\/+([0-9])/}"
}

prref () {
  local url="$1"
  local root="$2"
  echo "refs${url:${#root}}/head"
}

pr () {
  local url=$(prurl "$@")
  local root="$(prroot "$url")"
  local ref="$(prref "$url" "$root")"
  echo "$root $ref"
  #git pull --rebase $root $ref
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


nresolve () {
  node -p 'require.resolve("'$1'")'
}

ghn () {
  local me=npm
  # like: "git@github.com:$me/$repo.git"
  local name="${1:-$(basename "$PWD")}"
  local repo="git@github.com:$me/$name"
  git remote rm origin
  git remote add origin "$repo"
  git fetch -a "origin"
}

ght () {
  local me=tapjs
  # like: "git@github.com:$me/$repo.git"
  local name="${1:-$(basename "$PWD")}"
  local repo="git@github.com:$me/$name"
  git remote rm origin
  git remote add origin "$repo"
  git fetch -a "origin"
}

gio () {
  git remote add i "izs.me:$(basename $(pwd))"
  git fetch -a i
}

gho () {
  local me="$(git config --get github.user)"
  [ "$me" == "" ] && \
    echo "Please enter your github name as the github.user git config." && \
    return 1
  # like: "git@github.com:$me/$repo.git"
  local name="${1:-$(basename "$PWD")}"
  local repo="git@github.com:$me/$name"
  git remote add origin "$repo"
  git fetch -a origin
}

gpa () {
  git push --all "$@"
}

gpt () {
  git push --tags "$@"
}

gps () {
  git push --follow-tags "$@"
}

# Look up any ref's sha, and also copy it for pasting into bugs and such
# the echo -n bit is to remove the trailing \n
gsh () {
  local c="${1:-HEAD}"
  git show --no-patch --pretty=%H "$c" | tee >(xargs echo -n | pbcopy)
}

# licensing is funsies!
lic () {
  isc
}

alias n=npm
alias np=npm
alias nt="npm test --"
alias nf="npm test -- --no-coverage"
alias ns="npm run snap --"
# alias nc="npx npmc"

appveyor () {
  cat > appveyor.yml <<YML
environment:
  matrix:
    - nodejs_version: '8'
    - nodejs_version: '6'
install:
  - ps: Install-Product node \$env:nodejs_version
  - set PATH=%APPDATA%\\npm;%PATH%
  - npm install
matrix:
  fast_finish: true
build: off
version: '{build}'
shallow_clone: true
clone_depth: 1
test_script:
  - npm test
YML
}

scripts () {
  node -e '
    p = require("./package.json")
    p.scripts.test = "tap test/*.js --100 -J",
    p.scripts.preversion = "npm test",
    p.scripts.postversion = "npm publish",
    p.scripts.postpublish = "git push origin --all; git push origin --tags"
    p = JSON.stringify(p, null, 2) + "\n"
    require("fs").writeFileSync("./package.json", p)
  '
}

travis () {
  cat > .travis.yml <<YML
language: node_js

node_js:
  - node
  - 12
  - 10
  - 8

os:
  - linux
  - windows

cache:
  directories:
    - \$HOME/.npm

notifications:
  email: false
YML
}

isc () {
  if ! [ -f package.json ]; then
    echo "Run isc in a npm project." >&2
    return 1
  fi

  cat >LICENSE <<ISC
The ISC License

Copyright (c) npm, Inc. and Contributors

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
ISC

  local current="$(json license < package.json)"
  if [ "$current" = "ISC" ]; then
    echo "already ISC" >&2
    return 0
  fi

  node -e '
    j=require("./package.json")
    j.license = "ISC"
    console.log(JSON.stringify(j, null, 2))' > package.json.tmp &&\
  mv package.json.tmp package.json &&\
  git add package.json LICENSE &&\
  git commit -m "isc license" &&\
  npm version patch &&\
  git push origin master --tags &&\
  npm publish
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
    echo "Not on a branch, can't pull" >&2
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
    if ! [ "$( echo $i | perl -pi -e 's/([0-9]+\.){3}[0-9]+//g' 2>/dev/null )" == "" ]; then
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
__prompt () {
  echo -ne "\033[m";history -a
  echo ""
  [ -d .git ] && git stash list
  if [ $SHLVL -gt 1 ]; then
    { local i=$SHLVL; while [ $i -gt 1 ]; do echo -n '.'; let i--; done; }
  fi
  local DIR=${PWD/$HOME/\~}
  local HOST=${HOSTNAME:-$(uname -n)}
  HOST=${HOST%.local}
  echo -ne "\033]0;$(__git_ps1 "%s - " 2>/dev/null)${DIR/\~\/dev\//}\007"
  # echo -ne "$(__git_ps1 "%s " 2>/dev/null)"
  echo -ne "$(__git_ps1 "\033[40;35m%s\033[40;30m\033[0m " 2>/dev/null)"
  echo -ne "\033[44;37m$HOST\033[0m:$DIR"
  # echo -ne "$USER@$HOST:$DIR"
  if [ "$NAVE" != "" ]; then echo -ne " \033[44;37mnode@$NAVE\033[0m"
  else echo -ne " \033[32mnode@$(node -v 2>/dev/null)\033[0m"
  fi
  echo ""
  # [ -f package.json ] && echo -ne "$(node -e 'j=require("./package.json");if(j.name&&j.version)console.log(" \033[35m"+j.name+"@"+j.version+"\033[0m")')"
}

if [ "$ITERM_SHELL_INTEGRATION_INSTALLED" == "Yes" ]; then
  if ! [[ "${precmd_functions[@]}" == *"__prompt"* ]]; then
    precmd_functions+=(__prompt)
  fi
  PROMPT_COMMAND="__bp_precmd_invoke_cmd; __bp_interactive_mode"
elif [ "$PROMPT_COMMAND" = "" ]; then
  export PROMPT_COMMAND='__prompt;'
elif [[ "$PROMPT_COMMAND" != *"__prompt"* ]]; then
  export PROMPT_COMMAND="${PROMPT_COMMAND}; __prompt;"
fi

#this part gets repeated when you tab to see options
#PROMPT_COMMAND=
PS1="\\$ "

pres () {
  export PROMPT_COMMAND=''
  PS1='\n$ '
  clear
}

# view processes.
pg () {
  ps aux | grep "$@" | grep -v "$( echo grep "$@" )"
}
pga () {
  ps aux | grep "$@" | grep -v "$( echo grep "$@" )" | grep -v '/Applications'
}
pid () {
  pg "$@" | awk '{print $2}'
}

alias fh="ssh izs.me"

# floating-point calculations
calc () {
  local expression="$@"
  [ "${expression:0:6}" != "scale=" ] && expression="scale=16;$expression"
  echo "$expression" | bc
}


type git >&/dev/null && [ -f $HOME/.git-completion ] && . $HOME/.git-completion
[ -f $HOME/.cd-completion ] && . $HOME/.cd-completion

_npm_completion () {
  local words cword
  if type _get_comp_words_by_ref &>/dev/null; then
    _get_comp_words_by_ref -n = -n @ -w words -i cword
  else
    cword="$COMP_CWORD"
    words=("${COMP_WORDS[@]}")
  fi

  local si="$IFS"
  IFS=$'\n' COMPREPLY=($(COMP_CWORD="$cword" \
                         COMP_LINE="$COMP_LINE" \
                         COMP_POINT="$COMP_POINT" \
                         npm completion -- "${words[@]}" \
                         2>/dev/null)) || return $?
  IFS="$si"
}
complete -o default -F _npm_completion npm

complete -cf sudo

# call in the cleaner.
__garbage
export BASH_EXTRAS_LOADED=1
return 0
}
main
unset main
